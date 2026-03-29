# Lógica de Negócio — Aba Cadastrar (Cobrança Avulsa)

**Data:** 27/03/2026  
**Objetivo:** Explicar como as duas formas de cobrança funcionam, com casos reais e a recomendação de implementação.

---

## 1. As Duas Opções — Visão Geral

Quando o representante (síndico/administrador) quer criar uma cobrança extra para os moradores, ele tem **duas formas** de fazer isso:

| Opção | Nome na UI | O que acontece |
|---|---|---|
| **Opção A** | "Boleto Avulso" | Gera **agora** um boleto **separado** no ASAAS, com valor e vencimento próprios |
| **Opção B** | "Junto à Taxa Cond." | **NÃO gera boleto agora**. Apenas registra uma despesa que será **somada ao próximo boleto mensal** |

---

## 2. Opção A — Boleto Avulso (Gerar Boleto Separado)

### 2.1 Como funciona (passo a passo)

```
Representante preenche formulário
        ↓
Clica "Gerar Boleto"
        ↓
Flutter chama → API Laravel: POST /asaas/cobrancas/gerar-avulsa
        ↓
Laravel busca o morador da unidade no Supabase
        ↓
Laravel cria a cobrança no ASAAS (customer + valor + vencimento)
        ↓
ASAAS gera o boleto com código de barras + link de pagamento
        ↓
Laravel salva registro na tabela 'boletos' do Supabase
        com tipo = 'Avulso', status = 'Registrado'
        ↓
(Opcional) Dispara e-mail para o morador com o link
        ↓
Morador recebe boleto separado no seu painel / e-mail
```

### 2.2 Caso Real 1 — Conserto de Portão

> O portão do Bloco A quebrou. O condomínio chamou um técnico que cobrou R$ 1.200,00. O síndico decide dividir esse custo entre as **6 unidades do Bloco A**.

**Ação do Síndico:**
1. Abre Cobrança Avulsa → Aba Cadastrar
2. Conta Contábil: `Manutenção`
3. Descrição: `Conserto de portão - Bloco A`
4. Escolhe: **"Boleto Avulso"**
5. Dia de vencimento: `15`
6. Busca unidades → filtra "Bloco A"
7. Seleciona as 6 unidades
8. Define valor: `R$ 200,00` por unidade (R$ 1200 / 6)
9. Clica **"Gerar Boleto"**

**Resultado:**
- ✅ 6 boletos separados são gerados no ASAAS (1 por unidade)
- ✅ Cada morador recebe um boleto avulso de R$ 200,00
- ✅ O boleto mensal do condomínio **NÃO é alterado**
- ✅ Na aba Pesquisar, aparecem 6 registros com status "Registrado"

### 2.3 Caso Real 2 — Multa por Infração (1 unidade)

> O morador da unidade 302 do Bloco B fez uma festa até 3h da manhã. O síndico aplica multa de R$ 500,00.

**Ação do Síndico:**
1. Conta Contábil: `Multa de Infração`
2. Descrição: `Multa por perturbação do sossego - Art. 12 do Reg. Interno`
3. Escolhe: **"Boleto Avulso"**
4. Busca unidade: `302`
5. Seleciona apenas a unidade 302/B
6. Valor: `R$ 500,00`
7. Anexa foto do registro de ocorrência (futuro - upload)
8. Clica **"Gerar Boleto"**

**Resultado:**
- ✅ 1 boleto avulso de R$ 500,00 para o morador da 302
- ✅ O morador recebe por e-mail (se checkbox marcado)

### 2.4 Caso Real 3 — Acordo Parcelado (Recorrente)

> O morador da 101/A deve R$ 3.000,00 de meses atrasados. O síndico faz um acordo em 6x.

**Ação do Síndico:**
1. Conta Contábil: `Acordo de Pagamento`
2. Descrição: `Acordo - parcelas ref. Jan a Jun/2026`
3. Escolhe: **"Boleto Avulso"**
4. Marca **Recorrente = Sim**
5. Qtd. Meses: `6`
6. Início: Abr/2026 → Fim: Set/2026 (auto-calculado)
7. Seleciona unidade 101/A
8. Valor: `R$ 500,00` por parcela
9. Clica **"Gerar Boleto"**

