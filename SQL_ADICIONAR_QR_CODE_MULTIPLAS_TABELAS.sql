-- ============================================================================
-- SQL para adicionar coluna qr_code_url em múltiplas tabelas
-- Criado em: 25 de Novembro de 2025
-- ============================================================================

-- 1. Adicionar coluna qr_code_url à tabela UNIDADES
ALTER TABLE public.unidades
ADD COLUMN qr_code_url TEXT NULL DEFAULT NULL;

COMMENT ON COLUMN public.unidades.qr_code_url IS 
'URL pública da imagem QR Code da unidade salva em Supabase Storage (bucket: qr_codes). Formato esperado: https://[project-id].supabase.co/storage/v1/object/public/qr_codes/qr_[tipo]_[identificador]_[timestamp]_[uuid].png';

-- 2. Adicionar coluna qr_code_url à tabela IMOBILIARIAS
ALTER TABLE public.imobiliarias
ADD COLUMN qr_code_url TEXT NULL DEFAULT NULL;

COMMENT ON COLUMN public.imobiliarias.qr_code_url IS 
'URL pública da imagem QR Code da imobiliária salva em Supabase Storage (bucket: qr_codes). Formato esperado: https://[project-id].supabase.co/storage/v1/object/public/qr_codes/qr_[tipo]_[identificador]_[timestamp]_[uuid].png';

-- 3. Adicionar coluna qr_code_url à tabela PROPRIETARIOS
ALTER TABLE public.proprietarios
ADD COLUMN qr_code_url TEXT NULL DEFAULT NULL;

COMMENT ON COLUMN public.proprietarios.qr_code_url IS 
'URL pública da imagem QR Code do proprietário salva em Supabase Storage (bucket: qr_codes). Formato esperado: https://[project-id].supabase.co/storage/v1/object/public/qr_codes/qr_[tipo]_[identificador]_[timestamp]_[uuid].png';

-- 4. Adicionar coluna qr_code_url à tabela INQUILINOS
ALTER TABLE public.inquilinos
ADD COLUMN qr_code_url TEXT NULL DEFAULT NULL;

COMMENT ON COLUMN public.inquilinos.qr_code_url IS 
'URL pública da imagem QR Code do inquilino salva em Supabase Storage (bucket: qr_codes). Formato esperado: https://[project-id].supabase.co/storage/v1/object/public/qr_codes/qr_[tipo]_[identificador]_[timestamp]_[uuid].png';

-- ============================================================================
-- Resumo das alterações:
-- ============================================================================
-- ✅ Coluna qr_code_url adicionada a 4 tabelas
-- ✅ Tipo: TEXT (armazena URLs)
-- ✅ Default: NULL (permite dados sem QR Code)
-- ✅ Comentários descritivos adicionados
--
-- Para usar:
-- 1. Executar este script no Supabase SQL Editor
-- 2. Cada tabela terá uma coluna qr_code_url pronta
-- 3. Usar QrCodeGenerationService para gerar e salvar URLs
-- ============================================================================
