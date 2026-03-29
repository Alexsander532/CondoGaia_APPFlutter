# 🏢 Documentação para o Sócio — Feature de Boleto

**Objetivo deste documento:** Explicar de forma simples e completa como a feature de boleto funciona no CondoGaia, usando exemplos reais do dia a dia de um síndico. Ao final da leitura, você deve conseguir validar se a feature está completa para uso.

**Data:** 28/03/2026

---

## 📌 O que é a Feature de Boleto?

É a funcionalidade que permite o **síndico ou administrador** (representante) gerar cobranças para os moradores do condomínio. Existem dois tipos de cobrança:

| Tipo | O que é | Quando usar |
|---|---|---|
| 🔵 **Cobrança Mensal** | O boleto do mês com todos os valores do condomínio | Todo mês, para cobrar taxa condominial + encargos |
| 🟠 **Cobrança Avulsa (Boleto Avulso)** | Um boleto extra, separado do mensal | Para cobranças pontuais: multas, reparos, acordos |
| 🟡 **Junto à Taxa Condominial** | Valor extra embutido no próximo boleto mensal | Para rateios de água, gás, reserva de salão *(não implementado ainda)* |

---

## 1. 🔵 Cobrança Mensal — Como Funciona

### O que é?

A cobrança mensal é o "boleto do condomínio" que todo morador recebe todo mês. Ele pode incluir:

- **Cota Condominial** — o valor fixo que cada unidade paga
- **Fundo de Reserva** — percentual ou valor fixo para emergências
- **Multa por Infração** — se alguém levou multa
- **Controle/Tags** — taxa de manutenção de controles de acesso
- **Rateio de Água** — consumo individual ou rateio
- **Desconto** — valor de desconto para pagamento antecipado

### Caso Real 1 — Gerar Boleto do Mês de Abril

> O condomínio Mirante do Vale tem 24 unidades. A taxa condominial é R$ 500/mês. O fundo de reserva é 10% da taxa (R$ 50). O dia de vencimento é dia 10.

**O que o síndico faz:**
1. Abre a tela de **Boletos**
2. Clica em **"Gerar Cobrança Mensal"**
3. O sistema **automaticamente** preenche:
   - Data: `10/04/2026` (próximo mês, dia configurado)
   - Cota Condominial: `R$ 500,00` (valor fixo configurado)
   - Fundo de Reserva: `R$ 50,00` (10% de R$ 500)
   - Desconto: `R$ 240,00` (R$ 10,00 × 24 unidades)
4. Mostra: **"Todos (24)"** — boletos para todas as unidades
5. O síndico clica em **"GERAR BOLETO"**

**O que acontece por trás:**
- O sistema gera **24 boletos** (1 por unidade) no ASAAS
- Cada boleto tem o valor = R$ 500 + R$ 50 − R$ 10 = **R$ 540,00**
- Os boletos ficam disponíveis para pagamento online
- Se marcou "Enviar p/ E-Mail", cada morador recebe um e-mail

**Resultado:**
- ✅ 24 boletos gerados com valor correto
- ✅ Vencimento no dia 10 do próximo mês
- ✅ Desconto aplicado automaticamente

### Caso Real 2 — Gerar Para Um Bloco Específico

> O Bloco C teve uma reforma e o síndico quer cobrar apenas as 6 unidades do Bloco C um valor extra de manutenção.

**O que o síndico faz:**
1. Clica em **"Gerar Cobrança Mensal"**
2. Clica em **"Bloco/Unid."** (link azul sublinhado)
3. Seleciona Bloco C → marca as 6 unidades
4. O sistema atualiza: **"6 Boletos"**
5. O desconto recalcula: `R$ 60,00` (R$ 10 × 6)
6. Clica em **"GERAR BOLETO"**

**Resultado:**
- ✅ Apenas 6 boletos gerados (só Bloco C)
- ✅ O restante do condomínio não é afetado

### ⚠️ E se não tiver configuração financeira?

Se o síndico ainda não configurou os valores financeiros (cota, fundo, etc.), o sistema:
1. Mostra um **aviso vermelho**: "Configuração financeira não definida"
2. Exibe um botão **"Configurar agora"** que leva para a tela de Gestão Financeira
3. O botão "GERAR BOLETO" fica **desativado** até ter configuração

---

## 2. 🟠 Cobrança Avulsa (Boleto Avulso) — Como Funciona

