# 📊 ANÁLISE: PASSO 1 - ESTRUTURA ATUAL DE PERMISSÕES

## ✅ O QUE JÁ EXISTE NO APP

### 1. MODEL: AutorizadoInquilino

**Localização:** `lib/models/autorizado_inquilino.dart`

**Campos atuais relacionados a dias/horários:**

```dart
final String? horarioInicio;           // Exemplo: "08:00"
final String? horarioFim;              // Exemplo: "18:00"
final List<int>? diasSemanaPermitidos; // Exemplo: [0,1,2,3,4] (0=DOM, 1=SEG, etc)
```

**Status:** ✅ Campos para horários já existem!

---

### 2. SERVICE: AutorizadoInquilinoService

**Localização:** `lib/services/autorizado_inquilino_service.dart`

**Métodos disponíveis:**

| Método | Descrição |
|--------|-----------|
| `insertAutorizado(Map)` | Insere novo autorizado |
| `updateAutorizado(id, Map)` | Atualiza autorizado existente |
| `deleteAutorizado(id)` | Remove autorizado (soft delete) |
| `getAutorizadosByUnidade(id)` | Busca autorizados de uma unidade |
| `getAutorizadosByInquilino(id)` | Busca autorizados de um inquilino |
| `getAutorizadosByProprietario(id)` | Busca autorizados de um proprietário |

**Validações já implementadas:**
- ✅ Validar dados obrigatórios
- ✅ Validar CPF
- ✅ Validar vínculo (inquilino OU proprietário)
- ✅ Verificar CPF duplicado na unidade

---

## 🗄️ O QUE PRECISA ADICIONAR NO BANCO

### Campos Faltando:

Na tabela `autorizados_inquilinos`, **FALTAM** estas colunas:

```sql
-- Campo para tipo de seleção de dias
tipo_selecao_dias VARCHAR(20) DEFAULT 'dias_semana'

-- Campo para dias específicos (JSON)
dias_especificos JSONB DEFAULT '[]'
```

---

## 📋 COMPARAÇÃO: ANTES vs DEPOIS

### ANTES (Estado Atual):

```
┌──────────────────────────────────────────┐
│ autorizados_inquilinos (BANCO)           │
├──────────────────────────────────────────┤
│ id                                       │
│ unidade_id                               │
│ inquilino_id / proprietario_id           │
│ nome, cpf, parentesco                    │
│ horario_inicio       ✅                  │
│ horario_fim          ✅                  │
│ dias_semana_permitidos ✅ (List<int>)    │
│ veiculo_marca, modelo, placa             │
│ foto_url                                 │
│ ativo, created_at, updated_at            │
└──────────────────────────────────────────┘

MODEL: AutorizadoInquilino
├─ horarioInicio: String?    ✅
├─ horarioFim: String?       ✅
└─ diasSemanaPermitidos: List<int>?  ✅
```

### DEPOIS (Com implementação completa):

```
┌────────────────────────────────────────────────────────┐
│ autorizados_inquilinos (BANCO)                         │
├────────────────────────────────────────────────────────┤
│ id                                                     │
│ unidade_id                                             │
│ inquilino_id / proprietario_id                         │
│ nome, cpf, parentesco                                  │
│ horario_inicio              ✅                         │
│ horario_fim                 ✅                         │
│ dias_semana_permitidos      ✅                         │
│ tipo_selecao_dias           🆕 (dias_semana ou especificos)
│ dias_especificos            🆕 (JSONB array com datas)  │
│ veiculo_marca, modelo, placa                           │
│ foto_url                                               │
│ ativo, created_at, updated_at                          │
└────────────────────────────────────────────────────────┘

MODEL: AutorizadoInquilino
├─ horarioInicio: String?           ✅
├─ horarioFim: String?              ✅
├─ diasSemanaPermitidos: List<int>? ✅
├─ tipoSelecaoDias: String?         🆕
└─ diasEspecificos: List<String>?   🆕 (datas em ISO)
```

---

## 🎯 PLANO DE AÇÃO PARA COMPLETAR PASSO 1

### Sub-tarefa 1.1: Adicionar Colunas ao Banco

```sql
-- Executar no Supabase SQL Editor

ALTER TABLE autorizados_inquilinos 
ADD COLUMN tipo_selecao_dias VARCHAR(20) 
DEFAULT 'dias_semana'
CHECK (tipo_selecao_dias IN ('dias_semana', 'dias_especificos'));

ALTER TABLE autorizados_inquilinos 
ADD COLUMN dias_especificos JSONB 
DEFAULT '[]';
```

**Status:** 🔴 Não foi feito ainda
**Tempo:** ~2 minutos

---

### Sub-tarefa 1.2: Atualizar a Model

**Arquivo:** `lib/models/autorizado_inquilino.dart`

**Adicionar esses 2 campos:**

```dart
final String? tipoSelecaoDias;        // 'dias_semana' ou 'dias_especificos'
final List<String>? diasEspecificos;  // ['2025-01-15', '2025-01-20']
```

**Onde adicionar no construtor:**

