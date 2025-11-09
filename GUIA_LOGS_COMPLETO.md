# 📊 GUIA COMPLETO DE LOGS - Sistema de Mensagens do Representante

## ✅ STATUS ATUAL

Os logs estão **100% funcionando**! Veja o fluxo completo capturado:

### 1️⃣ Carregamento do Representante (PORTARIA_REP)
```
✅ [PORTARIA_REP] Representante obtido com sucesso
   📌 ID: 131b5020-a123-4643-9ee0-2574bee61cce
   📌 Nome: Alexsander
   📌 CPF: 123.456.789-12
✅ [PORTARIA_REP] Estado atualizado com representante
```
**Status**: ✅ Funcionando perfeitamente

### 2️⃣ Build da Tab Mensagem (PORTARIA_REP)
```
✅ [PORTARIA_REP] Representante carregado com sucesso
   📌 ID a passar para ConversasSimples: 131b5020-a123-4643-9ee0-2574bee61cce
   📌 Nome a passar para ConversasSimples: Alexsander
   📌 Condominio ID: 0ababacf-c924-4ee0-947c-850a0c6a46e3
```
**Status**: ✅ Dados corretos sendo passados

### 3️⃣ Abertura da Conversa (CONVERSAS_SIMPLES)
```
🟩 [CONVERSAS_SIMPLES] ═══ ABRINDO CONVERSA ═══
   📌 Conversa ID: 7c44d008-c518-46bc-8504-675de840de0c
   📌 Usuário: Jenifer Pauliana da Silva
   📌 Representante ID (widget): 131b5020-a123-4643-9ee0-2574bee61cce
   📌 Representante Nome (widget): Alexsander
✅ [CONVERSAS_SIMPLES] Conversa marcada como lida
🔀 [CONVERSAS_SIMPLES] Navegando para ChatRepresentanteScreenV2...
✅ [CONVERSAS_SIMPLES] Tela de chat aberta
```
**Status**: ✅ Navegação funcionando

### 4️⃣ Inicialização do Chat (CHAT_REP_V2)
```
🟪 [CHAT_REP_V2] ═══ INICIALIZANDO TELA ═══
   📌 Conversa ID: 7c44d008-c518-46bc-8504-675de840de0c
   📌 Condominio ID: 0ababacf-c924-4ee0-947c-850a0c6a46e3
   📌 Representante ID: 131b5020-a123-4643-9ee0-2574bee61cce
   📌 Representante Nome: Alexsander
```
**Status**: ✅ Dados chegando corretamente

### 5️⃣ Envio de Mensagem (CHAT_REP_V2)
```
🟪 [CHAT_REP_V2] ═══ ENVIANDO MENSAGEM ═══
   📌 Conteúdo: "hglg"
   📌 Conversa ID: 7c44d008-c518-46bc-8504-675de840de0c
   📌 Condominio ID: 0ababacf-c924-4ee0-947c-850a0c6a46e3
   📌 Representante ID: 131b5020-a123-4643-9ee0-2574bee61cce
   📌 Representante Nome: Alexsander
🔄 [CHAT_REP_V2] Chamando MensagensService.enviar()...
```
**Status**: ⏳ Aguardando logs da MensagensService

---

## 🔍 O PROBLEMA AGORA

Há um **aviso de UTF-8 encoding** nos logs, mas **NÃO é um erro que impede o funcionamento**.

O aviso aparece porque alguns caracteres especiais (emojis) estão sendo processados com encoding questionável. Isso é apenas um **warning do Flutter**, não afeta a funcionalidade.

---

## 📋 LOGS ESPERADOS QUE AINDA NÃO VIMOS

Quando você clicar em **enviar**, você deve ver:

