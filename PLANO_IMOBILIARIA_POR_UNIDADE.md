# 📋 Plano: Imobiliária por Unidade (não por Condomínio)

## 🔴 Problema Identificado

Atualmente, quando você salva uma imobiliária, ela é associada ao **condomínio todo**, então todas as unidades compartilham a mesma imobiliária.

**Exemplo do problema:**
```
Condomínio "Prédio A"
├── Unidade 101 → Imobiliária "ABC Imóveis" (CNPJ: 11.222.333/0001-81)
├── Unidade 102 → Imobiliária "ABC Imóveis" (mesma!)
└── Unidade 103 → Imobiliária "ABC Imóveis" (mesma!)
```

**Resultado desejado:**
```
Condomínio "Prédio A"
├── Unidade 101 → Imobiliária "ABC Imóveis"
├── Unidade 102 → Imobiliária "XYZ Corretora"
└── Unidade 103 → Imobiliária "ABC Imóveis"
```

---

## ✅ Solução: Adicionar Coluna `unidade_id`

### **Estrutura Atual:**
```
imobiliarias
├── id (UUID)
├── condominio_id (FK → condominios) ← PROBLEMA: apenas nível condomínio
├── nome
├── cnpj
├── email
└── ...
```

### **Estrutura Nova:**
```
imobiliarias
├── id (UUID)
├── condominio_id (FK → condominios) ← Mantém para contexto
├── unidade_id (FK → unidades) ← NOVO: associa cada imobiliária a uma unidade
├── nome
├── cnpj
├── email
└── ...
```

---

## 🔧 Mudanças Necessárias

### **1️⃣ Banco de Dados (SQL)**

**Comando 1: Adicionar coluna unidade_id**
```sql
ALTER TABLE imobiliarias 
ADD COLUMN unidade_id uuid NULL;

-- Adicionar chave estrangeira
ALTER TABLE imobiliarias 
ADD CONSTRAINT fk_imobiliarias_unidade 
FOREIGN KEY (unidade_id) REFERENCES unidades(id) ON DELETE CASCADE;

-- Adicionar índice para performance
CREATE INDEX IF NOT EXISTS idx_imobiliarias_unidade 
ON imobiliarias USING btree (unidade_id);
```

**Comando 2: Atualizar constraint UNIQUE**

**Antes** (compartilhada por condomínio):
```sql
CONSTRAINT uk_imobiliarias_cnpj_condominio UNIQUE (cnpj, condominio_id)
```

**Depois** (única por unidade):
```sql
-- Remover constraint antiga
ALTER TABLE imobiliarias 
DROP CONSTRAINT uk_imobiliarias_cnpj_condominio;

-- Adicionar nova constraint
ALTER TABLE imobiliarias 
ADD CONSTRAINT uk_imobiliarias_cnpj_unidade UNIQUE (cnpj, unidade_id);

-- Email também pode ser único por unidade
ALTER TABLE imobiliarias 
DROP CONSTRAINT uk_imobiliarias_email_condominio;

ALTER TABLE imobiliarias 
ADD CONSTRAINT uk_imobiliarias_email_unidade UNIQUE (email, unidade_id);
```

---

### **2️⃣ Modelo Dart (imobiliaria.dart)**

**Adicionar campo:**
```dart
class Imobiliaria {
  final String id;
  final String condominioId;
  final String? unidadeId;  // ← NOVO
  final String nome;
  final String cnpj;
  final String? telefone;
  final String? celular;
  final String? email;
  final bool? ativo;
  final String? fotoUrl;
  final DateTime? criadoEm;
  final DateTime? atualizadoEm;

  const Imobiliaria({
    required this.id,
    required this.condominioId,
    this.unidadeId,  // ← NOVO (opcional por compatibilidade)
    required this.nome,
    required this.cnpj,
    this.telefone,
    this.celular,
    this.email,
    this.ativo,
    this.fotoUrl,
    this.criadoEm,
    this.atualizadoEm,
  });

  factory Imobiliaria.fromJson(Map<String, dynamic> json) {
    return Imobiliaria(
      id: json['id'] as String,
      condominioId: json['condominio_id'] as String,
      unidadeId: json['unidade_id'] as String?,  // ← NOVO
      nome: json['nome'] as String,
      cnpj: json['cnpj'] as String,
      telefone: json['telefone'] as String?,
      celular: json['celular'] as String?,
      email: json['email'] as String?,
      ativo: json['ativo'] as bool?,
      fotoUrl: json['foto_url'] as String?,
      criadoEm: json['created_at'] != null 
        ? DateTime.parse(json['created_at'] as String)
        : null,
      atualizadoEm: json['updated_at'] != null
        ? DateTime.parse(json['updated_at'] as String)
        : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'condominio_id': condominioId,
      'unidade_id': unidadeId,  // ← NOVO
      'nome': nome,
      'cnpj': cnpj,
      'telefone': telefone,
      'celular': celular,
      'email': email,
      'ativo': ativo,
      'foto_url': fotoUrl,
      'created_at': criadoEm?.toIso8601String(),
      'updated_at': atualizadoEm?.toIso8601String(),
    };
  }

  Imobiliaria copyWith({
    String? id,
    String? condominioId,
    String? unidadeId,  // ← NOVO
    String? nome,
    String? cnpj,
    String? telefone,
    String? celular,
    String? email,
    bool? ativo,
    String? fotoUrl,
    DateTime? criadoEm,
    DateTime? atualizadoEm,
  }) {
    return Imobiliaria(
      id: id ?? this.id,
      condominioId: condominioId ?? this.condominioId,
      unidadeId: unidadeId ?? this.unidadeId,  // ← NOVO
      nome: nome ?? this.nome,
      cnpj: cnpj ?? this.cnpj,
      telefone: telefone ?? this.telefone,
      celular: celular ?? this.celular,
      email: email ?? this.email,
      ativo: ativo ?? this.ativo,
      fotoUrl: fotoUrl ?? this.fotoUrl,
      criadoEm: criadoEm ?? this.criadoEm,
      atualizadoEm: atualizadoEm ?? this.atualizadoEm,
    );
  }
}
```

