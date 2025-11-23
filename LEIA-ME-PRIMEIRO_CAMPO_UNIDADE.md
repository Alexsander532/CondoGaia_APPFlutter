# 📚 DOCUMENTAÇÃO - CAMPO DE UNIDADE

## 📋 DOCUMENTOS CRIADOS

Criei 4 documentos explicando como o campo "Unidade" é mapeado na edição de dados da unidade:

### 1. **RESUMO_CAMPO_UNIDADE.md** 🚀
**Objetivo:** Visão geral super rápida
- ✅ O que foi criado
- ✅ Mapa mental
- ✅ Fluxo simplificado
- ✅ Tabela rápida
- ✅ Onde encontrar
- ✅ Checklist de compreensão

**Tempo de leitura:** 5 minutos
**Para quem:** Quem quer entender rápido

---

### 2. **GUIA_CAMPO_UNIDADE.md** 📖
**Objetivo:** Índice completo com tudo
- ✅ Documentos disponíveis
- ✅ Começo rápido (choose your own adventure)
- ✅ Arquitetura em 30 segundos
- ✅ Estrutura dos documentos
- ✅ Conceitos-chave explicados
- ✅ Dicas importantes
- ✅ Leitura recomendada
- ✅ Checklist
- ✅ Exemplos de uso
- ✅ FAQ
- ✅ Como buscar no código
- ✅ Checklist final

**Tempo de leitura:** 15-20 minutos
**Para quem:** Quer saber tudo de forma estruturada

---

### 3. **MAPEAMENTO_CAMPO_UNIDADE.md** 📊
**Objetivo:** Documentação técnica detalhada
- ✅ Visão geral (fluxo de 3 camadas)
- ✅ Mapeamento completo com código
  - Na Interface (Flutter)
  - Carregamento de Dados
  - No Modelo Dart
  - No Banco de Dados
- ✅ Tabela de mapeamento
- ✅ Ciclo completo (carregar e salvar)
- ✅ Validações importantes
- ✅ Exemplo prático
- ✅ Para editar/manter o campo
- ✅ Arquivos relacionados

**Tempo de leitura:** 20-30 minutos
**Para quem:** Desenvolvedores que querem entender a técnica

---

### 4. **DIAGRAMA_FLUXO_CAMPO_UNIDADE.md** 🎨
**Objetivo:** Visualização com diagramas ASCII
- ✅ Diagrama de arquitetura
- ✅ Fluxo de carregamento detalhado (passo a passo)
- ✅ Fluxo de salvamento detalhado (passo a passo)
- ✅ Mapeamento campo por campo
- ✅ Onde encontrar cada referência (no código)
- ✅ Exemplo concreto (unidade A/310)
- ✅ Validações em cada camada
- ✅ Ciclo completo (resumo)
- ✅ Cheat sheet rápido

**Tempo de leitura:** 20 minutos
**Para quem:** Aprende melhor com diagramas visuais

---

## 🎯 COMO USAR ESTA DOCUMENTAÇÃO

### Cenário 1: "Quero entender rápido"
1. Leia: `RESUMO_CAMPO_UNIDADE.md` (5 min)
2. Pronto! ✅

### Cenário 2: "Preciso de compreensão completa"
1. Comece: `RESUMO_CAMPO_UNIDADE.md` (5 min)
2. Depois: `GUIA_CAMPO_UNIDADE.md` (15 min)
3. Aprofunde: `MAPEAMENTO_CAMPO_UNIDADE.md` (20 min)
4. Total: ~40 minutos com expertise completo

### Cenário 3: "Sou visual, prefiro diagramas"
1. Comece: `DIAGRAMA_FLUXO_CAMPO_UNIDADE.md` (20 min)
2. Depois: `MAPEAMENTO_CAMPO_UNIDADE.md` para código (20 min)
3. Total: ~40 minutos com entendimento completo

