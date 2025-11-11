-- =====================================================
-- MIGRAÇÃO: Adicionar coluna foto_perfil às tabelas proprietarios e inquilinos
-- Data: 2024-01-21
-- Descrição: Adiciona coluna para armazenar a URL da foto de perfil dos proprietários e inquilinos
-- Seguindo o mesmo padrão usado na tabela representantes
-- =====================================================

-- Adicionar coluna foto_perfil à tabela proprietarios (se não existir)
ALTER TABLE public.proprietarios 
ADD COLUMN IF NOT EXISTS foto_perfil TEXT;

-- Adicionar comentário à coluna proprietarios
COMMENT ON COLUMN public.proprietarios.foto_perfil IS 'URL da foto de perfil do proprietário armazenada no Supabase Storage';

-- Criar índice para otimizar consultas que filtram por proprietários com foto
CREATE INDEX IF NOT EXISTS idx_proprietarios_foto_perfil ON public.proprietarios(foto_perfil) 
WHERE foto_perfil IS NOT NULL;

-- =====================================================

-- Adicionar coluna foto_perfil à tabela inquilinos (se não existir)
ALTER TABLE public.inquilinos 
ADD COLUMN IF NOT EXISTS foto_perfil TEXT;

-- Adicionar comentário à coluna inquilinos
COMMENT ON COLUMN public.inquilinos.foto_perfil IS 'URL da foto de perfil do inquilino armazenada no Supabase Storage';

-- Criar índice para otimizar consultas que filtram por inquilinos com foto
CREATE INDEX IF NOT EXISTS idx_inquilinos_foto_perfil ON public.inquilinos(foto_perfil) 
WHERE foto_perfil IS NOT NULL;

-- =====================================================
-- OBSERVAÇÕES:
-- 1. A coluna foto_perfil agora armazena apenas URLs (não Base64)
-- 2. As imagens são salvas no bucket 'fotos_perfil' do Supabase Storage
-- 3. A coluna é opcional (permite NULL)
-- 4. Os índices são criados apenas para registros que possuem foto (WHERE foto_perfil IS NOT NULL)
-- =====================================================
