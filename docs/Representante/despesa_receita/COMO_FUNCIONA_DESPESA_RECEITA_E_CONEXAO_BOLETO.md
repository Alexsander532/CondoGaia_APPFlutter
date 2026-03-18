# Como Funciona: Despesa, Receita e a Conexão com o Boleto

**Para:** Síndicos e Administradores  
**Data:** 18/03/2026  
**Versão:** 2.0

---

## 1. A Relação Fundamental

```
┌─────────────────────────────────────────────────────────────────────────┐
│                    A FÓRMULA DO CONDOMÍNIO                               │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│   DESPESAS do Condomínio                                                │
│   (contas que o condomínio paga)                                        │
│                    │                                                    │
│                    ▼                                                    │
│   ═════════════════════════════════════════════════════════════════    │
│   ‖                                                                   ‖    │
│   ‖   TOTAL DE DESPESAS  ÷  Nº DE UNIDADES  =  COTA CONDOMINIAL     ‖    │
│   ‖                                                                   ‖    │
│   ═════════════════════════════════════════════════════════════════    │
│                    │                                                    │
│                    ▼                                                    │
│   COTA CONDOMINIAL                                                       │
│   (valor que cada morador paga no boleto)                               │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

### Arquitetura do Sistema:

```
┌─────────────────────────────────────────────────────────────────────────┐
│                    ARQUITETURA TÉCNICA                                   │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│   ┌─────────────┐     ┌─────────────┐     ┌─────────────┐              │
│   │   FLUTTER   │────▶│   LARAVEL   │────▶│    ASAAS    │              │
│   │  (App App)  │     │  (Backend)  │     │  (Gateway)  │              │
│   └─────────────┘     └─────────────┘     └─────────────┘              │
│          │                   │                                          │
│          │                   │                                          │
│          ▼                   ▼                                          │
│   ┌─────────────────────────────────────┐                              │
│   │           SUPABASE (Banco)           │                              │
│   │  • boletos                           │                              │
│   │  • despesas                          │                              │
│   │  • receitas                          │                              │
│   │  • unidades, moradores               │                              │
│   └─────────────────────────────────────┘                              │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## 2. O que são DESPESAS?

### Definição:
**Despesas** são todos os gastos que o condomínio tem para funcionar.

### Exemplos Práticos:

| Categoria | Exemplos | Valor Médio |
|-----------|----------|-------------|
| **Manutenção** | Elevador, portaria, limpeza | R$ 5.000 - R$ 15.000 |
| **Energia** | Luz das áreas comuns | R$ 800 - R$ 2.000 |
| **Água** | Área comum, piscina, jardim | R$ 500 - R$ 1.500 |
| **Salários** | Zelador, porteiro, faxineira | R$ 8.000 - R$ 20.000 |
| **Segurança** | Câmeras, alarme, vigilância | R$ 1.000 - R$ 3.000 |
| **Administrativo** | Contabilidade, taxas | R$ 500 - R$ 1.500 |
| **Reparos** | Encanador, eletricista | R$ 200 - R$ 2.000 |

### Tela de Cadastro de Despesa:

```
┌─────────────────────────────────────────────────────────────┐
│           NOVA DESPESA                                       │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│ Conta Bancária: [▼ Conta Itaú - Principal]                 │
│                                                             │
│ Categoria: [▼ Manutenção]                                   │
│                                                             │
│ Subcategoria: [▼ Elevador]                                  │
│                                                             │
│ Descrição:                                                  │
│ [Manutenção preventiva mensal do elevador            ]     │
│                                                             │
│ Valor: R$ [  1.200,00  ]                                    │
│                                                             │
│ Data de Vencimento: [  15  ] / [ 04 ] / [ 2026 ]           │
│                                                             │
│ ☐ Recorrente (repete todo mês)                             │
│   Se marcado: [12] meses                                    │
│   ☐ Me avisar antes do vencimento                          │
│                                                             │
│ Link do Boleto/Nota:                                        │
│ [https://...                                         ]      │
│                                                             │
│ 📎 Anexar foto/comprovante                                  │
│                                                             │
│           [CANCELAR]    [SALVAR DESPESA]                    │
└─────────────────────────────────────────────────────────────┘
```

