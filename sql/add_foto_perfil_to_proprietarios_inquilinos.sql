-- =====================================================
-- MIGRAÇÃO: Adicionar coluna foto_perfil às tabelas proprietarios e inquilinos
-- Data: 2024-01-15
-- Descrição: Adiciona coluna para armazenar a foto de perfil dos proprietários e inquilinos
-- Seguindo o mesmo padrão usado na tabela representantes
-- =====================================================

-- Adicionar coluna foto_perfil à tabela proprietarios
ALTER TABLE public.proprietarios 
ADD COLUMN foto_perfil TEXT;

-- Adicionar comentário à coluna proprietarios
COMMENT ON COLUMN public.proprietarios.foto_perfil IS 'URL ou base64 da foto de perfil do proprietário';

-- Criar índice para otimizar consultas que filtram por proprietários com foto
CREATE INDEX idx_proprietarios_foto_perfil ON public.proprietarios(foto_perfil) 
WHERE foto_perfil IS NOT NULL;

-- =====================================================

-- Adicionar coluna foto_perfil à tabela inquilinos
ALTER TABLE public.inquilinos 
ADD COLUMN foto_perfil TEXT;

-- Adicionar comentário à coluna inquilinos
COMMENT ON COLUMN public.inquilinos.foto_perfil IS 'URL ou base64 da foto de perfil do inquilino';

-- Criar índice para otimizar consultas que filtram por inquilinos com foto
CREATE INDEX idx_inquilinos_foto_perfil ON public.inquilinos(foto_perfil) 
WHERE foto_perfil IS NOT NULL;

-- =====================================================
-- OBSERVAÇÕES:
-- 1. A coluna foto_perfil é do tipo TEXT para suportar URLs ou dados base64
-- 2. A coluna é opcional (permite NULL)
-- 3. Os índices são criados apenas para registros que possuem foto (WHERE foto_perfil IS NOT NULL)
-- 4. O modelo Dart do Proprietario já possui o campo fotoPerfil
-- 5. O modelo Dart do Inquilino precisa ser atualizado para incluir o campo fotoPerfil
-- =====================================================