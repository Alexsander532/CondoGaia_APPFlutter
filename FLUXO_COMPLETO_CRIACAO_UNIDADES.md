# 🎬 FLUXO COMPLETO DE EXECUÇÃO - Sistema de Criação de Unidades

## 📊 VISÃO GERAL DO FLUXO

```
┌─────────────────────────────────────────────────────────────┐
│                   USUÁRIO CLICA NO BOTÃO                    │
│              "+ ADICIONAR UNIDADE"                          │
│         (em UnidadeMoradorScreen)                           │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ↓
┌─────────────────────────────────────────────────────────────┐
│         ModalCriarUnidadeWidget ABRE                        │
│    (ModalCriarUnidadeWidget._inicializarBlocos())           │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ↓
            ┌────────┴────────┐
            │                 │
    (Blocos existem)    (Sem blocos)
            │                 │
            ↓                 ↓
      Carrega lista      Cria bloco "A"
      de blocos          por padrão
         do DB              
```

---

## 🔍 PASSO 1: ModalCriarUnidadeWidget ABRE

### O que acontece no `initState()`:

```dart
@override
void initState() {
  super.initState();
  _inicializarBlocos();  // ← Executado automaticamente
}
```

### Dentro de `_inicializarBlocos()`:

```
┌─────────────────────────────────────────────────────────────┐
│ _inicializarBlocos()                                        │
│                                                             │
│ 1. Recebe lista de BlocoComUnidades do parent widget       │
│    (blocosExistentes)                                       │
│    └─ Cada item tem: {bloco: Bloco, unidades: List}        │
│                                                             │
│ 2. Extrai APENAS os blocos únicos                          │
│    final blocos = <String, Bloco>{};                       │
│    for (var blocoComUn in widget.blocosExistentes) {       │
│      blocos[blocoComUn.bloco.id] = blocoComUn.bloco;       │
│    }                                                        │
│    └─ Usa Map para evitar duplicatas (id como chave)      │
│                                                             │
│ 3. Converte Map em List                                    │
│    _blocos = blocos.values.toList();                       │
│    └─ Resultado: [BlocoA, BlocoB, BlocoC, ...]            │
│                                                             │
│ 4. SE lista vazia (nenhum bloco existe)                    │
│    if (_blocos.isEmpty) {                                  │
│      _blocos = [Bloco.novo(...)]  ← Cria bloco "A"         │
│    }                                                        │
│    └─ Padrão sensato para novos condomínios               │
│                                                             │
│ 5. Seleciona PRIMEIRO bloco como padrão                    │
│    _blocoselecionado = _blocos.first;                      │
│    └─ Sempre há algo selecionado                          │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Estado após inicialização:

```
_blocos = [Bloco A, Bloco B, Bloco C]
_blocoselecionado = Bloco A (primeiro)
_numeroController.text = "" (vazio)
_isLoading = false
_errorMessage = null
```

### UI que aparece para o usuário:

```
┌────────────────────────────────────┐
│   Criar Nova Unidade               │
│                                    │
│ Número da Unidade *                │
│ ┌────────────────────────────────┐ │
│ │ [_____________________]        │ │ ← Campo vazio
│ │ Ex: 101, 102, 201, 301        │ │
│ └────────────────────────────────┘ │
│                                    │
│ Selecione ou crie um Bloco *       │
│ ┌────────────────────────────────┐ │
│ │ ▼ A                            │ │ ← Dropdown com A
│ │ ├─ A (selecionado)             │ │    pré-selecionado
│ │ ├─ B                           │ │
│ │ ├─ C                           │ │
│ │ └─ + Criar Novo Bloco          │ │
│ └────────────────────────────────┘ │
│                                    │
│ [+ Criar Novo Bloco]               │ ← Botão alternativo
│                                    │
│ [CANCELAR]  [PRÓXIMO]              │
└────────────────────────────────────┘
```

---

## 👤 PASSO 2A: USUÁRIO PREENCHE NÚMERO DA UNIDADE

### User digita "101":

```
_numeroController.text = "101"
```

### UI muda dinamicamente:

```
┌────────────────────────────────────┐
│   Criar Nova Unidade               │
│                                    │
│ Número da Unidade *                │
│ ┌────────────────────────────────┐ │
│ │ 101                            │ │ ← Campo preenchido
│ └────────────────────────────────┘ │
```

---

## 🏢 PASSO 2B: USUÁRIO SELECIONA BLOCO

### Cenário 1: Seleciona bloco existente (ex: "B")

```dart
onChanged: (bloco) {
  if (bloco != null) {
    setState(() {
      _blocoselecionado = bloco;  // ← Bloco B selecionado
      _errorMessage = null;       // ← Limpa erros anteriores
    });
  }
}
```

**Estado:**
- `_blocoselecionado = Bloco B`
- Dropdown fecha
- UI atualiza

### Cenário 2: Clica "+ Criar Novo Bloco"

```
Usuário clica em "+ Criar Novo Bloco"
        ↓