---

## 3. O que são RECEITAS?

### Definição:
**Receitas** são todas as entradas de dinheiro no condomínio.

### Tipos de Receita:

| Tipo | Origem | Exemplo |
|------|--------|---------|
| **Taxa Condominial** | Pagamento dos moradores | R$ 630,00 x 48 unidades |
| **Aluguel de Áreas** | Salão de festas, churrasqueira | R$ 500,00 |
| **Juros/Multas** | Pagamentos atrasados | R$ 50,00 |
| **Rendimentos** | Aplicação financeira | R$ 200,00 |
| **Restituições** | Devoluções, reembolsos | R$ 100,00 |

### Tela de Cadastro de Receita:

```
┌─────────────────────────────────────────────────────────────┐
│           NOVA RECEITA                                       │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│ Conta Bancária: [▼ Conta Itaú - Principal]                 │
│                                                             │
│ Conta Contábil: [▼ Fundo de Reserva]                       │
│                 (Opções: Controle, Fundo Reserva, Obras)    │
│                                                             │
│ Descrição:                                                  │
│ [Aluguel do salão de festas - Unidade A/103           ]    │
│                                                             │
│ Valor: R$ [  500,00  ]                                      │
│                                                             │
│ Data do Crédito: [  20  ] / [ 03 ] / [ 2026 ]              │
│                                                             │
│ ☐ Recorrente (repete todo mês)                             │
│                                                             │
│ Tipo: [▼ MANUAL]                                            │
│       (MANUAL ou AUTOMÁTICO)                                │
│                                                             │
│           [CANCELAR]    [SALVAR RECEITA]                    │
└─────────────────────────────────────────────────────────────┘
```

---

## 4. O que são TRANSFERÊNCIAS?

### Definição:
**Transferências** são movimentações entre contas do próprio condomínio.

### Exemplo:
- Transferir R$ 5.000 da conta corrente para a poupança
- Mover dinheiro do Fundo de Reserva para Controle

---

## 5. Tipos de Boleto

### 5.1 Boleto Mensal (Cobrança Condominial)

**O que é:** Cobrança regular enviada todo mês para todos os moradores.

**Composição do Valor:**

| Componente | Descrição | Origem |
|------------|-----------|--------|
| **Cota Condominial** | Valor base dividido entre unidades | Despesas ÷ Nº unidades |
| **Fundo de Reserva** | Reserva para emergências (geralmente 10%) | Percentual sobre a cota |
| **Taxa de Controle** | Taxa administrativa do sistema | Valor fixo configurado |
| **Multa por Infração** | Multas aplicadas a unidades específicas | Cadastro de infrações |
| **Rateio de Água** | Consumo individual de água (se houver) | Leitura do hidrômetro |
| **Desconto** | Descontos aplicados (convênio, etc) | Valor negativo |

**Fórmula:**
```
VALOR BOLETO = Cota + Fundo Reserva + Multa + Controle + Rateio Água - Desconto
```

### 5.2 Boleto Avulso (Despesa Extraordinária)

**O que é:** Cobrança pontual para situações específicas.

**Quando usar:**
- Despesa extraordinária no meio do mês
- Multa aplicada a uma unidade específica
- Aluguel de salão de festas / churrasqueira
- Rateio de gás individualizado
- Sinistro / reparos emergenciais

**Contas Contábeis Disponíveis:**

| ID | Nome | Consta no Relatório? |
|----|------|---------------------|
| `taxa_condominal` | Taxa Condominal | Não |
| `multa_infracao` | Multa por Infração | **Sim** |
| `advertencia` | Advertência | **Sim** |
| `controle_tags` | Controle/Tags | Não |
| `manutencao_servicos` | Manutenção/Serviços | Não |
| `salao_festa` | Salão de Festa/Churrasqueira | Não |
| `agua` | Água | Não |
| `gas` | Gás | Não |
| `sinistro` | Sinistro | Não |

