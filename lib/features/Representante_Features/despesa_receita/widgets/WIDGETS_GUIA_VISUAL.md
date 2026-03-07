# 🎨 Widgets — Feature Despesa/Receita

Esta pasta contém todos os widgets visuais da feature. O design segue uma **hierarquia clara**: widgets compartilhados na base, um `BaseTabWidget` genérico no meio, e tabs específicas no topo.

---

## Visão geral da hierarquia

```
despesa_receita_screen.dart
├── DespesasTabWidget       ──────┐
├── ReceitasTabWidget       ──────┤ Usam BaseTabWidget<T>
├── TransferenciaTabWidget  ──────┘
│       └── BaseTabWidget<T>       ── shared_widgets.dart (helpers)
└── ResumoFinanceiroWidget  (fixo no rodapé da tela)
```

---

## `shared_widgets.dart` — Funções e widgets reutilizados

### Constantes globais
```dart
const kPrimaryColor = Color(0xFF0D3B66);   // Azul escuro principal
const kAccentColor  = Color(0xFF1A73E8);   // Azul brilhante para ações
const kMeses = ['Janeiro', ..., 'Dezembro']
const kContasContabeis = ['Controle', 'Fundo Reserva', 'Obras']
```

### `buildMesAnoSelector(state, cubit)`
Widget de navegação de período. Exibe `Mês/Ano` com setas `<` e `>` que chamam `cubit.mesAnterior()` e `cubit.proximoMes()`. Reutilizado identicamente nas 3 abas via `BaseTabWidget`.

### `buildSectionCard({icon, title, isExpanded, onToggle, child, accentColor?})`
Card colapsável com header clicável. Usado para os cards de **Filtros** e **Cadastrar/Editar** em cada aba. Quando `isEditing = true`, o card de cadastro usa `accentColor = Colors.orange.shade700`.

### `buildDropdownField({label, icon, value, items, onChanged})`
`DropdownButtonFormField` padronizado. Verifica automaticamente se o `value` atual existe nos `items` — se não existir, usa `null` (evita crash ao recarregar listas).

### `buildDateField({context, label, value, onChanged, firstDate?, lastDate?})`
Campo de data que abre o `showDatePicker` nativo ao toque. Exibe a data no formato `dd/MM/yyyy`. Tem botão `X` para limpar. Locale `pt_BR`.

### `showConfirmDeleteDialog(context, {quantidade})`
`AlertDialog` de confirmação antes de excluir. Retorna `Future<bool>`. Exibe mensagem singular/plural dependendo da `quantidade`. A exclusão só acontece se o usuário confirmar.

### `buildRecorrenciaSection({recorrente, onRecorrenteChanged, qtdMesesController, showMeAvisar?, meAvisar?, onMeAvisarChanged?})`
Card de recorrência com `Switch` para ativar e campo `qtdMeses` (se `null` = infinito). O parâmetro `showMeAvisar` é exclusivo das Despesas.

---

## `base_tab_widget.dart` — Widget genérico `BaseTabWidget<T>`

Widget **genérico de template** que estrutura o layout completo de uma aba. Elimina duplicação de código entre `DespesasTabWidget`, `ReceitasTabWidget` e `TransferenciaTabWidget`.

### O que ele renderiza (de cima para baixo)
```
1. Seletor Mês/Ano    → via buildMesAnoSelector()
2. Card: Filtros      → via buildSectionCard() + filtrosContent (passado pelo filho)
3. Card: Cadastro     → via buildSectionCard() + cadastroContent (passado pelo filho)
4. Seção: Registros   → tableName + contador, loading/empty state, tabela
5. FAB (+)            → Posicionado no canto inferior direito (some quando cadastro está aberto)
```

### Parâmetros principais
| Parâmetro | Tipo | Descrição |
|---|---|---|
| `items` | `List<T>` | Lista de itens da aba |
| `isLoading` | `bool` | Mostra CircularProgressIndicator |
| `tableHeader` | `Widget` | Header fixo da tabela |
| `itemBuilder` | `Function(context, state, cubit, item, index)` | Builder para cada linha |
| `tableFooterBuilder` | `Function(context, state, cubit)` | Rodapé com totais e ações |
| `filtrosContent` | `Widget` | Conteúdo do card de filtros |
| `cadastroContent` | `Widget` | Conteúdo do card de cadastro |
| `isEditing` | `bool` | Altera ícone/cor do card de cadastro |
| `onFabPressed` | `VoidCallback` | Ação do botão + |

> ⚠️ O `BaseTabWidget` lê o `DespesaReceitaCubit` via `context.read()` para repassar ao `itemBuilder` e `tableFooterBuilder`. Portanto, deve estar abaixo do `BlocProvider` na árvore (garantido pelo `despesa_receita_screen.dart`).

---

## `despesas_tab_widget.dart` — `DespesasTabWidget`

`StatefulWidget` que gerencia o estado **local** do formulário de despesas.

