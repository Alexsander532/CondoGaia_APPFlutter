# 📋 COMO A PORTARIA DO REPRESENTANTE USA OS BLOCOS

## 🎯 Resumo Executivo

A **Portaria do Representante** agrupa todos os dados (proprietários, inquilinos, visitantes, etc) **por unidade**, e cada unidade tem um **identificador que inclui o bloco**. Portanto, os blocos são **fundamentais** para organizar as informações.

---

## 📊 Estrutura de Dados na Portaria

### 1. Modelo de Dados - `PessoaUnidade`

```dart
class PessoaUnidade {
  final String id;
  final String nome;
  final String unidadeId;
  final String unidadeNumero;      // ← Número da unidade (101, 102, etc)
  final String unidadeBloco;       // ← BLOCO (A, B, C, etc) ← IMPORTANTE!
  final String tipo;                // 'P' (Proprietário) ou 'I' (Inquilino)
  final String? fotoPerfil;
}
```

**Importante:** Cada pessoa tem:
- `unidadeNumero` - Número da unidade
- `unidadeBloco` - **Bloco da unidade** - SEMPRE PRESENTE

---

## 🔄 Fluxo de Agrupamento de Dados

### Passo 1: Carregar Dados Separados
```
┌─────────────────────────────────────────┐
│  BANCO DE DADOS (Supabase)              │
│                                         │
│  Proprietários:                         │
│  - João, Unidade A-101                  │
│  - Maria, Unidade A-102                 │
│  - Pedro, Unidade B-201                 │
│                                         │
│  Inquilinos:                            │
│  - Ana, Unidade A-101                   │
│  - Carlos, Unidade B-201                │
│                                         │
└─────────────────────────────────────────┘
```

### Passo 2: Criar Chave de Agrupamento
```dart
// Para cada proprietário/inquilino:
String chaveUnidade = unidade.bloco != null && unidade.bloco!.isNotEmpty
    ? '${unidade.bloco}/${unidade.numero}'  // "A/101", "B/201"
    : unidade.numero;                       // "101" (se sem bloco)
```

**Exemplo:**
```
Proprietário João:
  - Unidade: A/101
  - Chave: "A/101"

Inquilino Ana:
  - Unidade: A/101
  - Chave: "A/101"  ← MESMA CHAVE!

Proprietário Pedro:
  - Unidade: B/201
  - Chave: "B/201"

Inquilino Carlos:
  - Unidade: B/201
  - Chave: "B/201"  ← MESMA CHAVE!
```

### Passo 3: Agrupar por Chave
```dart
Map<String, List<Map<String, dynamic>>> pessoasPorUnidade = {};

// Agrupa proprietários e inquilinos pela mesma chave
pessoasPorUnidade = {
  "A/101": [
    { nome: "João", tipo: "Proprietário" },
    { nome: "Ana", tipo: "Inquilino" },
  ],
  "A/102": [
    { nome: "Maria", tipo: "Proprietário" },
  ],
  "B/201": [
    { nome: "Pedro", tipo: "Proprietário" },
    { nome: "Carlos", tipo: "Inquilino" },
  ],
};
```

---

## 🗂️ Como Cada Seção Usa os Blocos

### Seção 1️⃣: PROPRIETÁRIOS / INQUILINOS

**Código:**
```dart
for (var proprietario in _proprietarios) {
  final unidade = _unidades.firstWhere((u) => u.id == proprietario.unidadeId);
  
  String chaveUnidade = unidade.bloco != null && unidade.bloco!.isNotEmpty
      ? '${unidade.bloco}/${unidade.numero}'
      : unidade.numero;
  
  if (!pessoasPorUnidade.containsKey(chaveUnidade)) {
    pessoasPorUnidade[chaveUnidade] = [];
  }
  
  pessoasPorUnidade[chaveUnidade]!.add({
    'nome': proprietario.nome,
    'cpf': proprietario.cpfCnpj,
    'fotoPerfil': proprietario.fotoPerfil,
    'tipo': 'Proprietário',
  });
}
```

**O que faz:**
- ✅ Busca cada proprietário
- ✅ Encontra a unidade associada
- ✅ **Cria chave usando BLOCO + NÚMERO**
- ✅ Agrupa proprietários por essa chave
- ✅ Faz o mesmo para inquilinos
- ✅ **Resultado: Uma lista de pessoas por unidade identificada por bloco**

**Exemplo de exibição:**
```
📌 A/101
  👤 João (Proprietário)
  👤 Ana (Inquilino)

📌 A/102
  👤 Maria (Proprietário)

📌 B/201
  👤 Pedro (Proprietário)
  👤 Carlos (Inquilino)
```

---

### Seção 2️⃣: VISITANTES

**Estrutura:**
```dart
class _SectionVisitante {
  final String unidadeBloco;       // ← BLOCO AQUI
  final String unidadeNumero;      // ← NÚMERO AQUI
  final String unidadeId;
  final String visitanteName;
  final String visitanteCpf;
  // ... mais campos
}
```

**Uso:**
```dart
final unidadeComparison = '${a.unidadeNumero}/${a.unidadeBloco}'
    .compareTo('${b.unidadeNumero}/${b.unidadeBloco}');
```

