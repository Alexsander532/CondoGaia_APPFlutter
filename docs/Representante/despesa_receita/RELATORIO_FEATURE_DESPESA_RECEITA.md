# 💰 Relatório da Feature — Gestão de Despesas, Receitas e Transferências

**Projeto:** CondoGaia App  
**Módulo:** Gestão Financeira do Condomínio  
**Perfil de Usuário:** Representante (Síndico / Administrador)  
**Data:** 22/03/2026  
**Versão:** 1.0 — Feature Completa

---

## 1. O que é essa Feature?

A feature de **Gestão de Despesas, Receitas e Transferências** é o módulo financeiro central do CondoGaia. Ela permite que o representante (síndico ou administrador) do condomínio registre, acompanhe e controle toda a movimentação financeira do condomínio de forma simples, organizada e em tempo real.

**Em resumo:** é o "caixa" digital do condomínio. Tudo que entra e sai de dinheiro é registrado e calculado automaticamente.

---

## 2. Por que essa Feature é importante?

Sem esse módulo, o síndico precisaria controlar tudo em planilhas externas ou no papel. Com ele:

- ✅ O síndico registra despesas no momento em que elas acontecem
- ✅ As receitas são registradas automaticamente quando um boleto é pago
- ✅ O saldo do condomínio é calculado em tempo real
- ✅ Existe um histórico financeiro completo, organizado por mês
- ✅ Os dados podem ser filtrados por conta bancária, categoria e tipo
- ✅ Há transparência total na prestação de contas

---

## 3. Como o Usuário Acessa?

O representante acessa pelo menu lateral do app:

**Menu → Gestão → Despesas/Receitas**

Ao abrir a tela, ele encontra **três abas** na parte superior:

| Aba | Função |
|-----|--------|
| **Despesas** | Controle de saídas de dinheiro |
| **Receitas** | Controle de entradas de dinheiro |
| **Transferências** | Movimentações entre contas do condomínio |

Na parte inferior, há um **Resumo Financeiro fixo** que mostra o saldo atualizado.

---

## 4. Módulo de Despesas — Como Funciona

### 4.1 O que são Despesas?

Despesas são **todos os gastos que o condomínio precisa pagar** para funcionar. Exemplos do dia a dia:

| Despesa | Valor Exemplo |
|---------|:-------------:|
| Conta de energia das áreas comuns | R$ 1.500,00 |
| Conta de água do prédio | R$ 800,00 |
| Salário do porteiro | R$ 2.500,00 |
| Manutenção do elevador | R$ 1.200,00 |
| Serviço de limpeza | R$ 600,00 |
| Taxa administrativa da administradora | R$ 800,00 |
| Seguro do prédio | R$ 400,00 |

### 4.2 Cadastrando uma Despesa — Exemplo Real

**Cenário:** O síndico recebeu a fatura mensal da empresa de manutenção do elevador, no valor de R$ 1.200,00, com vencimento em 15/04/2026.

**Passo a passo do que ele faz no app:**

1. Abre o menu **Gestão → Despesas/Receitas**
2. Clica no botão **"+ Cadastrar"**
3. Preenche o formulário:
   - **Conta Bancária:** Banco Itaú — Conta Principal
   - **Categoria:** Manutenção
   - **Subcategoria:** Elevador
   - **Descrição:** "Manutenção preventiva mensal do elevador — Abril/2026"
   - **Valor:** R$ 1.200,00 (o app formata automaticamente com ponto e vírgula)
   - **Data de Vencimento:** 15/04/2026 (o app formata automaticamente no padrão DD/MM/AAAA)
   - **Recorrente:** ✅ Sim — 12 meses (pois a manutenção é mensal)
   - **Me Avisar:** ✅ Sim (para ser notificado antes do vencimento)
4. Opcionalmente, ele pode:
   - Anexar uma **foto do boleto** tirando da câmera ou selecionando da galeria
   - Colar o **link** do boleto ou nota fiscal
5. Clica em **"Salvar Despesa"**
6. Resultado: A despesa aparece na tabela, o Total Débito no resumo financeiro aumenta R$ 1.200,00 e o Saldo Atual diminui R$ 1.200,00. Uma mensagem verde de confirmação aparece na tela.

### 4.3 Filtrando Despesas

O síndico pode filtrar a lista de despesas usando 4 filtros:

