-- Migration: Adicionar coluna bloco_unidade_id à tabela reservas
-- Data: 2024-11-18
-- Descrição: Adiciona referência para bloco/unidade quando a reserva é para Bloco/Unid

-- Adicionar coluna bloco_unidade_id (FK para unidades)
ALTER TABLE public.reservas
ADD COLUMN bloco_unidade_id UUID NULL DEFAULT NULL;

-- Comentário explicativo
COMMENT ON COLUMN public.reservas.bloco_unidade_id IS 'Referência para a unidade específica quando a reserva é para Bloco/Unid. NULL quando a reserva é para Condomínio.';

-- Criar índice para melhorar performance
CREATE INDEX IF NOT EXISTS idx_reservas_bloco_unidade_id ON public.reservas(bloco_unidade_id);

-- Adicionar constraint de chave estrangeira
ALTER TABLE public.reservas
ADD CONSTRAINT fk_reservas_bloco_unidade 
FOREIGN KEY (bloco_unidade_id) 
REFERENCES public.unidades(id) ON DELETE SET NULL;

-- Log da migração
INSERT INTO public.migration_log (migration_name, executed_at, description) 
VALUES (
    'add_bloco_unidade_to_reservas',
    NOW(),
    'Adicionada coluna bloco_unidade_id (UUID) para referenciar unidades específicas quando a reserva é para Bloco/Unid'
) ON CONFLICT (migration_name) DO NOTHING;
