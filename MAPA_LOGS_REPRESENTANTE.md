# 📍 MAPA DE LOGS - Sistema de Mensagens (Completo)

## 🎯 Mapa Visual de Todos os Logs

```
┌──────────────────────────────────────────────────────────────────────────────┐
│                     🟦 PORTARIA_REP (Azul Claro)                             │
├──────────────────────────────────────────────────────────────────────────────┤
│ initState() chamado                                                          │
│   ↓                                                                          │
│ 🔄 [PORTARIA_REP] Chamando AuthService.getCurrentRepresentante()            │
│   ↓                                                                          │
│ ✅ [PORTARIA_REP] Representante obtido com sucesso                          │
│    📌 ID: <uuid>                                                            │
│    📌 Nome: <nome>                                                          │
│    📌 CPF: <cpf>                                                            │
│   ↓                                                                          │
│ ✅ [PORTARIA_REP] Estado atualizado com representante                       │
│   ↓                                                                          │
│ _buildMensagemTab() chamado                                                 │
│   ↓                                                                          │
│ ✅ [PORTARIA_REP] Representante carregado com sucesso                       │
│    📌 ID a passar para ConversasSimples: <uuid>                             │
│    📌 Nome a passar para ConversasSimples: <nome>                           │
│    📌 Condominio ID: <uuid>                                                 │
└──────────────────────────────────────────────────────────────────────────────┘
         ↓
┌──────────────────────────────────────────────────────────────────────────────┐
│                   🟩 CONVERSAS_SIMPLES (Verde Claro)                         │
├──────────────────────────────────────────────────────────────────────────────┤
│ StreamBuilder escuta conversas                                              │
│   ↓                                                                          │
│ Usuário clica em conversa                                                   │
│   ↓                                                                          │
│ 🟩 [CONVERSAS_SIMPLES] ═══ ABRINDO CONVERSA ═══                            │
│    📌 Conversa ID: <uuid>                                                   │
│    📌 Usuário: <nome>                                                       │
│    📌 Unidade: <número>                                                     │
│    📌 Representante ID (widget): <uuid>                                     │
│    📌 Representante Nome (widget): <nome>                                   │
│   ↓                                                                          │
│ 📝 [CONVERSAS_SIMPLES] Marcando conversa como lida...                      │
│   ↓                                                                          │
│   ✅ [CONVERSAS_SIMPLES] Conversa marcada como lida                         │
│   ↓                                                                          │
│ 🔵 [CONVERSAS_SERVICE] Marcando conversa como lida                         │
│    📌 Conversa ID: <uuid>                                                   │
│    📌 Para Representante: true                                              │
│    📌 Limpando não-lidas do representante                                   │
│    🔄 Atualizando no Supabase...                                            │
│    ✅ Conversa marcada como lida                                            │
│   ↓                                                                          │
│ 🔀 [CONVERSAS_SIMPLES] Navegando para ChatRepresentanteScreenV2...         │
│   ↓                                                                          │
│ ✅ [CONVERSAS_SIMPLES] Tela de chat aberta                                  │
└──────────────────────────────────────────────────────────────────────────────┘
         ↓
┌──────────────────────────────────────────────────────────────────────────────┐
│               🟪 CHAT_REPRESENTANTE_V2 (Roxo Claro)                          │
├──────────────────────────────────────────────────────────────────────────────┤
│ Tela de chat aberta                                                         │
│   ↓                                                                          │
│ 🟪 [CHAT_REP_V2] ═══ INICIALIZANDO TELA ═══                                │
│    📌 Conversa ID: <uuid>                                                   │
│    📌 Condominio ID: <uuid>                                                 │
│    📌 Representante ID: <uuid>                                              │
│    📌 Representante Nome: <nome>                                            │
│    📌 Usuário: <nome>                                                       │
│    📌 Unidade: <número>                                                     │
│   ↓                                                                          │
│ 📝 [CHAT_REP_V2] Marcando conversa <uuid> como lida...                      │
│   ↓                                                                          │
│ 🔵 [CONVERSAS_SERVICE] Marcando conversa como lida                         │
│    📌 Conversa ID: <uuid>                                                   │
│    📌 Para Representante: true                                              │
│    ✅ Conversa marcada como lida                                            │
│   ↓                                                                          │
│ ✅ [CHAT_REP_V2] Conversa marcada como lida                                 │
│   ↓                                                                          │
│ Usuário digita mensagem e clica ENVIAR                                      │
│   ↓                                                                          │
│ 🟪 [CHAT_REP_V2] ═══ ENVIANDO MENSAGEM ═══                                │
│    📌 Conteúdo: "<mensagem>"                                                │
│    📌 Conversa ID: <uuid>                                                   │
│    📌 Condominio ID: <uuid>                                                 │
│    📌 Representante ID: <uuid>                                              │
│    📌 Representante Nome: <nome>                                            │
│   ↓                                                                          │
│ 🔄 [CHAT_REP_V2] Chamando MensagensService.enviar()...                     │
└──────────────────────────────────────────────────────────────────────────────┘
         ↓
┌──────────────────────────────────────────────────────────────────────────────┐
│             🟨 MENSAGENS_SERVICE (Amarelo Claro)                             │
├──────────────────────────────────────────────────────────────────────────────┤
│ 🟨 [MENSAGENS_SERVICE] ═══ ENVIAR MENSAGEM ═══                             │
│    📌 Conversa ID: <uuid>                                                   │
│    📌 Condominio ID: <uuid>                                                 │
│    📌 Remetente Tipo: representante                                         │
│    📌 Remetente ID: <uuid>                                                  │
│    📌 Remetente Nome: <nome>                                                │
│    📌 Conteúdo: "<mensagem>"                                                │
│    📌 Tipo Conteúdo: texto                                                  │
│   ↓                                                                          │
│ 🔄 [MENSAGENS_SERVICE] Inserindo mensagem no Supabase...                  │
│    📦 Dados: {conversa_id, condominio_id, remetente_tipo, ...}              │
│   ↓                                                                          │
│ ✅ [MENSAGENS_SERVICE] Mensagem inserida com sucesso!                       │
│    📌 Resultado: {id, status, created_at, ...}                              │
└──────────────────────────────────────────────────────────────────────────────┘
         ↓
┌──────────────────────────────────────────────────────────────────────────────┐
│             🔵 CONVERSAS_SERVICE (Continuação)                               │
├──────────────────────────────────────────────────────────────────────────────┤
│ De volta em [CHAT_REP_V2]                                                   │
│   ↓                                                                          │
│ 🔄 [CHAT_REP_V2] Atualizando última mensagem na conversa...                │
│   ↓                                                                          │
│ 🔵 [CONVERSAS_SERVICE] Atualizando última mensagem                         │
│    📌 Conversa ID: <uuid>                                                   │
│    📌 Preview: "<mensagem>"                                                 │
│    📌 Por: representante                                                    │
│    🔄 Atualizando no Supabase...                                            │
│    ✅ Última mensagem atualizada                                            │
│   ↓                                                                          │
│ ✅ [CHAT_REP_V2] Conversa atualizada                                        │
│   ↓                                                                          │
│ Limpar input e scroll para baixo                                            │
│   ↓                                                                          │
│ ✅ FLUXO COMPLETO SUCESSO                                                   │
└──────────────────────────────────────────────────────────────────────────────┘
```