| Filtro | Para que serve | Exemplo |
|--------|---------------|---------|
| **Conta Bancária** | Ver despesas de uma conta específica | "Mostrar só despesas do Banco Itaú" |
| **Categoria** | Ver despesas de uma categoria | "Mostrar só gastos com Manutenção" |
| **Subcategoria** | Detalhar dentro da categoria | "Mostrar só gastos com Elevador" |
| **Palavra-chave** | Buscar na descrição | Digitar "elevador" mostra apenas despesas que contêm essa palavra |

### 4.4 Editando uma Despesa

**Cenário:** O valor da manutenção do elevador mudou de R$ 1.200,00 para R$ 1.350,00.

1. O síndico marca o checkbox na linha da despesa na tabela
2. Clica no botão **"Editar"** que aparece no rodapé
3. O formulário abre pré-preenchido com todos os dados
4. Ele altera o valor para R$ 1.350,00
5. Clica em **"Salvar Alterações"**
6. Resultado: A tabela atualiza com o novo valor. O resumo financeiro recalcula automaticamente.

### 4.5 Excluindo Despesas

**Cenário:** Uma despesa foi lançada por engano.

1. O síndico marca o checkbox da(s) despesa(s) que deseja excluir
2. Clica no botão **"Excluir"**
3. Um diálogo de confirmação aparece: "Tem certeza que deseja excluir?"
4. Ele confirma
5. Resultado: Despesa(s) removida(s) da tabela. Resumo financeiro recalcula.

É possível usar o botão **"Selecionar Todos"** no cabeçalho da tabela para marcar/desmarcar todas as despesas de uma vez.

### 4.6 Modal de Detalhes

Ao tocar em qualquer despesa na tabela, abre um painel detalhado que mostra:
- Conta bancária vinculada
- Categoria e subcategoria
- Descrição completa
- Valor formatado
- Data de vencimento
- Indicador visual "MANUAL" ou "AUTOMÁTICO"
- Foto do comprovante (se houver)
- Link externo com botões para **copiar** ou **abrir no navegador** (se houver)

---

## 5. Módulo de Receitas — Como Funciona

### 5.1 O que são Receitas?

Receitas são **todas as entradas de dinheiro no condomínio**. Exemplos:

| Receita | Valor Exemplo | Tipo |
|---------|:-------------:|:----:|
| Pagamento de boleto condominial (morador A/101) | R$ 193,75 | Automático |
| Pagamento de boleto condominial (morador A/102) | R$ 193,75 | Automático |
| Aluguel do salão de festas | R$ 500,00 | Manual |
| Rendimento de aplicação financeira | R$ 120,00 | Manual |
| Juros por atraso de pagamento | R$ 45,00 | Automático |

### 5.2 Tipo Manual vs. Automático

O sistema diferencia dois tipos de receita com um indicador visual:

| Tipo | Significado | Quando acontece |
|------|------------|-----------------|
| **MANUAL** | Receita cadastrada pelo síndico | Aluguel do salão, rendimento, receita avulsa |
| **AUTOMÁTICO** | Receita criada automaticamente pelo sistema | Quando um boleto é pago pelo morador |

> **Importante:** Quando um morador paga o boleto condominial, o sistema recebe a confirmação do gateway de pagamento (Asaas) e cria automaticamente uma receita do tipo "AUTOMÁTICO" no valor pago. Isso garante que o saldo do condomínio se atualize sem que o síndico precise fazer nada.

### 5.3 Cadastrando uma Receita Manual — Exemplo Real

**Cenário:** O morador da unidade A/103 alugou o salão de festas por R$ 500,00.

1. O síndico vai para a aba **"Receitas"**
2. Clica em **"+ Cadastrar"**
3. Preenche o formulário:
   - **Conta Bancária:** Banco Itaú — Conta Principal
   - **Categoria:** Aluguel de Áreas
   - **Subcategoria:** Salão de Festas
   - **Conta Contábil:** Controle (para fins de classificação contábil)
   - **Descrição:** "Aluguel salão de festas — Unidade A/103 — 20/03/2026"
   - **Valor:** R$ 500,00
   - **Data do Crédito:** 20/03/2026
   - **Tipo:** Manual
4. Clica em **"Salvar Receita"**
5. Resultado: A receita aparece na tabela, o Total Crédito aumenta R$ 500,00 e o Saldo Atual aumenta R$ 500,00.

