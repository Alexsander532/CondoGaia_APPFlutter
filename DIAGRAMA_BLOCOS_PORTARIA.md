# 🎯 DIAGRAMA VISUAL: COMO BLOCOS FUNCIONAM NA PORTARIA

## 📊 Estrutura Hierárquica

```
BANCO DE DADOS (Supabase)
│
├── Tabela: unidades
│   ├── ID: 1 | Número: 101 | Bloco: A
│   ├── ID: 2 | Número: 102 | Bloco: A
│   ├── ID: 3 | Número: 201 | Bloco: B
│   └── ID: 4 | Número: 202 | Bloco: B
│
├── Tabela: proprietarios
│   ├── João | Unidade ID: 1
│   ├── Maria | Unidade ID: 2
│   ├── Pedro | Unidade ID: 3
│   └── Lucas | Unidade ID: 4
│
├── Tabela: inquilinos
│   ├── Ana | Unidade ID: 1
│   ├── Carlos | Unidade ID: 3
│   └── Fernanda | Unidade ID: 4
│
└── Tabela: visitantes
    ├── José | Bloco: A | Unidade: 101
    ├── Rita | Bloco: A | Unidade: 102
    ├── Marco | Bloco: B | Unidade: 201
    └── Paula | Bloco: B | Unidade: 202
```

---

## 🔄 Processo de Agrupamento

### PASSO 1: Carregar Dados Separados

```
PROPRIETARIOS          INQUILINOS            VISITANTES
    │                      │                      │
    ├─ João               ├─ Ana               ├─ José
    │  unidadeId: 1       │  unidadeId: 1      │  bloco: A
    │                     │                    │  numero: 101
    ├─ Maria              ├─ Carlos            │
    │  unidadeId: 2       │  unidadeId: 3      ├─ Rita
    │                     │                    │  bloco: A
    ├─ Pedro              └─ Fernanda          │  numero: 102
    │  unidadeId: 3          unidadeId: 4     │
    │                                         ├─ Marco
    └─ Lucas                                  │  bloco: B
       unidadeId: 4                           │  numero: 201
                                              │
                                              └─ Paula
                                                 bloco: B
                                                 numero: 202
```

### PASSO 2: Buscar Unidades Associadas

```
João (unidadeId: 1)
    │
    └─► Busca unidade ID: 1
            │
            └─► ENCONTRA: Número: 101, Bloco: A

Maria (unidadeId: 2)
    │
    └─► Busca unidade ID: 2
            │
            └─► ENCONTRA: Número: 102, Bloco: A

Pedro (unidadeId: 3)
    │
    └─► Busca unidade ID: 3
            │
            └─► ENCONTRA: Número: 201, Bloco: B

Lucas (unidadeId: 4)
    │
    └─► Busca unidade ID: 4
            │
            └─► ENCONTRA: Número: 202, Bloco: B
```

### PASSO 3: Criar Chave de Agrupamento

```
Unidade 101, Bloco A:
    │
    ├─ João (Proprietário) ─────┐
    │                            │
    └─ Ana (Inquilino) ──────────┼─► Chave: "A/101"
                                 │
    └─ José (Visitante) ─────────┘

Unidade 102, Bloco A:
    │
    └─ Maria (Proprietária) ────┐
                                 │
    └─ Rita (Visitante) ─────────┼─► Chave: "A/102"
                                 │

Unidade 201, Bloco B:
    │
    ├─ Pedro (Proprietário) ────┐
    │                            │
    ├─ Carlos (Inquilino) ───────┼─► Chave: "B/201"
    │                            │
    └─ Marco (Visitante) ────────┘

Unidade 202, Bloco B:
    │
    ├─ Lucas (Proprietário) ────┐
    │                            │
    ├─ Fernanda (Inquilino) ─────┼─► Chave: "B/202"
    │                            │
    └─ Paula (Visitante) ────────┘
```

### PASSO 4: Agrupar em Mapa

```
pessoasPorUnidade = {
  "A/101": [
    { nome: "João", tipo: "Proprietário", fotoPerfil: ... },
    { nome: "Ana", tipo: "Inquilino", fotoPerfil: ... },
  ],
  
  "A/102": [
    { nome: "Maria", tipo: "Proprietária", fotoPerfil: ... },
  ],
  
  "B/201": [
    { nome: "Pedro", tipo: "Proprietário", fotoPerfil: ... },
    { nome: "Carlos", tipo: "Inquilino", fotoPerfil: ... },
  ],
  
  "B/202": [
    { nome: "Lucas", tipo: "Proprietário", fotoPerfil: ... },
    { nome: "Fernanda", tipo: "Inquilina", fotoPerfil: ... },
  ],
};
```

---

## 🖥️ Exibição na Tela

