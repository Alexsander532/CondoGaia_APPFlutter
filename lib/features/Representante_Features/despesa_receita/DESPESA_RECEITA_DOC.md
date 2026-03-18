# 📊 Despesas, Receitas e Transferências — Documentação Funcional

> **Feature:** `despesa_receita`  
> **Módulo:** Representante Features → Gestão de Condomínio  
> **Última atualização:** 2026-03-18

---

## 1. Visão Geral

Este módulo permite ao **Representante do Condomínio** gerenciar toda a movimentação financeira:

| Aba | O que faz |
|-----|-----------|
| **Despesas** | Registra saídas de dinheiro (contas a pagar, manutenção, fornecedores, etc.) |
| **Receitas** | Registra entradas de dinheiro (taxas condominiais, aluguéis, rendimentos, etc.) |
| **Transferências** | Registra movimentações entre contas bancárias do condomínio |

O sistema calcula automaticamente o **Resumo Financeiro** exibido na parte inferior da tela, com Saldo Anterior, Total Receita, Total Despesa e Saldo Atual.

---

## 2. Fluxo do Usuário

```
Representante → Gestão → Despesas/Receitas
                            │
                            ├── Aba Despesas
                            │     ├── Filtros (Conta, Categoria, Subcategoria, Palavra-chave)
                            │     ├── Cadastrar / Editar despesa
                            │     └── Tabela de registros (selecionar, editar, excluir)
                            │
                            ├── Aba Receitas
                            │     ├── Filtros (Conta, Conta Contábil, Tipo)
                            │     ├── Cadastrar / Editar receita
                            │     └── Tabela de registros (selecionar, editar, excluir)
                            │
                            ├── Aba Transferências
                            │     ├── Filtros (Conta Débito, Conta Crédito)
                            │     ├── Cadastrar / Editar transferência
                            │     └── Tabela de registros (selecionar, editar, excluir)
                            │
                            └── Resumo Financeiro (rodapé fixo)
```

---

## 3. Entidades de Dados

### 3.1. Despesa (`despesas`)

| Campo | Tipo | Obrigatório | Descrição |
|-------|------|:-----------:|-----------|
| `id` | UUID | Auto | Identificador único |
| `condominio_id` | UUID | ✅ | FK para condomínio |
| `conta_id` | UUID | - | FK para `contas_bancarias` |
| `categoria_id` | UUID | - | FK para `categorias_financeiras` |
| `subcategoria_id` | UUID | - | FK para `subcategorias_financeiras` |
| `descricao` | String | - | Descrição da despesa |
| `valor` | Double | ✅ | Valor em R$ (deve ser > 0) |
| `data_vencimento` | Date | ✅ | Data de vencimento |
| `recorrente` | Boolean | - | Se é despesa recorrente |
| `qtd_meses` | Integer | - | Qtd de meses da recorrência |
| `me_avisar` | Boolean | - | Marcar para lembrete |
| `link` | String | - | Link externo (boleto, NF) |
| `foto_url` | String | - | URL da foto/anexo (futuro) |
| `tipo` | String | - | "MANUAL" ou "AUTOMATICO" |
| `created_at` | DateTime | Auto | Data de criação |

### 3.2. Receita (`receitas`)

| Campo | Tipo | Obrigatório | Descrição |
|-------|------|:-----------:|-----------|
| `id` | UUID | Auto | Identificador único |
| `condominio_id` | UUID | ✅ | FK para condomínio |
| `conta_id` | UUID | - | FK para `contas_bancarias` |
| `categoria_id` | UUID | - | FK para `categorias_financeiras` |
| `subcategoria_id` | UUID | - | FK para `subcategorias_financeiras` |
| `conta_contabil` | String | - | Classificação contábil (Controle, Fundo Reserva, Obras) |
| `descricao` | String | - | Descrição da receita |
| `valor` | Double | ✅ | Valor em R$ (deve ser > 0) |
| `data_credito` | Date | ✅ | Data do crédito |
| `recorrente` | Boolean | - | Se é receita recorrente |
| `qtd_meses` | Integer | - | Qtd de meses da recorrência |
| `tipo` | String | - | "MANUAL" ou "AUTOMATICO" |
| `created_at` | DateTime | Auto | Data de criação |

### 3.3. Transferência (`transferencias`)

