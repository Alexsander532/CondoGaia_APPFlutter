# 🤝 Relatório de Implementação — Acordos Financeiros

> **Documento para revisão de sócio** · Versão 1.0 · Março 2026  
> **Objetivo:** Explicar como funciona o módulo de Acordos Financeiros do CondoGaia, incluindo pesquisa de débitos, simulação de parcelamento, histórico de negociações e cancelamento de acordos. Este documento serve para o sócio verificar se todas as regras de negócio estão corretas.

---

## 1. Visão Geral do Módulo

O módulo de **Acordo** é onde o síndico (representante) negocia dívidas com moradores inadimplentes. Ele permite:

- **Pesquisar** boletos em aberto ou vencidos de um morador
- **Simular** um parcelamento com juros, multa e descontos
- **Registrar** o histórico de tentativas de contato com o morador
- **Cancelar** acordos existentes

### Status Geral das Funcionalidades:

| Funcionalidade | Status | Observação |
|---|---|---|
| Pesquisar boletos por unidade | ✅ Funcional | Filtros por tipo, situação e período |
| Selecionar boletos para negociar | ✅ Funcional | Checkbox para seleção múltipla |
| Simular parcelamento | ✅ Funcional | Com juros, multa, índice e acréscimos |
| Ver o valor total selecionado | ✅ Funcional | Soma automática dos boletos marcados |
| Registrar histórico de contato | ✅ Funcional | Log de tentativas de negociação |
| Cancelar acordo | ✅ UI pronta | O backend ainda é stub (simulação) |
| Gerar boletos do acordo | 🔲 Em breve | Botão presente, funcionalidade pendente |
| Enviar acordo por e-mail | 🔲 Em breve | Botão presente, funcionalidade pendente |
| Gerar PDF do acordo | 🔲 Em breve | Botão presente, funcionalidade pendente |

---

## 2. Estrutura de Telas — 3 Abas

O módulo de Acordo possui **3 abas** principais:

```
╭──────────────────────────────────────────────────╮
│  [Pesquisar]    [Negociar]    [Histórico]        │
╰──────────────────────────────────────────────────╯
```

| Aba | O que faz | Quando usar |
|---|---|---|
| **Pesquisar** | Busca e lista boletos de uma unidade | Primeiro passo: ver o que está devendo |
| **Negociar** | Simula parcelamento dos boletos selecionados | Segundo passo: propor acordo |
| **Histórico** | Registra tentativas de contato e anotações | Acompanhar a evolução da negociação |

---

## 3. Aba Pesquisar — Como Funciona

### 3.1 O que o síndico vê nesta tela

Ao abrir a aba "Pesquisar", o síndico vê:

1. **Barra de busca** — Para pesquisar por nome do morador ou bloco/unidade
2. **Filtros expansíveis** — Para refinar os resultados
3. **Tabela de resultados** — Lista de boletos encontrados
4. **Botões de ação** — Gerar PDF, Visualizar, E-mail, Compartilhar
5. **Botão de Cancelar Acordo** — Para cancelar acordos existentes

### 3.2 Filtros Disponíveis

| Filtro | Opções | O que faz |
|---|---|---|
| **Mês/Ano de Vencimento** | Navegação com setas ← → | Filtra boletos por período de vencimento |
| **Intervalo de Vencimento** | Data início – Data fim | Filtra por intervalo de datas |
| **Tipo de Emissão** | Todos / Avulso / Mensal / Acordo | Filtra pelo tipo do boleto |
| **Situação** | Todos / Ativo/A Vencer / Vencido / Pago / Cancelado | Filtra pelo status do boleto |

### 3.3 Tabela de Resultados — Colunas

