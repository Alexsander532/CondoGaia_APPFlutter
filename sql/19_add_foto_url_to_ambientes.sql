-- =====================================================
-- MIGRATION: Adicionar coluna foto_url à tabela ambientes
-- DATA: 17/11/2025
-- PROPÓSITO: Permitir armazenar fotos de ambientes (reservas)
-- =====================================================

-- Adicionar coluna foto_url
ALTER TABLE public.ambientes
ADD COLUMN foto_url TEXT NULL DEFAULT NULL;

-- Comentário explicativo
COMMENT ON COLUMN public.ambientes.foto_url IS 'URL da foto do ambiente armazenada no Supabase Storage (bucket: imagens_ambientes_representante)';

-- Criar índice para melhor performance em buscas por foto
CREATE INDEX IF NOT EXISTS idx_ambientes_foto_url 
ON ambientes(foto_url) WHERE foto_url IS NOT NULL;

-- Log da migração
INSERT INTO public.migration_log (migration_name, executed_at, description) 
VALUES (
    'add_foto_url_to_ambientes',
    NOW(),
    'Adicionada coluna foto_url para armazenar fotos dos ambientes (reservas) do representante'
) ON CONFLICT (migration_log_id) DO NOTHING;
