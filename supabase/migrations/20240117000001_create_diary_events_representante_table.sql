-- Migração para criar tabela de eventos de diário dos representantes
-- Descrição: Tabela para armazenar eventos de diário criados pelos representantes

CREATE TABLE IF NOT EXISTS public.eventos_diario_representante (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    
    -- Relacionamentos obrigatórios
    representante_id UUID NOT NULL REFERENCES public.representantes(id) ON DELETE CASCADE,
    condominio_id UUID NOT NULL REFERENCES public.condominios(id) ON DELETE CASCADE,
    
    -- Dados do evento
    titulo VARCHAR(255) NOT NULL,
    descricao TEXT,
    
    -- Data do evento (sem horários)
    data_evento DATE NOT NULL,
    
    -- Status do evento
    status VARCHAR(20) DEFAULT 'ativo' CHECK (status IN ('ativo', 'cancelado', 'concluido')),
    
    -- Campos de auditoria
    criado_em TIMESTAMPTZ DEFAULT NOW(),
    atualizado_em TIMESTAMPTZ DEFAULT NOW()
);

-- Criar índices para melhor performance
CREATE INDEX IF NOT EXISTS idx_eventos_diario_representante_id ON public.eventos_diario_representante(representante_id);
CREATE INDEX IF NOT EXISTS idx_eventos_diario_condominio_id ON public.eventos_diario_representante(condominio_id);
CREATE INDEX IF NOT EXISTS idx_eventos_diario_data_evento ON public.eventos_diario_representante(data_evento);
CREATE INDEX IF NOT EXISTS idx_eventos_diario_status ON public.eventos_diario_representante(status);
CREATE INDEX IF NOT EXISTS idx_eventos_diario_criado_em ON public.eventos_diario_representante(criado_em);

-- Índice composto para consultas por representante e data
CREATE INDEX IF NOT EXISTS idx_eventos_diario_rep_data ON public.eventos_diario_representante(representante_id, data_evento);

-- Trigger para atualizar automaticamente o campo atualizado_em
CREATE TRIGGER update_eventos_diario_atualizado_em
    BEFORE UPDATE ON public.eventos_diario_representante
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Comentários explicativos
COMMENT ON TABLE public.eventos_diario_representante IS 'Tabela para armazenar eventos de diário criados pelos representantes';
COMMENT ON COLUMN public.eventos_diario_representante.representante_id IS 'ID do representante que criou o evento';
COMMENT ON COLUMN public.eventos_diario_representante.condominio_id IS 'ID do condomínio relacionado ao evento';
COMMENT ON COLUMN public.eventos_diario_representante.data_evento IS 'Data do evento de diário (sem horários específicos)';
COMMENT ON COLUMN public.eventos_diario_representante.status IS 'Status do evento: ativo, cancelado, concluido';

-- Log da migração
INSERT INTO public.migration_log (migration_name, executed_at, description) 
VALUES (
    '20240117000001_create_diary_events_representante_table',
    NOW(),
    'Criada tabela eventos_diario_representante para eventos de diário vinculados ao representante e condomínio'
) ON CONFLICT (migration_name) DO NOTHING;