| Campo | Tipo | Obrigatório | Descrição |
|-------|------|:-----------:|-----------|
| `id` | UUID | Auto | Identificador único |
| `condominio_id` | UUID | ✅ | FK para condomínio |
| `conta_debito_id` | UUID | ✅ | FK = conta de origem |
| `conta_credito_id` | UUID | ✅ | FK = conta de destino |
| `descricao` | String | - | Descrição da transferência |
| `valor` | Double | ✅ | Valor em R$ |
| `data_transferencia` | Date | ✅ | Data da transferência |
| `recorrente` | Boolean | - | Se é recorrente |
| `qtd_meses` | Integer | - | Qtd de meses |
| `tipo` | String | - | "MANUAL" ou "AUTOMATICO" |
| `created_at` | DateTime | Auto | Data de criação |

---

## 4. Regras de Negócio

### 4.1. Navegação por Mês/Ano
- Ao entrar na tela, carrega dados do **mês/ano atual**.
- Setas `<` e `>` no seletor permitem navegar entre meses.
- **Cada navegação recarrega** todas as listas (despesas, receitas, transferências) e o saldo anterior.

### 4.2. Despesas
- **Filtros:** Conta Bancária, Categoria (tipo DESPESA), Subcategoria (cascata da categoria), Palavra-chave (busca na descrição).
- **Cadastro:** Conta + Categoria + Subcategoria + Descrição + Valor + Data Vencimento + Recorrência + Link.
- **Validações:** Valor > 0 e Data de Vencimento obrigatória.
- **Edição:** Seleciona 1 registro na tabela → botão "Editar" no rodapé → preenche formulário → "Salvar Alterações".
- **Exclusão:** Seleciona 1 ou mais registros → botão "Excluir" → diálogo de confirmação.
- **Seleção múltipla:** Checkbox individual ou "selecionar todos" no cabeçalho da tabela.

### 4.3. Receitas
- **Filtros:** Conta Bancária, Categoria, Subcategoria, Conta Contábil (Controle / Fundo Reserva / Obras), Tipo (Todos / Manual / Automático), Palavra-chave.
- **Cadastro:** Conta + Categoria + Subcategoria + Conta Contábil + Descrição + Valor + Data Crédito + Recorrência.
- **Validações:** Valor > 0 e Data do Crédito obrigatória.
- **Edição/Exclusão:** Mesmo fluxo das despesas.

### 4.4. Transferências
- **Filtros:** Conta Débito (origem) e Conta Crédito (destino).
- **Cadastro:** Conta Débito + Conta Crédito + Descrição + Valor + Data + Recorrência.
- **Validações:** Valor > 0, Data obrigatória, contas débito ≠ crédito.
- **Edição/Exclusão:** Mesmo fluxo das despesas.

### 4.5. Resumo Financeiro
- **Saldo Anterior:** Calculado automaticamente como (Total Receitas − Total Despesas) do mês anterior.
- **Total Receita:** Soma dos valores de todas as receitas do mês selecionado.
- **Total Despesa:** Soma dos valores de todas as despesas do mês selecionado.
- **Saldo Atual:** Saldo Anterior + Total Receita − Total Despesa.
- Suporta detalhamento **por conta bancária** (preparado mas ainda sem dados populados).

### 4.6. Recorrência
- Checkbox "Recorrente" + campo "Qtd. de Meses".
- Apenas para despesas: opção "Me Avisar" para notificações.
- **TODO (futuro)**: lógica automática de geração de registros recorrentes.

### 4.7. Upload de Comprovantes (Despesas)
- Seleção de imagem via câmera ou galeria (`image_picker`).
- Upload para bucket Supabase `comprovantes_financeiros`.
- Compressão automática (qualidade 70%, max 1200px).
- Visualização no modal de detalhes.

### 4.8. Links Externos (Despesas)
- Campo `link` para armazenar URL de boleto ou nota fiscal.
- No modal de detalhes: botões para copiar link e abrir no navegador.

---

## 5. Arquitetura do Código

