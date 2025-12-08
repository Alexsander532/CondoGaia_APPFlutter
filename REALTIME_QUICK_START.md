# ⚡ ATIVANDO REALTIME - Passo a Passo Rápido

## O Problema
Quando você envia uma mensagem no chat, o outro usuário não vê atualizar em tempo real. Precisa recarregar manualmente.

## A Solução: Ativar Realtime no Supabase

### 🔧 O que fazer:

**1. Abra o Supabase Dashboard**
   - URL: https://app.supabase.com
   - Projeto: `tukpgefrddfchmvtiujp`

**2. Vá para Database > Tables**
   - Clique em **Tables** (lado esquerdo)

**3. Procure a tabela `mensagens`**
   - Clique na tabela para selecioná-la
   - Você verá um painel à direita

**4. Ative Realtime**
   - Procure por um **toggle** de "Realtime" ou "Real-time" 
   - Clique para ativar (deve ficar verde/azul)
   - Confirme se aparecer um popup

**5. Repita para a tabela `conversas`**
   - Faça o mesmo processo

---

## ✅ Pronto!

Agora as mensagens vão atualizar em tempo real:
- ✨ Representante envia mensagem
- ⚡ Proprietario/Inquilino vê **instantaneamente** (sem recarregar)
- 🔄 Funciona nas 2 direções

---

## 🧪 Como Testar

1. Abra o app em 2 celulares (ou emuladores)
2. Um como **Representante**, outro como **Proprietario**
3. Abra o chat entre eles
4. **Representante** envia: "Olá"
5. **Proprietario** verá aparecer na hora (magic! ✨)

---

## ❌ Se não funcionar ainda...

**Verifique no Console (F12 do navegador):**
- Deve aparecer: `[STREAM_MENSAGENS] Recebeu X mensagens...`
- Se aparecer erro: `ERRO NO STREAM`

**Dica**: Se o erro disser algo sobre "cannot enable realtime", significa:
- Você não clicou certo no toggle
- Ou o toggle já estava ativado
- Tente fazer login de novo no Supabase ou recarregue a página

---

## 📞 Ficou com dúvida?

Abra uma issue ou envie o print screen mostrando:
- Onde você está no dashboard
- Se conseguiu encontrar a tabela `mensagens`
- Se vê o toggle de Realtime

