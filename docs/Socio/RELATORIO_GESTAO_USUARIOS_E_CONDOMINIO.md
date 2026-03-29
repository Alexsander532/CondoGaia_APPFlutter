# 📋 Relatório de Implementação — Gestão de Usuários e Condomínio

> **Documento para revisão de sócio** · Versão 1.0 · Março 2026  
> **Objetivo:** Explicar como funciona o módulo de Gestão do CondoGaia, incluindo cadastro de usuários, permissões, configurações financeiras e integração com outros módulos.

---

## 1. Visão Geral do Módulo

O módulo de **Gestão do Condomínio** é o "painel de controle" do síndico (representante). É por aqui que ele configura tudo o que o sistema precisa para funcionar corretamente: quem tem acesso, quanto custa a taxa, como funciona a multa, etc.

### O que o síndico consegue fazer nesse módulo:

| Funcionalidade | Status | Descrição Resumida |
|---|---|---|
| Adicionar/remover usuários | ✅ Funcional | Cadastrar sub-usuários com permissões específicas |
| Definir permissões granulares | ✅ Funcional | Controlar exatamente o que cada usuário pode ver/fazer |
| Configurar financeiro | ✅ Funcional | Taxa condominial, fundo de reserva, juros, multa, desconto |
| Cadastrar conta bancária | ✅ Funcional | Dados bancários do condomínio para integração com boletos |
| Gerenciar contas contábeis | ✅ Funcional | Categorias para organizar receitas e despesas |
| Configurar layout do boleto | 🔄 Parcial | Em desenvolvimento |

---

## 2. Gestão de Usuários — Como Funciona

### 2.1 Quem pode usar o sistema?

O sistema tem dois tipos principais de perfis:

1. **Representante (Síndico)** — Tem acesso total ao sistema
2. **Sub-usuários** — Pessoas que o síndico cadastra com acesso limitado

### 2.2 Como o síndico adiciona um novo usuário?

**Passo a passo real:**

1. O síndico vai em **Gestão > Perfil de Usuário**
2. Clica em **"Adicionar Usuário"**
3. Preenche:
   - Nome do usuário
   - E-mail (será usado para login)
   - Tipo de acesso (ex: Zelador, Administradora, Porteiro)
4. Define **quais módulos** o usuário terá acesso
5. Salva o cadastro

### 2.3 Sistema de Permissões — O que cada permissão faz

O sistema usa permissões **granulares**, ou seja, o síndico controla módulo por módulo. Veja todas as permissões disponíveis:

| Permissão | O que permite ao usuário |
|---|---|
| 🗨️ **Chat** | Acessar e usar o chat do condomínio |
| 📊 **Leitura** | Ver e registrar leituras de água e gás |
| ⚙️ **Gestão** | Acessar configurações gerais do condomínio |
| 💰 **Boleto** | Ver e gerenciar boletos dos condôminos |
| 🤝 **Acordo** | Negociar acordos financeiros com condôminos |
| 📧 **E-mail** | Enviar e-mails e circulares para moradores |
| 📝 **Ocorrência** | Registrar e gerenciar ocorrências |
| 💳 **Despesa/Receita** | Ver movimentação financeira do condomínio |
| 📑 **Cobrança** | Gerar cobranças avulsas e mensais |

### 2.4 Caso Real — Exemplo de Uso

> **Cenário:** O síndico quer que o zelador possa registrar leituras de água, mas sem acessar dados financeiros do condomínio.
>
> **O que ele faz:**
> 1. Adiciona o zelador como sub-usuário
> 2. Ativa APENAS a permissão de **Leitura** e **Chat**
> 3. Desativa todas as outras permissões (Boleto, Gestão, Acordo, etc.)
>
> **Resultado:** O zelador entra no app e vê apenas as telas de Leitura de consumo e Chat. Ele não consegue ver boletos, financeiro, nem nenhum dado sensível.