_abrirModalCriarBloco() é executado
        ↓
showDialog() abre ModalCriarBlocoWidget
```

---

## 🔧 PASSO 3: ModalCriarBlocoWidget (MODAL ANINHADO)

### Quando ModalCriarBloco é aberto:

```dart
Future<void> _abrirModalCriarBloco() async {
  final novoBloco = await showDialog<Bloco>(
    context: context,
    builder: (context) => ModalCriarBlocoWidget(
      condominioId: widget.condominioId,
    ),
  );
  // Aguarda até modal fechar e retornar algo
  
  if (novoBloco != null && mounted) {
    setState(() {
      _blocos.add(novoBloco);           // ← Adiciona novo bloco
      _blocoselecionado = novoBloco;    // ← Seleciona o novo
    });
  }
}
```

### UI do ModalCriarBloco:

```
┌────────────────────────────────────┐
│   Criar Novo Bloco                 │
│                                    │
│ Nome do Bloco                      │
│ ┌────────────────────────────────┐ │
│ │ [_____________________]        │ │ ← Campo vazio
│ │ Ex: A, B, C, Bloco Principal  │ │
│ └────────────────────────────────┘ │
│                                    │
│ [CANCELAR]  [CRIAR]                │
└────────────────────────────────────┘
```

### User digita "D" e clica CRIAR:

```dart
Future<void> _criarBloco() async {
  final nome = _nomeController.text.trim();  // "D"
  
  // 1. VALIDA
  if (nome.isEmpty) {
    // Mostra erro (não vai acontecer, tem "D")
  }
  
  // 2. PREPARA
  setState(() {
    _isLoading = true;        // ← Spinner aparece
    _errorMessage = null;
  });
  
  // 3. CRIA no banco
  try {
    final novoBloco = Bloco.novo(
      condominioId: widget.condominioId,
      nome: "D",
      codigo: "D",  // ← Transforma em maiúscula
      ordem: 0,
    );
    
    final blocoRetorno = 
      await _unidadeService.criarBloco(novoBloco);
    // ← Chama Supabase para INSERIR na tabela blocos
    
    // 4. RETORNA ao modal pai
    if (mounted) {
      Navigator.of(context).pop(blocoRetorno);
      // ← Fecha modal, retorna blocoRetorno
    }
  }
}
```

### O que acontece no Supabase:

```sql
INSERT INTO blocos (
  condominio_id,
  nome,
  codigo,
  ordem,
  ativo,
  created_at,
  updated_at
) VALUES (
  "cond-123",
  "D",
  "D",
  0,
  true,
  2025-11-20 10:30:45,
  2025-11-20 10:30:45
);

