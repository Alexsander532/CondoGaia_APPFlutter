-- Migração para adicionar relacionamento 1:N entre representantes e condomínios
-- Um condomínio pertence a um representante, um representante pode ter vários condomínios
-- Data: 15/01/2024

-- Adicionar coluna representante_id na tabela condominios
ALTER TABLE public.condominios 
ADD COLUMN representante_id UUID REFERENCES public.representantes(id) ON DELETE SET NULL;

-- Criar índice para melhorar performance das consultas
CREATE INDEX idx_condominios_representante_id ON public.condominios(representante_id);

-- Comentário explicativo sobre a coluna
COMMENT ON COLUMN public.condominios.representante_id IS 'ID do representante responsável pelo condomínio. NULL indica que o condomínio não tem representante atribuído.';

-- Atualizar as políticas RLS para considerar o novo relacionamento
-- (Opcional: pode ser implementado posteriormente para controle de acesso mais granular)

-- Exemplo de política RLS mais restritiva (comentada por enquanto):
-- DROP POLICY IF EXISTS "Permitir leitura para usuários autenticados" ON public.condominios;
-- CREATE POLICY "Permitir leitura baseada no representante" ON public.condominios
--     FOR SELECT USING (
--         auth.role() = 'authenticated' AND 
--         (representante_id IS NULL OR representante_id = auth.uid()::uuid)
--     );

-- Log da migração
INSERT INTO public.migration_log (migration_name, executed_at, description) 
VALUES (
    '20240115000000_add_representante_id_to_condominios',
    NOW(),
    'Adicionada coluna representante_id na tabela condominios para estabelecer relacionamento 1:N'
) ON CONFLICT DO NOTHING;

-- Criar tabela de log de migração se não existir
CREATE TABLE IF NOT EXISTS public.migration_log (
    id SERIAL PRIMARY KEY,
    migration_name VARCHAR(255) UNIQUE NOT NULL,
    executed_at TIMESTAMPTZ DEFAULT NOW(),
    description TEXT
);