| Coluna | O que mostra | Exemplo |
|---|---|---|
| ☐ | Checkbox para seleção | ✓ ou vazio |
| **BL/UNID** | Bloco e Unidade | A-102 |
| **PAR** | Número da parcela | 1/5 |
| **MÊS/ANO** | Referência do boleto | 05/2022 |
| **DATA VENC** | Data de vencimento | 10/08/2022 |
| **VALOR** | Valor do boleto | R$ 111,00 |
| **TIPO** | Tipo de emissão | MENSAL |
| **SITUAÇÃO** | Status atual | ATIVO / PAGO / A VENCER |
| **ANEXO** | Se há documento vinculado | 📎 ícone |

### 3.4 Cores das Situações

| Situação | Cor | Significado |
|---|---|---|
| **PAGO** | 🟢 Verde | Boleto já foi pago |
| **ATIVO** | 🟠 Laranja | Boleto ativo (ainda não venceu) |
| **A VENCER** | 🔵 Azul | Está prestes a vencer |
| **CANCELADO** | 🔴 Vermelho | Boleto foi cancelado |

### 3.5 Caso Real — Pesquisando dívida de um morador

> **Cenário:** O síndico quer ver todos os boletos em aberto da unidade A-102 para negociar com a moradora Maria da Silva.
>
> **Passo a passo:**
> 1. Digita **"A-102"** na barra de busca
> 2. Expande os filtros e seleciona **Situação: "Ativo/a vencer"**
> 3. O sistema mostra os boletos:
>
> | BL/UNID | PAR | MÊS/ANO | VENC | VALOR | SITUAÇÃO |
> |---|---|---|---|---|---|
> | A-102 | 1/5 | 05/2022 | 10/08/2022 | R$ 111,00 | PAGO ✅ |
> | A-102 | 2/5 | 05/2022 | 10/09/2022 | R$ 111,00 | ATIVO ⚠️ |
>
> 4. O síndico marca os boletos ATIVOS com o checkbox
> 5. Na parte inferior aparece: **"1 selecionado(s) — Total: R$ 111,00"**

---

## 4. Aba Negociar — Simulação de Parcelamento

### 4.1 Campos para Configurar o Acordo

Depois de selecionar os boletos na aba "Pesquisar", o síndico vai para a aba "Negociar" e configura:

| Campo | O que é | Exemplo |
|---|---|---|
| **Nº de Parcelas** | Quantas vezes divide a dívida | 6 |
| **Juros (%)** | Percentual de juros por parcela | 1% |
| **Multa (%)** | Percentual de multa aplicada | 2% |
| **Índice Correção (%)** | Atualização monetária | 0,5% |
| **Outros Acréscimos (R$)** | Taxas extras em valor fixo | R$ 50,00 |
| **1º Vencimento** | Data do primeiro pagamento | 15/04/2026 |
| **Entrada** | Se terá pagamento inicial | Sim/Não |
| **Valor da Entrada** | Quanto será pago de entrada | R$ 200,00 |

### 4.2 Como o Cálculo Funciona

O sistema pega o valor total dos boletos selecionados e aplica a fórmula:

```
Para cada parcela:
  Valor Parcela = (Total da Dívida - Entrada) ÷ Número de Parcelas
  Juros = Valor Parcela × (Juros% ÷ 100)
  Multa = Valor Parcela × (Multa% ÷ 100)
  Índice = Valor Parcela × (Índice% ÷ 100)
  Acréscimos = Outros Acréscimos ÷ Número de Parcelas
  
  TOTAL DA PARCELA = Valor + Juros + Multa + Índice + Acréscimos
```

### 4.3 Caso Real — Simulando um Acordo