```
despesa_receita/
├── models/
│   ├── despesa_model.dart          # Modelo Despesa (Equatable)
│   ├── receita_model.dart          # Modelo Receita (Equatable)
│   ├── transferencia_model.dart    # Modelo Transferencia (Equatable)
│   └── MODELS_ENTIDADES_GUIA.md    # Guia de modelos
├── services/
│   ├── i_despesa_receita_service.dart  # Interface abstrata
│   ├── despesa_receita_service.dart    # Implementação (Supabase)
│   └── SERVICES_ACESSO_DADOS_GUIA.md   # Guia de serviços
├── cubit/
│   ├── despesa_receita_cubit.dart   # Lógica de negócio (BLoC)
│   ├── despesa_receita_state.dart   # Estado imutável (Equatable)
│   └── CUBIT_ESTADO_GUIA.md         # Guia do Cubit
├── screens/
│   ├── despesa_receita_screen.dart  # Tela principal com TabBar
│   └── SCREEN_ENTRADA_GUIA.md       # Guia da tela
└── widgets/
    ├── base_tab_widget.dart         # Widget genérico para as 3 abas
    ├── shared_widgets.dart          # Componentes reutilizáveis (cores, constantes)
    ├── despesas_tab_widget.dart     # Aba de Despesas
    ├── despesa_detail_modal.dart    # Modal de detalhes da despesa
    ├── receitas_tab_widget.dart     # Aba de Receitas
    ├── receita_detail_modal.dart    # Modal de detalhes da receita
    ├── transferencia_tab_widget.dart # Aba de Transferências
    ├── resumo_financeiro_widget.dart # Widget do resumo financeiro
    └── WIDGETS_GUIA_VISUAL.md       # Guia visual dos widgets
```

### 5.1. Padrão de Arquitetura
- **State Management:** BLoC/Cubit com `flutter_bloc`.
- **Models:** Imutáveis com `Equatable`, `fromJson`, `toJson`, `copyWith`.
- **Service:** Abstração via interface, implementação direta com `supabase_flutter`.
- **Queries:** Supabase select com joins inline (ex: `contas_bancarias(banco)`).
- **Storage:** Supabase Storage bucket `comprovantes_financeiros` para upload de fotos.
- **Imagens:** `image_picker` para seleção de câmera/galeria.

### 5.2. Dependências Externas
- `contas_bancarias` — alimenta os dropdowns de conta.
- `categorias_financeiras` + `subcategorias_financeiras` — alimentam os filtros e cadastro de despesas.

---

## 6. Tabelas Supabase Relacionadas

| Tabela | Status | Registros |
|--------|--------|-----------|
| `contas_bancarias` | ✅ Populada | 4 contas |
| `categorias_financeiras` | ✅ Populada | ~20 categorias |
| `subcategorias_financeiras` | ✅ Populada | ~60 subcategorias |
| `despesas` | ✅ Criada | - |
| `receitas` | ✅ Criada | - |
| `transferencias` | ✅ Criada | - |

### 6.1. Supabase Storage
| Bucket | Status | Uso |
|--------|--------|-----|
| `comprovantes_financeiros` | ✅ Criado | Upload de fotos/comprovantes de despesas |

---

## 7. O que Funciona Hoje vs. O que Precisa Ser Feito

### ✅ Já implementado no Flutter:
- Modelos de dados completos (Despesa, Receita, Transferência) com campos de join
- Service com CRUD completo + filtros + cálculo de saldo anterior + upload de fotos
- Cubit com toda a lógica de estado (filtros, seleção, edição, navegação, imagens)
- UI completa com 3 abas (Despesas, Receitas, Transferências)
- Formulários de cadastro e edição
- Tabela com seleção múltipla, editar e excluir
- Componentes compartilhados (dropdowns, date picker, recorrência)
- Resumo financeiro com saldo anterior/atual
- Validações de formulário
- **Modal de detalhes** para despesas com visualização de foto, link e recorrência
- **Modal de detalhes** para receitas com indicador de tipo (Manual/Automático)
- **Upload de comprovantes** para despesas (câmera/galeria)
- **Links externos** para despesas (abrir no navegador, copiar)
- **Indicadores visuais** de tipo MANUAL/AUTOMATICO

### ✅ Backend Supabase:
- Tabelas `despesas`, `receitas`, `transferencias` criadas
- Bucket `comprovantes_financeiros` criado
- RLS configurado

### ⚠️ Pendente para funcionar 100%:
1. **Testar CRUD** end-to-end (criar, ler, editar, excluir)
2. **Verificar queries com join** (contas_bancarias, categorias, subcategorias)
3. **Popular dados de teste** para validar a listagem e filtros
4. **(Futuro)** Implementar lógica de recorrência automática
5. **(Futuro)** Implementar resumo detalhado por conta bancária
6. **(Futuro)** Implementar notificações "Me Avisar" para despesas recorrentes
7. **(Futuro)** Upload de comprovantes para receitas
