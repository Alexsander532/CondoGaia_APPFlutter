-- Adicionar coluna foto_url à tabela autorizados_inquilinos
ALTER TABLE public.autorizados_inquilinos
ADD COLUMN foto_url TEXT NULL DEFAULT NULL;

-- Comentário explicativo
COMMENT ON COLUMN public.autorizados_inquilinos.foto_url IS 'URL da foto do autorizado armazenada no Supabase Storage (bucket: visitante_adicionado_pelo_inquilino)';

-- Log da migração
INSERT INTO public.migration_log (migration_name, executed_at, description) 
VALUES (
    'add_foto_url_to_autorizados_inquilinos',
    NOW(),
    'Adicionada coluna foto_url para armazenar fotos dos autorizados do inquilino'
) ON CONFLICT (migration_name) DO NOTHING;
