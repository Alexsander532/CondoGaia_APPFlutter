# 📋 PLANO: Sistema de Criação de Unidades Manualmente

## 🎯 Visão Geral

Implementar um fluxo completo para **criar unidades manualmente** no app, com um modal de pré-configuração que simplifica o processo.

### Ideias Aprovadas ✅
- Modal antes de ir para a tela de detalhes (UX mais limpo)
- Seleção/criação de bloco no modal
- Bloco padrão "A" quando não existir
- Redirecionamento automático para `DetalhesUnidadeScreen`
- Unidade criada vazia (preenchida manualmente no formulário)

---

## 📊 Arquitetura da Solução

### Fluxo Visual

```
┌─────────────────────────────────────────────────┐
│    UnidadeMoradorScreen                         │
│  (Com/Sem unidades carregadas)                  │
│                                                 │
│  ┌─────────────────────────────────────────┐   │
│  │ [+ ADICIONAR UNIDADE]                   │   │
│  │ (Botão flutuante ou no final da lista)  │   │
│  └─────────────────────────────────────────┘   │
└──────────────┬──────────────────────────────────┘
               │ Clica
               ↓
┌─────────────────────────────────────────────────┐
│    MODAL: Criar Nova Unidade                    │
│  ┌─────────────────────────────────────────┐   │
│  │ Campo: Número da Unidade               │   │
│  │ [    101    ] ← obrigatório             │   │
│  │                                         │   │
│  │ Selecione o Bloco:                      │   │
│  │ (Se não houver, será criado "A")        │   │
│  │ ┌─────────────────────────────────────┐ │   │
│  │ │ Dropdown: [Bloco ▼]                 │ │   │
│  │ │ ├ A                                  │ │   │
│  │ │ ├ B                                  │ │   │
│  │ │ ├ C                                  │ │   │
│  │ │ └ + CRIAR NOVO BLOCO               │ │   │
│  │ └─────────────────────────────────────┘ │   │
│  │                                         │   │
│  │ [CANCELAR]  [PRÓXIMO]                  │   │
│  └─────────────────────────────────────────┘   │
└──────────────┬──────────────────────────────────┘
               │ Clica "Próximo"
               ↓
┌─────────────────────────────────────────────────┐
│  MODAL 2 (Opcional): Criar Novo Bloco          │
│  (Se selecionou "+ CRIAR NOVO BLOCO")          │
│  ┌─────────────────────────────────────────┐   │
│  │ Nome do Bloco:                          │   │
│  │ [__________________]                    │   │
│  │                                         │   │
│  │ [CANCELAR]  [CRIAR]                    │   │
│  └─────────────────────────────────────────┘   │
└──────────────┬──────────────────────────────────┘
               │ Bloco criado
               ↓
┌─────────────────────────────────────────────────┐
│  DetalhesUnidadeScreen                          │
│  (Nova unidade criada vazia)                    │
│                                                 │
│  Bloco A / Unidade 101                          │
│  ┌─────────────────────────────────────────┐   │
│  │ [📦 UNIDADE ▼]                          │   │
│  │ - Preencher dados da unidade             │   │
│  │ - [SALVAR UNIDADE]                      │   │
│  │                                         │   │
│  │ [👤 PROPRIETÁRIO ▼]                    │   │
│  │ - Preencher ou deixar vazio              │   │
│  │ - [SALVAR PROPRIETÁRIO] (opcional)      │   │
│  │                                         │   │
│  │ [🏠 INQUILINO ▼]                       │   │
│  │ - Preencher ou deixar vazio              │   │
│  │ - [SALVAR INQUILINO] (opcional)         │   │
│  │                                         │   │
│  │ [🏢 IMOBILIÁRIA ▼]                     │   │
│  │ - Preencher ou deixar vazio              │   │
│  │ - [SALVAR IMOBILIÁRIA] (opcional)       │   │
│  └─────────────────────────────────────────┘   │
└─────────────────────────────────────────────────┘
```

---

## 🏗️ Componentes a Criar

### 1. **Modal de Criação de Unidade**
- **Arquivo**: `lib/widgets/modal_criar_unidade_widget.dart` ✨ NOVO
- **Responsabilidade**: 
  - Campo de texto para número da unidade
  - Dropdown para selecionar bloco existente
  - Opção para criar novo bloco inline
  - Validação de entrada
  - Retorna dados ao fechar (número + bloco)

