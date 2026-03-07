# 📱 Screen — Feature Despesa/Receita

Esta pasta contém o **ponto de entrada** da feature: a tela principal que monta o scaffold, provê o Cubit e orquestra as tabs.

---

## Arquivo

| Arquivo | Responsabilidade |
|---|---|
| `despesa_receita_screen.dart` | Ponto de entrada. Monta AppBar, TabBar, TabBarView e Resumo |

---

## Estrutura da tela

```
DespesaReceitaScreen (StatelessWidget)
└── BlocProvider<DespesaReceitaCubit>     ← cria e injeta o Cubit
    └── _DespesaReceitaView (StatefulWidget)
        ├── TabController (3 tabs)
        └── Scaffold
            ├── AppBar
            │   ├── Logo CondoGaia
            │   ├── Ícones: Notificação, Fone de Ouvido
            │   └── Bottom:
            │       ├── Breadcrumb: "Home/Gestão/Despesas-Receitas"
            │       └── TabBar: Despesas | Receitas | Transferência
            └── Body: BlocConsumer
                ├── listener → exibe SnackBar de erro + limparErro()
                ├── builder: status == initial → CircularProgressIndicator
                └── Column
                    ├── Expanded
                    │   └── TabBarView
                    │       ├── DespesasTabWidget()
                    │       ├── ReceitasTabWidget()
                    │       └── TransferenciaTabWidget()
                    └── ResumoFinanceiroWidget (fixo no rodapé)
```

---

## Como o Cubit é criado

```dart
DespesaReceitaScreen({ required String condominioId })

BlocProvider(
  create: (context) => DespesaReceitaCubit(
    service: DespesaReceitaService(),
    condominioId: condominioId,
  )..carregarDados(),   // ← já dispara o carregamento inicial
  child: const _DespesaReceitaView(),
)
```

> O `condominioId` é passado por quem navega para esta tela (rota da gestão do condomínio).

---

## Ciclo de vida inicial

```
1. Tela abre → BlocProvider cria o Cubit
2. ..carregarDados() é chamado imediatamente
3. status = loading → body mostra CircularProgressIndicator
4. Cubit busca: contas, categorias, despesas, receitas, transferências, saldoAnterior
5. status = success → UI renderiza as tabs com os dados
```

---

## Tratamento de erros globais

O `BlocConsumer.listener` observa `state.errorMessage`:
```dart
if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(state.errorMessage!), backgroundColor: Colors.red),
  );
  context.read<DespesaReceitaCubit>().limparErro();
}
```
Erros de qualquer aba aparecem no SnackBar vermelho no rodapé da tela.

---

## `ResumoFinanceiroWidget` no rodapé

Recebe os valores diretamente do `state` computado:
```dart
ResumoFinanceiroWidget(
  saldoAnterior: state.saldoAnterior,   // calculado pelo Service (mês anterior)
  totalCredito:  state.totalReceitas,   // getter: soma de receitas[].valor
  totalDebito:   state.totalDespesas,   // getter: soma de despesas[].valor
  saldoAtual:    state.saldoAtual,      // saldoAnterior + receitas - despesas
)
```
> Os mapas por-conta não são passados aqui — implementação futura.

---

## AppBar

| Elemento | Comportamento atual |
|---|---|
| Ícone `menu` (hambúrguer) | `onPressed: () {}` — não implementado |
| Logo CondoGaia | Asset fixo `assets/images/logo_CondoGaia.png` |
| Ícone Sino (notificação) | `onPressed: () {}` — não implementado |
| Ícone Fone de Ouvido | `onPressed: () {}` — não implementado |
| Botão voltar (breadcrumb) | `Navigator.pop(context)` |

---

## TabController

Criado com **3 tabs** fixas. A mudança de aba não dispara nenhuma ação no Cubit — os dados já estão carregados no estado quando o usuário muda de aba. A filtragem é feita por tab individualmente ao clicar em "Pesquisar".

---

## ⚠️ Pontos de atenção para desenvolvimento

- O botão hambúrguer e os ícones de notificação/suporte estão com `() {}` — precisam ser conectados ao drawer/navegação.
- Para navegar até esta tela, é necessário passar o `condominioId`:
  ```dart
  Navigator.push(context, MaterialPageRoute(
    builder: (_) => DespesaReceitaScreen(condominioId: 'uuid-do-condominio'),
  ));
  ```
- O `ResumoFinanceiroWidget` fica **fora** do `Expanded`/`TabBarView` — isso é intencional para ser sempre visível, independente da aba ativa.
- Se precisar adicionar uma 4ª tab, atualize o `TabController(length: 4)` e adicione o widget no `TabBarView`.