> **Cenário 2:** A administradora do condomínio precisa gerar boletos e acompanhar pagamentos, mas não precisa de chat ou leitura.
>
> **O que o síndico faz:**
> 1. Adiciona a administradora como sub-usuário
> 2. Ativa: **Boleto**, **Cobrança**, **Despesa/Receita**, **Acordo**
> 3. Desativa: Chat, Leitura, Ocorrência
>
> **Resultado:** A administradora tem uma visão focada em financeiro e cobranças.

---

## 3. Configurações Financeiras — Como Funciona

### 3.1 O que o síndico configura aqui?

Esta é a parte mais importante da gestão porque **alimenta automaticamente a geração de boletos**. Quando o síndico configura o financeiro corretamente, o sistema usa esses valores para preencher automaticamente os boletos mensais.

### 3.2 Campos Disponíveis

| Campo | O que é | Exemplo Real |
|---|---|---|
| **Taxa Condominial** | Valor mensal que cada unidade paga | R$ 450,00 |
| **Fundo de Reserva** | Percentual sobre a taxa, acumulado para emergências | 10% (= R$ 45,00) |
| **Tipo de Cobrança** | Como o valor é calculado | Fixo ou Rateio |
| **Multa (%)** | Percentual cobrado quando atrasa | 2% |
| **Juros ao Mês (%)** | Juros mensais sobre atraso | 1% |
| **Desconto Garantidora (%)** | Desconto para condôminos que pagam em dia | Calculado automaticamente |
| **Data de Vencimento** | Dia fixo para vencimento do boleto | Dia 10 |

### 3.3 Tipos de Cobrança — Diferença entre Fixo e Rateio

| Tipo | Como funciona | Quando usar |
|---|---|---|
| **Fixo** | Todo mundo paga o mesmo valor | Condomínios pequenos com unidades iguais |
| **Rateio** | O valor total das despesas é dividido entre as unidades | Condomínios com unidades de tamanhos diferentes |

### 3.4 Caso Real — Como o Financeiro alimenta o Boleto

> **Situação:** O condomínio "Residencial Pinheiros" tem 20 unidades. O síndico configurou:
> - Taxa condominial: **R$ 500,00** (Fixo)
> - Fundo de reserva: **10%** (R$ 50,00)
> - Multa por atraso: **2%**
> - Juros mensal: **1%**
> - Dia de vencimento: **dia 10**
>
> **O que acontece quando o síndico vai gerar os boletos do mês:**
> 1. O sistema puxa automaticamente: Taxa R$ 500 + Fundo R$ 50 = **R$ 550,00**
> 2. Define vencimento para o **dia 10** do mês seguinte
> 3. Se um morador atrasar, o sistema calcula: Multa 2% (R$ 11) + Juros 1% ao mês
> 4. O síndico **não precisa digitar nada manualmente** — tudo vem das configurações

### 3.5 Desconto Garantidora — Como funciona

O desconto é calculado automaticamente com base no número de unidades do condomínio. Quanto mais unidades, menor o desconto pois o risco é diluído.

> **Exemplo:** Um condomínio com 50 unidades recebe um desconto diferente de um com 10 unidades. Esse cálculo é feito automaticamente pelo sistema quando o síndico salva as configurações financeiras.

---

## 4. Conta Bancária — Cadastro

O síndico precisa cadastrar a conta bancária do condomínio para que os boletos sejam gerados corretamente. Os dados são:

- **Banco** (ex: Bradesco, Itaú, Caixa)
- **Agência**
- **Conta**
- **Tipo** (Corrente ou Poupança)
- **Titular**
- **CNPJ do Condomínio**

> ⚠️ **Importante:** Esses dados são usados na integração com o Asaas (sistema de pagamentos). Sem conta bancária cadastrada, não é possível gerar boletos.

---

## 5. Contas Contábeis — Categorização Financeira

As contas contábeis servem para **organizar** de onde vem o dinheiro (receitas) e para onde vai (despesas).

### Exemplos de Contas Contábeis:

