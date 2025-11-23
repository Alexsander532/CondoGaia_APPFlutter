# 📚 GUIA COMPLETO - CAMPO DE UNIDADE NA EDIÇÃO

> Documentação detalhada sobre como o campo "Unidade" é mapeado na tela de edição de dados da unidade

## 🎯 Objetivo

Este guia explica **passo a passo** como o campo de número de unidade ("310") viaja através do sistema:

- 🎨 **Interface** (o que o usuário vê)
- 📦 **Modelo** (como os dados são estruturados)
- 🔌 **Serviço** (como os dados são buscados/salvos)
- 🗄️ **Banco de Dados** (onde os dados são armazenados)

---

## 📖 DOCUMENTOS DISPONÍVEIS

### 1. **MAPEAMENTO_CAMPO_UNIDADE.md** ⭐ COMECE AQUI
   - 📊 Mapeamento técnico completo
   - 🔗 Tabela de relações entre camadas
   - 💾 Estrutura no banco de dados
   - 🔄 Fluxo de carregamento e salvamento
   - ✅ Validações em cada camada
   
   **Ideal para:** Entender a arquitetura completa

### 2. **DIAGRAMA_FLUXO_CAMPO_UNIDADE.md** 🎨 VISUAL
   - 📐 Diagramas de arquitetura
   - 🔀 Fluxos detalhados com ASCII art
   - 📋 Exemplos práticos
   - 🧭 Localização de código
   - ⚡ Cheat sheet rápido
   
   **Ideal para:** Ver visualmente como funciona

---

## 🚀 COMEÇO RÁPIDO

### Você quer...

#### ❓ "Entender o mapeamento completo"
→ Leia: `MAPEAMENTO_CAMPO_UNIDADE.md` seção 1-4

#### ❓ "Saber por que o campo funciona"
→ Leia: `DIAGRAMA_FLUXO_CAMPO_UNIDADE.md` seção 1-3

#### ❓ "Achar onde o código está"
→ Leia: `MAPEAMENTO_CAMPO_UNIDADE.md` tabela + seção "Arquivos Relacionados"

#### ❓ "Ver um exemplo concreto"
→ Leia: `DIAGRAMA_FLUXO_CAMPO_UNIDADE.md` seção 6

#### ❓ "Editar/modificar o campo"
→ Leia: `MAPEAMENTO_CAMPO_UNIDADE.md` seção "Para Editar/Manter o Campo"

#### ❓ "Rápida referência"
→ Leia: `DIAGRAMA_FLUXO_CAMPO_UNIDADE.md` seção 8 (Cheat Sheet)

---

## 📍 ARQUITETURA EM 30 SEGUNDOS

```
┌─────────────────────────────────────────┐
│   TELA (UI)                              │
│   _unidadeController.text = "310"       │
└─────────────────────────────────────────┘
              ↓ Quando edita e salva ↓
┌─────────────────────────────────────────┐
│   MODELO (Dart)                          │
│   Unidade(numero: "310", ...)           │
└─────────────────────────────────────────┘
              ↓ Envia para banco ↓
┌─────────────────────────────────────────┐
│   SERVIÇO (Backend)                      │
│   buscarDetalhesUnidade(numero: "310") │
└─────────────────────────────────────────┘
              ↓ Busca/Salva em ↓
┌─────────────────────────────────────────┐
│   BANCO (PostgreSQL)                     │
│   unidades.numero = "310"               │
└─────────────────────────────────────────┘
```

---

## 🗂️ ESTRUTURA DOS DOCUMENTOS

### MAPEAMENTO_CAMPO_UNIDADE.md

```
1. Visão Geral
   └─ Fluxo de 3 camadas

2. Mapeamento Completo
   ├─ Na Interface (Flutter)
   ├─ Carregamento de Dados
   ├─ No Modelo Dart
   └─ No Banco de Dados

3. Tabela de Mapeamento
   └─ Visão geral de todos os campos

4. Ciclo Completo
   ├─ Ao Carregar
   └─ Ao Salvar

5. Validações
   ├─ Interface
   └─ Banco

6. Exemplo Prático
   ├─ Na Tela
   └─ No Banco

7. Para Editar/Manter
   └─ Como modificar o campo

8. Arquivos Relacionados
   └─ Lista de arquivos envolvidos
```

### DIAGRAMA_FLUXO_CAMPO_UNIDADE.md