**Resultado:**
- ✅ **6 boletos** são gerados de uma vez no ASAAS
- ✅ Vencimentos: 15/04, 15/05, 15/06, 15/07, 15/08, 15/09
- ✅ Descrição: `Acordo - parcelas ref... (Parcela 1/6)`, `(Parcela 2/6)`, etc.
- ✅ Tudo fica registrado na aba Pesquisar

---

## 3. Opção B — Junto à Taxa Condominial (Composição)

### 3.1 Conceito

Nessa opção, a cobrança **NÃO gera um boleto agora**. Em vez disso, ela fica registrada como uma **despesa pendente** associada à unidade para um determinado mês/ano. Quando o síndico for **gerar o boleto mensal** naquele mês, essas despesas são automaticamente **somadas ao valor do boleto mensal**.

### 3.2 Fluxo Completo (passo a passo)

```
Representante preenche formulário
        ↓
Clica "Gerar Composição"
        ↓
Flutter salva na tabela 'despesas_extras' do Supabase
        (status = 'Pendente', tipo = 'Composição')
        (NÃO chama ASAAS, NÃO gera boleto)
        ↓
... dias depois ...
        ↓
Síndico vai na tela de Boletos → "Gerar Cobrança Mensal"
        ↓
O sistema busca as despesas_extras pendentes para cada
unidade naquele mês
        ↓
O boleto mensal é gerado com valor =
    Cota Condominial
    + Fundo de Reserva
    + Água/Gás (rateio)
    + Despesas Extras ← AQUI ENTRAM AS COMPOSIÇÕES
    - Desconto
        ↓
ASAAS gera UM ÚNICO boleto por unidade com o valor total
        ↓
As despesas_extras são marcadas como 'Processado'
```

### 3.3 Caso Real 4 — Consumo de Água Individual

> O condomínio tem hidrômetro individual. O síndico apura o consumo de cada unidade todo mês. Em Abril, as leituras foram:

| Unidade | Consumo (m³) | Valor |
|---|---|---|
| 101/A | 12 m³ | R$ 96,00 |
| 102/A | 8 m³ | R$ 64,00 |
| 201/A | 15 m³ | R$ 120,00 |
| 202/A | 10 m³ | R$ 80,00 |

**Ação do Síndico:**
1. Abre Cobrança Avulsa → Aba Cadastrar
2. Conta Contábil: `Água Individual`
3. Mês/Ano: `Abril/2026`
4. Descrição: `Consumo de água individual - Abril/2026`
5. Escolhe: **"Junto à Taxa Cond."**
6. Busca unidades do Bloco A
7. Seleciona 4 unidades e define o valor **individual** de cada uma (editando inline)
8. Clica **"Gerar Composição"**

**Resultado agora:**
- ✅ 4 registros salvos na tabela `despesas_extras` com status `Pendente`
- ❌ **NENHUM boleto** foi gerado
- ❌ **Nenhuma chamada** ao ASAAS

**Quando o síndico gerar o boleto mensal de Abril:**
- O boleto da unidade 101/A será: Cota (R$ 500) + Fundo (R$ 50) + **Água (R$ 96)** = **R$ 646,00**
- O boleto da unidade 201/A será: Cota (R$ 500) + Fundo (R$ 50) + **Água (R$ 120)** = **R$ 670,00**
- O morador recebe **1 boleto só** com tudo incluso

### 3.4 Caso Real 5 — Gás Central

> O condomínio recebeu a conta de gás de R$ 2.400,00. São 24 unidades. O síndico rateia igualmente.

**Ação do Síndico:**
1. Conta Contábil: `Gás`
2. Descrição: `Rateio de gás - Abril/2026`
3. Escolhe: **"Junto à Taxa Cond."**
4. Seleciona TODAS as unidades
5. Valor: `R$ 100,00` por unidade (R$ 2400 / 24)
6. Clica **"Gerar Composição"**

**Resultado:**
- ✅ 24 registros em `despesas_extras` (1 por unidade)
- ✅ Na geração mensal, cada boleto terá +R$ 100 de gás

### 3.5 Caso Real 6 — Reserva de Salão de Festas

> O morador da 303/C reservou o salão de festas. Taxa de uso: R$ 300,00.