### Cenário 4: "Preciso editar o campo"
1. Leia: `MAPEAMENTO_CAMPO_UNIDADE.md` seção "Para Editar/Manter"
2. Use: `DIAGRAMA_FLUXO` seção "Cheat Sheet" como referência
3. Localize: Todos os 4 arquivos que precisam ser alterados

### Cenário 5: "Encontrar um bug"
1. Leia: `MAPEAMENTO_CAMPO_UNIDADE.md` seção "Validações"
2. Procure: Em `DIAGRAMA_FLUXO` "Ciclo Completo" qual passo está falhando
3. Use: "Onde Encontrar Referência" para localizar código

---

## 🗂️ ESTRUTURA DOS ARQUIVOS

```
DOCUMENTAÇÃO DO CAMPO UNIDADE
│
├─ RESUMO_CAMPO_UNIDADE.md ◄─────────── START HERE (5 min)
│  ├─ O que foi criado
│  ├─ Mapa mental
│  ├─ Fluxo simplificado
│  ├─ Tabela rápida
│  ├─ Onde encontrar
│  ├─ Checklist
│  └─ Exemplo real
│
├─ GUIA_CAMPO_UNIDADE.md ◄──────────── ÍNDICE COMPLETO (15 min)
│  ├─ Documentos disponíveis
│  ├─ Começo rápido
│  ├─ Arquitetura em 30s
│  ├─ Conceitos-chave
│  ├─ Dicas importantes
│  ├─ Leitura recomendada
│  ├─ Exemplos de uso
│  ├─ FAQ
│  ├─ Como buscar código
│  └─ Próximos passos
│
├─ MAPEAMENTO_CAMPO_UNIDADE.md ◄──── TÉCNICO (20-30 min)
│  ├─ Visão geral
│  ├─ Mapeamento na Interface
│  ├─ Carregamento de dados
│  ├─ No Modelo Dart
│  ├─ No Banco de Dados
│  ├─ Tabela de mapeamento
│  ├─ Ciclo completo
│  ├─ Validações
│  ├─ Exemplo prático
│  ├─ Para editar/manter
│  └─ Arquivos relacionados
│
└─ DIAGRAMA_FLUXO_CAMPO_UNIDADE.md ◄─ VISUAL (20 min)
   ├─ Diagrama de arquitetura
   ├─ Fluxo de carregamento
   ├─ Fluxo de salvamento
   ├─ Mapeamento campo x campo
   ├─ Onde encontrar código
   ├─ Exemplo concreto
   ├─ Validações em cada camada
   ├─ Ciclo completo
   └─ Cheat sheet
```

---

## 🔑 CONCEITOS PRINCIPAIS

### Campo "Unidade"
```
O número que identifica cada apartamento
Exemplo: "310" (no bloco A)
```

### Controlador (_unidadeController)
```
Objeto Flutter que armazena o valor do campo
Acesso: _unidadeController.text = "310"
```

### Modelo Unidade
```
Classe Dart que representa a unidade
Campo: numero (String)
```

### Serviço UnidadeDetalhesService
```
Busca e salva dados no banco
Filtra por: numero + bloco + condominio_id
```

### Tabela unidades
```
Armazena os dados no PostgreSQL
Coluna: numero VARCHAR(10) NOT NULL
```

---

## 📊 FLUXO RESUMIDO

```
┌─────────────────────────────────────────────────────┐
│  CARREGAMENTO                                        │
├─────────────────────────────────────────────────────┤
│  Banco:     SELECT * WHERE numero='310'              │
│    ↓                                                  │
│  Modelo:    Unidade(numero='310')                   │
│    ↓                                                  │
│  UI:        _unidadeController.text = '310'         │
│    ↓                                                  │
│  Tela:      Mostra [310 ]                            │
└─────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────┐
│  SALVAMENTO                                          │
├─────────────────────────────────────────────────────┤
│  Tela:      Usuário digita [310 ]                    │
│    ↓                                                  │
│  UI:        _unidadeController.text = '310'         │
│    ↓                                                  │
│  Modelo:    Unidade(numero='310')                   │
│    ↓                                                  │
│  Banco:     UPDATE ... SET numero='310'              │
└─────────────────────────────────────────────────────┘
```