**O que faz:**
- ✅ Cada visitante é associado a uma unidade
- ✅ Usa **BLOCO + NÚMERO** como identificador único
- ✅ Ordena visitantes por essa combinação

---

### Seção 3️⃣: AUTORIZADO PARA INQUILINO

**Estrutura:**
```dart
class _SectionAutorizado {
  final String unidadeBloco;       // ← BLOCO AQUI
  final String unidadeNumero;      // ← NÚMERO AQUI
  // ... mais campos
}
```

**Uso:**
```dart
// Agrupa autorizados por unidade (bloco + número)
final unidadeComparison = '${a.unidadeNumero}/${a.unidadeBloco}'
    .compareTo('${b.unidadeNumero}/${b.unidadeBloco}');
```

---

### Seção 4️⃣: ENCOMENDAS

**Estrutura:**
```dart
class _SectionEncomenda {
  final String unidadeBloco;       // ← BLOCO AQUI
  final String unidadeNumero;      // ← NÚMERO AQUI
  // ... mais campos
}
```

**Uso (Encomendas Pendentes):**
```dart
String chaveUnidade = unidade.bloco != null && unidade.bloco!.isNotEmpty
    ? '${unidade.bloco}/${unidade.numero}'
    : unidade.numero;

// Agrupa encomendas por unidade (bloco + número)
```

**Uso (Encomendas Entregues):**
```dart
String chaveUnidade = unidade.bloco != null && unidade.bloco!.isNotEmpty
    ? '${unidade.bloco}/${unidade.numero}'
    : unidade.numero;

// Agrupa encomendas por unidade (bloco + número)
```

---

## 🎯 Por Que Todos Usam Blocos?

### Razão 1: **Identificador Único**
```
❌ Número único: 101 pode estar em bloco A ou B
✅ Bloco + Número: A/101 é completamente único
```

### Razão 2: **Agrupamento Lógico**
```
Sem blocos:
┌─────────────┐
│ 101         │
│ 102         │
│ 201         │
│ 202         │
└─────────────┘
Confuso! Qual é qual?

Com blocos:
┌─────────────┐
│ Bloco A:    │
│  - 101      │
│  - 102      │
├─────────────┤
│ Bloco B:    │
│  - 201      │
│  - 202      │
└─────────────┘
Organizado e claro!
```

### Razão 3: **Busca e Filtro**
```dart
// Usuário digita: "A/101"
// Sistema busca por bloco + número
// Encontra TODAS as informações dessa unidade:
// - Proprietários
// - Inquilinos
// - Visitantes
// - Autorizados
// - Encomendas
```

### Razão 4: **Pesquisa Rápida**
```
Hint text: "Pesquisar unidade/bloco..."
           ↓
Usuário digita "A/101" ou só "101"
           ↓
Filtra unidades por bloco + número
           ↓
Mostra todas as pessoas dessa unidade
```

---

## 📋 Mapeamento de Blocos em Cada Seção

| Seção | Campo | Tipo | Uso |
|-------|-------|------|-----|
| Proprietários/Inquilinos | `unidade.bloco` | String | Chave de agrupamento |
| Visitantes | `_SectionVisitante.unidadeBloco` | String | Identificador |
| Autorizado | `_SectionAutorizado.unidadeBloco` | String | Identificador |
| Encomendas | `_SectionEncomenda.unidadeBloco` | String | Identificador |
| Busca | `unidade.bloco` | String | Filtro na pesquisa |

---

## 🔗 Fluxo de Dados Completo

```
┌─────────────────────────────────────────────────┐
│                 USUÁRIO NA PORTARIA             │
│         (Portaria do Representante)             │
└────────────────────┬────────────────────────────┘
                     │
                     ▼
        ┌────────────────────────┐
        │   Pesquisar Unidade    │
        │  "Pesquisar unidade... │
        │  bloco..."             │
        └────────────┬───────────┘
                     │
        ┌────────────▼───────────┐
        │ Usuário digita: "A/101"│
        └────────────┬───────────┘
                     │
        ┌────────────▼───────────────────┐
        │ Buscar todas as pessoas com    │
        │ bloco = "A" E número = "101"   │
        └────────────┬───────────────────┘
                     │
        ┌────────────▼──────────────────────────┐
        │  Exibir TODAS as seções dessa unidade:│
        │  ✅ Proprietários (João)              │
        │  ✅ Inquilinos (Ana)                  │
        │  ✅ Visitantes (registrados)          │
        │  ✅ Autorizados (para inquilino)      │
        │  ✅ Encomendas (pendentes/entregues) │
        └─────────────────────────────────────┘
```

---

## 💾 Dados no Banco de Dados

### Tabela: `unidades`
```
id      | numero | bloco | condominio_id
--------|--------|-------|---------------
1       | 101    | A     | cond-123
2       | 102    | A     | cond-123
3       | 201    | B     | cond-123
```

### Tabela: `proprietarios`
```
id      | nome   | unidade_id | cpf_cnpj
--------|--------|------------|----------
1       | João   | 1          | 123.456
2       | Maria  | 2          | 234.567
3       | Pedro  | 3          | 345.678
```

