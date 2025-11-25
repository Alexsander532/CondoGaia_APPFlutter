-- ============================================================================
-- SQL: ADICIONAR COLUNA qr_code_url NA TABELA autorizados_inquilinos
-- ============================================================================

-- ✅ COMANDO SIMPLES (Execute isto no Supabase SQL Editor)
ALTER TABLE autorizados_inquilinos 
ADD COLUMN qr_code_url TEXT;

-- ============================================================================
-- OU USE ESTE COMANDO COM MAIS DETALHES:
-- ============================================================================

ALTER TABLE autorizados_inquilinos 
ADD COLUMN qr_code_url TEXT 
DEFAULT NULL;

-- ============================================================================
-- OU COM COMENTÁRIO (Opcional, para documentação):
-- ============================================================================

ALTER TABLE autorizados_inquilinos 
ADD COLUMN qr_code_url TEXT DEFAULT NULL;

COMMENT ON COLUMN autorizados_inquilinos.qr_code_url IS 
'URL pública da imagem QR Code salva em Supabase Storage (bucket: qr_codes). 
Gerada uma vez ao criar/atualizar autorizado. Formato: 
https://[project-id].supabase.co/storage/v1/object/public/qr_codes/qr_[nome]_[timestamp].png';

-- ============================================================================
-- PARA EXECUTAR NO SUPABASE:
-- ============================================================================

/*
1. Abra: https://supabase.com
2. Selecione seu projeto
3. Menu esquerdo: SQL Editor
4. Clique em: New Query (ou New SQL Query)
5. Cole UM dos comandos acima (recomendo o SIMPLES)
6. Clique em: [Run] ou [Ctrl + Enter]
7. Veja a mensagem: "Success. No rows returned."
8. Pronto! Coluna criada ✅
*/

-- ============================================================================
-- VERIFICAR SE A COLUNA FOI CRIADA:
-- ============================================================================

-- Execute este comando para confirmar:
SELECT column_name, data_type, is_nullable 
FROM information_schema.columns 
WHERE table_name = 'autorizados_inquilinos' 
ORDER BY column_name;

-- Resultado esperado:
-- column_name            | data_type      | is_nullable
-- ---------------------+----------------+------------
-- id                    | uuid           | NO
-- nome                  | text           | NO
-- cpf                   | text           | YES
-- ... (outras colunas)
-- qr_code_url           | text           | YES  ✅ (ESTA É A NOVA!)

-- ============================================================================
-- DELETAR A COLUNA (SE PRECISAR REVERTER):
-- ============================================================================

-- ALTER TABLE autorizados_inquilinos DROP COLUMN qr_code_url;

-- ============================================================================
-- ATUALIZAR REGISTROS EXISTENTES COM NULL (Compatibilidade):
-- ============================================================================

-- Todos os registros antigos terão NULL, e isso é OK!
-- O sistema gerará QR Code quando necessário.

UPDATE autorizados_inquilinos 
SET qr_code_url = NULL 
WHERE qr_code_url IS NULL;

-- ============================================================================
-- FIM DO SCRIPT SQL
-- ============================================================================
