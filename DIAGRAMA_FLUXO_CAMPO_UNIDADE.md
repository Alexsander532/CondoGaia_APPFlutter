# 🎨 VISUALIZAÇÃO - FLUXO DO CAMPO DE UNIDADE

## 1. DIAGRAMA DE ARQUITETURA

```
┌──────────────────────────────────────────────────────────────────┐
│                        TELA DE EDIÇÃO                             │
│                  (detalhes_unidade_screen.dart)                   │
│                                                                    │
│  ┌────────────────────────────────────────────────────────────┐  │
│  │  CAMPO VISUAL: "Unidade*"                                  │  │
│  │  ┌──────────────────────────────────────────────────────┐  │  │
│  │  │ 310                                           |       │  │  │
│  │  └──────────────────────────────────────────────────────┘  │  │
│  │  Controlador: _unidadeController                           │  │
│  └────────────────────────────────────────────────────────────┘  │
│                          ↓ onChanged                               │
│  Armazena valor em _unidadeController.text = "310"              │
└──────────────────────────────────────────────────────────────────┘
                           ↓
┌──────────────────────────────────────────────────────────────────┐
│                        MODELO DART                                │
│                      (unidade.dart)                               │
│                                                                    │
│  class Unidade {                                                 │
│    final String numero;  // "310" ← CAMPO PRINCIPAL             │
│    final String bloco;   // "A"                                  │
│    final double? fracaoIdeal;  // null                           │
│    ...                                                            │
│  }                                                                │
│                                                                    │
│  Unidade.fromJson({'numero': '310', 'bloco': 'A', ...})        │
└──────────────────────────────────────────────────────────────────┘
                           ↓
┌──────────────────────────────────────────────────────────────────┐
│                      SERVIÇO BACKEND                              │
│              (unidade_detalhes_service.dart)                      │
│                                                                    │
│  buscarDetalhesUnidade(                                          │
│    condominioId: 'xxx...',                                       │
│    numero: '310',        ← USADO NO FILTRO                       │
│    bloco: 'A'                                                    │
│  )                                                                │
│                                                                    │
│  Query SQL gerada:                                               │
│  SELECT * FROM unidades                                          │
│  WHERE condominio_id = 'xxx...'                                  │
│    AND numero = '310'                                            │
│    AND bloco = 'A'                                               │
└──────────────────────────────────────────────────────────────────┘
                           ↓
┌──────────────────────────────────────────────────────────────────┐
│                   BANCO DE DADOS                                  │
│            (PostgreSQL - Supabase)                                │
│                                                                    │
│  Tabela: unidades                                                │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │ id  │ numero │ bloco │ fracao_ideal │ area_m2 │ ...     │  │
│  ├─────┼────────┼───────┼──────────────┼─────────┼─────────┤  │
│  │uuid │  310   │   A   │   0.014      │  NULL   │ ...     │  │
│  │uuid │  311   │   A   │   0.014      │  65.50  │ ...     │  │
│  │uuid │  101   │   B   │   NULL       │  NULL   │ ...     │  │
│  └─────┴────────┴───────┴──────────────┴─────────┴─────────┘  │
│                          ▲                                        │
│                   Encontra a linha                                │
│                  numero = '310'                                   │
└──────────────────────────────────────────────────────────────────┘
```

---

## 2. FLUXO DE CARREGAMENTO DETALHADO