```
1. Diagrama de Arquitetura
   └─ Visual da estrutura completa

2. Fluxo de Carregamento Detalhado
   └─ Passo a passo com setas

3. Fluxo de Salvamento
   └─ Passo a passo com setas

4. Mapeamento Campo por Campo
   └─ Tabela de equivalência

5. Onde Encontrar Cada Referência
   ├─ No Código Frontend
   ├─ No Serviço
   ├─ No Modelo
   └─ No Banco

6. Exemplo Concreto
   ├─ Na Tela
   ├─ No Objeto Dart
   ├─ No JSON
   └─ No Banco

7. Validações em Cada Camada
   ├─ Camada UI
   ├─ Camada Modelo
   └─ Camada Banco

8. Ciclo Completo - Resumo
   └─ Fluxo simplificado

9. Cheat Sheet
   └─ Tabela rápida de referência
```

---

## 🔑 CONCEITOS-CHAVE

### Campo "Unidade"
- **O quê:** Número que identifica a unidade (ex: "310")
- **Onde aparece:** Tela de edição de dados da unidade
- **Tipo:** String (text) com máx 10 caracteres
- **Obrigatório:** Sim

### Controlador (_unidadeController)
- **O quê:** Objeto que armazena o valor do campo de texto
- **Onde:** Em `detalhes_unidade_screen.dart` linha 56
- **Função:** Conectar UI com dados
- **Valor:** `_unidadeController.text` = "310"

### Modelo Unidade
- **O quê:** Classe que representa uma unidade
- **Onde:** Em `unidade.dart`
- **Campos:** numero, bloco, fracao_ideal, area_m2, etc.
- **Funções:** fromJson (ler), toJson (escrever)

### Serviço UnidadeDetalhesService
- **O quê:** Busca e salva dados no banco
- **Onde:** Em `unidade_detalhes_service.dart`
- **Métodos:** buscarDetalhesUnidade, atualizarUnidade
- **Filtro:** Busca por numero + bloco + condominio_id

### Tabela unidades
- **O quê:** Armazena os dados das unidades
- **Onde:** Banco PostgreSQL (Supabase)
- **Campo:** numero VARCHAR(10) NOT NULL
- **Índice:** UNIQUE(bloco_id, numero)

---

## 💡 DICAS IMPORTANTES

### ✅ O que o campo faz bem
- ✓ Identifica unicamente cada unidade (junto com bloco)
- ✓ É obrigatório e validado
- ✓ Tem limite de 10 caracteres
- ✓ É editável na interface
- ✓ Sincroniza com banco automaticamente

### ⚠️ Limitações e restrições
- ⚠️ Não pode estar vazio
- ⚠️ Máximo 10 caracteres
- ⚠️ Deve ser único por bloco
- ⚠️ Não pode ter apenas espaços

### 🔧 Se você quiser modificar
- **Tipo de dado:** Altere em 3 lugares (UI, Modelo, Banco)
- **Validação:** Adicione no salvamento + SQL
- **Rótulo:** Apenas na interface
- **Posição:** Apenas na interface

---

## 📚 LEITURA RECOMENDADA

### Para iniciantes
1. **DIAGRAMA_FLUXO_CAMPO_UNIDADE.md** - Entenda visualmente
2. **MAPEAMENTO_CAMPO_UNIDADE.md** - Aprenda detalhes
3. **Exemplo Prático** - Veja um caso real

### Para desenvolvedores
1. **MAPEAMENTO_CAMPO_UNIDADE.md** - Tabela de mapeamento
2. **Ciclo Completo** - Carregamento e salvamento
3. **Validações** - O que precisa ser mantido
4. **Arquivos Relacionados** - Código exato

### Para manutenção
1. **Para Editar/Manter o Campo** - Como modificar
2. **Cheat Sheet** - Referência rápida
3. **Arquivos Relacionados** - Tudo que afeta

---

## 📋 CHECKLIST - O QUE MEMORIZAR

### Basicamente
- [ ] Campo é armazenado em `unidades.numero`
- [ ] UI acessa via `_unidadeController.text`
- [ ] Modelo: `Unidade.numero` (String)
- [ ] Banco busca por: `WHERE numero = '310' AND bloco = 'A'`

### Detalhes
- [ ] Máx 10 caracteres (VARCHAR(10))
- [ ] Obrigatório (NOT NULL)
- [ ] Único por bloco (UNIQUE constraint)
- [ ] Ser em `detalhes_unidade_screen.dart` linha ~610

### Fluxo
- [ ] Carregamento: Banco → Modelo → Controlador → UI
- [ ] Salvamento: UI → Controlador → Modelo → Banco

---

## 🎓 EXEMPLOS DE USO

