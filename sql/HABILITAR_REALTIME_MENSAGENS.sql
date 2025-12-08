-- ================================================================
-- HABILITAR REALTIME PARA MENSAGENS EM TEMPO REAL
-- ================================================================
-- 
-- Este script habilita Realtime para as tabelas de mensagens e conversas
-- Copie e cole este código no Supabase SQL Editor
-- Dashboard > SQL Editor > Nova Query > Cole este código > Run
--
-- ================================================================

-- 1. Habilitar Realtime para a tabela MENSAGENS
ALTER PUBLICATION supabase_realtime ADD TABLE mensagens;

-- 2. Habilitar Realtime para a tabela CONVERSAS  
ALTER PUBLICATION supabase_realtime ADD TABLE conversas;

-- 3. (OPCIONAL) Se as policies estão muito restritivas, verifique
--    Você pode ver as policies existentes com:
SELECT 
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  qual,
  with_check
FROM pg_policies
WHERE tablename IN ('mensagens', 'conversas')
ORDER BY tablename, policyname;

-- ================================================================
-- VERIFICAR SE REALTIME ESTÁ ATIVO
-- ================================================================
-- Execute esta query para listar tabelas com Realtime ativado:

SELECT 
  schemaname,
  tablename,
  'REALTIME ATIVO' as status
FROM pg_publication_tables 
WHERE pubname = 'supabase_realtime'
ORDER BY tablename;

-- ================================================================
-- NOTAS IMPORTANTES
-- ================================================================
--
-- 1. Se receber erro "publication" already has table", é porque
--    já está ativado. Tudo bem! Pode ignorar.
--
-- 2. Se as mensagens ainda não atualizarem após isso:
--    - Reinicie o app
--    - Verifique se RLS está muito restritivo
--    - Veja o console (F12) para erros de conexão
--
-- 3. Para DESABILITAR Realtime (não recomendado):
--    ALTER PUBLICATION supabase_realtime DROP TABLE mensagens;
--    ALTER PUBLICATION supabase_realtime DROP TABLE conversas;
--
-- ================================================================