> **Cenário:** Maria da Silva deve 3 boletos que somam R$ 1.500,00. O síndico quer propor um acordo.
>
> **Dados da negociação:**
> - Total da dívida: **R$ 1.500,00**
> - Número de parcelas: **5**
> - Juros: **1%**
> - Multa: **2%**
> - Índice: **0%**
> - Outros acréscimos: **R$ 0,00**
> - Entrada: **Não**
> - 1º vencimento: **10/04/2026**
>
> **Resultado da simulação:**
>
> | Parcela | Mês/Ano | Vencimento | Valor Base | Juros | Multa | Total |
> |---|---|---|---|---|---|---|
> | 1/5 | 04/2026 | 10/04/2026 | R$ 300,00 | R$ 3,00 | R$ 6,00 | **R$ 309,00** |
> | 2/5 | 05/2026 | 10/05/2026 | R$ 300,00 | R$ 3,00 | R$ 6,00 | **R$ 309,00** |
> | 3/5 | 06/2026 | 10/06/2026 | R$ 300,00 | R$ 3,00 | R$ 6,00 | **R$ 309,00** |
> | 4/5 | 07/2026 | 10/07/2026 | R$ 300,00 | R$ 3,00 | R$ 6,00 | **R$ 309,00** |
> | 5/5 | 08/2026 | 10/08/2026 | R$ 300,00 | R$ 3,00 | R$ 6,00 | **R$ 309,00** |
> | **Total** | | | **R$ 1.500** | **R$ 15** | **R$ 30** | **R$ 1.545,00** |

> **Caso Real 2 — Com entrada:**
>
> - Total da dívida: **R$ 1.500,00**
> - Entrada: **R$ 300,00**
> - Parcelas: **4**
> - Juros: 1%, Multa: 2%
>
> Cálculo: (R$ 1.500 - R$ 300) ÷ 4 = **R$ 300,00 por parcela**
> Com juros e multa: R$ 300 + R$ 3 + R$ 6 = **R$ 309,00 por parcela**
>
> O morador paga R$ 300 de entrada + 4 × R$ 309 = **R$ 1.536,00 total**

### 4.4 Ações após Simulação

Depois de simular, o síndico pode:

| Ação | O que faz | Status |
|---|---|---|
| **Gerar Boletos** | Cria os boletos de cada parcela no sistema | 🔲 Em breve |
| **Excluir Parcela** | Remove uma parcela da simulação | ✅ Funcional |
| **Disparar E-mail** | Envia os detalhes do acordo por e-mail | 🔲 Em breve |

---

## 5. Aba Histórico — Registro de Negociações

### 5.1 Para que serve

O histórico é um **diário de negociação**. O síndico registra cada tentativa de contato com o morador inadimplente, criando um log completo.

### 5.2 O que é registrado

| Campo | O que é | Exemplo |
|---|---|---|
| **BL/UNID** | Qual unidade | A/102 |
| **Data** | Data do contato | 11/09/2022 |
| **Hora** | Horário | 09H |
| **Descrição** | O que aconteceu | "Liguei e disse que vai falar com o marido e retornar" |

### 5.3 Caso Real — Registrando tentativas

> **Linha do tempo da negociação com Maria da Silva (A-102):**
>
> | Data | Hora | O que aconteceu |
> |---|---|---|
> | 01/09/2022 | 10H | "Enviei e-mail de cobrança, sem resposta." |
> | 05/09/2022 | 14H | "Liguei. Ela disse que está sem condições no momento." |
> | 11/09/2022 | 09H | "Liguei novamente. Disse que vai falar com o marido e retornar." |
> | 18/09/2022 | 16H | "Retornou. Propôs parcelar em 5x. Simulemos o acordo." |
> | 20/09/2022 | 10H | "Acordo fechado em 5x de R$309. Boletos gerados." |
>
> **Por que isso é importante:** Esse histórico serve como prova de que o condomínio tentou negociar amigavelmente antes de tomar medidas mais drásticas (como ação judicial).

---

## 6. Cancelamento de Acordo

### 6.1 Como funciona

O síndico pode cancelar um acordo existente. Ao clicar em "Cancelar Acordo", o sistema mostra:

1. **Resumo do acordo:** BL/UNID, Nome do morador
2. **Tabela de parcelas** com data, valor e situação de cada uma
3. **Totais:**
   - Total de parcelas **PAGAS**
   - Total de parcelas **ATIVAS**
   - Total de parcelas **A VENCER**