### Estado local (não vai pro Cubit)
| Variável | Descrição |
|---|---|
| `_editandoId` | ID da despesa em edição (null = modo criação) |
| `_contaIdCadastro`, `_categoriaIdCadastro`, `_subcategoriaIdCadastro` | Dropdowns do formulário |
| `_dataVencimento` | Data selecionada via DatePicker |
| `_recorrente`, `_meAvisar` | Toggles de recorrência |
| `_filtroContaId`, `_filtroCategoriaId`, `_filtroSubcategoriaId` | Dropdowns de filtro |
| `_filtrosExpandidos`, `_cadastroExpandido` | Estado de collapse dos cards |

### Fluxo de edição
1. Usuário seleciona **exatamente 1** despesa na tabela → rodapé mostra botão "Editar" ativo
2. Toque em "Editar" → `cubit.iniciarEdicaoDespesa(despesa)` + `_cadastroExpandido = true`
3. No próximo `build`, `state.despesaEditando != null && _editandoId != state.despesaEditando!.id` → `_preencherFormParaEdicao()` via `addPostFrameCallback`
4. Usuário edita e toca "Salvar Alterações" → `_salvar()` → `cubit.salvarDespesa(despesa com id)`
5. Cubit emite `clearDespesaEditando: true` → `_limparFormulario()` é chamado

### Validações ao salvar
- Valor deve ser `> 0`
- Data de vencimento é **obrigatória**

### Tabela de despesas
Colunas: `Checkbox | Descrição (+ conta) | Categoria | Vencimento | Valor | Tipo`
- Valor exibido em **vermelho** (saída)
- Badge "Rec." para recorrentes, "MANUAL"/"AUTOMATICO" para os demais
- Clique na linha faz `toggleDespesaSelecionada`

### Rodapé de ações
- Aparece apenas quando há itens
- "Editar" ativo apenas com **1 selecionado**
- "Excluir" mostra `showConfirmDeleteDialog` antes de executar
- Exibe contador de selecionados e total do valor selecionado

---

## `receitas_tab_widget.dart` — `ReceitasTabWidget`

Estrutura análoga ao `DespesasTabWidget`, mas para receitas.

### Diferenças em relação a `DespesasTabWidget`
| Aspecto | Despesas | Receitas |
|---|---|---|
| Filtros | Conta, Categoria, Subcategoria, Palavra-chave | Conta, Conta Contábil, Tipo |
| Campo data | `dataVencimento` | `dataCredito` |
| Campo extra | `link`, `meAvisar` | `contaContabil` |
| Categoria | Dropdown de categorias | Não tem — usa `contaContabil` |
| Cor do valor | Vermelho | Verde |

### Filtros de receitas
- **Conta**: dropdown de `state.contas`
- **Conta Contábil**: dropdown fixo `['Controle', 'Fundo Reserva', 'Obras']` (`kContasContabeis`)
- **Tipo**: dropdown `['Todos', 'Manual', 'Automático']`

---

## `transferencia_tab_widget.dart` — `TransferenciaTabWidget`

Estrutura análoga, para transferências entre contas.

### Diferenças em relação a `DespesasTabWidget`
| Aspecto | Despesas | Transferências |
|---|---|---|
| Conta no filtro | 1 conta | Conta Débito + Conta Crédito |
| Campo data | `dataVencimento` | `dataTransferencia` |
| Categorias | Sim | Não |
| Valor (cor) | Vermelho | Azul neutro |
| Tabela colunas | Desc, Categ, Venc, Valor, Tipo | Débito, Crédito, Data, Valor, Tipo |

---

## `resumo_financeiro_widget.dart` — `ResumoFinanceiroWidget`

Widget `StatefulWidget` exibido **fixo no rodapé** da tela (abaixo das tabs). Tem seu próprio estado `_expanded` para colapsar.

### O que exibe
| Seção | Fonte |
|---|---|
| Saldo Anterior (mês passado) | `state.saldoAnterior` (calculado pelo Service) |
| Total Receita | `state.totalReceitas` (getter do State) |
| Total Despesa | `state.totalDespesas` (getter do State) |
| Saldo Atual | `state.saldoAtual` = saldoAnterior + receitas - despesas |

Cada seção mostra o total consolidado. Os mapas `saldoAnteriorPorConta`, `totalCreditoPorConta`, etc. estão definidos nos parâmetros mas **não são preenchidos atualmente** (passados como `{}`) — integração por conta está pendente.

---

## ⚠️ Pontos de atenção para desenvolvimento

- **`_preencherFormParaEdicao`** usa `addPostFrameCallback` para evitar chamar `setState` durante o `build`. Não remova esse wrapper.
- **Botão "Editar" só ativa com 1 item selecionado** — selecionar múltiplos desativa o botão (mas mantém o "Excluir" ativo).
- O `BaseTabWidget` **não controla** `_filtrosExpandidos` e `_cadastroExpandido` — esses estados são locais a cada Tab Widget (não vão pro Cubit).
- Para adicionar uma nova aba (ex: "Orçamentos"), basta criar um novo `StatefulWidget` que constrói um `BaseTabWidget<SeuModel>`.
- Os mapas por-conta do `ResumoFinanceiroWidget` estão preparados para receber breakdown por conta bancária — isso é uma **evolução futura** não implementada ainda.