### O que é?

É um boleto **separado** do mensal. Serve para cobranças pontuais como multas, consertos, acordos, etc. O morador recebe um boleto **a mais**, além do mensal.

### Existem DUAS formas de gerar um boleto avulso:

#### Forma 1: Pelo botão rápido na tela de Boletos
Um modal simples onde o síndico preenche os campos básicos e gera.

#### Forma 2: Pela tela de Cobrança Avulsa (mais completa)
Uma tela dedicada com abas de Pesquisar e Cadastrar, com mais opções.

---

### Caso Real 3 — Multa por Infração (1 morador)

> O morador da unidade 302/B fez uma festa até 3h da manhã. O síndico decide aplicar multa de R$ 500,00.

**O que o síndico faz (pelo botão rápido):**
1. Na tela de Boletos, clica no botão **"Cobrança Avulsa"**
2. Seleciona Conta Contábil: **"Multa por Infração"**
3. O checkbox **"Constar no Relatório"** aparece automaticamente ✅
4. Clica em **"Unidade/Bloco/Nome"** → seleciona só a 302/B
5. Data: `15/04/2026`
6. Valor: `R$ 500,00`
7. Descrição: `Multa por perturbação do sossego - Art. 12 do Reg. Interno`
8. Marca ✅ **"Enviar p/ E-Mail"**
9. Clica **"GERAR BOLETO AVULSO"**

**O que acontece:**
- O sistema cria um customer para o morador no ASAAS (se não existir)
- Gera 1 boleto de R$ 500 com vencimento 15/04
- Salva o boleto no banco de dados com tipo = **"Avulso"**
- Envia e-mail para o morador da 302/B
- O boleto fica na lista com status **"Ativo"**

**Resultado:**
- ✅ 1 boleto avulso de R$ 500 para o morador da 302/B
- ✅ E-mail enviado com a cobrança
- ✅ O boleto mensal do mês **NÃO é alterado** (são cobranças independentes)
- ✅ Aparece "Constar no Relatório" para referência em assembleias

---

### Caso Real 4 — Conserto de Portão (6 unidades do Bloco A)

> O portão do Bloco A quebrou. O técnico cobrou R$ 1.200,00. O síndico decide dividir entre as 6 unidades do Bloco A.

**O que o síndico faz:**
1. Abre **Cobrança Avulsa** → Aba **Cadastrar**
2. Conta Contábil: `Manutenção/Serviços`
3. Forma de Cobrança: **"Boleto Avulso"**
4. Dia de Vencimento: `15`
5. Descrição: `Conserto de portão automático - Bloco A`
6. Seleciona as 6 unidades do Bloco A
7. Define valor: **R$ 200,00** por unidade (1200 ÷ 6)
8. Clica **"Gerar Boleto"**

**O que acontece:**
- 6 boletos separados são gerados no ASAAS
- Cada morador do Bloco A recebe um boleto de R$ 200
- Os moradores dos outros blocos **não são afetados**

**Resultado:**
- ✅ 6 boletos avulsos de R$ 200 cada
- ✅ Total cobrado: R$ 1.200 (cobre o custo do portão)
- ✅ Na aba "Pesquisar", aparecem 6 registros com status "Ativo"

---

### Caso Real 5 — Acordo Parcelado (Dívida em 6x)

> O morador da 101/A deve R$ 3.000 de meses atrasados. O síndico faz um acordo em 6 parcelas.

**O que o síndico faz:**
1. Aba Cadastrar → Conta Contábil: `Taxa Condominal`
2. Forma de Cobrança: **"Boleto Avulso"**
3. Marca **"Recorrente" = Sim**
4. Quantidade de Meses: `6`
5. Seleciona unidade 101/A
6. Valor: **R$ 500** por parcela
7. Descrição: `Acordo de pagamento - Ref. Jan a Jun/2026`
8. Clica **"Gerar Boleto"**

**O que acontece:**
- O sistema gera **6 boletos de uma vez** no ASAAS
- Vencimentos: 15/04, 15/05, 15/06, 15/07, 15/08, 15/09
- Descrição de cada: `Acordo de pagamento (Parcela 1/6)`, `(Parcela 2/6)`, etc.
- Todos aparecem na aba "Pesquisar"