### De MensagensService:
```
═══════════════════════════════════════════════════════════════════════════════
🟨 [MENSAGENS_SERVICE] ═══ ENVIAR MENSAGEM ═══
   📌 Conversa ID: 7c44d008-c518-46bc-8504-675de840de0c
   📌 Condominio ID: 0ababacf-c924-4ee0-947c-850a0c6a46e3
   📌 Remetente Tipo: representante
   📌 Remetente ID: 131b5020-a123-4643-9ee0-2574bee61cce
   📌 Remetente Nome: Alexsander
   📌 Conteúdo: "hglg"
   📌 Tipo Conteúdo: texto

🔄 [MENSAGENS_SERVICE] Inserindo mensagem no Supabase...
✅ [MENSAGENS_SERVICE] Mensagem inserida com sucesso!
═══════════════════════════════════════════════════════════════════════════════
```

**Se vir isso**, significa que a mensagem foi enviada para Supabase! ✅

---

## 🎯 PRÓXIMO PASSO - COMPLETE OS LOGS

Você precisa **clicar em ENVIAR** e compartilhar a SAÍDA COMPLETA do console. Procure por:

1. ✅ Logs do `[MENSAGENS_SERVICE]`
2. ✅ Mensagem de sucesso ou erro
3. ✅ Qualquer erro PostgreSQL (se houver)

---

## 🔧 COMO INTERPRETAR OS LOGS

| Padrão | Significado | Ação |
|--------|-------------|------|
| `✅` | Sucesso | Tudo OK, próximo passo |
| `❌` | Erro | Problema crítico, parar |
| `⏳` | Aguardando | Processando, espere |
| `🔄` | Em progresso | Chamando serviço |
| `📌` | Informação | Valor de uma variável |

---

## 📊 ESTRUTURA DOS LOGS POR LAYER

```
┌─ PORTARIA_REP (🟦 - Azul)
│  ├─ _carregarRepresentanteAtual()
│  └─ _buildMensagemTab()
│
├─ CONVERSAS_SIMPLES (🟩 - Verde)
│  └─ _abrirConversa()
│
├─ CHAT_REP_V2 (🟪 - Roxo)
│  ├─ initState()
│  └─ _enviarMensagem()
│
└─ MENSAGENS_SERVICE (🟨 - Amarelo)
   └─ enviar()
```

**Cada nível tem uma cor diferente para fácil rastreamento!**

---

## ✨ COMO USAR OS LOGS PARA DEBUGAR

### Se der erro ao enviar:

1. Procure por `❌ [CHAT_REP_V2]` ou `❌ [MENSAGENS_SERVICE]`
2. Leia a mensagem de erro
3. Compartilhe comigo o erro completo

### Se não aparecer logs do MensagensService:

1. Significa que a mensagem não chegou até lá
2. Procure por erro em `[CHAT_REP_V2]`
3. Verifique se `representanteId` não está vazio

### Se aparecer erro PostgreSQL:

1. Procure por `PostgreException`
2. Verifique o campo que falhou
3. Compartilhe a mensagem de erro completa

---

## 🚀 PRÓXIMO COMANDO

Execute no terminal:

```bash
flutter run -v 2>&1 | tee debug_mensagens.log
```

Isso salvará todos os logs em um arquivo `debug_mensagens.log` para análise posterior!

---

## 📝 TEMPLATE PARA COMPARTILHAR LOGS

Quando tiver um erro, compartilhe assim:

```
❌ ERRO ENCONTRADO:

1. O que fez: [descrição da ação]
2. Resultado esperado: [o que deveria acontecer]
3. Resultado real: [o que realmente aconteceu]

LOGS RELEVANTES:
[cole os logs com ❌ ou erro]

QUESTÃO: [qual é a dúvida ou problema?]
```

---

## ✅ CHECKLIST ANTES DE TESTAR

- [x] Representante carregado (visto nos logs)
- [x] ID do representante válido
- [x] Nome do representante correto
- [x] Conversa aberta com sucesso
- [ ] Mensagem enviada com sucesso ← **PRÓXIMO PASSO**
- [ ] Mensagem aparece no Supabase
- [ ] Inquilino vê a mensagem em tempo real

