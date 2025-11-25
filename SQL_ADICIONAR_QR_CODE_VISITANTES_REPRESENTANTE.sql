-- ============================================================================
-- SQL: ADICIONAR COLUNA qr_code_url NA TABELA autorizados_visitantes_portaria_representante
-- ============================================================================
-- Descrição: Adiciona suporte a QR Code para visitantes autorizados pelo representante
-- Data: 2025-11-25
-- ============================================================================

-- ✅ COMANDO SIMPLES (Execute isto no Supabase SQL Editor)
ALTER TABLE autorizados_visitantes_portaria_representante 
ADD COLUMN qr_code_url TEXT;

-- ============================================================================
-- OU USE ESTE COMANDO COM MAIS DETALHES:
-- ============================================================================

ALTER TABLE autorizados_visitantes_portaria_representante 
ADD COLUMN qr_code_url TEXT 
DEFAULT NULL;

-- ============================================================================
-- OU COM COMENTÁRIO (Opcional, para documentação):
-- ============================================================================

ALTER TABLE autorizados_visitantes_portaria_representante 
ADD COLUMN qr_code_url TEXT DEFAULT NULL;

COMMENT ON COLUMN autorizados_visitantes_portaria_representante.qr_code_url IS 
'URL pública da imagem QR Code salva em Supabase Storage (bucket: qr_codes). 
Gerada uma vez ao criar/atualizar visitante autorizado. Formato: 
https://[project-id].supabase.co/storage/v1/object/public/qr_codes/qr_[nome]_[timestamp].png';

-- ============================================================================
-- PARA EXECUTAR NO SUPABASE:
-- ============================================================================

/*
1. Abra: https://supabase.com
2. Selecione seu projeto
3. Menu esquerdo: SQL Editor
4. Clique em: New Query (ou New SQL Query)
5. Cole o COMANDO SIMPLES acima
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
WHERE table_name = 'autorizados_visitantes_portaria_representante' 
ORDER BY column_name;

-- Resultado esperado (procure por):
-- qr_code_url            | text           | YES

-- ============================================================================
-- VISUALIZAR ESTRUTURA COMPLETA DA TABELA:
-- ============================================================================

SELECT * FROM information_schema.columns 
WHERE table_name = 'autorizados_visitantes_portaria_representante';

-- ============================================================================
-- DELETAR A COLUNA (SE PRECISAR REVERTER):
-- ============================================================================

-- ALTER TABLE autorizados_visitantes_portaria_representante DROP COLUMN qr_code_url;

-- ============================================================================
-- ATUALIZAR REGISTROS EXISTENTES COM NULL (Compatibilidade):
-- ============================================================================

-- Todos os registros antigos terão NULL, e isso é OK!
-- O sistema gerará QR Code quando necessário.

UPDATE autorizados_visitantes_portaria_representante 
SET qr_code_url = NULL 
WHERE qr_code_url IS NULL;

-- ============================================================================
-- FIM DO SCRIPT SQL
-- ============================================================================
