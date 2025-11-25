-- ============================================================================
-- SQL: ADICIONAR COLUNAS agrupar_boletos E matricula_imovel
-- Tabela: proprietarios
-- ============================================================================

-- Adicionar coluna agrupar_boletos
ALTER TABLE public.proprietarios
ADD COLUMN agrupar_boletos BOOLEAN DEFAULT false;

COMMENT ON COLUMN public.proprietarios.agrupar_boletos IS 
'Indica se os boletos devem ser agrupados. Padrão: false (Não)';

-- Adicionar coluna matricula_imovel
ALTER TABLE public.proprietarios
ADD COLUMN matricula_imovel BOOLEAN DEFAULT false;

COMMENT ON COLUMN public.proprietarios.matricula_imovel IS 
'Indica se há matrícula do imóvel para fazer upload. Padrão: false (Não)';

-- ============================================================================
-- COMO EXECUTAR NO SUPABASE:
-- ============================================================================

/*
1. Abra: https://supabase.com
2. Selecione seu projeto
3. Menu esquerdo: SQL Editor
4. Clique em: New Query (ou New SQL Query)
5. Cole o comando acima (sem este comentário)
6. Clique em: [Run] ou [Ctrl + Enter]
7. Veja a mensagem: "Success. No rows returned."
8. Pronto! Colunas criadas ✅
*/

-- ============================================================================
-- VERIFICAR SE AS COLUNAS FORAM CRIADAS:
-- ============================================================================

SELECT column_name, data_type, column_default, is_nullable 
FROM information_schema.columns 
WHERE table_name = 'proprietarios' 
AND column_name IN ('agrupar_boletos', 'matricula_imovel')
ORDER BY column_name;

-- Resultado esperado:
-- column_name        | data_type | column_default | is_nullable
-- ------------------+-----------+----------------+-----------
-- agrupar_boletos    | boolean   | false          | YES
-- matricula_imovel   | boolean   | false          | YES