```
╔════════════════════════════════════════════════════════╗
║         PORTARIA DO REPRESENTANTE                      ║
╠════════════════════════════════════════════════════════╣
║                                                        ║
║  [Pesquisar unidade/bloco... ________________]         ║
║                                                        ║
╠════════════════════════════════════════════════════════╣
║                                                        ║
║  📍 BLOCO A / UNIDADE 101                             ║
║  ┌──────────────────────────────────────────────────┐ ║
║  │ 🏠 João (Proprietário)                           │ ║
║  │    CPF: 123.456.789-10                           │ ║
║  │ 👤 Ana (Inquilina)                               │ ║
║  │    CPF: 234.567.891-01                           │ ║
║  │ 🚗 José (Visitante)                              │ ║
║  └──────────────────────────────────────────────────┘ ║
║                                                        ║
║  📍 BLOCO A / UNIDADE 102                             ║
║  ┌──────────────────────────────────────────────────┐ ║
║  │ 🏠 Maria (Proprietária)                          │ ║
║  │    CPF: 345.678.912-02                           │ ║
║  │ 🚗 Rita (Visitante)                              │ ║
║  └──────────────────────────────────────────────────┘ ║
║                                                        ║
║  📍 BLOCO B / UNIDADE 201                             ║
║  ┌──────────────────────────────────────────────────┐ ║
║  │ 🏠 Pedro (Proprietário)                          │ ║
║  │    CPF: 456.789.123-03                           │ ║
║  │ 👤 Carlos (Inquilino)                            │ ║
║  │    CPF: 567.890.234-04                           │ ║
║  │ 🚗 Marco (Visitante)                             │ ║
║  └──────────────────────────────────────────────────┘ ║
║                                                        ║
║  📍 BLOCO B / UNIDADE 202                             ║
║  ┌──────────────────────────────────────────────────┐ ║
║  │ 🏠 Lucas (Proprietário)                          │ ║
║  │    CPF: 678.901.234-05                           │ ║
║  │ 👤 Fernanda (Inquilina)                          │ ║
║  │    CPF: 789.012.345-06                           │ ║
║  │ 🚗 Paula (Visitante)                             │ ║
║  └──────────────────────────────────────────────────┘ ║
║                                                        ║
╚════════════════════════════════════════════════════════╝
```

---

## 🔍 Fluxo de Busca

### Cenário: Usuário digita "A/101"

```
┌─────────────────────────────────────────────────┐
│ Usuário digita: "A/101"                         │
└────────────────┬────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────┐
│ Procura unidades onde:                          │
│   bloco == "A" E numero == "101"                │
└────────────────┬────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────┐
│ ENCONTROU: Unidade ID 1                         │
│   Número: 101                                   │
│   Bloco: A                                      │
└────────────────┬────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────┐
│ Busca proprietários dessa unidade:              │
│   WHERE unidadeId = 1                           │
│   RESULTADO: João                               │
└────────────────┬────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────┐
│ Busca inquilinos dessa unidade:                 │
│   WHERE unidadeId = 1                           │
│   RESULTADO: Ana                                │
└────────────────┬────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────┐
│ Busca visitantes dessa unidade:                 │
│   WHERE bloco = "A" E numero = "101"            │
│   RESULTADO: José                               │
└────────────────┬────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────┐
│ RESULTADO FINAL:                                │
│ ═══════════════════════════════════════════════ │
│ 📍 Bloco A / Unidade 101                        │
│    🏠 João (Proprietário)                       │
│    👤 Ana (Inquilina)                           │
│    🚗 José (Visitante)                          │
│    ✅ 2 Autorizados                             │
│    📦 1 Encomenda Pendente                      │
└─────────────────────────────────────────────────┘
```

---

## 🔄 Matriz de Agrupamento