### Tabela: `inquilinos`
```
id      | nome   | unidade_id | cpf_cnpj
--------|--------|------------|----------
1       | Ana    | 1          | 456.789
2       | Carlos | 3          | 567.890
```

### Quando Agrupa:
```
Unidade 1 (A/101):
  - João (Proprietário)
  - Ana (Inquilino)

Unidade 2 (A/102):
  - Maria (Proprietário)

Unidade 3 (B/201):
  - Pedro (Proprietário)
  - Carlos (Inquilino)
```

---

## 🎨 Exibição Visual na UI

### Aba: Proprietários/Inquilinos

```
═══════════════════════════════════════════════════════
              PROPRIETÁRIOS / INQUILINOS
═══════════════════════════════════════════════════════

[Pesquisar unidade/bloco...]

═══════════════════════════════════════════════════════
┌─ Bloco A / Unidade 101
│ 🏠 João (Proprietário)
│    CPF: 123.456.789-10
│
│ 👤 Ana (Inquilino)
│    CPF: 234.567.891-01
├─────────────────────────────────────────────────────

┌─ Bloco A / Unidade 102
│ 🏠 Maria (Proprietária)
│    CPF: 345.678.912-02
├─────────────────────────────────────────────────────

┌─ Bloco B / Unidade 201
│ 🏠 Pedro (Proprietário)
│    CPF: 456.789.123-03
│
│ 👤 Carlos (Inquilino)
│    CPF: 567.890.234-04
├─────────────────────────────────────────────────────
```

---

## 🔍 Exemplo Prático: Buscar "A/101"

### 1. Usuário digita na pesquisa:
```
"A/101"
```

### 2. Sistema processa:
```dart
// Procura onde bloco = "A" E numero = "101"
List<Unidade> resultados = _unidades.where((u) =>
  u.bloco == "A" && u.numero == "101"
).toList();
```

### 3. Sistema busca todas as pessoas:
```dart
// Proprietários dessa unidade
_proprietarios.where((p) => 
  p.unidadeId == unidadeProcurada.id
)

// Inquilinos dessa unidade
_inquilinos.where((i) => 
  i.unidadeId == unidadeProcurada.id
)

// Visitantes dessa unidade
_visitantes.where((v) => 
  v.unidadeBloco == "A" && v.unidadeNumero == "101"
)

// Autorizados dessa unidade
_autorizados.where((a) => 
  a.unidadeBloco == "A" && a.unidadeNumero == "101"
)

// Encomendas dessa unidade
_encomendas.where((e) => 
  e.unidadeBloco == "A" && e.unidadeNumero == "101"
)
```

### 4. Exibe resultado consolidado:
```
Unidade A/101:
  👤 João (Proprietário)
  👤 Ana (Inquilino)
  🚗 1 visitante registrado
  ✅ 2 autorizados
  📦 3 encomendas pendentes
```

---

## ⚠️ O Que Acontece Sem Blocos?

Se o condomínio tem `temBlocos = false`:

### Antes (Com Blocos):
```
Chave: "A/101"
Exibição: "A / 101"
```

### Depois (Sem Blocos):
```
Chave: "101" (só número)
Exibição: "101" (sem bloco)
```

**Código:**
```dart
String chaveUnidade = unidade.bloco != null && unidade.bloco!.isNotEmpty
    ? '${unidade.bloco}/${unidade.numero}'  // Se tem bloco
    : unidade.numero;                        // Se não tem bloco
```

---

## 🎓 Conclusão

### Por Que Todos Usam Blocos:

1. ✅ **Identificação Única** - "A/101" é diferente de "B/101"
2. ✅ **Agrupamento Lógico** - Organiza unidades por bloco
3. ✅ **Busca Eficiente** - Encontra tudo de uma unidade rapidamente
4. ✅ **Organização Visual** - Mostra dados estruturados
5. ✅ **Compatibilidade** - Funciona com ou sem blocos

### Estrutura:
```
Bloco (A, B, C...)
    └─ Unidade (101, 102...)
          ├─ Proprietários
          ├─ Inquilinos
          ├─ Visitantes
          ├─ Autorizados
          └─ Encomendas
```

### Adaptação ao `temBlocos`:
- ✅ Se `temBlocos = true`: Mostra "A/101" (bloco + número)
- ✅ Se `temBlocos = false`: Mostra "101" (só número)
- ✅ **Dados nunca mudam**, apenas a exibição muda

---

## 🔧 Código Principal de Agrupamento

```dart
// Este é o código que faz TUDO funcionar:
String chaveUnidade = unidade.bloco != null && unidade.bloco!.isNotEmpty
    ? '${unidade.bloco}/${unidade.numero}'
    : unidade.numero;

// Com essa chave:
// 1. Agrupa proprietários por unidade
// 2. Agrupa inquilinos por unidade
// 3. Agrupa visitantes por unidade
// 4. Agrupa autorizados por unidade
// 5. Agrupa encomendas por unidade
// 6. Permite buscar por "A/101" ou "101"
```

Este é o padrão usado **em TODAS as seções** da Portaria do Representante!