### 5.4 Conta Contábil

Cada receita pode ser classificada em uma **Conta Contábil**, que organiza a contabilidade do condomínio:

| Conta Contábil | Para que serve | Exemplo |
|---------------|---------------|---------|
| **Controle** | Receitas de operação diária | Taxa condominial, aluguel de salão |
| **Fundo de Reserva** | Reserva financeira do condomínio | Percentual sobre cota, rendimentos |
| **Obras** | Receitas destinadas a obras | Rateio de obras, contribuições extras |

### 5.5 Filtrando Receitas

| Filtro | Exemplo de Uso |
|--------|---------------|
| **Conta Bancária** | Ver receitas recebidas na conta do Itaú |
| **Conta Contábil** | Ver apenas receitas do Fundo de Reserva |
| **Tipo** | Ver só receitas Automáticas (boletos pagos) ou só Manuais |
| **Palavra-chave** | Buscar "salão" na descrição |

---

## 6. Módulo de Transferências — Como Funciona

### 6.1 O que são Transferências?

Transferências são **movimentações internas entre contas bancárias** do próprio condomínio. Não representam entrada nem saída de dinheiro — apenas remanejamento entre contas.

### 6.2 Exemplo Real

**Cenário:** O síndico precisa transferir R$ 5.000,00 da conta corrente para a poupança (fundo de reserva).

1. O síndico vai para a aba **"Transferências"**
2. Clica em **"+ Cadastrar"**
3. Preenche:
   - **Conta Débito (Origem):** Banco Itaú — Conta Corrente
   - **Conta Crédito (Destino):** Banco Itaú — Poupança
   - **Descrição:** "Transferência para fundo de reserva — Abril/2026"
   - **Valor:** R$ 5.000,00
   - **Data:** 05/04/2026
4. Clica em **"Salvar Transferência"**

> **Proteção:** O sistema impede que o síndico selecione a mesma conta como origem e destino. Se tentar, uma mensagem de erro é exibida.

---

## 7. Resumo Financeiro — O "Painel de Controle" do Dinheiro

Na parte inferior da tela existe um **painel fixo** que mostra o resumo financeiro do mês selecionado. Este painel atualiza em tempo real conforme o síndico cadastra, edita ou exclui registros.

### 7.1 Composição do Resumo

| Indicador | O que representa | Cor |
|-----------|-----------------|-----|
| **Saldo Anterior** | Dinheiro que sobrou do mês passado | Azul |
| **Total Crédito** | Soma de todas as receitas do mês | Verde |
| **Total Débito** | Soma de todas as despesas do mês | Vermelho |
| **Saldo Atual** | Resultado final do mês | Verde (positivo) / Vermelho (negativo) |

### 7.2 Fórmula do Saldo

```
Saldo Atual = Saldo Anterior + Total Crédito − Total Débito
```

### 7.3 Exemplo Prático Completo com Números Reais

**Condomínio Gaia Prime — Abril/2026**

| Passo | O que aconteceu | Efeito no Resumo |
|:-----:|----------------|-------------------|
| — | Saldo anterior (sobrou de Março) | Saldo Anterior: **R$ 2.500,00** |
| 1 | Síndico lança despesa de Energia: R$ 1.500,00 | Total Débito: R$ 1.500,00 / Saldo: R$ 1.000,00 |
| 2 | Síndico lança despesa de Água: R$ 800,00 | Total Débito: R$ 2.300,00 / Saldo: R$ 200,00 |
| 3 | Síndico lança despesa de Porteiro: R$ 2.500,00 | Total Débito: R$ 4.800,00 / Saldo: −R$ 2.300,00 🔴 |
| 4 | Síndico lança despesa de Elevador: R$ 1.200,00 | Total Débito: R$ 6.000,00 / Saldo: −R$ 3.500,00 🔴 |
| 5 | Síndico lança despesa de Limpeza: R$ 600,00 | Total Débito: R$ 6.600,00 / Saldo: −R$ 4.100,00 🔴 |
| 6 | Síndico lança despesa Administrativa: R$ 800,00 | Total Débito: R$ 7.400,00 / Saldo: −R$ 4.900,00 🔴 |
| 7 | Moradores começam a pagar boletos... | |
| 8 | 10 moradores pagam (R$ 193,75 cada) → Receita Automática | Total Crédito: R$ 1.937,50 / Saldo: −R$ 2.962,50 🔴 |
| 9 | Mais 20 moradores pagam → Receita Automática acumula | Total Crédito: R$ 5.812,50 / Saldo: R$ 912,50 |
| 10 | Todos os 48 moradores pagaram | Total Crédito: R$ 9.300,00 / Saldo: **R$ 4.400,00** ✅ |
| 11 | Aluguel do salão: R$ 500,00 (receita manual) | Total Crédito: R$ 9.800,00 / Saldo: **R$ 4.900,00** ✅ |