### Ler o valor na UI
```dart
String numero = _unidadeController.text;  // "310"
```

### Criar um objeto Unidade
```dart
final unidade = Unidade(
  numero: '310',
  bloco: 'A',
  condominioId: 'abc123',
  // ...
);
```

### Converter de JSON (do banco)
```dart
final unidade = Unidade.fromJson({
  'numero': '310',
  'bloco': 'A',
  // ...
});
```

### Converter para JSON (para salvar)
```dart
final json = unidade.toJson();
// {
//   'numero': '310',
//   'bloco': 'A',
//   // ...
// }
```

### Buscar do banco
```dart
final dados = await service.buscarDetalhesUnidade(
  condominioId: 'abc123',
  numero: '310',      // ← Campo que filtra
  bloco: 'A',
);
```

---

## ❓ FAQ - PERGUNTAS FREQUENTES

### P: Por que o campo é chamado "numero" no banco e não "unidade"?
**R:** Para clareza. "unidade" é a classe inteira, "numero" é o campo específico que armazena o número.

### P: O campo "310" é string ou número?
**R:** String. Porque pode ter letras (ex: "310A", "A101") e é mais fácil para comparação.

### P: Precisa ser único?
**R:** Sim, mas apenas dentro do bloco. Por isso a constraint é `UNIQUE(bloco_id, numero)`.

### P: O que acontece se tentar deixar em branco?
**R:** O banco rejeita com erro `NOT NULL`, e a interface deveria validar antes.

### P: Posso mudar o tipo de String para int?
**R:** Tecnicamente sim, mas precisaria alterar 3 lugares (UI, Modelo, Banco) e perder suporte a letras.

### P: Onde está o código que salva?
**R:** `detalhes_unidade_screen.dart` linha ~3400 (método `_salvarUnidade()`).

### P: Onde está o código que carrega?
**R:** `detalhes_unidade_screen.dart` linha ~147 (método `_carregarDados()`).

---

## 🔍 BUSCAR RÁPIDO NO CÓDIGO

### Arquivo: detalhes_unidade_screen.dart
```
Ctrl+G → 56    → TextEditingController declaration
Ctrl+G → 147   → _carregarDados() method
Ctrl+G → 161   → Preenche _unidadeController
Ctrl+G → 610   → Renderiza TextField
Ctrl+G → 3400  → _salvarUnidade() method (aproximadamente)
```

### Arquivo: unidade.dart
```
Ctrl+G → 14    → final String numero;
Ctrl+G → 102   → factory Unidade.fromJson()
Ctrl+G → 135   → toJson() mapping
```

### Arquivo: unidade_detalhes_service.dart
```
Ctrl+G → 12-25 → Método buscarDetalhesUnidade
Ctrl+G → 25    → Query com filtro numero
Ctrl+G → 35    → Unidade.fromJson()
Ctrl+G → 100   → atualizarUnidade()
```

### Arquivo: 10_recreate_unidades_manual_input.sql
```
Ctrl+F → "numero VARCHAR(10)" → Definição do campo
Ctrl+F → "UNIQUE INDEX" → Constraint de unicidade
```

---

## 📞 RESUMO EXECUTIVO

Se você está aqui porque:

| Motivo | Faça isto |
|--------|-----------|
| Não entendo como funciona | Leia: DIAGRAMA_FLUXO_CAMPO_UNIDADE.md seção 1 |
| Preciso editar o campo | Leia: MAPEAMENTO_CAMPO_UNIDADE.md seção "Para Editar" |
| Achar código específico | Leia: DIAGRAMA_FLUXO seção "Onde Encontrar" |
| Preciso de referência rápida | Leia: DIAGRAMA_FLUXO seção 8 (Cheat Sheet) |
| Bug com campo de unidade | Leia: MAPEAMENTO seção "Validações" |
| Entender o fluxo de dados | Leia: DIAGRAMA_FLUXO seções 2-3 |

---

## 🎯 PRÓXIMOS PASSOS

Depois de ler esta documentação:

1. ✅ Abra `detalhes_unidade_screen.dart` linha 56
2. ✅ Procure por `_unidadeController`
3. ✅ Veja como é usado na UI (linha ~610)
4. ✅ Abra `unidade.dart` e veja a classe
5. ✅ Abra `unidade_detalhes_service.dart` e veja como busca
6. ✅ Execute a app e edite uma unidade para ver na prática

---

**Última atualização:** Novembro 2025
**Status:** ✅ Documentação Completa
**Versão:** 1.0

