-- Migration: Adicionar coluna termo_locacao à tabela reservas
-- Data: 2024-11-18
-- Descrição: Adiciona campo booleano para registrar aceitar termo de locação

-- Adicionar coluna termo_locacao
ALTER TABLE public.reservas
ADD COLUMN termo_locacao BOOLEAN NOT NULL DEFAULT false;

-- Comentário explicativo
COMMENT ON COLUMN public.reservas.termo_locacao IS 'Indica se o representante aceitou o termo de locação do ambiente';

-- Criar índice para melhorar performance em filtros
CREATE INDEX IF NOT EXISTS idx_reservas_termo_locacao ON public.reservas(termo_locacao);

-- Log da migração
INSERT INTO public.migration_log (migration_name, executed_at, description) 
VALUES (
    'add_termo_locacao_to_reservas',
    NOW(),
    'Adicionada coluna termo_locacao (booleana) para registrar aceitação do termo de locação'
) ON CONFLICT (migration_name) DO NOTHING;
