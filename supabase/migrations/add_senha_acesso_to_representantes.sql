-- Adicionar coluna senha_acesso à tabela representantes
-- Esta migração adiciona uma nova coluna para armazenar a senha de acesso dos representantes

-- Adicionar a coluna senha_acesso do tipo VARCHAR
ALTER TABLE public.representantes 
ADD COLUMN IF NOT EXISTS senha_acesso VARCHAR(255);

-- Definir a senha '123456' para todos os representantes existentes na tabela
UPDATE public.representantes 
SET senha_acesso = '123456' 
WHERE senha_acesso IS NULL;

-- Comentário: A senha padrão '123456' foi definida para todos os representantes existentes
-- Recomenda-se que os representantes alterem suas senhas após o primeiro ac