**Resumo final do mês:**

| Indicador | Valor |
|-----------|------:|
| Saldo Anterior | R$ 2.500,00 |
| Total Crédito (Receitas) | R$ 9.800,00 |
| Total Débito (Despesas) | R$ 7.400,00 |
| **Saldo Atual** | **R$ 4.900,00** |

> **Observação:** O saldo negativo é exibido em vermelho, sinalizando ao síndico que ainda faltam receitas para cobrir as despesas do mês. Conforme os moradores pagam os boletos, o saldo vai se tornando positivo.

---

## 8. Navegação por Mês/Ano

Na parte superior da tela existe um seletor com setas que permite navegar entre os meses:

```
    [ < ]    Março 2026    [ > ]
```

- Ao clicar na **seta esquerda**, o sistema carrega os dados do mês anterior
- Ao clicar na **seta direita**, carrega o mês seguinte
- O ano muda automaticamente (Dezembro → Novembro troca o ano)
- Todos os dados recarregam: despesas, receitas, transferências e saldo anterior

**Utilidade:** O síndico pode consultar o histórico financeiro de qualquer mês para prestação de contas ou conferência.

---

## 9. Funcionalidades Adicionais

### 9.1 Upload de Comprovantes (Despesas)

O síndico pode **anexar fotos** de boletos, notas fiscais ou recibos às despesas:

- Pode tirar uma foto com a **câmera** do dispositivo
- Ou selecionar da **galeria** de imagens
- A imagem é automaticamente comprimida para economizar espaço
- A foto fica disponível no Modal de Detalhes para consulta futura

### 9.2 Links Externos (Despesas)

Cada despesa pode ter um **link** para a nota fiscal, boleto online ou qualquer documento externo:

- No Modal de Detalhes, existem dois botões:
  - **"Copiar"** — copia o link para a área de transferência
  - **"Abrir"** — abre o link no navegador

### 9.3 Formatação Automática de Valores

O sistema formata automaticamente os campos de entrada:

| Campo | Comportamento |
|-------|-------------|
| **Valor (R$)** | Adiciona pontos de milhar e vírgula decimal automaticamente. Ex: digitar "150050" → exibe "1.500,50" |
| **Data** | Adiciona barras automaticamente. Ex: digitar "15032026" → exibe "15/03/2026" |

### 9.4 Validações de Segurança

O sistema impede erros comuns do usuário:

| Validação | O que acontece |
|-----------|---------------|
| Salvar sem valor | ❌ Sistema bloqueia e exibe mensagem de erro |
| Salvar sem data | ❌ Sistema bloqueia e exibe mensagem de erro |
| Transferir para a mesma conta | ❌ Sistema bloqueia — conta origem deve ser diferente da conta destino |
| Excluir sem confirmação | ❌ Sempre aparece diálogo "Tem certeza?" |

---

## 10. Conexão com o Boleto — O Ciclo Completo do Dinheiro

Esta feature está diretamente conectada ao módulo de Boletos do sistema. O ciclo funciona assim:

### Passo 1 — O síndico lança as despesas do mês
O síndico registra todos os gastos previstos do condomínio (energia, água, salários, manutenção, etc.).

### Passo 2 — O síndico calcula a cota condominial
Com base no total de despesas, ele divide pelo número de unidades do condomínio:

> **Exemplo:** R$ 7.400,00 de despesas ÷ 48 unidades = **R$ 154,17 por unidade**

### Passo 3 — O síndico gera os boletos
Na tela de Geração de Cobrança Mensal, ele define o valor do boleto (cota + fundo de reserva + taxas) e gera um boleto para cada morador.

### Passo 4 — Os moradores pagam
Os moradores pagam via banco, internet banking ou lotérica.