| Tipo | Exemplo | Uso |
|---|---|---|
| Receita | "Taxa Condominial" | Aparece ao gerar boleto como descrição da cobrança |
| Receita | "Fundo de Reserva" | Separação contábil do fundo |
| Receita | "Aluguel de Salão" | Receita extra do condomínio |
| Despesa | "Energia Elétrica" | Categorizar gastos com energia |
| Despesa | "Manutenção Elevador" | Categorizar gastos de manutenção |

> **Caso Real:** Quando o síndico gera um boleto avulso para cobrar uma taxa extra de mudança, ele seleciona a conta contábil "Taxa de Mudança" para que fique categorizado corretamente no financeiro.

---

## 6. Integração com Outros Módulos

O módulo de Gestão é o **alicerce** de todos os outros módulos. Veja como ele se conecta:

```
┌──────────────────┐
│   GESTÃO         │
│  (Configurações) │
└────────┬─────────┘
         │
         ├──→ BOLETOS: Usa taxa, juros, multa, vencimento, conta bancária
         │
         ├──→ COBRANÇA AVULSA: Usa contas contábeis para categorizar
         │
         ├──→ LEITURA: Valores são incorporados nos boletos (rateio água)
         │
         ├──→ ACORDO: Usa juros e multa para calcular parcelamento
         │
         └──→ USUÁRIOS: Controla quem acessa cada módulo
```

### Exemplo prático da integração:

> O síndico configura no financeiro: **juros de 1% ao mês** e **multa de 2%**.
>
> Quando ele vai para o módulo de **Acordo** para negociar com um morador inadimplente, o sistema já usa esses mesmos percentuais como base para o cálculo das parcelas.

---

## 7. Como os Dados são Salvos

Toda a configuração é salva no **Supabase** (banco de dados na nuvem), nas seguintes tabelas:

| Tabela | O que armazena |
|---|---|
| `configuracoes_financeiras` | Taxa, juros, multa, tipo de cobrança, desconto |
| `contas_bancarias` | Dados bancários do condomínio |
| `contas_contabeis` | Categorias de receita e despesa |
| `usuarios_condominio` | Sub-usuários e suas permissões |

> **Para o sócio:** Isso significa que as configurações ficam seguras na nuvem e qualquer alteração é refletida imediatamente para todos os usuários do condomínio.

---

## 8. Regras de Negócio Importantes

### ✅ Regras que já estão implementadas:

1. **Apenas o representante (síndico) pode adicionar sub-usuários** — Sub-usuários não podem adicionar outros
2. **As permissões são aplicadas em tempo real** — Se o síndico remove a permissão de Boleto de um sub-usuário, ele imediatamente perde acesso
3. **A configuração financeira é obrigatória para gerar boletos** — O sistema avisa se falta configuração
4. **O desconto garantidora é calculado automaticamente** — Baseado no número de unidades
5. **A conta bancária é validada antes de salvar** — Campos obrigatórios como CNPJ e agência são verificados
6. **O tipo de cobrança (Fixo/Rateio) afeta como o boleto é calculado** — Fixo = mesmo valor para todos; Rateio = proporcional
7. **As configurações financeiras são pré-carregadas na geração de boletos** — O síndico não precisa redigitar valores

### ⚠️ Pontos para revisar:

1. O layout do boleto (personalização visual) ainda está em desenvolvimento
2. A funcionalidade de importar unidades em massa (via planilha) ainda não foi implementada
3. A tela de configuração avançada (taxa condominial diferenciada por bloco) ainda não existe

---

## 9. Resumo para Verificação

**Perguntas para o sócio validar:**

- [ ] O sistema de permissões cobre todos os módulos necessários?
- [ ] Os campos financeiros estão completos? Falta algum encargo?
- [ ] O fluxo de adicionar usuário está claro e simples?
- [ ] O cálculo de desconto garantidora está correto?
- [ ] A integração entre financeiro e geração de boleto faz sentido?
- [ ] Falta algum tipo de cobrança além de Fixo e Rateio?