-- Retorna: Bloco {
--   id: "bloco-uuid-gerado",
--   condominioId: "cond-123",
--   nome: "D",
--   codigo: "D",
--   ordem: 0,
--   ativo: true,
--   createdAt: 2025-11-20 10:30:45,
--   updatedAt: 2025-11-20 10:30:45
-- }
```

### De volta para ModalCriarUnidade:

```dart
if (novoBloco != null && mounted) {
  setState(() {
    _blocos.add(novoBloco);        // ← Bloco D adicionado
    _blocoselecionado = novoBloco; // ← Bloco D selecionado
  });
}
```

**Nova UI:**

```
┌────────────────────────────────────┐
│   Criar Nova Unidade               │
│                                    │
│ Número da Unidade *                │
│ ┌────────────────────────────────┐ │
│ │ 101                            │ │
│ └────────────────────────────────┘ │
│                                    │
│ Selecione o Bloco *                │
│ ┌────────────────────────────────┐ │
│ │ ▼ D                            │ │ ← Bloco D agora selecionado!
│ │ ├─ A                           │ │
│ │ ├─ B                           │ │
│ │ ├─ C                           │ │
│ │ ├─ D ← NOVO!                   │ │
│ │ └─ + Criar Novo Bloco          │ │
│ └────────────────────────────────┘ │
```

---

## ✅ PASSO 4: USER CLICA "PRÓXIMO"

### Executa `_validarECriarUnidade()`:

```dart
Future<void> _validarECriarUnidade() async {
  final numero = _numeroController.text.trim();  // "101"
  
  // VALIDAÇÃO 1: Número não vazio?
  if (numero.isEmpty) {
    setState(() {
      _errorMessage = 'Número da unidade é obrigatório';
    });
    return;  // ← Não continua
  }
  // ✅ Passou (numero = "101")
  
  // VALIDAÇÃO 2: Bloco selecionado?
  if (_blocoselecionado == null) {
    setState(() {
      _errorMessage = 'Selecione um bloco';
    });
    return;  // ← Não continua
  }
  // ✅ Passou (bloco = D)
  
  // VALIDAÇÃO 3: Número não duplicado?
  final unidadesNoBloco = widget.blocosExistentes
    .firstWhere(
      (b) => b.bloco.id == _blocoselecionado!.id,
      // ← Procura bloco com mesmo ID
      orElse: () => BlocoComUnidades(
        bloco: _blocoselecionado!, 
        unidades: []
      ),
    )
    .unidades;
  
  final jaExiste = 
    unidadesNoBloco.any((u) => u.numero == numero);
    // ← Verifica se "101" já existe no Bloco D
  
  if (jaExiste) {
    setState(() {
      _errorMessage = 
        'Já existe uma unidade com número 101 no bloco D';
    });
    return;  // ← Não continua
  }
  // ✅ Passou (número 101 é único no bloco D)
  
  // TODAS VALIDAÇÕES PASSARAM! ✅
  
  setState(() {
    _isLoading = true;    // ← Spinner aparece
    _errorMessage = null; // ← Limpa mensagens
  });
  
  try {
    // RETORNAR os dados para modal PAI
    if (mounted) {
      Navigator.of(context).pop({
        'numero': '101',
        'bloco': _blocoselecionado!,  // Bloco D
      });
    }
  } catch (e) {
    setState(() {
      _errorMessage = 'Erro: $e';
      _isLoading = false;
    });
  }
}
```

### Fluxo de Validação Visual:

```
┌──────────────────────────────┐
│ Número vazio?                │
│ "101" → NÃO ✅              │
└──────────────────────────────┘
         ↓
┌──────────────────────────────┐
│ Bloco selecionado?           │
│ D → SIM ✅                   │
└──────────────────────────────┘
         ↓
┌──────────────────────────────┐
│ Número duplicado em D?       │
│ "101" → NÃO ✅              │
└──────────────────────────────┘
         ↓
┌──────────────────────────────┐
│ TUDO OK! ✅                  │
│ Fechar modal com dados       │
└──────────────────────────────┘
```

---

## 🔄 PASSO 5: VOLTANDO PARA UnidadeMoradorScreen

### ModalCriarUnidade fecha e retorna:

```dart
// Em UnidadeMoradorScreen._processarCriacaoUnidade()

final resultado = await showDialog<Map<String, dynamic>>(
  context: context,
  builder: (context) => ModalCriarUnidadeWidget(...),
);
// ← Aguarda modal fechar