### 5.3 Comparativo: Mensal vs Avulso

| Característica | Boleto Mensal | Boleto Avulso |
|----------------|---------------|---------------|
| **Frequência** | Todo mês | Sob demanda |
| **Destinatários** | Todas as unidades | Unidades selecionadas |
| **Composição** | Múltiplos componentes | Valor único + descrição |
| **Conta Contábil** | Automática (Mensal) | Selecionável |
| **Relatório** | Sempre consta | Depende da conta |

---

## 6. Como Tudo Isso Se Conecta ao BOLETO

### O Fluxo Completo:

```
┌─────────────────────────────────────────────────────────────────────────┐
│                    FLUXO: DESPESA → BOLETO                               │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│   PASSO 1: Síndico lança as DESPESAS                                   │
│   ┌─────────────────────────────────────────────────────────────────┐  │
│   │ • Conta de luz: R$ 1.500,00                                    │  │
│   │ • Conta de água: R$ 800,00                                     │  │
│   │ • Salário porteiro: R$ 2.500,00                                │  │
│   │ • Manutenção elevador: R$ 1.200,00                             │  │
│   │ • Limpeza: R$ 600,00                                           │  │
│   │ • Taxa administrativa: R$ 800,00                               │  │
│   │ • Seguro: R$ 400,00                                            │  │
│   │ ─────────────────────────────────────────────────────────────  │  │
│   │ TOTAL DESPESAS: R$ 7.800,00                                    │  │
│   └─────────────────────────────────────────────────────────────────┘  │
│                              │                                          │
│                              ▼                                          │
│   PASSO 2: Sistema calcula a COTA                                      │
│   ┌─────────────────────────────────────────────────────────────────┐  │
│   │                                                                 │  │
│   │   R$ 7.800,00 (despesas)                                        │  │
│   │   ÷ 48 (unidades)                                              │  │
│   │   ─────────────────                                            │  │
│   │   = R$ 162,50 por unidade                                      │  │
│   │                                                                 │  │
│   │   + Fundo de Reserva (10%): R$ 16,25                           │  │
│   │   + Taxa de Controle: R$ 15,00                                 │  │
│   │   ─────────────────────────────────────────────────            │  │
│   │   COTA FINAL: R$ 193,75 por unidade                            │  │
│   │                                                                 │  │
│   └─────────────────────────────────────────────────────────────────┘  │
│                              │                                          │
│                              ▼                                          │
│   PASSO 3: Síndico GERA O BOLETO                                       │
│   ┌─────────────────────────────────────────────────────────────────┐  │
│   │                                                                 │  │
│   │   Na tela "Gerar Cobrança Mensal", o síndico preenche:         │  │
│   │                                                                 │  │
│   │   Cota Condominial: R$ 162,50                                  │  │
│   │   Fundo de Reserva: R$ 16,25                                   │  │
│   │   Taxa de Controle: R$ 15,00                                   │  │
│   │   ─────────────────────────────────────────────────            │  │
│   │   VALOR DO BOLETO: R$ 193,75                                   │  │
│   │                                                                 │  │
│   └─────────────────────────────────────────────────────────────────┘  │
│                              │                                          │
│                              ▼                                          │
│   PASSO 4: Morador PAGA o boleto                                       │
│   ┌─────────────────────────────────────────────────────────────────┐  │
│   │                                                                 │  │
│   │   48 moradores x R$ 193,75 = R$ 9.300,00                       │  │
│   │                                                                 │  │
│   │   (Isso vira RECEITA no sistema!)                              │  │
│   │                                                                 │  │
│   └─────────────────────────────────────────────────────────────────┘  │
│                              │                                          │
│                              ▼                                          │
│   PASSO 5: Sistema registra como RECEITA                               │
│   ┌─────────────────────────────────────────────────────────────────┐  │
│   │                                                                 │  │
│   │   Quando o boleto é pago:                                       │  │
│   │   → Sistema cria uma RECEITA automática                         │  │
│   │   → Tipo: AUTOMÁTICO                                            │  │
│   │   → Conta: Banco Itaú                                           │  │
│   │                                                                 │  │
│   └─────────────────────────────────────────────────────────────────┘  │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## 6. O Resumo Financeiro

### O que o Síndico Vê:

```
┌─────────────────────────────────────────────────────────────┐
│           RESUMO FINANCEIRO - ABRIL/2026                     │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│ ┌─────────────────────────────────────────────────────────┐│
│ │ SALDO ANTERIOR (Março):                      R$ 2.500,00││
│ │ (sobrou do mês passado)                                  ││
│ └─────────────────────────────────────────────────────────┘│
│                                                             │
│ ┌─────────────────────────────────────────────────────────┐│
│ │ (+) TOTAL RECEITAS:                          R$ 9.300,00││
│ │     (pagamentos dos boletos + alugueis + etc)           ││
│ └─────────────────────────────────────────────────────────┘│
│                                                             │
│ ┌─────────────────────────────────────────────────────────┐│
│ │ (-) TOTAL DESPESAS:                          R$ 7.800,00││
│ │     (contas que o condomínio pagou)                     ││
│ └─────────────────────────────────────────────────────────┘│
│                                                             │
│ ══════════════════════════════════════════════════════════│
│                                                             │
│ ┌─────────────────────────────────────────────────────────┐│
│ │ (=) SALDO ATUAL:                             R$ 4.000,00││
│ │     (saldo anterior + receitas - despesas)              ││
│ └─────────────────────────────────────────────────────────┘│
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## 7. A Conexão Automática