```
┌─────────────────────────────────────────────────────────────┐
│                      AGRUPAMENTO POR UNIDADE                │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  CHAVE: "A/101"  ← Bloco + Número                          │
│  ┌───────────────────────────────────────────────────────┐ │
│  │ Proprietários:                                        │ │
│  │   ├─ João                                             │ │
│  │   └─ (mais...)                                        │ │
│  │                                                       │ │
│  │ Inquilinos:                                           │ │
│  │   ├─ Ana                                              │ │
│  │   └─ (mais...)                                        │ │
│  │                                                       │ │
│  │ Visitantes:                                           │ │
│  │   ├─ José                                             │ │
│  │   └─ (mais...)                                        │ │
│  │                                                       │ │
│  │ Autorizados:                                          │ │
│  │   ├─ [Nomes dos autorizados para inquilino]          │ │
│  │   └─ (mais...)                                        │ │
│  │                                                       │ │
│  │ Encomendas:                                           │ │
│  │   ├─ Pendentes: 2                                     │ │
│  │   ├─ Entregues: 5                                     │ │
│  │   └─ (mais...)                                        │ │
│  └───────────────────────────────────────────────────────┘ │
│                                                             │
│  CHAVE: "A/102"  ← Bloco + Número                          │
│  ┌───────────────────────────────────────────────────────┐ │
│  │ Proprietários:                                        │ │
│  │   ├─ Maria                                            │ │
│  │   └─ (mais...)                                        │ │
│  │ [... resto das seções]                                │ │
│  └───────────────────────────────────────────────────────┘ │
│                                                             │
│  CHAVE: "B/201"  ← Bloco + Número                          │
│  ┌───────────────────────────────────────────────────────┐ │
│  │ Proprietários:                                        │ │
│  │   ├─ Pedro                                            │ │
│  │   └─ (mais...)                                        │ │
│  │ [... resto das seções]                                │ │
│  └───────────────────────────────────────────────────────┘ │
│                                                             │
│  CHAVE: "B/202"  ← Bloco + Número                          │
│  ┌───────────────────────────────────────────────────────┐ │
│  │ Proprietários:                                        │ │
│  │   ├─ Lucas                                            │ │
│  │   └─ (mais...)                                        │ │
│  │ [... resto das seções]                                │ │
│  └───────────────────────────────────────────────────────┘ │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## 📊 Tabela: Qual Campo Usa Bloco

| Tipo | Campo | Descrição | Usa Bloco? |
|------|-------|-----------|-----------|
| Unidade | `unidade.bloco` | Campo na tabela unidades | ✅ SIM |
| Proprietário | `unidade.bloco` (via lookup) | Encontra bloco da unidade | ✅ SIM |
| Inquilino | `unidade.bloco` (via lookup) | Encontra bloco da unidade | ✅ SIM |
| Visitante | `visitante.unidadeBloco` | Campo direto na seção | ✅ SIM |
| Autorizado | `autorizado.unidadeBloco` | Campo direto na seção | ✅ SIM |
| Encomenda | `encomenda.unidadeBloco` | Campo direto na seção | ✅ SIM |

---

## 🎯 Padrão de Código Repetido

Este padrão aparece **VÁRIAS VEZES** no arquivo:

```dart
String chaveUnidade = unidade.bloco != null && unidade.bloco!.isNotEmpty
    ? '${unidade.bloco}/${unidade.numero}'
    : unidade.numero;
```

**Localidades (linhas aproximadas):**
1. **Linha ~1546** - Encomendas Pendentes
2. **Linha ~1586** - Encomendas Entregues
3. **Linha ~873** - Exibição na pesquisa

**Motivo:** Precisa criar a mesma chave em todos os lugares para garantir consistência no agrupamento!

---

## ⚡ Fluxo Rápido: Do Usuário ao Dado

```
Usuário abre Portaria
         │
         ▼
Carrega dados: Proprietários, Inquilinos, Visitantes, etc
         │
         ▼
Para CADA unidade, cria chave: "A/101", "A/102", etc
         │
         ▼
Agrupa proprietários + inquilinos + visitantes por chave
         │
         ▼
Exibe tudo organizado por bloco
         │
         ▼
Usuário digita "A/101" na busca
         │
         ▼
Filtra pela chave "A/101"
         │
         ▼
Mostra TODAS as informações dessa unidade
         │
         ▼
Usuário vê proprietários, inquilinos, visitantes, etc de A/101
```

---

## 🎓 Por Que Todos Usam a Mesma Chave?

### ❌ Se usassem chaves diferentes:

```
Proprietário de A/101: chave = "101"
Visitante de A/101: chave = "A_101"
Encomenda de A/101: chave = "A-101"

Resultado: DESASTRE!
Não consegue encontrar as informações associadas!
```

### ✅ Com a mesma chave:

```
Proprietário de A/101: chave = "A/101"
Visitante de A/101: chave = "A/101"
Encomenda de A/101: chave = "A/101"

Resultado: PERFEITO!
Todos os dados de A/101 são encontrados facilmente!
```

---

## 🔐 Garantia de Consistência

```
Toda vez que alguém precisa referenciar uma unidade:
│
├─ Proprietário?  ─► Busca bloco da unidade ─► Cria chave "A/101"
├─ Inquilino?     ─► Busca bloco da unidade ─► Cria chave "A/101"
├─ Visitante?     ─► Usa unidadeBloco       ─► Cria chave "A/101"
├─ Autorizado?    ─► Usa unidadeBloco       ─► Cria chave "A/101"
└─ Encomenda?     ─► Usa unidadeBloco       ─► Cria chave "A/101"

Resultado: MESMA CHAVE = DADOS AGRUPADOS CORRETAMENTE!
```

---

## 📌 Conclusão do Diagrama

A Portaria do Representante **precisa dos blocos** para:

1. ✅ **Organizar dados** - Agrupa tudo por unidade
2. ✅ **Buscar rapidamente** - Encontra tudo de uma unidade
3. ✅ **Exibir claramente** - Mostra estrutura lógica (Bloco A/101)
4. ✅ **Manter consistência** - Mesma chave em todas as seções
5. ✅ **Evitar conflitos** - "A/101" ≠ "B/101"

**A chave é:** `"${bloco}/${numero}"` ou apenas `numero` (se sem bloco)