---

## 🎯 MAPA DE LOCALIZAÇÃO

### Na Interface (Flutter)
```
Arquivo: detalhes_unidade_screen.dart
Linha:   56      → TextEditingController _unidadeController
Linha:   147     → método _carregarDados()
Linha:   161     → _unidadeController.text = _unidade?.numero
Linha:   610     → TextField para o campo visual
```

### No Modelo
```
Arquivo: unidade.dart
Linha:   14      → final String numero;
Linha:   102     → factory Unidade.fromJson()
Linha:   135     → 'numero': numero em toJson()
```

### No Serviço
```
Arquivo: unidade_detalhes_service.dart
Linha:   12-25   → método buscarDetalhesUnidade()
Linha:   25      → .eq('numero', numero) - FILTRO
Linha:   35      → Unidade.fromJson(unidadeData)
```

### No Banco
```
Arquivo: 10_recreate_unidades_manual_input.sql
Linha:   35      → numero VARCHAR(10) NOT NULL
Arquivo: 20240120000003_create_unidades.sql
Linha:   10      → numero VARCHAR(20) NOT NULL (original)
```

---

## ✅ CHECKLIST DE APRENDIZADO

Depois de ler toda a documentação, você consegue:

- [ ] Explicar onde o campo é renderizado
- [ ] Descrever o fluxo de carregamento
- [ ] Descrever o fluxo de salvamento
- [ ] Achar o controlador no código
- [ ] Achar a classe Unidade
- [ ] Achar o serviço de busca
- [ ] Achar a tabela no banco
- [ ] Listar os 4 arquivos principais
- [ ] Explicar por que é VARCHAR(10)
- [ ] Explicar validações
- [ ] Saber como editar o campo
- [ ] Responder perguntas sobre o mapeamento

---

## 🚀 PRÓXIMOS PASSOS

### Passo 1: Leitura
```
Comece com RESUMO_CAMPO_UNIDADE.md (5 min)
```

### Passo 2: Entendimento
```
Leia GUIA_CAMPO_UNIDADE.md ou DIAGRAMA_FLUXO (20 min)
```

### Passo 3: Aprofundamento
```
Leia MAPEAMENTO_CAMPO_UNIDADE.md (30 min)
```

### Passo 4: Prática
```
Abra o código em VS Code:
- detalhes_unidade_screen.dart linha 56
- unidade.dart linha 14
- unidade_detalhes_service.dart linha 25
- SQL arquivo linha 35
```

### Passo 5: Validação
```
Edite uma unidade na app e veja na prática como funciona
```

---

## 📞 SUPORTE RÁPIDO

| Dúvida | Arquivo | Seção |
|--------|---------|-------|
| Onde está o campo? | DIAGRAMA_FLUXO | "Onde Encontrar" |
| Como funciona? | MAPEAMENTO | "Mapeamento Completo" |
| Por que assim? | DIAGRAMA_FLUXO | "Fluxo Detalhado" |
| Como editar? | MAPEAMENTO | "Para Editar/Manter" |
| Exemplo rápido? | GUIA | "Exemplos de Uso" |
| Tem bug? | MAPEAMENTO | "Validações" |

---

## 💡 RESUMO FINAL

O campo "Unidade" é um número (string) que:

1. **Você vê** na tela como campo editável
2. **Armazenado** em `_unidadeController.text`
3. **Representado** no modelo como `Unidade.numero`
4. **Guardado** no banco em `unidades.numero`
5. **Validado** como NOT NULL e máx 10 caracteres
6. **Sincronizado** automaticamente entre UI ↔ Banco

**Pronto para aprender!** 🎉

---

**Comece agora:** Abra `RESUMO_CAMPO_UNIDADE.md`