### O que acontece AUTOMATICAMENTE:

| Evento | O que o Sistema Faz |
|--------|---------------------|
| **Boleto é pago** | Cria uma RECEITA automática |
| **Receita é registrada** | Atualiza o Saldo Atual |
| **Despesa é lançada** | Atualiza o Saldo Atual |
| **Mês muda** | Calcula o Saldo Anterior |

### O que o Síndico FAZ MANUALMENTE:

| Ação | Quando |
|------|--------|
| **Lançar despesas** | Quando chega uma conta |
| **Gerar boletos** | Uma vez por mês (ou automático) |
| **Dar baixa em dinheiro** | Quando alguém paga em espécie |
| **Lançar receitas extras** | Aluguel de salão, etc |

---

## 8. Exemplo Prático Completo

### Cenário: Condomínio Gaia Prime - Abril/2026

#### Dia 01/04 - Síndico lança as despesas:

```
DESPESAS DE ABRIL:
├─ Energia elétrica (áreas comuns)...... R$ 1.500,00
├─ Água (áreas comuns)................. R$ 800,00
├─ Salário do porteiro................. R$ 2.500,00
├─ Manutenção do elevador.............. R$ 1.200,00
├─ Limpeza e jardinagem................ R$ 600,00
├─ Taxa administrativa................. R$ 800,00
├─ Seguro do prédio.................... R$ 400,00
└─ Fundo de obras (reserva)............ R$ 500,00
   ─────────────────────────────────────────────
   TOTAL DESPESAS: R$ 7.300,00
```

#### Dia 05/04 - Síndico gera os boletos:

```
GERAR COBRANÇA MENSAL:

Cota Condominial: R$ 7.300,00 ÷ 48 = R$ 152,08
Fundo de Reserva: R$ 15,21 (10%)
Taxa de Controle: R$ 15,00
─────────────────────────────────────
VALOR DO BOLETO: R$ 182,29 por unidade

☑ Enviar para registro
☑ Enviar por email

[GERAR COBRANÇA]
```

#### Dia 10/04 - Vencimento dos boletos:

