# 🎯 RESUMO VISUAL - CAMPO DE UNIDADE

## O QUE FOI CRIADO

Criei **3 documentos detalhados** explicando como o campo "Unidade" funciona:

```
GUIA_CAMPO_UNIDADE.md ◄─── COMECE AQUI (Índice)
    │
    ├─→ MAPEAMENTO_CAMPO_UNIDADE.md (Técnico)
    │   └─ Explicação detalhada + tabelas + código
    │
    └─→ DIAGRAMA_FLUXO_CAMPO_UNIDADE.md (Visual)
        └─ Diagramas + fluxos + exemplos
```

---

## 📍 LOCALIZAÇÃO DOS DOCUMENTOS

```
c:\Users\Alexsander\Desktop\Aplicativos\APPflutter\condogaiaapp\
│
├─ GUIA_CAMPO_UNIDADE.md                    ⭐ ÍNDICE PRINCIPAL
├─ MAPEAMENTO_CAMPO_UNIDADE.md              📊 TÉCNICO DETALHADO
└─ DIAGRAMA_FLUXO_CAMPO_UNIDADE.md          🎨 VISUAL E EXEMPLOS
```

---

## 🎯 MAPA MENTAL DO CAMPO

```
CAMPO "UNIDADE" = "310"

┌──────────────────────────────────────┐
│  NA INTERFACE (Flutter)               │
│  ┌─────────────────────────────────┐ │
│  │ Unidade*: [310         ]        │ │
│  └─────────────────────────────────┘ │
│  Arquivo: detalhes_unidade_screen.dart
│  Controlador: _unidadeController
└──────────────────────────────────────┘
              │
              │ (quando salva)
              ↓
┌──────────────────────────────────────┐
│  NO MODELO (Dart)                     │
│  Unidade {                            │
│    numero: "310",  ◄─── AQUI!         │
│    bloco: "A",                        │
│    ...                                │
│  }                                    │
│  Arquivo: unidade.dart                │
└──────────────────────────────────────┘
              │
              │ (busca/salva)
              ↓
┌──────────────────────────────────────┐
│  NO SERVIÇO (Backend)                 │
│  buscarDetalhesUnidade(               │
│    numero: "310"  ◄─── FILTRO         │
│  )                                    │
│  Arquivo: unidade_detalhes_service    │
└──────────────────────────────────────┘
              │
              │ (query)
              ↓
┌──────────────────────────────────────┐
│  NO BANCO (PostgreSQL)                │
│  SELECT * FROM unidades               │
│  WHERE numero = '310'                 │
│                                       │
│  Coluna: unidades.numero              │
│  Tipo: VARCHAR(10)                    │
│  Restrição: NOT NULL                  │
└──────────────────────────────────────┘
```

---

## 🔄 FLUXO SIMPLIFICADO

### Ao CARREGAR:
```
Banco: numero='310'
    ↓
Modelo: Unidade(numero='310')
    ↓
UI: _unidadeController.text = '310'
    ↓
Tela: Mostra [310]
```

### Ao SALVAR:
```
Tela: Usuário digita [310]
    ↓
UI: _unidadeController.text = '310'
    ↓
Modelo: Unidade(numero='310')
    ↓
Serviço: UPDATE unidades SET numero='310'
    ↓
Banco: Armazena numero='310'
```

---

## 📊 TABELA RÁPIDA

| Local | Nome | Tipo | Obrigatório |
|-------|------|------|-------------|
| 🎨 UI | `_unidadeController.text` | String | ✅ |
| 📦 Modelo | `Unidade.numero` | String | ✅ |
| 🔌 Serviço | Parâmetro `numero` | String | ✅ |
| 🗄️ Banco | `unidades.numero` | VARCHAR(10) | ✅ |

---

## 🔍 ONDE ENCONTRAR

### Para ver o campo na tela
```
Arquivo: detalhes_unidade_screen.dart
Linha: ~610
Procure por: Container com TextField e hintText '101'
```

### Para ver no banco
```
Arquivo: 10_recreate_unidades_manual_input.sql
Linha: 35
Procure por: numero VARCHAR(10) NOT NULL
```

### Para ver no modelo
```
Arquivo: unidade.dart
Linha: 14
Procure por: final String numero;
```

### Para ver no serviço
```
Arquivo: unidade_detalhes_service.dart
Linha: 25
Procure por: .eq('numero', numero)
```

---

## ✅ CHECKLIST DE COMPREENSÃO

Depois de ler a documentação, você deve saber:

- [ ] Campo é armazenado em `unidades.numero`
- [ ] UI acessa via `_unidadeController.text`
- [ ] Modelo Dart: `Unidade.numero`
- [ ] Banco busca com: `WHERE numero = '310'`
- [ ] Máximo 10 caracteres
- [ ] É obrigatório
- [ ] É único por bloco
- [ ] Carregamento: Banco → Modelo → UI
- [ ] Salvamento: UI → Modelo → Banco

---

## 🚀 PRÓXIMOS PASSOS

1. **Comece lendo:** `GUIA_CAMPO_UNIDADE.md` (índice principal)
2. **Para técnico:** `MAPEAMENTO_CAMPO_UNIDADE.md` (detalhes)
3. **Para visual:** `DIAGRAMA_FLUXO_CAMPO_UNIDADE.md` (diagramas)
4. **Abra o código:** `detalhes_unidade_screen.dart` linha 56

---

## 💡 EXEMPLO REAL

Se você está editando a unidade A/310:

```
1. Abre a tela
   → Busca no banco: WHERE numero='310' AND bloco='A'

2. Banco retorna:
   {id: uuid, numero: '310', bloco: 'A', ...}

3. Modelo converte:
   Unidade(numero: '310', bloco: 'A', ...)

4. UI preenche:
   _unidadeController.text = '310'

5. Tela mostra:
   [Unidade*: [310 ]]

6. Você clica Salvar
   → _unidadeController.text = '310'
   → Envia para banco
   → UPDATE unidades SET numero='310' WHERE id=uuid
   → Sucesso! ✅
```

---

## 📞 DÚVIDAS RÁPIDAS

**P: Onde está o campo na interface?**
A: `detalhes_unidade_screen.dart:610` - É o primeiro TextField da seção "Unidade"

**P: O que é _unidadeController?**
A: Um objeto que armazena o valor do campo de texto ("310")

**P: Por que precisa ser diferente por bloco?**
A: Porque na mesma estrutura pode ter "310" no bloco A e "310" no bloco B

**P: Pode ter letras?**
A: Sim, é string. Pode ser "310", "A101", "101A", etc.

**P: Quem valida se está vazio?**
A: O banco (NOT NULL) e idealmente a UI antes de salvar

---

## 🎓 RESUMO EM 2 MINUTOS

O campo "Unidade" é um número (string) que identifica cada apartamento:

1. **Você vê na tela:** Um campo editável que começa com "310"
2. **No código Flutter:** Armazenado em `_unidadeController.text`
3. **No modelo:** Representado como `Unidade.numero` = "310"
4. **No banco:** Guardado em `unidades.numero` VARCHAR(10)
5. **Quando salva:** Envia "310" de volta para o banco

Pronto! 🎉

---

**Para entender melhor:** Abra `GUIA_CAMPO_UNIDADE.md`

