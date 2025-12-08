# 🔄 Guia de Configuração - Realtime Mensagens em Tempo Real

## Problema
As mensagens no chat (Portaria/Representante, Proprietario, Inquilino) não atualizam em tempo real quando o outro usuário está com o chat aberto.

## Solução
O **Supabase Realtime** precisa estar **habilitado** para as tabelas `mensagens` e `conversas`.

---

## ✅ Passo 1: Acessar Supabase Dashboard

1. Abra [https://app.supabase.com](https://app.supabase.com)
2. Selecione seu projeto `tukpgefrddfchmvtiujp`
3. Vá para **Database** > **Tables**

---

## ✅ Passo 2: Habilitar Realtime na Tabela `mensagens`

1. Encontre a tabela `mensagens` na lista
2. Clique no menu de **3 pontos** ⋮ ou na tabela
3. Procure por **Realtime** ou **Real-time status**
4. Ative o Realtime (o toggle deve ficar verde/azul)

**Estrutura esperada da tabela `mensagens`:**
```sql
- id (uuid, primary key)
- conversa_id (uuid, foreign key)
- condominio_id (uuid)
- remetente_tipo (text: 'usuario' | 'representante')
- remetente_id (uuid)
- remetente_nome (text)
- conteudo (text)
- tipo_conteudo (text: 'texto', 'imagem', etc)
- status (text: 'enviada', 'entregue', 'lida')
- lida (boolean)
- created_at (timestamp)
- updated_at (timestamp)
```

---

## ✅ Passo 3: Habilitar Realtime na Tabela `conversas`

1. Encontre a tabela `conversas`
2. Ative o Realtime também (para atualizações de status, arquivamento, etc)

**Estrutura esperada da tabela `conversas`:**
```sql
- id (uuid, primary key)
- condominio_id (uuid)
- unidade_id (uuid)
- usuario_tipo (text: 'proprietario' | 'inquilino')
- usuario_id (uuid)
- usuario_nome (text)
- representante_id (uuid)
- representante_nome (text)
- status (text: 'ativa', 'arquivada', 'bloqueada')
- total_mensagens (integer)
- mensagens_nao_lidas_usuario (integer)
- mensagens_nao_lidas_representante (integer)
- ultima_mensagem_data (timestamp)
- created_at (timestamp)
- updated_at (timestamp)
```

---

## ✅ Passo 4: Verificar RLS Policies

Se o Realtime está ativado mas ainda não funciona, verifique as **Row Level Security** policies:

### Para `mensagens`:
```sql
-- Permitir ler próprias mensagens
CREATE POLICY "Users can read messages from their conversations"
ON mensagens
FOR SELECT
USING (true); -- Permite leitura de todos (ajuste conforme necessário)

-- Permitir inserir mensagens
CREATE POLICY "Users can insert messages"
ON mensagens
FOR INSERT
WITH CHECK (true);
```

### Para `conversas`:
```sql
-- Permitir ler conversas
CREATE POLICY "Users can read conversations"
ON conversas
FOR SELECT
USING (true);

-- Permitir atualizar conversas
CREATE POLICY "Users can update conversations"
ON conversas
FOR UPDATE
USING (true);
```

---

## 🔍 Como Testar se Realtime Está Funcionando

### Teste 1: Via Dashboard (Visual)
1. Abra Supabase Dashboard
2. Vá em **Realtime** (seção lateral)
3. Você verá:
   - ✅ Tabelas com Realtime ativado (com ícone de live)
   - ❌ Tabelas sem Realtime desativado

### Teste 2: Via Flutter (Prático)
1. Abra o app em um celular/emulador como **Representante**
2. Abra o app em outro celular/emulador como **Proprietario**
3. Representante abre chat com Proprietario
4. Proprietario envia mensagem
5. **Esperado**: Mensagem aparece **instantaneamente** no chat do Representante (sem precisar atualizar manualmente)

### Teste 3: Verificar Logs
1. No console (F12) do navegador web:
   ```
   [CHAT_REP_V2] Recebeu X mensagens do stream
   ```
2. Ao enviar mensagem:
   ```
   [CHAT_REP_V2] ENVIANDO MENSAGEM
   [MENSAGENS_SERVICE] ENVIAR MENSAGEM
   ```

---

## 🐛 Problemas Comuns

### ❌ "As mensagens não atualizam em tempo real"

**Causa**: Realtime não está habilitado

**Solução**: 
1. Acesse Supabase > Database > Tables
2. Selecione a tabela `mensagens`
3. Procure o toggle de **Realtime** e ative-o

---

### ❌ "Socket connection refused"

**Causa**: URL ou credenciais do Supabase incorretas

**Solução**:
1. Verifique em `lib/main.dart` se `SUPABASE_URL` e `SUPABASE_ANON_KEY` estão corretos
2. Teste em web/mobile
3. Verifique se a chave tem permissões corretas

---

### ❌ "Permissão negada ao conectar Realtime"

**Causa**: RLS policies bloqueando acesso

**Solução**:
1. Desabilite RLS temporariamente para testar (apenas em desenvolvimento):
   ```sql
   ALTER TABLE mensagens DISABLE ROW LEVEL SECURITY;
   ALTER TABLE conversas DISABLE ROW LEVEL SECURITY;
   ```
2. Se funcionar, implemente policies corretas
3. Reabilite RLS

---

## 📋 Checklist de Ativação

- [ ] Supabase Dashboard aberto
- [ ] Tabela `mensagens` com Realtime ativado (ícone verde/azul)
- [ ] Tabela `conversas` com Realtime ativado
- [ ] RLS policies permitem leitura/escrita
- [ ] `lib/main.dart` com credenciais corretas
- [ ] App compilado com as mudanças
- [ ] Teste prático: 2 usuários, enviar mensagem, verificar se atualiza

---

## 📚 Documentação Oficial

- [Supabase Realtime Documentation](https://supabase.com/docs/guides/realtime)
- [Realtime Best Practices](https://supabase.com/docs/guides/realtime/best-practices)
- [Row Level Security](https://supabase.com/docs/guides/auth/row-level-security)

---

## 🚀 Próximas Etapas

Após ativar Realtime:

1. **Teste em Development**: Verifique se as mensagens atualizam
2. **Monitore Performance**: Se muitos usuários, considere filtros de stream
3. **Implemente Indicadores**: "Digitando...", "Lido", etc
4. **Cache Local**: Implemente cache para melhor UX offline

---

## 📞 Suporte

Se mesmo após ativar Realtime não funcionar:

1. Verifique o Console (F12) para erros de conexão
2. Teste conexão: `curl https://tukpgefrddfchmvtiujp.supabase.co`
3. Verifique Rate Limits do Supabase (Dashboard > Usage)
4. Reinicie o app