**Ação do Síndico:**
1. Conta Contábil: `Salão de Festas`
2. Descrição: `Reserva salão - Festa dia 25/04`
3. Escolhe: **"Junto à Taxa Cond."**
4. Seleciona apenas 303/C
5. Valor: R$ 300,00
6. Anexa: link do termo de uso assinado
7. Clica **"Gerar Composição"**

**Resultado:**
- ✅ 1 registro de despesa para a unidade 303/C
- ✅ No boleto mensal da 303/C: Cota + Fundo + **Salão (R$ 300)** = valor total

---

## 4. Comparação Direta

| Aspecto | Boleto Avulso | Junto à Taxa Cond. |
|---|---|---|
| **Quando gera boleto?** | AGORA, imediatamente | Na próxima geração mensal |
| **Quantos boletos?** | 1 boleto separado por unidade | 0 boletos (vira parte do boleto mensal) |
| **Chama ASAAS?** | SIM | NÃO (ASAAS é chamado na geração mensal) |
| **Onde salva?** | Tabela `boletos` (tipo='Avulso') | Tabela `despesas_extras` (status='Pendente') |
| **Vencimento** | Definido pelo síndico no formulário | Vencimento do boleto mensal |
| **O morador vê** | Boleto separado no ASAAS | Valor embutido no boleto mensal |
| **Melhor para** | Multas, acordos, cobranças urgentes | Água, gás, rateios, taxas mensais |

---

## 5. Recomendação de Implementação

### 5.1 Tabela `despesas_extras` (NOVA — necessária para "Junto à Taxa")

```sql
CREATE TABLE despesas_extras (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    condominio_id UUID NOT NULL REFERENCES condominios(id),
    unidade_id UUID NOT NULL REFERENCES unidades(id),
    conta_contabil TEXT NOT NULL,          -- 'Água', 'Gás', 'Multa', etc.
    descricao TEXT,                        -- Descrição livre
    valor NUMERIC(10, 2) NOT NULL,         -- Valor da despesa
    mes_referencia INTEGER NOT NULL,       -- Mês (1-12)
    ano_referencia INTEGER NOT NULL,       -- Ano (ex: 2026)
    status TEXT DEFAULT 'Pendente',        -- 'Pendente' | 'Processado' | 'Cancelado'
    boleto_id UUID REFERENCES boletos(id), -- Preenchido quando a despesa é processada
    anexo_url TEXT,                        -- Link do comprovante
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

> **Quando o "Gerar Cobrança Mensal" rodar**, ele busca todas as `despesas_extras` com `status = 'Pendente'` para aquele `condominio_id` + `mes/ano`. Soma os valores ao boleto mensal de cada unidade e marca as despesas como `status = 'Processado'` com o `boleto_id` do boleto gerado.

### 5.2 Mudanças no Flutter (Cubit)

```
Se tipoCobranca == 'Boleto Avulso':
    → chamar insertCobrancaAvulsaBatch() (fluxo ATUAL, já existe)
    → que chama Laravel → ASAAS → salva em 'boletos'

Se tipoCobranca == 'Junto à Taxa Cond.':
    → chamar NOVO método: inserirDespesaExtra()
    → que salva na nova tabela 'despesas_extras' do Supabase
    → NÃO chama ASAAS, NÃO chama Laravel
```

### 5.3 Mudanças no `gerarCobrancaMensal()` (BoletoService)

```dart
// No gerarCobrancaMensal(), ANTES de chamar o Laravel, buscar despesas extras:
final despesas = await _supabase
    .from('despesas_extras')
    .select()
    .eq('condominio_id', condominioId)
    .eq('mes_referencia', mes)
    .eq('ano_referencia', ano)
    .eq('status', 'Pendente');