### Passo 5 — O sistema registra receitas automaticamente
Quando o gateway de pagamento (Asaas) confirma que um boleto foi pago, o sistema **automaticamente** cria uma receita do tipo "AUTOMÁTICO" no valor pago. O síndico não precisa fazer nada — o saldo é atualizado em tempo real.

### Resumo Visual do Ciclo

```
  DESPESAS (síndico lança)
       ↓
  COTA CONDOMINIAL (total despesas ÷ unidades)
       ↓
  BOLETOS (gerados para cada morador)
       ↓
  PAGAMENTO (morador paga)
       ↓
  RECEITA AUTOMÁTICA (sistema registra)
       ↓
  SALDO ATUALIZADO (em tempo real)
```

---

## 11. Casos de Uso Reais — Dia a Dia do Síndico

### Caso 1: "Chegou a conta de luz"

O síndico recebe a fatura de energia elétrica das áreas comuns no valor de R$ 1.850,00. Ele:
1. Abre Despesas/Receitas
2. Cadastra com categoria "Energia", subcategoria "Áreas Comuns"
3. Digita R$ 1.850,00 como valor
4. Marca como recorrente (12 meses)
5. Anexa a foto da fatura
6. Salva

**Resultado:** A despesa fica registrada, o saldo do mês atualiza e ele tem o comprovante guardado digitalmente.

---

### Caso 2: "Morador alugou o salão"

O morador do ap. B/205 pagou R$ 500,00 para alugar o salão de festas. O síndico:
1. Vai na aba Receitas
2. Cadastra como receita Manual
3. Seleciona conta contábil "Controle"
4. Informa a descrição: "Aluguel salão — B/205 — Festa dia 25/03"
5. Salva

**Resultado:** O saldo do condomínio aumenta R$ 500,00.

---

### Caso 3: "Preciso mover dinheiro para a poupança"

O síndico precisa transferir R$ 3.000,00 da conta corrente para a poupança do fundo de reserva. Ele:
1. Vai na aba Transferências
2. Seleciona conta débito: Conta Corrente Itaú
3. Seleciona conta crédito: Poupança Itaú
4. Informa valor e data
5. Salva

**Resultado:** A transferência fica registrada como movimentação interna, sem alterar o saldo total do condomínio.

---

### Caso 4: "Morador pagou o boleto atrasado"

Um morador pagou o boleto de Fevereiro com atraso (com juros). O sistema:
1. Recebe a confirmação de pagamento do Asaas (gateway)
2. Atualiza o status do boleto para "Pago"
3. **Cria automaticamente** uma receita do tipo "AUTOMÁTICO"
4. O saldo do condomínio é atualizado

**Resultado:** O síndico não precisa fazer nada. Ao abrir a tela de Receitas, ele verá a receita marcada com o badge "AUTOMÁTICO".

---

### Caso 5: "Preciso prestar contas do mês passado"

O conselho fiscal pede o demonstrativo de Fevereiro/2026. O síndico:
1. Abre Despesas/Receitas
2. Usa as setas de navegação para voltar para Fevereiro/2026
3. Visualiza todas as despesas, receitas e transferências do mês
4. Confere o resumo: Saldo Anterior, Total Crédito, Total Débito, Saldo Atual
5. Usa os filtros para detalhar por categoria ou conta bancária

**Resultado:** Todas as informações para a prestação de contas estão organizadas e acessíveis.

---

## 12. Resumo Final da Feature

| Aspecto | Detalhe |
|---------|---------|
| **Despesas** | Cadastro completo com categoria, subcategoria, recorrência, foto e link |
| **Receitas** | Manuais (síndico cadastra) e Automáticas (geradas pelo pagamento de boleto) |
| **Transferências** | Movimentações entre contas do condomínio |
| **Resumo Financeiro** | Saldo Anterior + Créditos − Débitos = Saldo Atual (atualização em tempo real) |
| **Histórico** | Navegação por mês/ano para consultar qualquer período |
| **Filtros** | Por conta bancária, categoria, subcategoria, conta contábil, tipo e palavra-chave |
| **Validações** | Valor obrigatório, data obrigatória, contas diferentes em transferência |
| **Feedback** | Mensagens de sucesso/erro em cada operação |
| **Comprovantes** | Upload de fotos de boletos e notas fiscais |
| **Automação** | Receitas criadas automaticamente quando boletos são pagos |

---

*Documento preparado em 22/03/2026 — Equipe Desenvolvimento CondoGaia*