**Resultado:**
- ✅ 6 boletos com vencimentos sequenciais
- ✅ Valor total do acordo: R$ 3.000
- ✅ Parcelas são cobranças SEPARADAS do boleto mensal

---

### Caso Real 6 — Água Individual (Valores Diferentes)

> O síndico apurou o consumo de água de cada unidade. Os valores são diferentes.

| Unidade | Consumo | Valor |
|---|---|---|
| 101/A | 12 m³ | R$ 96,00 |
| 102/A | 8 m³ | R$ 64,00 |
| 201/A | 15 m³ | R$ 120,00 |
| 202/A | 10 m³ | R$ 80,00 |

**O que o síndico faz (pela tela de Cobrança Avulsa):**
1. Conta Contábil: **"Água"**
2. Forma de Cobrança: **"Boleto Avulso"**
3. Seleciona as 4 unidades
4. **Edita o valor de cada unidade individualmente** (edição inline na tabela)
5. Clica **"Gerar Boleto"**

**Resultado:**
- ✅ 4 boletos com valores DIFERENTES
- ✅ Morador da 101/A recebe boleto de R$ 96
- ✅ Morador da 201/A recebe boleto de R$ 120
- ✅ Cada morador paga apenas seu consumo

---

## 3. 📋 Aba Pesquisar — Gerenciar Cobranças Existentes

A aba **Pesquisar** da tela de Cobrança Avulsa mostra todas as cobranças avulsas já geradas.

### O que aparece na lista:

Para cada cobrança, o síndico vê:
- 🏠 **Unidade** (ex: A - 101)
- 💰 **Valor** (ex: R$ 500,00)
- 📅 **Vencimento** (ex: 15/04/2026)
- 📊 **Status** (Ativo, Pago, Vencido, Cancelado)
- 📝 **Descrição** (ex: Multa por infração)

### O que o síndico pode fazer:

| Ação | Como | O que acontece |
|---|---|---|
| **Excluir** | Botão vermelho (lixeira) | Remove a cobrança do banco de dados |
| **Sincronizar** | Botão azul (sincronizar) | Atualiza o status consultando o ASAAS |

### Caso Real 7 — Verificar se um Boleto foi Pago

> O morador da 302/B disse que já pagou a multa de R$ 500. O síndico quer confirmar.

**O que o síndico faz:**
1. Abre Cobrança Avulsa → Aba **Pesquisar**
2. Encontra o boleto da 302/B
3. Status atual: **"Ativo"** (pode estar desatualizado)
4. Clica no botão **"Sincronizar"**
5. O sistema consulta o ASAAS e atualiza
6. Status muda para: **"Pago"** ✅

**Resultado:**
- ✅ Status atualizado em tempo real
- ✅ O síndico confirma que o morador realmente pagou

---

## 4. 🟡 "Junto à Taxa Condominial" — O Que é e Status Atual

### ⚠️ ESTA FUNCIONALIDADE AINDA NÃO ESTÁ IMPLEMENTADA

A opção "Junto à Taxa Condominial" é a **segunda forma** de cobrança avulsa. Ao contrário do "Boleto Avulso" (que gera um boleto separado agora), esta opção **NÃO gera boleto imediatamente**. Em vez disso, o valor é **guardado** e será **somado ao próximo boleto mensal**.

### Como funcionaria (quando implementado):

```
Síndico cadastra: "Água Individual - R$ 96 para 101/A"
Escolhe: "Junto à Taxa Condominial"
    │
    ▼ O sistema SALVA o registro (NÃO gera boleto)
    │
    ▼ ... dias depois ...
    │
    ▼ Síndico gera o boleto mensal de Abril
    │
    ▼ O boleto da 101/A vem com:
    │  Cota Condominial:  R$ 500,00
    │  Fundo de Reserva:  R$  50,00
    │  Água Individual:   R$  96,00  ← AQUI ENTRA
    │  ─────────────────────────────
    │  TOTAL:             R$ 646,00
```

### Caso Real 8 — Gás Central (quando implementado)

> O condomínio recebeu conta de gás de R$ 2.400. São 24 unidades, rateio igual.

**O que o síndico faria:**
1. Conta Contábil: "Gás"
2. **"Junto à Taxa Condominial"**
3. Seleciona todas as 24 unidades
4. Valor: R$ 100 cada
5. Clica "Gerar Composição"