4. **Botão de confirmação** para efetuar o cancelamento

### 6.2 Caso Real — Cancelando um acordo

> **Cenário:** O acordo da Maria (A-102) em 5 parcelas de R$ 309 foi feito, mas ela não pagou a 3ª parcela. O síndico decide cancelar o acordo.
>
> **O que aparece na tela de cancelamento:**
>
> | BL/UNID | Nome |
> |---|---|
> | A-102 | Maria da Silva |
>
> | Parcela | Data | Valor | Situação |
> |---|---|---|---|
> | 1/5 | 10/04/2026 | R$ 309,00 | PAGO |
> | 2/5 | 10/05/2026 | R$ 309,00 | PAGO |
> | 3/5 | 10/06/2026 | R$ 309,00 | ATIVO (não pago) |
> | 4/5 | 10/07/2026 | R$ 309,00 | A VENCER |
> | 5/5 | 10/08/2026 | R$ 309,00 | A VENCER |
>
> | Resumo | Valor |
> |---|---|
> | Total PAGAS | R$ 618,00 |
> | Total ATIVAS | R$ 309,00 |
> | Total A VENCER | R$ 618,00 |
>
> O síndico confirma e o acordo é **CANCELADO**. As parcelas ativas e a vencer voltam para a dívida original.

> ⚠️ **Nota:** Atualmente, o cancelamento funciona **apenas na interface**. A integração definitiva com o backend (para cancelar boletos no Asaas, etc.) ainda precisa ser implementada.

---

## 7. Regras de Negócio — Resumo

### ✅ Regras implementadas:

1. **Só pode negociar boletos com status ATIVO ou A VENCER** — Boletos pagos não entram na simulação
2. **O valor total do acordo é a soma dos boletos selecionados** — Sistema calcula automaticamente
3. **Juros e multa são aplicados sobre cada parcela individualmente** — Não sobre o total
4. **Outros acréscimos são divididos igualmente entre as parcelas** — Distribuição proporcional
5. **A entrada é subtraída do total antes da divisão em parcelas** — Reduz o valor base
6. **O vencimento de cada parcela é incrementado mensalmente** — A partir do 1º vencimento definido
7. **O histórico é cumulativo** — Cada entrada é adicionada, nunca removida
8. **Apenas boletos selecionados na aba Pesquisar são levados para Negociar** — O síndico controla o que entra no acordo

### ⚠️ O que ainda precisa ser implementado:

1. **Gerar boletos reais** — Quando o síndico confirma o acordo, os boletos de cada parcela devem ser criados no Asaas
2. **Enviar acordo por e-mail** — Mandar os termos do acordo pro morador
3. **Gerar PDF** — Documento formal do acordo para assinatura
4. **Integração com Supabase** — Os dados de acordo devem ser salvos em tabela própria (atualmente usa dados mock)
5. **Cancelamento real** — Quando cancela, deve cancelar boletos no Asaas e atualizar Supabase
6. **Leitor QR** — Botão presente na tela mas funcionalidade ainda não implementada

---

## 8. Resumo para Verificação

**Perguntas para o sócio validar:**

- [ ] O cálculo de juros sobre cada parcela está correto? Deveria ser sobre o total?
- [ ] A multa deveria ser aplicada apenas uma vez (no ato do acordo) ou em cada parcela?
- [ ] Precisamos de um campo para "desconto" no acordo (ex: desconto por pagamento à vista)?
- [ ] O histórico de contatos atende à necessidade jurídica?
- [ ] O cancelamento de acordo deve reverter automaticamente a dívida original?
- [ ] Precisamos de impressão de "termo de acordo" para assinatura presencial?
- [ ] Quais informações devem constar no e-mail do acordo enviado ao morador?
- [ ] Precisamos de assinatura digital no acordo?