if (resultado != null && mounted) {
  _processarCriacaoUnidade(resultado);
  // ← Modal retornou dados
}
```

### `resultado` contém:

```dart
{
  'numero': '101',
  'bloco': Bloco(
    id: 'bloco-uuid-d',
    condominioId: 'cond-123',
    nome: 'D',
    codigo: 'D',
    ordem: 0,
    ativo: true,
    createdAt: 2025-11-20 10:30:45,
    updatedAt: 2025-11-20 10:30:45,
  )
}
```

---

## 🚀 PASSO 6: CRIAR UNIDADE NO BANCO

### Em `_processarCriacaoUnidade()`:

```dart
Future<void> _processarCriacaoUnidade(Map<String, dynamic> dados) async {
  try {
    final numero = dados['numero'] as String;        // "101"
    final bloco = dados['bloco'] as Bloco;           // Bloco D
    
    // Mostra loading
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 12),
            Text('Criando unidade...'),
          ],
        ),
      ),
    );
    
    // CRIA UNIDADE no banco
    final _ = await _unidadeService.criarUnidadeRapida(
      condominioId: widget.condominioId!,
      numero: numero,        // "101"
      bloco: bloco,          // Bloco D (já existe no banco)
    );
    // ← Chama Supabase para INSERIR unidade
```

### O que `criarUnidadeRapida()` faz:

```dart
Future<Unidade> criarUnidadeRapida({
  required String condominioId,
  required String numero,
  required Bloco bloco,
}) async {
  try {
    // 1. VERIFICA se bloco tem ID
    late final Bloco blocoCriado;
    
    if (bloco.id.isEmpty) {
      // ID vazio = bloco novo, cria primeiro
      blocoCriado = await criarBloco(bloco);
    } else {
      // ID não vazio = bloco já existe, usa direto
      blocoCriado = bloco;  // ← Nossa situação
    }
    
    // 2. CRIA Unidade com tipo padrão
    final unidade = Unidade.nova(
      condominioId: condominioId,  // "cond-123"
      numero: numero,               // "101"
      bloco: blocoCriado.nome,      // "D"
      tipoUnidade: 'A',            // Padrão
    );
    
    // 3. INSERE no Supabase
    final response = await _supabase
        .from('unidades')
        .insert(unidade.toJson())
        .select()
        .single();
    
    // 4. RETORNA unidade criada
    return Unidade.fromJson(response);
  }
}
```

### O que acontece no Supabase:

```sql
INSERT INTO unidades (
  condominio_id,
  numero,
  bloco,
  tipo_unidade,
  ativo,
  -- ... outros campos com valores padrão ...
) VALUES (
  "cond-123",
  "101",
  "D",
  "A",
  true,
  -- ...
);

-- Retorna: Unidade {
--   id: "unidade-uuid",
--   condominioId: "cond-123",
--   numero: "101",
--   bloco: "D",
--   tipoUnidade: "A",
--   ativo: true,
--   -- ...
-- }
```

---

## 📱 PASSO 7: NAVEGAR PARA DetalhesUnidadeScreen

### Após criar unidade:

```dart
if (mounted) {
  // 1. Fecha o snackbar
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  
  // 2. Recarrega lista de unidades (para incluir a nova)
  await _carregarDados();
  
  // 3. NAVEGA para DetalhesUnidadeScreen
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => DetalhesUnidadeScreen(
        condominioId: widget.condominioId,
        condominioNome: widget.condominioNome,
        condominioCnpj: widget.condominioCnpj,
        bloco: bloco.nome,      // "D"
        unidade: numero,        // "101"
        modo: 'criar',          // ← MODO CRIAÇÃO!
      ),
    ),
  ).then((_) {
    // Quando usuário voltar de DetalhesUnidadeScreen
    _carregarDados();  // Recarrega lista novamente
  });
}
```

---

## 📝 PASSO 8: DetalhesUnidadeScreen EM MODO CRIAÇÃO

### No `initState()`:

```dart
@override
void initState() {
  super.initState();
  
  if (widget.modo == 'criar') {
    // ← Nossa situação
    _inicializarParaCriacao();
  } else {
    _carregarDados();  // Para modo edição
  }
}