---

## 📋 Legenda de Cores

| Cor | Componente | Arquivo |
|-----|-----------|---------|
| 🟦 Azul | PortariaRepresentanteScreen | `portaria_representante_screen.dart` |
| 🟩 Verde | ConversasSimples | `conversas_simples_screen.dart` |
| 🟪 Roxo | ChatRepresentanteScreenV2 | `chat_representante_screen_v2.dart` |
| 🟨 Amarelo | MensagensService | `mensagens_service.dart` |
| 🔵 Azul Escuro | ConversasService | `conversas_service.dart` |

---

## ✅ Checklist de Logs Esperados

Ao enviar uma mensagem, você deve ver todos esses logs (em ordem):

- [ ] 🟪 `[CHAT_REP_V2] ═══ ENVIANDO MENSAGEM ═══`
- [ ] 📌 `Conteúdo: "<sua mensagem>"`
- [ ] 📌 `Representante ID: <uuid válido>`
- [ ] 🔄 `[CHAT_REP_V2] Chamando MensagensService.enviar()...`
- [ ] 🟨 `[MENSAGENS_SERVICE] ═══ ENVIAR MENSAGEM ═══`
- [ ] 📌 `Remetente ID: <uuid válido>`
- [ ] 🔄 `[MENSAGENS_SERVICE] Inserindo mensagem no Supabase...`
- [ ] ✅ `[MENSAGENS_SERVICE] Mensagem inserida com sucesso!`
- [ ] 🔵 `[CONVERSAS_SERVICE] Atualizando última mensagem`
- [ ] ✅ `[CONVERSAS_SERVICE] Última mensagem atualizada`
- [ ] ✅ `[CHAT_REP_V2] Conversa atualizada`

**Se vir tudo isso, a mensagem foi enviada com sucesso!** ✅

---

## 🔍 Como Debugar Usando Este Mapa

### Cenário 1: Mensagem não enviada

1. Procure por 🟨 `[MENSAGENS_SERVICE]`
2. Se não encontrar, erro está em `[CHAT_REP_V2]`
3. Se encontrar ❌, veja qual foi o erro PostgreSQL

### Cenário 2: Representante ID vazio

1. Procure por 🟪 `[CHAT_REP_V2] ═══ ENVIANDO`
2. Verifique se `Representante ID: <uuid>`
3. Se estiver vazio, erro está em 🟦 `[PORTARIA_REP]`

### Cenário 3: Conversa não marca como lida

1. Procure por 🔵 `[CONVERSAS_SERVICE] Marcando`
2. Se não encontrar, erro está em 🟩 `[CONVERSAS_SIMPLES]`
3. Se encontrar ❌, veja qual foi o erro Supabase

---

## 🚀 Próxima Ação

**Teste agora!** Execute:

```bash
flutter run -v 2>&1 | tee debug_$(date +%s).log
```

Então:
1. Navegue até Portaria → Tab "Mensagem"
2. Clique em uma conversa
3. Envie uma mensagem
4. Procure por todos os logs acima

Compartilhe os logs comigo se houver qualquer ❌!