**Resultado esperado:**
- Nenhum boleto é gerado agora
- 24 registros ficam "pendentes"
- Quando o mensal de abril for gerado, cada boleto terá +R$ 100 de gás

### Status desta funcionalidade:
- ❌ **Interface:** Botão existe, mas mostra "Em breve"
- ❌ **Banco de dados:** Tabela `despesas_extras` precisa ser criada
- ❌ **Backend:** Não implementado
- ❌ **Integração com boleto mensal:** Não implementado

---

## 5. 📊 Comparação: Boleto Avulso vs Junto à Taxa

| Aspecto | Boleto Avulso ✅ | Junto à Taxa ❌ |
|---|---|---|
| **Gera boleto agora?** | SIM, imediatamente | NÃO, fica pendente |
| **O morador recebe** | Boleto separado | Valor embutido no mensal |
| **Quantos boletos?** | 1 boleto extra por unidade | 0 boletos novos |
| **Ideal para** | Multas, acordos, emergências | Água, gás, rateios mensais |
| **Status** | ✅ Implementado | ❌ Não implementado |

---

## 6. 📧 E-mails — Como Funciona o Envio

### Quando o e-mail é enviado?

O e-mail é enviado quando o síndico marca a opção **"Enviar p/ E-Mail"** antes de gerar o boleto.

### O que o morador recebe?

Um e-mail com:
- Nome do morador
- Descrição da cobrança
- Valor
- Data de vencimento
- Link do comprovante (se houver)

### E se o e-mail falhar?

- O boleto **É gerado normalmente** (o e-mail não bloqueia a geração)
- O sistema tenta enviar, mas se falhar, apenas registra o erro internamente
- O síndico **NÃO recebe aviso** de que o e-mail falhou (ponto de melhoria futura)

### Quem recebe o e-mail?

O e-mail é enviado para o endereço cadastrado do **proprietário ou inquilino** da unidade.

---

## 7. 🔒 Regras de Negócio Atuais

### 7.1 Regras da Cobrança Mensal

1. **Configuração obrigatória** — O síndico precisa ter configurado os valores financeiros antes de gerar
2. **Valor fixo** — A cota condominial é fixa (definida na Gestão Financeira)
3. **Desconto por unidade** — O desconto total = desconto unitário × quantidade de unidades
4. **1 boleto por unidade** — Cada unidade recebe exatamente 1 boleto mensal
5. **Vencimento automático** — Calculado com base no dia configurado, para o próximo mês

### 7.2 Regras da Cobrança Avulsa

1. **Valor mínimo** — R$ 0,01 (validação no ASAAS)
2. **Conta contábil obrigatória** — Sempre precisa selecionar uma categoria
3. **Multa e Advertência** — Automaticamente marcam "Constar no Relatório"
4. **Recorrência** — Mínimo 2 meses, máximo 24 meses
5. **1 boleto por unidade por vencimento** — Mesmo com recorrência
6. **CPF/CNPJ obrigatório** — O morador precisa ter CPF cadastrado para gerar boleto no ASAAS
7. **Edição inline de valores** — Na tela de Cobrança Avulsa, é possível definir valores diferentes por unidade

### 7.3 Regras de Sincronização

1. **Status do ASAAS é a verdade** — O status no ASAAS sempre tem prioridade
2. **Webhook automático** — O ASAAS notifica automaticamente quando um pagamento é feito
3. **Sincronização manual** — Disponível para conferência sob demanda
4. **Mapeamento de status:**
   - Pago no ASAAS → Pago no sistema
   - Vencido no ASAAS → Vencido no sistema
   - Estornado no ASAAS → Estornado no sistema

---

## 8. ✅ Checklist de Validação

Use este checklist para verificar se a feature está completa:

### Cobrança Mensal
- [x] Gerar boleto mensal para todas as unidades
- [x] Selecionar unidades específicas (Bloco/Unid)
- [x] Valores preenchidos automaticamente da configuração
- [x] Alerta se configuração financeira ausente
- [x] Cálculo automático de desconto
- [x] Opção de enviar por e-mail
- [x] Opção de enviar para registro

### Cobrança Avulsa (Boleto Avulso)
- [x] Gerar boleto avulso pelo dialog rápido
- [x] Gerar boleto avulso pela tela dedicada
- [x] Selecionar conta contábil (10 categorias)
- [x] Selecionar unidades específicas
- [x] Definir valor (igual para todos ou individual)
- [x] Descrição personalizada
- [x] Recorrência (parcelamento em N meses)
- [x] Upload de comprovante
- [x] Envio de e-mail de notificação
- [x] "Constar no Relatório" automático para Multa/Advertência

