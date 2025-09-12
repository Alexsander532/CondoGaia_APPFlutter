-- Migração: Adicionar coluna foto_perfil à tabela representantes
-- Data: 2024-01-15
-- Descrição: Adiciona coluna para armazenar a foto de perfil dos representantes

-- Adicionar coluna foto_perfil à tabela representantes
ALTER TABLE public.representantes 
ADD COLUMN foto_perfil TEXT;

-- Adicionar comentário à coluna
COMMENT ON COLUMN public.representantes.foto_perfil IS 'URL ou base64 da foto de perfil do representante';

-- Criar índice para otimizar consultas que filtram por representantes com foto
CREATE INDEX idx_representantes_foto_perfil ON public.representantes(foto_perfil) 
WHERE foto_perfil IS NOT NULL;

-- Atualizar a função de trigger para incluir foto_perfil nas atualizações
-- (A função update_updated_at_column já existe e será aplicada automaticamente)