```
USUARIO ACESSA A TELA
    │
    ├─ DetalhesUnidadeScreen recebe:
    │  ├─ condominioId: 'abc123...'
    │  ├─ bloco: 'A'
    │  └─ unidade: '310'
    │
    ↓
initState() chamado
    │
    ├─ Se modo='criar' → _inicializarParaCriacao()
    │  └─ Carrega apenas bloco e unidade dos parâmetros
    │
    └─ Se modo='editar' → _carregarDados()  ← CASO ATUAL
        │
        ↓
    _carregarDados() chama:
        │
        ├─ UnidadeDetalhesService.buscarDetalhesUnidade(
        │  │  condominioId='abc123...',
        │  │  numero='310',
        │  │  bloco='A'
        │  └─)
        │
        ↓
    Supabase Query:
        │
        ├─ from('unidades')
        ├─ .select()
        ├─ .eq('condominio_id', 'abc123...')
        ├─ .eq('numero', '310')         ← FILTRO PRINCIPAL
        ├─ .eq('bloco', 'A')
        └─ .maybeSingle()               ← Retorna 1 ou null
        │
        ↓
    Banco retorna JSON:
        │
        ├─ {
        │    id: 'uuid123',
        │    numero: '310',              ← CAMPO ENCONTRADO
        │    bloco: 'A',
        │    fracao_ideal: 0.014,
        │    area_m2: null,
        │    ...
        │  }
        │
        ↓
    Unidade.fromJson() converte para objeto
        │
        ├─ Unidade(
        │    numero: '310',
        │    bloco: 'A',
        │    fracaoIdeal: 0.014,
        │    ...
        │  )
        │
        ↓
    setState() preenche os controladores
        │
        ├─ _unidadeController.text = '310'
        ├─ _blocoController.text = 'A'
        ├─ _fracaoIdealController.text = '0.014'
        └─ ...
        │
        ↓
    Widget reconstruído (rebuild)
        │
        └─ Campo agora mostra "310" ✅
```

---

## 3. FLUXO DE SALVAMENTO

```
USUARIO CLICA EM "SALVAR UNIDADE"
    │
    ↓
_salvarUnidade() chamado
    │
    ├─ Coleta valores dos controladores:
    │  ├─ numero = _unidadeController.text  // "310"
    │  ├─ bloco = _blocoController.text     // "A"
    │  ├─ fracao = _fracaoIdealController.text
    │  └─ ...
    │
    ├─ Validação básica:
    │  └─ if (numero.isEmpty) return erro
    │
    ├─ setState(() { _isLoadingUnidade = true; })
    │
    ↓
Criar Map com dados:
    │
    ├─ dados = {
    │    'numero': '310',
    │    'bloco': 'A',
    │    'fracao_ideal': 0.014,
    │    'area_m2': null,
    │    ...
    │  }
    │
    ↓
Chamar serviço:
    │
    ├─ _service.atualizarUnidade(
    │    unidadeId: 'uuid123',
    │    dados: dados
    │  )
    │
    ↓
Banco executa UPDATE:
    │
    ├─ UPDATE unidades 
    │  SET numero='310', bloco='A', fracao_ideal=0.014, ...
    │  WHERE id='uuid123'
    │
    ├─ Resultado: 1 registro atualizado ✅
    │
    ↓
setState() com sucesso:
    │
    ├─ _isLoadingUnidade = false
    └─ Mostrar snackbar: "Dados da unidade salvos com sucesso!"
```

---

## 4. MAPEAMENTO CAMPO POR CAMPO

```
┌─────────────────────────────────────────────────────────────┐
│                     MAPEAMENTO DETALHADO                     │
├────────────────┬──────────────┬──────────────┬──────────────┤
│ UI (Flutter)   │ Modelo       │ JSON/Banco   │ SQL Type     │
├────────────────┼──────────────┼──────────────┼──────────────┤
│                │              │              │              │
│ _unidadeCtrl   │ Unidade      │ {            │ CREATE TABLE │
│   .text        │   .numero    │   numero:    │ unidades {   │
│   = "310"      │   = "310"    │   "310"      │   numero     │
│                │              │ }            │   VARCHAR(10)│
│                │              │              │   NOT NULL   │
│                │              │              │ }            │
│                │              │              │              │
│ TextField      │ String       │ String       │ VARCHAR      │
│ (editable)     │ (final)      │ (dynamic)    │ (max 10)     │
│                │              │              │              │
└────────────────┴──────────────┴──────────────┴──────────────┘
```

---

## 5. ONDE ENCONTRAR CADA REFERÊNCIA

### No Código Frontend:

```
detalhes_unidade_screen.dart
├─ Linha 14-16: Propriedades do widget (bloco, unidade)
├─ Linha 56: Declaração de _unidadeController
├─ Linha 130-147: initState() → _carregarDados()
├─ Linha 161: Preenche _unidadeController.text
├─ Linha 601-625: Renderiza o TextField para "Unidade"
└─ Linha ~3400: _salvarUnidade() (salva dados)
```

### No Serviço:

```
unidade_detalhes_service.dart
├─ Linha 12-25: Parâmetros do método
├─ Linha 26-29: Filtra por numero = ? AND bloco = ?
├─ Linha 31-33: Busca com maybeSingle()
├─ Linha 35: Converte JSON → Unidade.fromJson()
└─ Linha 100-110: atualizarUnidade() para salvar
```

