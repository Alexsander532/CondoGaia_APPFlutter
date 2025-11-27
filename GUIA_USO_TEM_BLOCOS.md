# 🎯 GUIA DE USO: Configuração de Blocos por Condomínio

## 📱 Como usar a nova funcionalidade

### Acessar a Tela
1. Acesse **Home → Gestão → Unidades/Morador**
2. Você verá o novo **TOGGLE** ao lado do botão "ADICIONAR UNIDADE"

```
┌─────────────────────────────────────────────────┐
│  ➕ ADICIONAR UNIDADE    [⚙️ Com Blocos] |▢|   │
│                                                 │
│  Tooltip: "Com blocos (Bloco A, B, C...)"      │
└─────────────────────────────────────────────────┘
```

---

## 🔀 TOGGLE: Alternando entre modos

### Modo 1: COM BLOCOS ✅ (Padrão)
**Quando o toggle está LIGADO (azul):**

```
UNIDADES MORADOR
┌─────────────────────────────────┐
│  Bloco A                  5/10  │  ← Cabeçalho com nome do bloco
│  [101] [102] [103] [104] [105] │  ← Unidades agrupadas
├─────────────────────────────────┤
│  Bloco B                  8/8   │
│  [201] [202] [203] [204] [205] │
│  [206] [207] [208]             │
└─────────────────────────────────┘
```

**O que funciona:**
- ✅ Unidades organizadas por Bloco (A, B, C...)
- ✅ Mostra ocupação (5/10, 8/8)
- ✅ Botão "ADICIONAR UNIDADE" → dropdown para selecionar bloco
- ✅ Pode criar novos blocos
- ✅ Portaria mostra: "Bloco A - Unidade 101"
- ✅ Reservas mostram: "Bloco A - 101"

---

### Modo 2: SEM BLOCOS 🔲 (Novo)
**Quando o toggle está DESLIGADO (cinza):**

```
UNIDADES MORADOR
┌─────────────────────────────────┐
│  [101] [102] [103] [104] [105] │  ← SEM título de bloco
│  [106] [107] [108] [201] [202] │  ← Grid simples
│  [203] [204] [205] [206] [207] │
│  [208]                          │
└─────────────────────────────────┘
```

**O que funciona:**
- ✅ Unidades mostradas em grid, sem agrupamento
- ✅ Ordenadas por número (101, 102, 103...)
- ✅ Botão "ADICIONAR UNIDADE" → **SEM dropdown de bloco**
- ✅ Mostra mensagem: "Condomínio sem blocos"
- ✅ Unidades criadas internamente em bloco "invisível"
- ✅ Portaria mostra: "Unidade 101" (sem bloco)
- ✅ Reservas mostram: "101" (sem bloco)

---

## 🔄 Como alternar entre modos

### Passo 1: Clique no Toggle
```
[⚙️ Com Blocos] |▢|  ← Clique aqui para mudar
```

### Passo 2: Aguarde a atualização
```
⏳ Loading... (loading spinner aparece no toggle)
```

### Passo 3: Veja a confirmação
```
✅ Exibição sem blocos ativada!  ← Snackbar aparece
```

### Passo 4: Interface se adapta automaticamente
- Unidades são reorganizadas
- Dropdown de blocos desaparece/aparece
- Tudo continua funcionando normalmente

---

## 📝 Criar Unidade - Comparação

### COM BLOCOS (toggle ON)
```
CRIAR NOVA UNIDADE
┌─────────────────────────────┐
│ Número da Unidade: [  101  ] │
│                             │
│ Selecione ou crie um Bloco: │
│ ┌─────────────────────────┐ │
│ │ Bloco A         ▼       │ │  ← Dropdown
│ └─────────────────────────┘ │
│                             │
│ + Criar Novo Bloco          │  ← Botão para novo bloco
│                             │
│ [CANCELAR] [CRIAR]          │
└─────────────────────────────┘
```

### SEM BLOCOS (toggle OFF)
```
CRIAR NOVA UNIDADE
┌─────────────────────────────┐
│ Número da Unidade: [  101  ] │
│                             │
│ ┌─────────────────────────┐ │
│ │ ℹ️ Condomínio sem blocos  │ │  ← Informativo
│ │ Unidade será criada sem  │ │
│ │ agrupamento              │ │
│ └─────────────────────────┘ │
│                             │
│ [CANCELAR] [CRIAR]          │
└─────────────────────────────┘
```

