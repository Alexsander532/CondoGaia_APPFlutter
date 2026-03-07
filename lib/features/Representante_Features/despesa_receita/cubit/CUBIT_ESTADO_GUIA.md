# 🧠 Cubit & State — Feature Despesa/Receita

Esta pasta contém o coração do gerenciamento de estado da feature, usando o padrão **BLoC/Cubit** (pacote `bloc`).

---

## Arquivos

| Arquivo | Responsabilidade |
|---|---|
| `despesa_receita_cubit.dart` | Lógica de negócio e chamadas ao Service |
| `despesa_receita_state.dart` | Estrutura imutável do estado + getters computados |

---

## `DespesaReceitaState`

Estado imutável que agrupa **tudo** que a UI precisa saber. Principais campos:

### Dados carregados do backend
| Campo | Tipo | Descrição |
|---|---|---|
| `despesas` | `List<Despesa>` | Despesas do mês selecionado |
| `receitas` | `List<Receita>` | Receitas do mês selecionado |
| `transferencias` | `List<Transferencia>` | Transferências do mês selecionado |
| `contas` | `List<ContaBancaria>` | Contas bancárias (para dropdowns) |
| `categorias` | `List<CategoriaFinanceira>` | Categorias + subcategorias (para dropdowns) |
| `saldoAnterior` | `double` | Saldo calculado do mês passado |

### Filtros ativos
| Campo | Para qual aba |
|---|---|
| `filtroContaId` | Despesas e Receitas |
| `filtroCategoriaId` / `filtroSubcategoriaId` | Despesas |
| `filtroPalavraChave` | Despesas (busca no campo `descricao`) |
| `filtroContaContabil` | Receitas |
| `filtroTipoReceita` | Receitas (`'Todos'`, `'MANUAL'`, `'AUTOMATICO'`) |
| `filtroContaDebitoId` / `filtroContaCreditoId` | Transferências |

### Seleção de itens (por aba, separados)
```
despesasSelecionadas:     Set<String>  — IDs das despesas marcadas
receitasSelecionadas:     Set<String>  — IDs das receitas marcadas
transferenciasSelecionadas: Set<String> — IDs das transferências marcadas
```
> ⚠️ São `Set<String>` separados para que selecionar na aba Despesas não afete as outras abas.

### Modo edição
```
despesaEditando:       Despesa?       — despesa sendo editada (null = modo criação)
receitaEditando:       Receita?
transferenciaEditando: Transferencia?
```

### UI State
| Campo | Tipo | Descrição |
|---|---|---|
| `mesSelecionado` / `anoSelecionado` | `int` | Mês/ano do filtro de período |
| `cadastroExpandido` | `bool` | Controla o card de cadastro/edição por aba |
| `isSaving` | `bool` | Salvar em andamento (mostra loading) |
| `status` | `DespesaReceitaStatus` | `initial`, `loading`, `success`, `error` |
| `errorMessage` | `String?` | Mensagem de erro para o SnackBar |

### Getters computados (não salvos no State, calculados na hora)
```dart
totalDespesas   → double   // soma de despesas[].valor
totalReceitas   → double   // soma de receitas[].valor
saldoAtual      → double   // saldoAnterior + totalReceitas - totalDespesas
categoriasDespesa → List<CategoriaFinanceira>  // tipo == 'DESPESA'
categoriasReceita → List<CategoriaFinanceira>  // tipo == 'RECEITA'
subcategoriasFiltradas → List<Subcategoria>    // subcats da categoria selecionada no filtro
```

---

## `DespesaReceitaCubit`

Recebe o `DespesaReceitaService` e o `condominioId` no construtor. Inicializa o estado com mês/ano atual.

### Ciclo de vida típico
```
DespesaReceitaCubit() → carregarDados() → emit(success)
```

### Grupos de métodos

#### 1. Carregamento (`carregarDados`)
- Busca contas, categorias, despesas, receitas, transferências e saldo anterior **em paralelo**
- Filtra pelo `mesSelecionado`/`anoSelecionado` atual
- Limpa as seleções ao recarregar

#### 2. Navegação mês/ano
```dart
mesAnterior()  → decrementa mês (com virada de ano) → chama carregarDados()
proximoMes()   → incrementa mês (com virada de ano) → chama carregarDados()
```

#### 3. Filtros e pesquisa
```dart
atualizarFiltros({...})      → atualiza estado dos filtros (não busca ainda)
pesquisarDespesas()          → busca com filtros de despesas aplicados
pesquisarReceitas()          → busca com filtros de receitas aplicados
pesquisarTransferencias()    → busca com filtros de transferências aplicados
```

#### 4. CRUD
Cada entidade tem o mesmo padrão:
```
salvar<X>(model)          → isSaving=true → service.salvar → pesquisar<X>()
excluir<X>sSelecionadas() → loading → service.excluirMultiplos() → pesquisar<X>()
```

#### 5. Seleção por aba
```
toggleDespesaSelecionada(id)       → adiciona/remove do Set
selecionarTodasDespesas(ids)       → toggle all (se todos selecionados → deseleciona tudo)
// Equivalente para Receitas e Transferências
```

#### 6. Modo edição
```
iniciarEdicao<X>(model)   → popula despesaEditando/receitaEditando/transferenciaEditando
cancelarEdicao<X>()       → zera o campo (clearDespesaEditando: true)
```
> Quando `salvar<X>` termina com sucesso, o cubit automaticamente faz `clearDespesaEditando: true`.

#### 7. UI State
```
toggleCadastro()  → inverte cadastroExpandido
limparErro()      → zera errorMessage (chamado após SnackBar)
```

---

## Fluxo de edição (passo a passo)

```
1. Usuário toca em editar um item na tabela
2. Tab Widget chama: cubit.iniciarEdicaoDespesa(despesa)
3. State emite: despesaEditando = despesa
4. Form do card de cadastro pré-preenche os campos (isEditing = true)
5. Usuário salva → cubit.salvarDespesa(novaVersion)
6. Service faz UPDATE (presença do id ≠ null)
7. State emite: despesaEditando = null, recarrega lista
```

---

## ⚠️ Pontos de atenção para desenvolvimento

- O método `copyWith` usa flags booleanas especiais (`clearDespesaEditando`, `clearErrorMessage`, `clearTransferenciaEditando`, `clearReceitaEditando`) porque campos anuláveis não podem ser zerados com `??` convencional.
- `atualizarFiltros` **não dispara busca automaticamente** — é necessário chamar `pesquisar<Entidade>()` depois.
- O estado compartilha um único `cadastroExpandido` — as abas individuais controlam seu estado local de filtro.