```
Moradores pagam:
├─ 45 moradores pagaram pelo banco........ R$ 8.203,05
├─ 2 moradores pagaram em dinheiro........ R$ 364,58
└─ 1 morador não pagou................... R$ 0,00
   ───────────────────────────────────────────────
   RECEITA DO MÊS: R$ 8.567,63
```

#### Dia 30/04 - Resumo do mês:

```
═════════════════════════════════════════════════════
           RESUMO FINANCEIRO - ABRIL/2026
═════════════════════════════════════════════════════

Saldo Anterior (de Março):........... R$ 2.500,00
(+) Receitas (boletos + extras):.... R$ 8.567,63
(-) Despesas do mês:................ R$ 7.300,00
─────────────────────────────────────────────────────
(=) SALDO ATUAL:.................... R$ 3.767,63

═════════════════════════════════════════════════════
```

---

## 9. Perguntas Frequentes

### P: O síndico precisa calcular a cota manualmente?
**R:** Não necessariamente. O sistema mostra o total de despesas, e o síndico divide pelo número de unidades. No futuro, o sistema fará isso automaticamente.

### P: E se tiver despesa extra no meio do mês?
**R:** O síndico lança a despesa. Se já gerou os boletos, pode:
- Gerar um boleto avulso para cada morador
- Deixar para o próximo mês
- Fazer um rateio extra

### P: Quem paga em dinheiro, como fica?
**R:** O síndico registra o pagamento na tela de boletos ("Receber"). Isso cria uma receita automaticamente.

### P: O demonstrativo financeiro é automático?
**R:** Sim! O morador vê no app a composição do boleto e o demonstrativo de onde o dinheiro foi gasto.

---

## 10. Fluxo Técnico Detalhado

### 10.1 Geração de Boleto Mensal

```
┌─────────────────────────────────────────────────────────────────────────┐
│                    FLUXO TÉCNICO: BOLETO MENSAL                          │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│   1. APP (Flutter)                                                      │
│   └── BoletoCubit.gerarCobrancaMensal()                                │
│       │                                                                 │
│       ▼                                                                 │
│   2. SERVICE                                                            │
│   └── BoletoService.gerarCobrancaMensal()                              │
│       │   • Busca unidades do condomínio                                │
│       │   • Busca proprietários/inquilinos                              │
│       │   • Monta lista de moradores com CPF, email                    │
│       │                                                                 │
│       ▼                                                                 │
│   3. BACKEND (Laravel)                                                  │
│   └── POST /api/asaas/boletos/gerar-mensal                             │
│       │   • BoletoService.gerarCobrancaMensal()                        │
│       │                                                                 │
│       ▼                                                                 │
│   4. ASAAS API                                                          │
│   └── CobrancaService.criar() para cada morador                        │
│       │   • Cria customer (se não existir)                             │
│       │   • Cria payment (cobrança)                                    │
│       │   • Retorna: paymentId, bankSlipUrl, barCode                   │
│       │                                                                 │
│       ▼                                                                 │
│   5. SUPABASE                                                           │
│   └── INSERT na tabela 'boletos'                                        │
│       │   • tipo: 'Mensal'                                              │
│       │   • status: 'Ativo'                                             │
│       │   • asaas_payment_id                                            │
│       │   • identification_field (linha digitável)                     │
│       │   • bar_code                                                    │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

### 10.2 Geração de Boleto Avulso

```
┌─────────────────────────────────────────────────────────────────────────┐
│                    FLUXO TÉCNICO: BOLETO AVULSO                           │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│   1. APP (Flutter)                                                      │
│   └── GerarCobrancaAvulsaDialog                                         │
│       │   • Seleciona conta contábil                                    │
│       │   • Seleciona unidades específicas                              │
│       │   • Define valor e descrição                                    │
│       │                                                                 │
│       ▼                                                                 │
│   2. BACKEND (Laravel)                                                  │
│   └── POST /api/asaas/boletos/gerar-avulso                             │
│       │   • BoletoAvulsoService.gerarCobrancaAvulsa()                  │
│       │                                                                 │
│       ▼                                                                 │
│   3. SUPABASE                                                           │
│   └── INSERT na tabela 'boletos'                                        │
│       │   • tipo: 'Avulso'                                              │
│       │   • classe: conta contábil selecionada                         │
│       │   • constar_relatorio: 'SIM' ou 'NAO'                          │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