// Agrupar por unidade_id e somar ao valor do boleto daquela unidade
// Depois de gerar o boleto, marcar como Processado
```

### 5.4 Diagrama de Fluxo Completo

```
┌─────────────────────────────────────────────────────────────┐
│                  ABA CADASTRAR                              │
│                                                             │
│  [Formulário: Conta, Descrição, Valor, Unidades...]        │
│                                                             │
│         ┌────────────┐        ┌───────────────────┐        │
│         │Boleto Avulso│        │Junto à Taxa Cond.│        │
│         └─────┬──────┘        └────────┬──────────┘        │
│               │                        │                    │
│               ▼                        ▼                    │
│    ┌─────────────────┐     ┌──────────────────────┐        │
│    │ "Gerar Boleto"  │     │ "Gerar Composição"   │        │
│    └────────┬────────┘     └──────────┬───────────┘        │
└─────────────┼──────────────────────────┼────────────────────┘
              │                          │
              ▼                          ▼
    ┌──────────────────┐     ┌────────────────────────┐
    │ Laravel API      │     │ Supabase Direto         │
    │ POST gerar-avulsa│     │ INSERT despesas_extras  │
    └────────┬─────────┘     │ status = 'Pendente'    │
             │               └────────────┬───────────┘
             ▼                            │
    ┌──────────────────┐                  │ (espera)
    │ ASAAS API        │                  │
    │ Cria Payment     │                  ▼
    └────────┬─────────┘        ┌────────────────────┐
             │                  │ Geração Mensal      │
             ▼                  │ (dias depois)       │
    ┌──────────────────┐        │                    │
    │ Supabase         │        │ Busca despesas     │
    │ INSERT boletos   │        │ + Soma ao boleto   │
    │ tipo = 'Avulso'  │        │ mensal de cada     │
    └──────────────────┘        │ unidade            │
                                └────────────────────┘
                                         │
                                         ▼
                                ┌────────────────────┐
                                │ ASAAS API           │
                                │ 1 boleto por unid.  │
                                │ valor = taxa + extra│
                                └────────────────────┘
```

---

## 6. O que já EXISTE no Código vs O que PRECISA ser Criado

### ✅ JÁ EXISTE (pronto para uso)
- Fluxo completo do "Boleto Avulso": Flutter → Laravel → ASAAS → Supabase
- `CobrancaController@gerarAvulsa` com suporte a recorrência
- `CobrancaService::gerarAvulsa()` com criação de customer automático
- `insertCobrancaAvulsaBatch()` no Repository Flutter
- Tabela `boletos` no Supabase
- E-mail service para envio via Resend

### 🔴 PRECISA SER CRIADO (para "Junto à Taxa Cond.")
1. **Tabela `despesas_extras`** no Supabase (ver SQL na seção 5.1)
2. **Método `inserirDespesaExtra()`** no `CobrancaAvulsaRepository` ou novo `DespesaExtraRepository`
3. **Método `adicionarComposicao()`** no `CobrancaAvulsaCubit` (chamar o novo repository)
4. **Alterar `gerarCobrancaMensal()`** no `BoletoService` para:
   - Buscar despesas extras pendentes daquele mês
   - Somar ao valor do boleto de cada unidade
   - Marcar como processado após geração
5. **Alterar GerarCobrancaMensalDialog** para exibir as despesas extras acumuladas (informativo)

---

## 7. Sugestão de Prioridade para Hoje

Como o fluxo "Boleto Avulso" já está **90% pronto**, recomendo focar nele hoje:

1. **Corrigir os bugs existentes** da aba Cadastrar (campos recorrente, proprietário, etc.)
2. **Testar o fluxo completo** Boleto Avulso end-to-end
3. **Deixar a opção "Junto à Taxa"** com a UI pronta mas com um `TODO` no botão (ou um snackbar "funcionalidade em breve")

O fluxo "Junto à Taxa" pode ser implementado em uma **segunda etapa**, pois requer:
- Nova tabela no Supabase
- Alteração na geração mensal (feature que já funciona e não queremos quebrar)
- Mais testes de integração

---

## 8. Resumo Visual

```
  ┌──────────────────────────────────────────────┐
  │         COBRANÇA AVULSA (Cadastrar)          │
  │                                              │
  │  "Quero cobrar algo extra dos moradores"     │
  │                                              │
  │  ┌──────────────┐  ┌──────────────────────┐  │
  │  │ BOLETO AVULSO│  │ JUNTO À TAXA COND.  │  │
  │  │              │  │                      │  │
  │  │ Gera AGORA   │  │ Soma no PRÓXIMO     │  │
  │  │ Boleto       │  │ boleto mensal       │  │
  │  │ SEPARADO     │  │                      │  │
  │  │              │  │ Morador paga         │  │
  │  │ Morador paga │  │ TUDO JUNTO           │  │
  │  │ por FORA do  │  │ (taxa + extras)      │  │
  │  │ boleto mensal│  │                      │  │
  │  └──────────────┘  └──────────────────────┘  │
  └──────────────────────────────────────────────┘
```
