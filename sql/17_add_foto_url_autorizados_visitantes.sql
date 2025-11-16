-- Migration: Adicionar coluna foto_url à tabela autorizados_visitantes_portaria_representante
-- Data: 2025-11-16
-- Descrição: Adiciona suporte para armazenar URLs de fotos dos visitantes autorizados

ALTER TABLE public.autorizados_visitantes_portaria_representante
ADD COLUMN foto_url text null;

-- Criar índice para melhorar buscas por foto_url
CREATE INDEX IF NOT EXISTS idx_visitantes_portaria_foto_url 
ON public.autorizados_visitantes_portaria_representante USING btree (foto_url);