### Gerenciamento
- [x] Listar cobranças avulsas existentes
- [x] Excluir cobrança avulsa
- [x] Sincronizar status com o gateway de pagamento
- [ ] ~~Ver detalhes de um boleto~~ *(não implementado)*
- [ ] ~~Editar cobrança existente~~ *(não implementado)*
- [ ] ~~Reenviar e-mail~~ *(não implementado)*
- [ ] ~~Filtros avançados (data, status)~~ *(não implementado)*

### Junto à Taxa Condominial
- [ ] ~~Salvar despesa extra pendente~~ *(não implementado)*
- [ ] ~~Incorporar ao boleto mensal~~ *(não implementado)*

---

## 9. 📱 O Que o Morador Vê

Quando o síndico gera um boleto (mensal ou avulso), o morador pode:

1. **Receber por e-mail** — Se o síndico marcou "Enviar p/ E-Mail"
2. **Acessar no ASAAS** — O boleto fica registrado na plataforma de pagamento
3. **Pagar online** — Via link do boleto (pix, cartão, ou boleto bancário)
4. **Usar a linha digitável** — Para pagamento no app do banco

O morador **NÃO** tem acesso direto ao app CondoGaia (por enquanto). Toda a operação é feita pelo representante.

---

## 10. 🎯 Resumo Visual

```
┌──────────────────────────────────────────────────────┐
│           TELA DE BOLETOS DO REPRESENTANTE            │
│                                                      │
│  ┌─────────────────┐    ┌─────────────────────────┐  │
│  │ COBRANÇA MENSAL │    │ COBRANÇA AVULSA         │  │
│  │                 │    │                         │  │
│  │ • Todo mês      │    │ • Quando precisar       │  │
│  │ • Todas unidades│    │ • Unidades específicas  │  │
│  │ • Taxa + Fundo  │    │ • Valor personalizado   │  │
│  │   + Desconto    │    │ • 10 categorias         │  │
│  │ • Auto-preenche │    │ • Parcelamento 2-24x    │  │
│  │                 │    │ • Upload comprovante    │  │
│  │ ✅ Funcionando  │    │ ✅ Funcionando           │  │
│  └─────────────────┘    └─────────────────────────┘  │
│                                                      │
│  ┌──────────────────────────────────────────────────┐│
│  │ ABA PESQUISAR (Cobranças Avulsas)                ││
│  │                                                  ││
│  │ [Unidade] [Valor] [Vencimento] [Status] [Ações]  ││
│  │  A-101    R$200    15/04/2026   Ativo   🗑️ 🔄    ││
│  │  A-102    R$200    15/04/2026   Pago    🗑️ 🔄    ││
│  │  B-302    R$500    15/04/2026   Ativo   🗑️ 🔄    ││
│  │                                                  ││
│  │ ✅ Funcionando                                   ││
│  └──────────────────────────────────────────────────┘│
└──────────────────────────────────────────────────────┘
```

---

## 11. ❓ Perguntas para Validação

Após ler este documento, considere:

1. **As categorias de conta contábil estão suficientes?** (Taxa, Multa, Advertência, Controle, Manutenção, Salão, Água, Gás, Sinistro)
2. **Falta alguma regra de negócio?** Por exemplo, limite de valor, aprovação antes de gerar, etc.
3. **O parcelamento de 2-24 meses é adequado?** Ou precisa de mais/menos?
4. **O envio de e-mail ao morador é suficiente?** Precisa de WhatsApp também?
5. **A funcionalidade "Junto à Taxa" é prioridade?** Se sim, qual o prazo desejado?
6. **Quem deve ter permissão para gerar boletos avulsos?** Só o síndico ou outros funcionários?
7. **Precisa de aprovação/confirmação antes de gerar?** (ex: "Tem certeza que deseja gerar 24 boletos?")
8. **Precisa de algum relatório de cobranças?** (ex: relatório mensal de receitas avulsas)

---

*Este documento foi gerado automaticamente com base no código-fonte atual do sistema CondoGaia. Todos os exemplos são baseados nas funcionalidades reais implementadas.*