### 2. **Modal de Criação de Bloco**
- **Arquivo**: `lib/widgets/modal_criar_bloco_widget.dart` ✨ NOVO
- **Responsabilidade**: 
  - Campo de texto para nome do bloco
  - Validação (não permitir duplicatas)
  - Criar bloco no banco antes de fechar
  - Retorna o novo bloco criado

### 3. **Serviço de Criação Rápida**
- **Arquivo**: Estender `lib/services/unidade_service.dart` 🔄 MODIFICAR
- **Método novo**: `Future<Unidade> criarUnidadeRapida(String condominioId, String numero, String blocoNome)`
  - Verifica se bloco existe
  - Se não existir, cria bloco "A" por padrão
  - Cria a unidade
  - Retorna a unidade criada

### 4. **Botão Adicionar Unidade**
- **Arquivo**: `lib/screens/unidade_morador_screen.dart` 🔄 MODIFICAR
- **Onde**: 
  - Sempre visível (acima da lista quando tem unidades, como CTA quando não tem)
  - Botão flutuante ou botão normal
  - Ícone: `Icons.add_circle_outline`
  - Cor: Azul (#4A90E2)
- **Ação**: Abre `ModalCriarUnidadeWidget`

### 5. **Integração com DetalhesUnidadeScreen**
- **Arquivo**: `lib/screens/detalhes_unidade_screen.dart` 🔄 MODIFICAR
- **Mudanças**:
  - Adicionar modo "CRIAÇÃO" (vs "EDIÇÃO")
  - Em modo criação, não carregar dados do banco
  - Inicializar com valores vazios/padrão
  - Número e bloco preenchidos do modal
  - Botão "Salvar Unidade" obrigatório antes de continuar

---

## 🔄 Fluxo de Dados

```
┌────────────────────────────────────────────┐
│   UnidadeMoradorScreen                     │
│   (condominioId, condominioNome, ...)      │
└──────────────┬─────────────────────────────┘
               │
               ├─→ [Botão "Adicionar Unidade"] ─┐
               │                                 │
               │                          ┌──────↓──────┐
               │                          │ Abre Modal  │
               │                          │ Criação     │
               │                          └──────┬──────┘
               │                                 │
               │                    ┌────────────↓────────────┐
               │                    │ ModalCriarUnidade       │
               │                    │ - Campo número          │
               │                    │ - Dropdown blocos       │
               │                    │ - Opção novo bloco      │
               │                    └────────────┬────────────┘
               │                                 │
               │            ┌────────────────────┴────────────────────┐
               │            │                                         │
               │    ┌───────↓────────┐                     ┌──────────↓────────┐
               │    │ Bloco Existente│                     │ Novo Bloco        │
               │    │ Selecionado    │                     │ ("+Criar")        │
               │    └───────┬────────┘                     └──────────┬────────┘
               │            │                                        │
               │            │                            ┌───────────↓────────────┐
               │            │                            │ Abre Modal Criar Bloco│
               │            │                            │ (nome do novo bloco)   │
               │            │                            └───────────┬────────────┘
               │            │                                        │
               │            │                            ┌───────────↓────────────┐
               │            │                            │ criarBloco()           │
               │            │                            │ (UnidadeService)       │
               │            │                            └───────────┬────────────┘
               │            │                                        │
               │            └────────────────────┬───────────────────┘
               │                                 │
               │                    ┌────────────↓─────────────┐
               │                    │ Modal fecha com:         │
               │                    │ - numero (ex: "101")     │
               │                    │ - bloco (ex: "A")        │
               │                    │ - blocoId (UUID)         │
               │                    └────────────┬─────────────┘
               │                                 │
               │            ┌────────────────────↓──────────────────┐
               │            │ criarUnidadeRapida()                 │
               │            │ (UnidadeService)                     │
               │            │ Parâmetros:                          │
               │            │ - condominioId                       │
               │            │ - numero                             │
               │            │ - blocoNome ou blocoId               │
               │            └────────────┬───────────────────────────┘
               │                         │
               │            ┌────────────↓──────────────────┐
               │            │ Unidade criada no banco        │
               │            │ Retorna: Unidade              │
               │            └────────────┬──────────────────┘
               │                         │
               └─→ Navigator.push() ─────→ DetalhesUnidadeScreen
                    + modo: 'criar'
                    + unidade: Unidade
                    + condominioId
                    + condominioNome
                    + condominioCnpj
```

---

## 📝 Detalhes de Implementação

### A. Modal de Criação de Unidade

**Arquivo**: `lib/widgets/modal_criar_unidade_widget.dart`

```dart
class ModalCriarUnidadeWidget extends StatefulWidget {
  final String condominioId;
  final List<BlocoComUnidades> blocosExistentes;
  
  const ModalCriarUnidadeWidget({
    required this.condominioId,
    required this.blocosExistentes,
  });

  // Retorna Map com:
  // - numero: String
  // - blocoNome: String
  // - blocoId: String? (null se novo)
}
```

**Funcionalidades**:
- Campo com máscara para número (até 10 caracteres)
- Dropdown que lista blocos existentes
- Opção "+ CRIAR NOVO BLOCO" abre modal secundário
- Validação: número não pode estar vazio
- Validação: número não pode estar duplicado (verificar no banco)
- Retorna ao Modal pai quando fecha

### B. Modal de Criação de Bloco

**Arquivo**: `lib/widgets/modal_criar_bloco_widget.dart`

```dart
class ModalCriarBlocoWidget extends StatefulWidget {
  final String condominioId;
  
  const ModalCriarBlocoWidget({
    required this.condominioId,
  });

  // Retorna Bloco criado
}
```

**Funcionalidades**:
- Campo de texto para nome do bloco
- Validação: não permitir nomes duplicados
- Cria no banco e retorna o objeto
- Padrão: se lista de blocos está vazia, sugerir "A"

### C. Serviço de Criação Rápida

**Arquivo**: `lib/services/unidade_service.dart` (estender)

```dart
Future<Unidade> criarUnidadeRapida({
  required String condominioId,
  required String numero,
  required String blocoNomeOuId,
}) async {
  // 1. Verificar se o bloco existe
  //    - Se é UUID, buscar direto
  //    - Se é nome, procurar por nome
  //    - Se não encontrar, criar novo bloco
  
  // 2. Validar se número já existe neste condomínio
  
  // 3. Criar Unidade com valores padrão:
  //    {
  //      numero: numero,
  //      condominio_id: condominioId,
  //      bloco: blocoNome,
  //      fracao_ideal: null,
  //      area_m2: null,
  //      tipo_unidade: 'A',
  //      isencao_nenhum: true,
  //      ativo: true,
  //      ...
  //    }
  
  // 4. Retornar Unidade criada
}
```

### D. Botão Adicionar Unidade

**Arquivo**: `lib/screens/unidade_morador_screen.dart` (modificar)

**Opção 1 - Botão no Topo** (quando há unidades):
```
┌─────────────────────────────────┐
│ [🔍 Buscar...]                  │
│ [➕ ADICIONAR UNIDADE]           │ ← Novo
├─────────────────────────────────┤
│ Bloco A         [3/3]           │
│ [101] [102] [103]               │
├─────────────────────────────────┤
│ Bloco B         [2/4]           │
│ [201] [202]                     │
└─────────────────────────────────┘
```

**Opção 2 - CTA Grande** (quando não há unidades):
```
┌─────────────────────────────────┐
│     🏢 Gestão de Unidades       │
│                                 │
│  Clique abaixo para criar        │
│  sua primeira unidade            │
│                                 │
│  [➕ ADICIONAR UNIDADE]         │
└─────────────────────────────────┘
```

### E. Integração DetalhesUnidadeScreen

**Mudanças necessárias**:

1. **Adicionar parâmetro constructor**:
```dart
class DetalhesUnidadeScreen extends StatefulWidget {
  // ... parametros existentes ...
  final String? modo; // 'criar' ou 'editar' (padrão)
  
  const DetalhesUnidadeScreen({
    // ...
    this.modo = 'editar',
  });
}
```

2. **No initState(), verificar modo**:
```dart
@override
void initState() {
  super.initState();
  if (widget.modo == 'criar') {
    // NÃO carregar do banco
    // Preencher apenas número e bloco
    _inicializarParaCriacao();
  } else {
    // Comportamento normal
    _carregarDados();
  }
}

void _inicializarParaCriacao() {
  _unidadeController.text = widget.unidade;
  _blocoController.text = widget.bloco;
  // Deixar resto vazio
}
```

3. **Botão Salvar obrigatório**:
- Em modo criação, usuário DEVE salvar a unidade antes de fechar
- Ou mostrar diálogo: "Salvar unidade antes de continuar?"

---

## ✅ Checklist de Implementação

### Fase 1: Widgets
- [ ] Criar `ModalCriarUnidadeWidget`
  - [ ] Campo de número
  - [ ] Dropdown de blocos
  - [ ] Opção novo bloco
  - [ ] Validação
  - [ ] Callback/return

- [ ] Criar `ModalCriarBlocoWidget`
  - [ ] Campo de nome
  - [ ] Validação duplicatas
  - [ ] Criação no banco
  - [ ] Callback/return

### Fase 2: Service
- [ ] Adicionar `criarUnidadeRapida()` em UnidadeService
- [ ] Lógica de criação ou seleção de bloco
- [ ] Validação de número duplicado

### Fase 3: Screen
- [ ] Adicionar botão "Adicionar Unidade" em UnidadeMoradorScreen
- [ ] Abrir modal ao clicar
- [ ] Receber dados do modal
- [ ] Chamar service para criar unidade
- [ ] Navegar para DetalhesUnidadeScreen

### Fase 4: DetalhesUnidadeScreen
- [ ] Adicionar parâmetro `modo`
- [ ] Lógica diferente para 'criar' vs 'editar'
- [ ] Inicializar corretamente em modo criação
- [ ] Avisar antes de fechar se não salvou

### Fase 5: Testes
- [ ] Criar unidade do zero
- [ ] Selecionar bloco existente
- [ ] Criar novo bloco
- [ ] Validação de duplicatas
- [ ] Preenchimento de dados
- [ ] Salvamento correto

---

## 🎨 UX Considerations

### Por que Modal primeiro?
✅ Clareza: Usuário vê logo o que precisa (número + bloco)
✅ Simpleza: Não pula para formulário vazio confuso
✅ Validação: Já verifica duplicatas antes de criar unidade
✅ Consistência: Segue padrão de criação em wizard/steps

### Por que Bloco "A" padrão?
✅ Comum em real estate (Bloco A é o primeiro)
✅ Reduz decisões se não tem blocos
✅ Usuário pode mudar depois se necessário

### Por que Não Salvar Automático?
✅ Mais seguro: Usuário vê dados antes de confirmar
✅ Flexível: Pode adicionar informações adicionais
✅ Controle: Usuário decide quando persiste

---

## 🔗 Como Se Encaixa no App

```
GestaoScreen
    ↓
UnidadeMoradorScreen (Gestor de unidades)
    ├─ Listar unidades existentes
    ├─ [Botão Adicionar] ← NOVO
    │   ├─ Modal criação
    │   ├─ Modal bloco (se necessário)
    │   └─ UnidadeService.criarUnidadeRapida()
    │
    └─ Clicar em unidade
        ↓
        DetalhesUnidadeScreen
            ├─ Modo 'editar' (agora existente)
            └─ Modo 'criar' (NEW - nova unidade)
                ├─ Salvar Unidade (obrigatório)
                ├─ Preencher Proprietário (opcional)
                ├─ Preencher Inquilino (opcional)
                └─ Preencher Imobiliária (opcional)
```

---

## 💡 Diferenciais da Solução

✅ **Modal + Screen**: Dois passos claros (seleção + preenchimento)
✅ **Bloco Automático**: "A" padrão quando não existe
✅ **Validação Real**: Verifica duplicatas no banco
✅ **Modo Flexível**: DetalhesUnidadeScreen serve para criar e editar
✅ **UX Clara**: Usuário sempre sabe onde está no processo
✅ **Sem Breaking Changes**: Código existente continua funcionando

---

## 📌 Questionamentos Resolvidos

**P: Por que não criar tudo em um único formulário?**
R: Modal simplifica e valida antes. Formulário completo ficaria overwhelmed.

**P: Bloco é obrigatório?**
R: Sim, toda unidade precisa estar em um bloco. Padrão "A" resolve.

**P: E se quiser editar bloco depois?**
R: Em DetalhesUnidadeScreen, campo de bloco está editable (já existe).

**P: Quando o usuário volta em UnidadeMoradorScreen?**
R: Após clicar "Voltar" em DetalhesUnidadeScreen. Lista se atualiza com nova unidade.

---

**Status do Plano**: ✅ APROVADO PARA IMPLEMENTAÇÃO
**Próximo Passo**: Aguardando aprovação para começar Fase 1 (Widgets)
