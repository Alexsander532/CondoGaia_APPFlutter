# 📊 MAPEAMENTO DO CAMPO DE UNIDADE - EDIÇÃO DE DADOS

## 🎯 Visão Geral

Quando você está na tela de **Edição dos Dados da Unidade** (`DetalhesUnidadeScreen`), o campo de **"Unidade"** (número da unidade) é mapeado através de 3 camadas:

```
Interface (UI) → Modelo (Dart) → Banco de Dados (PostgreSQL)
```

---

## 🔗 MAPEAMENTO COMPLETO

### 1️⃣ **NA INTERFACE (Flutter - detalhes_unidade_screen.dart)**

#### Campo Visual
```dart
// Linha 56 - Controlador de texto para o campo "Unidade*"
final TextEditingController _unidadeController = TextEditingController();
```

#### Renderização na UI
```dart
// Linhas 601-625 - Primeiro campo da seção "Unidade"
Container(
  height: 45,
  decoration: BoxDecoration(
    border: Border.all(color: const Color(0xFFE0E0E0)),
    borderRadius: BorderRadius.circular(8),
    color: Colors.white,
  ),
  child: TextField(
     controller: _unidadeController,  // ← Controlador que armazena o valor
     decoration: const InputDecoration(
       hintText: '101',  // ← Exemplo de valor (número da unidade)
       hintStyle: TextStyle(
         color: Color(0xFF999999),
         fontSize: 14,
       ),
       border: InputBorder.none,
       contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
     ),
   ),
),
```

**Status na Interface:**
- ✅ Campo é editável
- ✅ Validação obrigatória (marcado com `*`)
- ✅ Preenchido automaticamente ao carregar dados

---

### 2️⃣ **CARREGAMENTO DE DADOS (UnidadeDetalhesService)**

#### Como os dados chegam na tela

**Fluxo de Carregamento:**

```
DetalhesUnidadeScreen.initState()
    ↓
_carregarDados()
    ↓
UnidadeDetalhesService.buscarDetalhesUnidade()
    ↓
Consulta ao Banco: SELECT * FROM unidades WHERE numero = ? AND bloco = ? AND condominio_id = ?
    ↓
Retorna Map com a unidade
    ↓
Unidade.fromJson() - Converte JSON para objeto Dart
    ↓
Preenche: _unidadeController.text = _unidade?.numero ?? ''
```

#### Código de Busca (unidade_detalhes_service.dart)

```dart
// Linhas 16-29
Future<Map<String, dynamic>> buscarDetalhesUnidade({
  required String condominioId,
  required String numero,        // ← NÚMERO PASSADO COMO PARÂMETRO
  required String bloco,
}) async {
  try {
    // 1. Buscar a unidade
    final unidadeData = await _supabase
        .from('unidades')
        .select()
        .eq('condominio_id', condominioId)
        .eq('numero', numero)    // ← FILTRO PELO NÚMERO
        .eq('bloco', bloco)
        .maybeSingle();          // ← Retorna um registro ou null
    
    if (unidadeData == null) {
      throw Exception('Unidade não encontrada');
    }
    
    final unidade = Unidade.fromJson(unidadeData);  // ← Converte para objeto
    // ...
  }
}
```

---

### 3️⃣ **NO MODELO DART (unidade.dart)**

#### Classe Unidade

```dart
class Unidade {
  // Campo principal de identificação
  final String numero;                    // ← ESSE É O CAMPO!
  final String condominioId;
  final String? bloco;
  // ... outros campos ...
  
  Unidade({
    required this.numero,                 // ← OBRIGATÓRIO
    required this.condominioId,
    this.bloco,
    // ...
  });
}
```

#### Conversão de JSON (lines 102-125)

```dart
factory Unidade.fromJson(Map<String, dynamic> json) {
  return Unidade(
    id: json['id'] ?? '',
    numero: json['numero'] ?? '',        // ← CAMPO DO BANCO MAPEADO PARA DART
    condominioId: json['condominio_id'] ?? '',
    bloco: json['bloco'],
    fracaoIdeal: json['fracao_ideal']?.toDouble(),
    areaM2: json['area_m2']?.toDouble(),
    // ... outros campos ...
  );
}

Map<String, dynamic> toJson() {
  return {
    'numero': numero,                     // ← CAMPO DO DART MAPEADO PARA BANCO
    'condominio_id': condominioId,
    'bloco': bloco,
    // ...
  };
}
```

---

### 4️⃣ **NO BANCO DE DADOS (PostgreSQL)**

#### Tabela `unidades`

```sql
CREATE TABLE unidades (
    -- Campos de identificação primária
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Campos obrigatórios da interface
    numero VARCHAR(10) NOT NULL,        -- ← CAMPO NA TABELA (máx 10 caracteres)
    condominio_id UUID NOT NULL,
    
    -- Campos opcionais
    bloco VARCHAR(10),
    fracao_ideal DECIMAL(10,6),
    area_m2 DECIMAL(10,2),
    -- ... outros campos ...
    
    -- Constraints
    CONSTRAINT unidades_numero_not_empty CHECK (trim(numero) != ''),
    
    -- Índices para performance
    UNIQUE INDEX uk_unidades_numero ON (bloco_id, numero)  -- Número único por bloco
);
```

**Características do Campo:**
- 📋 **Nome na tabela:** `numero`
- 📝 **Tipo:** `VARCHAR(10)` (texto até 10 caracteres)
- 🔴 **Obrigatório:** SIM (NOT NULL)
- 🔑 **Índice:** Sim (UNIQUE com bloco_id para garantir unicidade)
- ✅ **Constraint:** Não pode ser vazio (trim(numero) != '')