void _inicializarParaCriacao() {
  setState(() {
    _unidadeController.text = widget.unidade;  // "101"
    _blocoController.text = widget.bloco;      // "D"
    _isLoadingDados = false;
    _errorMessage = null;
    // Deixa resto vazio para user preencher
  });
}
```

### UI que aparece:

```
┌─────────────────────────────────────────────┐
│ Home/Gestão/Unid/D/101                      │
│                                             │
│ ⚠️ Modo Criação: Nova Unidade               │
│    Salve a unidade antes de prosseguir      │ ← Aviso!
│                                             │
│ Bloco D / Unidade 101                       │
│                                             │
│ ┌───────────────────────────────────────────┤
│ │ 📦 UNIDADE                                │
│ │                                           │
│ │ Número: 101 (preenchido)                  │
│ │ Bloco: D (preenchido)                     │
│ │ Fração: [_____] (vazio)                   │
│ │ Área: [_____] (vazio)                     │
│ │ [SALVAR UNIDADE]                          │
│ │                                           │
│ │ 👤 PROPRIETÁRIO                           │
│ │ Nome: [_____] (vazio)                     │
│ │ CPF: [_____] (vazio)                      │
│ │ [SALVAR] (opcional)                       │
│ │                                           │
│ │ 🏠 INQUILINO                             │
│ │ Nome: [_____] (vazio)                     │
│ │ CPF: [_____] (vazio)                      │
│ │ [SALVAR] (opcional)                       │
│ │                                           │
│ │ 🏢 IMOBILIÁRIA                           │
│ │ Nome: [_____] (vazio)                     │
│ │ CNPJ: [_____] (vazio)                     │
│ │ [SALVAR] (opcional)                       │
│ └───────────────────────────────────────────┘
│                                             │
│ [Voltar]                                    │
└─────────────────────────────────────────────┘
```

### User preenche dados (ex: Fração Ideal = 0.5):

```
_unidadeController.text = "101" (não muda)
_blocoController.text = "D" (não muda)
_fracaoIdealController.text = "0.5" (digitado)
_areaController.text = "80" (digitado)
```

### User clica "SALVAR UNIDADE":

```dart
Future<void> _salvarUnidade() async {
  setState(() {
    _isLoadingUnidade = true;
  });
  
  try {
    // Simulando delay de API
    await Future.delayed(const Duration(seconds: 1));
    
    // Mostrar feedback de sucesso
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Dados da unidade salvos com sucesso!'),
        backgroundColor: Colors.green,
      ),
    );
    // ← Em prod, aqui faria update no banco
  }
}
```

**Resultado:** ✅ Unidade salva com sucesso!

---

## 🎉 PASSO 9: VOLTAR PARA UnidadeMoradorScreen

### User clica "Voltar":

```dart
// Em DetalhesUnidadeScreen.build()
IconButton(
  icon: const Icon(Icons.arrow_back_ios, size: 24),
  onPressed: () {
    Navigator.pop(context);  // ← Volta para UnidadeMoradorScreen
  },
),
```

### De volta em UnidadeMoradorScreen:

```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => DetalhesUnidadeScreen(...),
  ),
).then((_) {
  // Executado quando volta de DetalhesUnidadeScreen
  _carregarDados();  // Recarrega lista do banco
});
```

### `_carregarDados()` executa:

```dart
Future<void> _carregarDados() async {
  try {
    // Busca do banco TODAS as unidades do condomínio
    final blocosUnidades = 
      await _unidadeService.listarUnidadesCondominio(
        widget.condominioId!,
      );
    
    setState(() {
      _blocosUnidades = blocosUnidades;
      _blocosUnidadesFiltrados = blocosUnidades;
      _isLoading = false;
    });
  }
}
```

### Resultado - Banco retorna:

```sql
SELECT 
  blocos.*,
  unidades.* 