---

### **3️⃣ Serviço (unidade_detalhes_service.dart)**

**Atualizar método `buscarDetalhesUnidade()`:**
```dart
// ANTES: Buscar qualquer imobiliária do condomínio
final imobiliariaData = await _supabase
    .from('imobiliarias')
    .select()
    .eq('condominio_id', condominioId)
    .limit(1)
    .maybeSingle();

// DEPOIS: Buscar imobiliária ESPECÍFICA da unidade
final imobiliariaData = await _supabase
    .from('imobiliarias')
    .select()
    .eq('unidade_id', unidade.id)  // ← Filtrar por unidade
    .maybeSingle();
```

**Atualizar método `criarImobiliaria()`:**
```dart
// ANTES
Future<Imobiliaria> criarImobiliaria({
  required String condominioId,
  required String nome,
  // ...
})

// DEPOIS
Future<Imobiliaria> criarImobiliaria({
  required String condominioId,
  required String unidadeId,  // ← NOVO
  required String nome,
  // ...
}) async {
  try {
    final response = await _supabase
        .from('imobiliarias')
        .insert({
          'condominio_id': condominioId,
          'unidade_id': unidadeId,  // ← NOVO
          'nome': nome,
          'cnpj': cnpj,
          // ...
        })
        .select()
        .single();

    return Imobiliaria.fromJson(response);
  } catch (e) {
    throw Exception('Erro ao criar imobiliária: $e');
  }
}
```

---

### **4️⃣ Tela (detalhes_unidade_screen.dart)**

**Atualizar chamada `_salvarImobiliaria()`:**

```dart
// ANTES
final novaImobiliaria = await _service.criarImobiliaria(
  condominioId: widget.condominioId ?? '',
  nome: _imobiliariaNomeController.text.trim(),
  cnpj: _imobiliariaCnpjController.text.trim(),
  // ...
);

// DEPOIS
final novaImobiliaria = await _service.criarImobiliaria(
  condominioId: widget.condominioId ?? '',
  unidadeId: widget.unidade ?? '',  // ← NOVO: passar unidade
  nome: _imobiliariaNomeController.text.trim(),
  cnpj: _imobiliariaCnpjController.text.trim(),
  // ...
);
```

---

## 📊 Fluxo Técnico Completo

```
User abre Detalhes da Unidade A
    ↓
buscarDetalhesUnidade(unidadeId: "A")
    ↓
SELECT * FROM imobiliarias 
WHERE unidade_id = "A"
    ↓
Carrega imobiliária ESPECÍFICA da Unidade A
(Ou null se não existir)
    ↓
User preenche dados e clica "SALVAR IMOBILIÁRIA"
    ↓
_salvarImobiliaria() é chamado
    ↓
Se não existe:
  criarImobiliaria(
    unidadeId: "A",
    nome: "ABC Imóveis",
    cnpj: "11.222.333/0001-81"
  )
    ↓
INSERT INTO imobiliarias (unidade_id, ...)
VALUES ("A", ...)
    ↓
✅ Imobiliária criada APENAS para Unidade A
```

---

## ✨ Benefícios

✅ **Independência:** Cada unidade tem sua própria imobiliária  
✅ **Segurança:** Constraint UNIQUE garante único CNPJ por unidade  
✅ **Isolamento:** Mudança em uma unidade não afeta outras  
✅ **Flexibilidade:** Diferentes imobiliárias por unidade  

---

## 🔄 Migração de Dados Existentes

Se já houver imobiliárias no banco com unidades existentes, executar:

```sql
-- Atualizar imobiliárias existentes
-- Buscar a primeira unidade de cada condomínio e associar
UPDATE imobiliarias i
SET unidade_id = (
  SELECT id FROM unidades u 
  WHERE u.condominio_id = i.condominio_id 
  LIMIT 1
)
WHERE unidade_id IS NULL;
```

---

## 📋 Sequência de Implementação

1. ✅ Executar SQL: Adicionar `unidade_id`
2. ✅ Atualizar `imobiliaria.dart`: Adicionar campo
3. ✅ Atualizar `unidade_detalhes_service.dart`: Modificar métodos
4. ✅ Atualizar `detalhes_unidade_screen.dart`: Passar `unidadeId`
5. ✅ Testar: Criar imobiliárias em 2 unidades diferentes

---

## ✅ Status

- 📋 Plano criado
- ⏳ Aguardando implementação