---

## 📋 TABELA DE MAPEAMENTO

| Camada | Localization | Nome do Campo | Tipo | Obrigatório | Descrição |
|--------|--------------|---------------|------|-------------|-----------|
| **UI (Flutter)** | `detalhes_unidade_screen.dart:56` | `_unidadeController` | `TextEditingController` | ✅ | Campo de entrada editável |
| **UI (Flutter)** | `detalhes_unidade_screen.dart:161` | Preenche com | `String` (número da unidade) | ✅ | `_unidadeController.text = _unidade?.numero` |
| **Modelo (Dart)** | `unidade.dart:14` | `numero` | `String` | ✅ | Campo no objeto Unidade |
| **Serviço (Dart)** | `unidade_detalhes_service.dart:25` | Parâmetro `numero` | `String` | ✅ | Usada em WHERE para buscar |
| **Banco (SQL)** | `10_recreate_unidades_manual_input.sql:35` | `numero` | `VARCHAR(10)` | ✅ | Campo na tabela unidades |

---

## 🔄 CICLO COMPLETO: CARREGAR E SALVAR

### Ao CARREGAR os Dados:

```
1. DetalhesUnidadeScreen recebe: bloco="A", unidade="310"
2. Chama: buscarDetalhesUnidade(condominioId, numero="310", bloco="A")
3. Banco retorna: { numero: "310", bloco: "A", ... }
4. Unidade.fromJson() converte para: Unidade(numero="310", bloco="A", ...)
5. Preenche: _unidadeController.text = "310"
6. Na tela aparece: "310" no campo "Unidade*"
```

### Ao SALVAR os Dados:

```
1. Usuário clica em "Salvar Unidade"
2. _isLoadingUnidade = true
3. Coleta valor: final numero = _unidadeController.text
4. Valida: if (numero.isEmpty) return (erro)
5. Cria mapa: { numero: "310", bloco: "A", ... }
6. Chama: _service.atualizarUnidade(unidadeId, dados)
7. Banco executa: UPDATE unidades SET numero='310' WHERE id=?
8. Sucesso: "Dados da unidade salvos com sucesso!"
```

---

## ⚠️ VALIDAÇÕES IMPORTANTES

### Na Interface (Frontend)
```dart
// O campo é obrigatório (*)
// Indicado visualmente no rótulo "Unidade*"

// Validação ao salvar (presumivelmente implementada)
if (_unidadeController.text.isEmpty) {
  // Mostrar erro
  return;
}
```

### No Banco (Backend)
```sql
-- Constraint: Número não pode ser vazio
CONSTRAINT unidades_numero_not_empty CHECK (trim(numero) != ''),

-- Constraint: Máximo 10 caracteres
numero VARCHAR(10) NOT NULL,

-- Índice: Garantir unicidade por bloco
UNIQUE INDEX uk_unidades_numero ON (bloco_id, numero)
```

---

## 🔍 EXEMPLO PRÁTICO

### Dados da Unidade A/310 na Tela:

```
┌─ UNIDADE ──────────────────────────────┐
│ Unidade*:  [ 310            ]          │  ← _unidadeController.text = "310"
│ Bloco:     [ A              ]          │  ← _blocoController.text = "A"
│ Fração Ideal: [ 0.014       ]          │
│ Área (m²): [                ]          │
└────────────────────────────────────────┘
```

### Correspondência no Banco:

```sql
SELECT * FROM unidades 
WHERE condominio_id = 'xyz...' 
  AND numero = '310' 
  AND bloco = 'A';

-- Resultado:
-- id        | numero | bloco | fracao_ideal | area_m2 | ...
-- 'uuid...' | '310'  | 'A'   | 0.014000     | NULL    | ...
```

---

## 📌 RESUMO - FLUXO DIRETO

```
┌─────────────────────────────────────────────────────────┐
│                    CAMPO DE UNIDADE                      │
│                                                           │
│  UI:       _unidadeController (TextField)               │
│            ↓                                              │
│  Model:    Unidade.numero (String)                      │
│            ↓                                              │
│  Service:  buscarDetalhesUnidade(...numero: String...)  │
│            ↓                                              │
│  Database: unidades.numero (VARCHAR(10) NOT NULL)       │
│                                                           │
└─────────────────────────────────────────────────────────┘
```

---

## 🎓 PARA EDITAR/MANTER O CAMPO

Se você quiser **modificar** algo relacionado ao campo de unidade:

1. **Mudar o tipo de dado:**
   - Alterar em: `unidade.dart` (classe)
   - Alterar em: SQL (tabela)
   - Alterar em: `unidade_detalhes_service.dart` (busca/salvamento)

2. **Adicionar validação:**
   - Adicionar em: `detalhes_unidade_screen.dart` (ao salvar)
   - Adicionar em: SQL (CONSTRAINT)

3. **Mudar o rótulo ou placeholder:**
   - Apenas em: `detalhes_unidade_screen.dart` (UI)

4. **Mover a posição do campo:**
   - Apenas em: `detalhes_unidade_screen.dart` (UI)

---

## 📚 ARQUIVOS RELACIONADOS

| Arquivo | Propósito |
|---------|-----------|
| `lib/screens/detalhes_unidade_screen.dart` | Exibe e edita o campo na UI |
| `lib/models/unidade.dart` | Define a estrutura do modelo |
| `lib/services/unidade_detalhes_service.dart` | Busca e salva dados do banco |
| `sql/10_recreate_unidades_manual_input.sql` | Define a tabela no banco |
| `supabase/migrations/20240120000003_create_unidades.sql` | Criação original da tabela |

