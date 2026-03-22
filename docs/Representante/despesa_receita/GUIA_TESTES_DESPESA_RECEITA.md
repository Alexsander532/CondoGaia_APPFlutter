# 🧪 Guia Completo de Testes — Despesa, Receita e Transferência

**Data:** 21/03/2026  
**Status dos Testes Unitários:** ✅ **89/89 passando**

---

## Sumário

1. [Testes Unitários (Automatizados)](#1-testes-unitários-automatizados)
2. [Como Executar os Testes](#2-como-executar-os-testes)
3. [Testes Manuais — Passo a Passo Completo](#3-testes-manuais--passo-a-passo-completo)
   - 3.1 [Aba Despesas](#31-aba-despesas)
   - 3.2 [Aba Receitas](#32-aba-receitas)
   - 3.3 [Aba Transferências](#33-aba-transferências)
   - 3.4 [Resumo Financeiro](#34-resumo-financeiro)
   - 3.5 [Navegação por Mês/Ano](#35-navegação-por-mêsano)
   - 3.6 [Formatadores de Input](#36-formatadores-de-input)
4. [Checklist de Validação](#4-checklist-de-validação)
5. [Resultado Atual dos Testes Unitários](#5-resultado-atual-dos-testes-unitários)

---

## 1. Testes Unitários (Automatizados)

Os testes unitários ficam em `test/features/despesa_receita/` e cobrem 4 áreas:

| Arquivo | O que testa | Nº de testes |
|---------|-------------|:------------:|
| `models_test.dart` | Modelos Despesa, Receita, Transferência, CategoriaFinanceira | 25 |
| `state_test.dart` | Estado do Cubit (valores padrão, copyWith, computed getters, Equatable) | 24 |
| `cubit_test.dart` | Lógica de negócio do DespesaReceitaCubit (carregar, pesquisar, salvar, excluir, seleção, edição, navegação) | 17 |
| `input_formatters_test.dart` | BrazilianCurrencyFormatter e DateInputFormatter | 23 |
| **Total** | | **89** |

### O que cada grupo de testes cobre:

#### `models_test.dart`
- **Despesa Model** (8 testes):
  - Criação com valores padrão
  - Desserialização de JSON completo (todos os campos + joins)
  - JSON com valores nulos
  - JSON sem `condominio_id`
  - `toJson` com/sem `id`
  - `toJson` exclui campos de join
  - `copyWith` preserva campos não alterados
  - Equatable (igualdade e desigualdade)

- **Receita Model** (6 testes):
  - Criação com valores padrão
  - JSON completo (incluindo `conta_contabil`)
  - JSON mínimo
  - `toJson` com/sem campos de join
  - `copyWith` parcial
  - Equatable

- **Transferencia Model** (6 testes):
  - Criação padrão
  - JSON completo (com `conta_debito`, `conta_credito`)
  - `toJson` com/sem `id`
  - `toJson` sem campos de join
  - `copyWith`
  - Equatable

- **CategoriaFinanceira** (2 testes): com/sem subcategorias
- **SubcategoriaFinanceira** (1 teste): parse de JSON

#### `state_test.dart`
- **Estado Inicial** (1 teste): verifica todos os valores padrão (status, listas vazias, filtros nulos, seleções vazias)
- **copyWith** (7 testes):
  - Atualizar status
  - Atualizar listas de dados
  - Atualizar filtros
  - `clearDespesaEditando`, `clearReceitaEditando`, `clearTransferenciaEditando`
  - `clearErrorMessage`
  - Atualizar seleções por aba
- **Computed Getters** (9 testes):
  - `categoriasDespesa` filtra só tipo DESPESA
  - `categoriasReceita` filtra só tipo RECEITA
  - `subcategoriasFiltradas` (sem categoria, com categoria, categoria sem subs, categoriaId inexistente)
  - `totalDespesas` (soma valores, lista vazia = 0)
  - `totalReceitas` (soma valores)
  - `saldoAtual` = saldoAnterior + receitas - despesas (positivo e negativo)
- **Equatable** (3 testes): igualdade/desigualdade de estados

#### `cubit_test.dart`
- **carregarDadosIniciais** (2 testes): loading → success com todos os dados; error quando serviço falha
- **pesquisarDespesas** (1 teste): loading → success com lista e seleção limpa
- **pesquisarReceitas** (1 teste): loading → success com lista e seleção limpa
- **pesquisarTransferencias** (1 teste): loading → success com lista
- **atualizarFiltros** (1 teste): todos os filtros atualizados no state
- **salvarDespesa** (2 testes): sucesso (chama service + pesquisa); falha (isSaving + errorMessage)
- **salvarReceita** (1 teste): chama service e pesquisa depois
- **excluirDespesasSelecionadas** (1 teste): chama service com IDs selecionados
- **Toggle seleção** (3 testes): toggle individual (add/remove), selecionar/desselecionar todas, toggle receita
- **Modo edição** (3 testes): iniciar/cancelar edição de despesa, receita, transferência
- **Navegação Mês** (1 teste): mesAnterior decrementa e recarrega dados

#### `input_formatters_test.dart`
- **BrazilianCurrencyFormatter** (12 testes):
  - Texto vazio, dígitos simples, separadores de milhar (4 e 7 dígitos)
  - Vírgula decimal, formatação com vírgula, rejeição de segunda vírgula
  - Remoção de zeros à esquerda, zero único em `0,50`
  - Remoção de caracteres não numéricos, posição do cursor
- **DateInputFormatter** (10 testes):
  - Texto vazio, 1-8 dígitos com formatação DD/MM/AAAA automática
  - Rejeição de >10 caracteres, remoção de caracteres não numéricos, posição do cursor

---

## 2. Como Executar os Testes

### Rodar todos os testes da feature:
```bash
cd condogaiaapp
flutter test test/features/despesa_receita/
```

### Rodar um arquivo específico:
```bash
flutter test test/features/despesa_receita/models_test.dart
flutter test test/features/despesa_receita/state_test.dart
flutter test test/features/despesa_receita/cubit_test.dart
flutter test test/features/despesa_receita/input_formatters_test.dart
```

### Rodar com output detalhado:
```bash
flutter test test/features/despesa_receita/ --reporter=expanded
```

### Rodar TODOS os testes do app:
```bash
flutter test
```

---

## 3. Testes Manuais — Passo a Passo Completo

> **Pré-requisito:** Ter o app rodando (`flutter run`) e estar logado como Representante com um condomínio selecionado.

### 3.1 Aba Despesas

#### 3.1.1 Cadastrar Despesa ✅CONCLUÍDO

| # | Passo | Resultado Esperado |
|:-:|-------|-------------------|
| 1 | Acesse **Gestão** → **Despesas/Receitas** | Tela abre na aba **Despesas** |
| 2 | Clique no botão **"+ Cadastrar"** | Formulário de cadastro expande |
| 3 | Selecione uma **Conta Bancária** | Dropdown exibe contas do condomínio |
| 4 | Selecione uma **Categoria** (tipo DESPESA) | Lista mostra apenas categorias tipo DESPESA |
| 5 | Selecione uma **Subcategoria** | Lista mostra subcategorias da categoria selecionada |
| 6 | Preencha a **Descrição** | Campo aceita texto livre |
| 7 | Digite o **Valor** (ex: `1.500,50`) | Formatação brasileira automática (ponto de milhar, vírgula decimal) |
| 8 | Preencha a **Data de Vencimento** (ex: `15032026`) | Auto-formata para `15/03/2026` |
| 9 | Marque **"Recorrente"** | Campo "Qtd. de Meses" aparece |
| 10 | Preencha Qtd. de Meses (ex: `12`) | Aceita número inteiro |
| 11 | Marque **"Me Avisar"** | Checkbox marcado |
| 12 | Preencha um **Link** (opcional) | Campo aceita URL |
| 13 | Clique em **"📎 Anexar foto"** (opcional) | Abre seletor de câmera/galeria |
| 14 | Clique em **"Salvar Despesa"** | ✅ Despesa aparece na tabela, formulário fecha |
| 15 | Tente salvar **sem valor** | ❌ Validação impede (valor > 0) |
| 16 | Tente salvar **sem data de vencimento** | ❌ Validação impede |

#### 3.1.2 Listar e Filtrar Despesas ✅CONCLUÍDO

| # | Passo | Resultado Esperado |
|:-:|-------|-------------------|
| 1 | Verifique a tabela de despesas | Lista despesas do mês/ano selecionado |
| 2 | Filtre por **Conta Bancária** | Tabela mostra apenas despesas daquela conta |
| 3 | Filtre por **Categoria** | Tabela filtra pela categoria |
| 4 | Filtre por **Subcategoria** | Filtra pela subcategoria (depende de ter selecionado categoria antes) |
| 5 | Digite uma **Palavra-chave** na busca | Filtra despesas pela descrição |
| 6 | Limpe todos os filtros | Volta a mostrar todas as despesas do mês |

#### 3.1.3 Editar Despesa ✅CONCLUÍDO

| # | Passo | Resultado Esperado |
|:-:|-------|-------------------|
| 1 | Marque o checkbox de **1 despesa** na tabela | Despesa selecionada (highlight) |
| 2 | Clique no botão **"Editar"** no rodapé | Formulário preenche com dados da despesa |
| 3 | Altere o **Valor** | Campo atualiza a formatação |
| 4 | Clique em **"Salvar Alterações"** | ✅ Dado atualizado na tabela |

#### 3.1.4 Excluir Despesas ✅CONCLUÍDO

| # | Passo | Resultado Esperado |
|:-:|-------|-------------------|
| 1 | Marque 1 ou mais despesas | Checkboxes marcados |
| 2 | Clique em **"Excluir"** | Diálogo de confirmação aparece |
| 3 | Confirme a exclusão | ✅ Despesas removidas da tabela |
| 4 | Use o **"Selecionar Todos"** no cabeçalho | Todas as despesas selecionadas |
| 5 | Clique "Selecionar Todos" novamente | Todas desselecionadas |

#### 3.1.5 Modal de Detalhes da Despesa ✅CONCLUÍDO

| # | Passo | Resultado Esperado |
|:-:|-------|-------------------|
| 1 | Toque em uma despesa na tabela | Modal de detalhes abre |
| 2 | Verifique info exibida | Conta, categoria, subcategoria, descrição, valor, data, tipo |
| 3 | Se tem foto: visualize a imagem | Imagem carrega corretamente |
| 4 | Se tem link: clique em **"Abrir"** | Abre URL no navegador |
| 5 | Se tem link: clique em **"Copiar"** | Link copiado para a área de transferência |
| 6 | Verifique indicador de tipo | "MANUAL" ou "AUTOMÁTICO" exibido |

---

### 3.2 Aba Receitas

#### 3.2.1 Cadastrar Receita ✅CONCLUÍDO

| # | Passo | Resultado Esperado |
|:-:|-------|-------------------|
| 1 | Clique na aba **"Receitas"** | Aba de receitas ativa |
| 2 | Clique em **"+ Cadastrar"** | Formulário expande |
| 3 | Selecione **Conta Bancária** | Dropdown com contas |
| 4 | Selecione **Categoria** (tipo RECEITA) | Lista mostra apenas categorias tipo RECEITA |
| 5 | Selecione **Subcategoria** | Subcategorias da categoria |
| 6 | Selecione **Conta Contábil** | Opções: Controle, Fundo Reserva, Obras |
| 7 | Preencha **Descrição** | Texto livre |
| 8 | Digite o **Valor** | Formatação BR automática |
| 9 | Preencha **Data do Crédito** | Auto-formata DD/MM/AAAA |
| 10 | Marque **Recorrente** (opcional) | Campo Qtd. Meses aparece |
| 11 | Selecione **Tipo** (Manual/Automático) | Dropdown com as opções |
| 12 | Clique **"Salvar Receita"** | ✅ Receita aparece na tabela |
| 13 | Tente salvar sem valor | ❌ Validação impede |
| 14 | Tente salvar sem data de crédito | ❌ Validação impede |

#### 3.2.2 Filtrar Receitas ✅CONCLUÍDO

| # | Passo | Resultado Esperado |
|:-:|-------|-------------------|
| 1 | Filtre por **Conta Bancária** | Tabela filtra |
| 2 | Filtre por **Conta Contábil** | Filtra por Controle / Fundo Reserva / Obras |
| 3 | Filtre por **Tipo** (Todos / Manual / Automático) | Filtra pelo tipo de receita |
| 4 | Use **Palavra-chave** na busca | Filtra pela descrição |

#### 3.2.3 Editar e Excluir Receitas ✅CONCLUÍDO

> Mesmo fluxo que despesas (seções 3.1.3 e 3.1.4).

#### 3.2.4 Modal de Detalhes da Receita ✅CONCLUÍDO

| # | Passo | Resultado Esperado |
|:-:|-------|-------------------|
| 1 | Toque em uma receita na tabela | Modal abre |
| 2 | Verifique indicador de tipo | Badge "MANUAL" ou "AUTOMÁTICO" |
| 3 | Verifique conta contábil | Exibido corretamente |

---

### 3.3 Aba Transferências

#### 3.3.1 Cadastrar Transferência

| # | Passo | Resultado Esperado |
|:-:|-------|-------------------|
| 1 | Clique na aba **"Transferência"** | Aba ativa |
| 2 | Clique **"+ Cadastrar"** | Formulário expande |
| 3 | Selecione **Conta Débito** (origem) | Dropdown com contas |
| 4 | Selecione **Conta Crédito** (destino) | Dropdown com contas (deve ser ≠ origem) |
| 5 | Preencha **Descrição** | Texto livre |
| 6 | Digite **Valor** | Formatação BR |
| 7 | Preencha **Data da Transferência** | Auto-formata DD/MM/AAAA |
| 8 | Clique **"Salvar Transferência"** | ✅ Transferência na tabela |
| 9 | Tente salvar com **mesma conta débito e crédito** | ❌ Validação impede |

#### 3.3.2 Filtrar Transferências

| # | Passo | Resultado Esperado |
|:-:|-------|-------------------|
| 1 | Filtre por **Conta Débito** | Tabela filtra pela conta de origem |
| 2 | Filtre por **Conta Crédito** | Tabela filtra pela conta de destino |

#### 3.3.3 Editar e Excluir Transferências

> Mesmo fluxo que despesas (seções 3.1.3 e 3.1.4).

---

### 3.4 Resumo Financeiro ✅CONCLUÍDO

| # | Passo | Resultado Esperado |
|:-:|-------|-------------------|
| 1 | Verifique o rodapé fixo da tela | Exibe: Saldo Anterior, Total Crédito, Total Débito, Saldo Atual |
| 2 | Cadastre uma **despesa** de R$ 500 | **Total Débito** aumenta R$ 500, **Saldo Atual** diminui R$ 500 |
| 3 | Cadastre uma **receita** de R$ 800 | **Total Crédito** aumenta R$ 800, **Saldo Atual** aumenta R$ 800 |
| 4 | Exclua a despesa e a receita | Valores voltam ao estado anterior |
| 5 | Verifique a fórmula | `Saldo Atual = Saldo Anterior + Total Crédito - Total Débito` |
| 6 | Se saldo negativo | Valor exibido em vermelho |

---

### 3.5 Navegação por Mês/Ano ✅CONCLUÍDO

| # | Passo | Resultado Esperado |
|:-:|-------|-------------------|
| 1 | Verifique o seletor de mês/ano | Exibe mês e ano atual |
| 2 | Clique na **seta esquerda** `<` | Muda para o mês **anterior** |
| 3 | Verifique se os dados recarregaram | Despesas, receitas, transferências e saldo anterior atualizados |
| 4 | Clique na **seta direita** `>` | Volta para o mês seguinte |
| 5 | Navegue para um mês sem dados | Tabelas vazias, saldo anterior pode variar |
| 6 | Navegue para dezembro → novembro (virada de ano) | Ano muda corretamente |

---

### 3.6 Formatadores de Input ✅CONCLUÍDO

#### Formatador de Moeda (BrazilianCurrencyFormatter)

| Entrada digitada | Resultado formatado |
|:----------------:|:-------------------:|
| `5` | `5` |
| `99` | `99` |
| `1234` | `1.234` |
| `1234567` | `1.234.567` |
| `100,50` | `100,50` |
| `1234,56` | `1.234,56` |
| `100,50,` | `100,50` (rejeita segunda vírgula) |
| `007` | `7` (remove zeros à esquerda) |
| `0,50` | `0,50` (mantém zero único) |
| `12a3b4` | `1.234` (remove letras) |

#### Formatador de Data (DateInputFormatter) ✅CONCLUÍDO

| Entrada digitada | Resultado formatado |
|:----------------:|:-------------------:|
| `1` | `1` |
| `15` | `15` |
| `150` | `15/0` |
| `1503` | `15/03` |
| `15032` | `15/03/2` |
| `15032026` | `15/03/2026` |
| >10 caracteres | Bloqueado (max `DD/MM/AAAA`) |

---

## 4. Checklist de Validação

### ✅ Testes Unitários
- [x] `models_test.dart` — 25/25 passando
- [x] `state_test.dart` — 24/24 passando  
- [x] `cubit_test.dart` — 17/17 passando
- [x] `input_formatters_test.dart` — 23/23 passando

### 📋 Testes Manuais — Despesas
- [x] Cadastrar despesa com todos os campos
- [x] Cadastrar despesa com campos obrigatórios apenas
- [x] Validação de valor > 0
- [x] Validação de data obrigatória
- [x] Listar despesas do mês 
- [x] Filtrar por conta, categoria, subcategoria, palavra-chave
- [x] Editar despesa existente
- [x] Excluir despesa individual
- [x] Excluir múltiplas despesas
- [x] Selecionar todas / desselecionar todas
- [x] Upload de foto/comprovante
- [x] Abrir modal de detalhes
- [x] Link externo: copiar e abrir

### 📋 Testes Manuais — Receitas
- [x] Cadastrar receita com todos os campos
- [x] Validação de valor > 0
- [x] Validação de data de crédito obrigatória
- [x] Filtro por conta bancária
- [x] Filtro por conta contábil (Controle, Fundo Reserva, Obras)
- [x] Filtro por tipo (Todos, Manual, Automático)
- [x] Filtro por palavra-chave
- [x] Editar receita existente
- [x] Excluir receita individual e múltiplas
- [x] Modal de detalhes com badge de tipo

### 📋 Testes Manuais — Transferências
- [x] Cadastrar transferência
- [x] Validação conta débito ≠ conta crédito
- [x] Filtro por conta débito e crédito
- [x] Editar e excluir transferências

### 📋 Testes Manuais — Resumo Financeiro
- [x] Saldo Anterior correto para o mês
- [x] Total Crédito = soma das receitas
- [x] Total Débito = soma das despesas
- [x] Saldo Atual = Saldo Anterior + Crédito - Débito
- [x] Valores atualizam após CRUD

### 📋 Testes Manuais — Navegação
- [x] Navegar mês anterior/próximo
- [x] Dados recarregam ao mudar mês
- [x] Virada de ano funciona

---

## 5. Resultado Atual dos Testes Unitários

```
$ flutter test test/features/despesa_receita/ --reporter=expanded

00:01 +89: All tests passed!
```

> **Executado em:** 21/03/2026 às 19:32h  
> **Resultado:** ✅ 89/89 testes passando  
> **Tempo de execução:** ~1 segundo