### No Modelo:

```
unidade.dart
├─ Linha 14: final String numero;  ← DEFINIÇÃO
├─ Linha 102-125: fromJson() ← LEITURA DO BANCO
├─ Linha 128-150: toJson() ← ESCRITA NO BANCO
└─ Linha 161-200: copyWith() ← ATUALIZAÇÃO
```

### No Banco:

```
10_recreate_unidades_manual_input.sql
└─ Linha 35: numero VARCHAR(10) NOT NULL,  ← DEFINIÇÃO NA TABELA

20240120000003_create_unidades.sql
└─ Linha ~10: numero VARCHAR(20) NOT NULL,  ← CRIAÇÃO ORIGINAL
```

---

## 6. EXEMPLO CONCRETO - UNIDADE A/310

### Na Tela (UI):
```
┌────────────────────────────────────┐
│ UNIDADE                             │
│ Unidade*: [310            ]         │ ← _unidadeController.text
│ Bloco:    [A              ]         │
│ Fração:   [0.014          ]         │
└────────────────────────────────────┘
```

### No Objeto Dart:
```dart
Unidade(
  id: 'uuid-123',
  numero: '310',           ← String
  bloco: 'A',
  condominioId: 'condo-456',
  fracaoIdeal: 0.014,
  areaM2: null,
  // ...
)
```

### No JSON (requisição):
```json
{
  "numero": "310",
  "bloco": "A",
  "condominio_id": "condo-456",
  "fracao_ideal": 0.014,
  "area_m2": null
}
```

### No Banco:
```sql
SELECT * FROM unidades WHERE numero='310' AND bloco='A';

-- Retorna:
-- id        | numero | bloco | condominio_id | fracao_ideal | ...
-- uuid-123  | 310    | A     | condo-456     | 0.014000     | ...
```

---

## 7. VALIDAÇÕES EM CADA CAMADA

### Camada UI (detalhes_unidade_screen.dart):
```dart
✓ Campo marcado com asterisco (*) = obrigatório
✓ Texto em vermelho = indica obrigatoriedade
✓ Campo é um TextField editable
```

### Camada Modelo (unidade.dart):
```dart
✓ required String numero  ← Obrigatório no construtor
✓ Sem validação específica (apenas tipo String)
```

### Camada Banco (SQL):
```sql
✓ NOT NULL  ← Não pode ser vazio
✓ CHECK (trim(numero) != '')  ← Não pode ter apenas espaços
✓ VARCHAR(10)  ← Máximo 10 caracteres
✓ UNIQUE(bloco_id, numero)  ← Não pode repetir por bloco
```

---

## 8. CICLO COMPLETO - RESUMO EXECUTIVO

```
START
  │
  ├─→ UI apresenta campo "Unidade*" com controlador
  │
  ├─→ Se modo='editar':
  │    │
  │    ├─ Busca unidade no banco usando numero + bloco
  │    │
  │    ├─ Retorna objeto Unidade
  │    │
  │    └─ Preenche _unidadeController.text com numero
  │
  ├─→ Usuário edita campo (opcional)
  │
  ├─→ Usuário clica "Salvar"
  │
  ├─→ Coleta _unidadeController.text
  │
  ├─→ Envia para banco com UPDATE
  │
  ├─→ Banco atualiza o campo numero
  │
  └─→ Mostra sucesso ✅

END
```

---

## 📌 CHEAT SHEET - RÁPIDO

| O que | Onde | Como |
|------|------|------|
| **Ver o campo** | `detalhes_unidade_screen.dart:601` | TextField com _unidadeController |
| **Buscar do banco** | `unidade_detalhes_service.dart:25` | .eq('numero', numero) |
| **Definição do tipo** | `unidade.dart:14` | final String numero; |
| **Converter de JSON** | `unidade.dart:102` | json['numero'] ?? '' |
| **Salvar no banco** | `unidade.dart:135` | 'numero': numero |
| **Tabela** | SQL | unidades.numero VARCHAR(10) |
| **Validação SQL** | SQL | NOT NULL, CHECK(trim != '') |
| **Unicidade** | SQL | UNIQUE(bloco_id, numero) |