### 10.3 Arquivos do Sistema

| Arquivo | Função |
|---------|--------|
| `BoletoService.php` | Serviço de boletos mensais (Backend) |
| `BoletoAvulsoService.php` | Serviço de boletos avulsos (Backend) |
| `BoletoCubit.dart` | Gerenciador de estado (Flutter) |
| `BoletoService.dart` | Comunicação com API (Flutter) |
| `gerar_cobranca_mensal_dialog.dart` | UI boleto mensal |
| `gerar_cobranca_avulsa_dialog.dart` | UI boleto avulso |

---

## 11. Webhook e Confirmação de Pagamento

### 11.1 Como o Sistema Sabe que o Boleto Foi Pago?

```
┌─────────────────────────────────────────────────────────────────────────┐
│                    FLUXO: CONFIRMAÇÃO DE PAGAMENTO                       │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│   1. MORADOR paga o boleto                                              │
│       │   (via banco, internet banking, lotérica)                      │
│       │                                                                 │
│       ▼                                                                 │
│   2. ASAAS recebe confirmação                                           │
│       │   • Status muda para 'RECEIVED'                                 │
│       │   • Data de confirmação registrada                             │
│       │                                                                 │
│       ▼                                                                 │
│   3. WEBHOOK ASAAS → BACKEND                                            │
│       │   POST /api/webhooks/asaas                                      │
│       │   { paymentId, status: 'RECEIVED', paymentDate }               │
│       │                                                                 │
│       ▼                                                                 │
│   4. BACKEND atualiza SUPABASE                                          │
│       │   • UPDATE boletos SET status = 'Pago'                         │
│       │   • data_pagamento = paymentDate                               │
│       │                                                                 │
│       ▼                                                                 │
│   5. CRIAÇÃO AUTOMÁTICA DE RECEITA                                      │
│       │   • INSERT na tabela 'receitas'                                │
│       │   • tipo: 'AUTOMATICO'                                          │
│       │   • valor: valor do boleto                                     │
│       │   • descricao: 'Pagamento boleto ref: MM/AAAA'                 │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

### 11.2 Status do Boleto

| Status | Significado |
|--------|-------------|
| **Ativo** | Boleto gerado, aguardando pagamento |
| **Registrado** | Boleto registrado no banco |
| **Pago** | Pagamento confirmado |
| **Vencido** | Passou do vencimento sem pagamento |
| **Cancelado** | Boleto cancelado manualmente |

---

## 12. Diagrama Final

```
┌─────────────────────────────────────────────────────────────────────────┐
│                    ECOSSISTEMA FINANCEIRO DO CONDOMÍNIO                  │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│                        ┌─────────────────┐                              │
│                        │    SÍNDICO      │                              │
│                        └────────┬────────┘                              │
│                                 │                                       │
│           ┌─────────────────────┼─────────────────────┐                │
│           │                     │                     │                │
│           ▼                     ▼                     ▼                │
│   ┌───────────────┐     ┌───────────────┐     ┌───────────────┐        │
│   │   DESPESAS    │     │   RECEITAS    │     │ TRANSFERÊNCIAS│        │
│   │               │     │               │     │               │        │
│   │ • Luz         │     │ • Boletos     │     │ • Conta A→B   │        │
│   │ • Água        │     │ • Aluguéis    │     │               │        │
│   │ • Salários    │     │ • Juros       │     │               │        │
│   │ • Manutenção  │     │ • Multas      │     │               │        │
│   └───────┬───────┘     └───────┬───────┘     └───────────────┘        │
│           │                     │                                       │
│           │    ┌────────────────┘                                       │
│           │    │                                                        │
│           ▼    ▼                                                        │
│   ┌───────────────────────────────────────────────────────────────┐    │
│   │                    RESUMO FINANCEIRO                          │    │
│   │                                                               │    │
│   │   Saldo Anterior + Receitas - Despesas = Saldo Atual         │    │
│   └───────────────────────────────────────────────────────────────┘    │
│                                 │                                       │
│                                 ▼                                       │
│                        ┌─────────────────┐                              │
│                        │  BOLETO MENSAL  │                              │
│                        │                 │                              │
│                        │ Cota = Despesas │                              │
│                        │    ÷ Unidades   │                              │
│                        └─────────────────┘                              │
│                                 │                                       │
│                                 ▼                                       │
│                        ┌─────────────────┐                              │
│                        │    MORADOR      │                              │
│                        │                 │                              │
│                        │ • Paga boleto   │                              │
│                        │ • Vê composição │                              │
│                        │ • Vê demostrat. │                              │
│                        └─────────────────┘                              │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## 13. Resumo Rápido

