-- Adicionar coluna foto_url à tabela evento_agenda_representante
ALTER TABLE public.evento_agenda_representante
ADD COLUMN foto_url TEXT NULL DEFAULT NULL;

-- Comentário explicativo
COMMENT ON COLUMN public.evento_agenda_representante.foto_url IS 'URL da foto do evento armazenada no Supabase Storage (bucket: imagens_agenda_representante)';

-- Log da migração
INSERT INTO public.migration_log (migration_name, executed_at, description) 
VALUES (
    'add_foto_url_to_evento_agenda_representante',
    NOW(),
    'Adicionada coluna foto_url para armazenar fotos dos eventos de agenda do representante'
) ON CONFLICT (migration_name) DO NOTHING;