---

## 🏢 Comportamento nas outras telas

### Portaria do Representante
| Modo | Exibição | Exemplo |
|------|----------|---------|
| COM BLOCOS | Bloco/Unidade | "Bloco A/101" |
| SEM BLOCOS | Apenas número | "101" |

✅ **Já funciona automaticamente!**

---

### Reservas
| Modo | Dropdown | Exibição |
|------|----------|----------|
| COM BLOCOS | Bloco A - 101 | Unidade: Bloco A - 101 |
| SEM BLOCOS | 101 | Unidade: 101 |

✅ **Já funciona automaticamente!**

---

### Agenda (Representante/Prop/Inq)
- ⚪ **SEM MUDANÇAS** - Agenda não mostra blocos, apenas eventos

---

## ❓ Perguntas Frequentes

### P1: Posso alternar entre modos quantas vezes quiser?
**R:** Sim! Você pode ligar e desligar o toggle quantas vezes desejar. As unidades não são perdidas.

### P2: Os dados das unidades são perdidos quando mudo de modo?
**R:** Não! Todas as unidades e seus dados (proprietários, inquilinos, etc.) são mantidos.

### P3: Quando mudo para "sem blocos", as unidades existentes ainda têm bloco?
**R:** Sim, internamente elas continuam em um bloco invisível, mas a UI não mostra isso.

### P4: Posso criar blocos quando está em modo "sem blocos"?
**R:** Não, o botão "Criar Novo Bloco" fica escondido. Você pode apenas criar unidades.

### P5: O que acontece se eu criar unidades em "com blocos" e depois mudo para "sem blocos"?
**R:** Todas as unidades continuam existindo, mas aparecem em um grid único, ordenadas por número.

### P6: Qual é o modo padrão?
**R:** Por padrão, todos os condominios são criados em modo "COM BLOCOS" (compatibilidade com sistema existente).

---

## 🛠️ Troubleshooting

### O toggle não responde
- Aguarde alguns segundos (pode estar atualizando no banco)
- Recarregue a tela (seta de voltar e voltar)

### Unidades desapareceram ao alternar
- Elas não desapareceram, apenas a visualização mudou
- Alterne o toggle de volta para vê-las
- Ou recarregue a tela

### Erro ao salvar a configuração
- Verifique sua conexão com internet
- Verifique se tem permissão no banco (RLS)
- Tente novamente

### Portaria/Reservas mostram blocos mesmo em modo "sem blocos"
- Recarregue a tela
- As unidades antigas podem ainda ter bloco preenchido
- Edite-as para remover o bloco

---

## 📊 Casos de Uso

### ✅ Use COM BLOCOS se:
- Seu condomínio tem várias torres/blocos (A, B, C...)
- Precisa organizar unidades em grupos
- Quer exibir ocupação por bloco
- Tem mais de 50 unidades

### ✅ Use SEM BLOCOS se:
- Condomínio tem apenas uma estrutura
- Prefere lista simples de unidades
- Quer interface mais limpa
- Tem menos de 50 unidades

---

## 🎨 Comportamento visual do Toggle

```
ESTADOS VISUAIS DO TOGGLE:

COM BLOCOS (Ativo)
┌─────────────────────────────┐
│  [🔀 Ativo]                 │
│  ⬜ → Azul (Color: #4A90E2) │
│  Ícone: layers              │
│  Tooltip: Com blocos...     │
└─────────────────────────────┘

SEM BLOCOS (Inativo)
┌─────────────────────────────┐
│  [⊙ Inativo]                │
│  ⬜ → Cinza (Color: #999999)│
│  Ícone: list_alt            │
│  Tooltip: Sem blocos...     │
└─────────────────────────────┘

ATUALIZANDO
┌─────────────────────────────┐
│  [⏳ Atualizando]            │
│  ⟳ Spinner gira              │
│  Toggle desabilitado        │
└─────────────────────────────┘
```

---

**Aproveite a nova funcionalidade! 🚀**