```dart
const AutorizadoInquilino({
  required this.id,
  required this.unidadeId,
  this.inquilinoId,
  this.proprietarioId,
  required this.nome,
  required this.cpf,
  this.parentesco,
  this.horarioInicio,
  this.horarioFim,
  this.diasSemanaPermitidos,
  this.tipoSelecaoDias,         // 🆕 ADICIONAR AQUI
  this.diasEspecificos,          // 🆕 ADICIONAR AQUI
  this.veiculoMarca,
  this.veiculoModelo,
  this.veiculoCor,
  this.veiculoPlaca,
  this.fotoUrl,
  this.ativo = true,
  this.createdAt,
  this.updatedAt,
});
```

**Onde adicionar em fromJson():**

```dart
factory AutorizadoInquilino.fromJson(Map<String, dynamic> json) {
  return AutorizadoInquilino(
    id: json['id'] as String,
    // ... outros campos ...
    horarioFim: json['horario_fim'] as String?,
    diasSemanaPermitidos: json['dias_semana_permitidos'] != null
        ? List<int>.from(json['dias_semana_permitidos'] as List)
        : null,
    tipoSelecaoDias: json['tipo_selecao_dias'] as String?,           // 🆕
    diasEspecificos: json['dias_especificos'] != null
        ? List<String>.from(json['dias_especificos'] as List)
        : null,                                                        // 🆕
    // ... resto dos campos ...
  );
}
```

**Onde adicionar em toJson():**

```dart
Map<String, dynamic> toJson() {
  return {
    'id': id,
    // ... outros campos ...
    'horario_fim': horarioFim,
    'dias_semana_permitidos': diasSemanaPermitidos,
    'tipo_selecao_dias': tipoSelecaoDias,     // 🆕
    'dias_especificos': diasEspecificos,      // 🆕
    // ... resto dos campos ...
  };
}
```

**Status:** 🔴 Não foi feito ainda
**Tempo:** ~10 minutos

---

### Sub-tarefa 1.3: Atualizar o Service

**Arquivo:** `lib/services/autorizado_inquilino_service.dart`

**No método `insertAutorizado()`, adicionar validação:**

```dart
static Future<AutorizadoInquilino?> insertAutorizado(
  Map<String, dynamic> autorizadoData,
) async {
  try {
    // Validações existentes...
    if (!_validarDadosObrigatorios(autorizadoData)) {
      throw Exception('Dados obrigatórios não fornecidos');
    }
    
    // 🆕 ADICIONAR ESTA VALIDAÇÃO
    _validarTipoSelecaoDias(autorizadoData);
    
    // resto do código...
  }
}

// 🆕 ADICIONAR ESTA FUNÇÃO DE VALIDAÇÃO
static void _validarTipoSelecaoDias(Map<String, dynamic> data) {
  final tipoSelecao = data['tipo_selecao_dias'] ?? 'dias_semana';
  
  if (tipoSelecao == 'dias_semana') {
    // Validar se tem dias da semana selecionados
    final diasSemana = data['dias_semana_permitidos'];
    if (diasSemana == null || (diasSemana is List && diasSemana.isEmpty)) {
      throw Exception('Selecione pelo menos um dia da semana');
    }
  } else if (tipoSelecao == 'dias_especificos') {
    // Validar se tem datas específicas selecionadas
    final diasEspecificos = data['dias_especificos'];
    if (diasEspecificos == null || (diasEspecificos is List && diasEspecificos.isEmpty)) {
      throw Exception('Selecione pelo menos uma data específica');
    }
  }
}
```

**Status:** 🔴 Não foi feito ainda
**Tempo:** ~5 minutos

---

## 📝 RESUMO DO ESTADO ATUAL

### ✅ O QUE JÁ ESTÁ PRONTO:

| Item | Status | Local |
|------|--------|-------|
| Model com campos de horários | ✅ | `autorizado_inquilino.dart` |
| Service com insert/update | ✅ | `autorizado_inquilino_service.dart` |
| Campo `dias_semana_permitidos` | ✅ | Banco de dados |
| Validações básicas | ✅ | Service |
| Methods de busca | ✅ | Service |

### 🔴 O QUE PRECISA FAZER:

| Item | Status | Tempo |
|------|--------|-------|
| Adicionar 2 colunas no banco | 🔴 | 2 min |
| Atualizar Model (2 campos) | 🔴 | 10 min |
| Atualizar Service (1 validação) | 🔴 | 5 min |
| **TOTAL PASSO 1** | 🔴 | **~17 min** |

---

## 🚀 PRÓXIMOS PASSOS

Após completar Passo 1, você terá:

✅ Modelo de dados completo
✅ Service com validações
✅ Banco pronto para receber dados

Isso permite passar para **Passo 2: Implementar UI no Modal**

---

## 💡 RECOMENDAÇÃO

**Comece assim:**

1. ✅ Execute os 2 comandos SQL no Supabase
2. ✅ Atualize a Model (10 min)
3. ✅ Atualize o Service (5 min)
4. ✅ Teste compilação (verificar erros)
5. ✅ Pronto para Passo 2!

Quer que eu faça essas mudanças agora? 🎯