| Conceito | O que é | Onde Entra |
|----------|---------|------------|
| **Despesa** | Gasto do condomínio | Síndico lança manualmente |
| **Receita** | Entrada de dinheiro | Automática (boleto pago) ou manual |
| **Cota** | Valor do boleto | Calculada a partir das despesas |
| **Saldo** | Caixa do condomínio | Atualizado automaticamente |
| **Boleto Mensal** | Cobrança regular | Gerado mensalmente pelo síndico |
| **Boleto Avulso** | Cobrança extraordinária | Gerado sob demanda |

### A Regra de Ouro:

> **DESPESAS determinam a COTA, que determina o BOLETO, que gera RECEITAS.**

---

## 14. O que estava faltando no documento original

### Lacunas identificadas e corrigidas:

| Item | Status |
|------|--------|
| **Arquitetura técnica** | ✅ Adicionado (Flutter → Laravel → ASAAS → Supabase) |
| **Tipos de boleto** | ✅ Adicionado (Mensal vs Avulso) |
| **Composição do valor do boleto** | ✅ Detalhado (Cota, Fundo Reserva, Multa, etc) |
| **Contas contábeis do avulso** | ✅ Listado todas as opções |
| **Fluxo técnico detalhado** | ✅ Adicionado com arquivos envolvidos |
| **Webhook de confirmação** | ✅ Explicado como funciona |
| **Status do boleto** | ✅ Tabela com todos os status |
| **Campo "constar no relatório"** | ✅ Explicado quando é usado |

---

## 15. Checklist do Síndico

### Antes de gerar o boleto mensal:

- [ ] Conferir se todas as despesas do mês foram lançadas
- [ ] Verificar se há despesas recorrentes configuradas
- [ ] Calcular a cota condominial (despesas ÷ unidades)
- [ ] Definir percentual do fundo de reserva
- [ ] Verificar se há multas por infração a cobrar
- [ ] Conferir rateio de água (se aplicável)

### Ao gerar boleto avulso:

- [ ] Selecionar a conta contábil correta
- [ ] Definir se deve constar no relatório
- [ ] Selecionar as unidades específicas (ou todas)
- [ ] Preencher descrição clara e detalhada
- [ ] Definir data de vencimento adequada

---

## 16. Próximas Implementações (Roadmap)

| Funcionalidade | Status | Prioridade |
|----------------|--------|------------|
| Cálculo automático da cota | Planejado | Alta |
| Demonstrativo financeiro para morador | Em desenvolvimento | Alta |
| Webhook ASAAS → criação automática de receita | A implementar | Alta |
| Segunda via de boleto para morador | Implementado | Média |
| Notificação de vencimento por push | Planejado | Média |
| Relatório de inadimplência | Planejado | Média |