FROM blocos
JOIN unidades ON blocos.id = unidades.bloco_id
WHERE blocos.condominio_id = 'cond-123';

-- Retorna incluindo nossa nova unidade:
-- Bloco D: [101 (NOVO!), ...]
```

### UI Atualizada:

```
┌────────────────────────────────┐
│ UnidadeMoradorScreen           │
│                                │
│ [Pesquisar] [Importar]         │
│ [Configuração]                 │
│ [➕ ADICIONAR UNIDADE]         │
│                                │
│ ┌─── BLOCO A ───┐              │
│ │ [101] [102]   │              │
│ └────────────────┘             │
│                                │
│ ┌─── BLOCO D ───┐              │
│ │ [101] ✨ NOVO │ ← AQUI!      │
│ └────────────────┘             │
│                                │
└────────────────────────────────┘
```

---

## 📊 RESUMO DO FLUXO COMPLETO

```
USUÁRIO CLICA "+ ADICIONAR"
    ↓
ModalCriarUnidade ABRE
    ├─ Carrega blocos existentes
    ├─ Se vazio, cria bloco "A" padrão
    └─ Seleciona 1º bloco
    ↓
USER PREENCHE DADOS
    ├─ Número: "101"
    ├─ Bloco: "D" (ou cria novo)
    └─ Se clicar criar bloco:
       └─ ModalCriarBloco abre (modal aninhado)
          ├─ User digita nome "D"
          ├─ Cria no Supabase
          └─ Retorna, seleciona novo bloco
    ↓
USER CLICA "PRÓXIMO"
    ├─ Valida número (não vazio)
    ├─ Valida bloco (selecionado)
    ├─ Valida número único no bloco
    └─ Retorna dados
    ↓
CRIA UNIDADE NO BANCO
    ├─ criarUnidadeRapida()
    ├─ INSERT na tabela unidades
    └─ Retorna unidade criada
    ↓
NAVEGA PARA DetalhesUnidadeScreen
    ├─ Modo: 'criar'
    ├─ Preenche número e bloco
    ├─ Deixa resto vazio
    └─ Mostra aviso orange
    ↓
USER PREENCHE DADOS ADICIONAIS
    ├─ Fração ideal
    ├─ Área
    ├─ Proprietário (opcional)
    ├─ Inquilino (opcional)
    └─ Imobiliária (opcional)
    ↓
USER CLICA "SALVAR UNIDADE"
    └─ Confirma criação
    ↓
USER CLICA "VOLTAR"
    ↓
RECARREGA LISTA
    ├─ Busca banco novamente
    ├─ Inclui unidade nova
    └─ Mostra na UI
    ↓
✨ UNIDADE CRIADA E VISÍVEL NA LISTA!
```

---

## 🔐 VALIDAÇÕES IMPLEMENTADAS

### No ModalCriarUnidade:
1. ✅ Número não vazio
2. ✅ Bloco selecionado
3. ✅ Número não duplicado NO MESMO BLOCO

### No ModalCriarBloco:
1. ✅ Nome não vazio
2. ⚠️ Sem validação de duplicata (poderia ter)

### No Service (criarUnidadeRapida):
1. ✅ Verifica se bloco tem ID (novo ou existente)
2. ✅ Cria bloco se necessário
3. ✅ Cria unidade com valores sensatos

---

## 🎯 PONTOS-CHAVE DO DESIGN

| Aspecto | Por quê | Como |
|---------|---------|------|
| **Modal em 2 passos** | Não sobrecarrega | Bloco → Unidade |
| **Bloco "A" padrão** | Evita confusão | Se vazio, cria auto |
| **Validação em client** | Rápido, sem latência | Antes de salvar |
| **Modal aninhado** | UX fluida | Criar bloco inline |
| **Aviso em modo criação** | Usuário não se perde | Banner orange |
| **Reload após voltar** | Sempre consistente | _carregarDados() |

---

**Este é o fluxo COMPLETO que acontecerá quando o usuário clicar em "+ ADICIONAR UNIDADE"** 🎬
