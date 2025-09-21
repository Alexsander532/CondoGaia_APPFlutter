-- Migração para criar tabela de eventos de agenda dos representantes
-- Data: 16/01/2024
-- Descrição: Tabela para armazenar eventos de agenda criados pelos representantes

CREATE TABLE IF NOT EXISTS public.eventos_agenda_representante (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    
    -- Relacionamentos obrigatórios
    representante_id UUID NOT NULL REFERENCES public.representantes(id) ON DELETE CASCADE,
    condominio_id UUID NOT NULL REFERENCES public.condominios(id) ON DELETE CASCADE,
    
    -- Dados do evento
    titulo VARCHAR(255) NOT NULL,
    descricao TEXT,
    
    -- Data e horário do evento
    data_evento DATE NOT NULL,
    hora_inicio TIME NOT NULL,
    hora_fim TIME,
    
    -- Configurações do evento
    evento_recorrente BOOLEAN DEFAULT FALSE,
    numero_meses_recorrencia INTEGER CHECK (numero_meses_recorrencia > 0 AND numero_meses_recorrencia <= 60),
    
    -- Configurações de notificação
    avisar_condominios_email BOOLEAN DEFAULT FALSE,
    avisar_representante_email BOOLEAN DEFAULT FALSE,
    
    -- Status do evento
    status VARCHAR(20) DEFAULT 'ativo' CHECK (status IN ('ativo', 'cancelado', 'concluido')),
    
    -- Campos de auditoria
    criado_em TIMESTAMPTZ DEFAULT NOW(),
    atualizado_em TIMESTAMPTZ DEFAULT NOW()
);

-- Criar índices para melhor performance
CREATE INDEX IF NOT EXISTS idx_eventos_agenda_representante_id ON public.eventos_agenda_representante(representante_id);
CREATE INDEX IF NOT EXISTS idx_eventos_agenda_condominio_id ON public.eventos_agenda_representante(condominio_id);
CREATE INDEX IF NOT EXISTS idx_eventos_agenda_data_evento ON public.eventos_agenda_representante(data_evento);
CREATE INDEX IF NOT EXISTS idx_eventos_agenda_status ON public.eventos_agenda_representante(status);
CREATE INDEX IF NOT EXISTS idx_eventos_agenda_criado_em ON public.eventos_agenda_representante(criado_em);

-- Índice composto para consultas por representante e data
CREATE INDEX IF NOT EXISTS idx_eventos_agenda_rep_data ON public.eventos_agenda_representante(representante_id, data_evento);

-- Habilitar RLS (Row Level Security)
ALTER TABLE public.eventos_agenda_representante ENABLE ROW LEVEL SECURITY;

-- Política para permitir leitura para usuários autenticados
CREATE POLICY "Permitir leitura para usuários autenticados" ON public.eventos_agenda_representante
    FOR SELECT USING (auth.role() = 'authenticated');

-- Política para permitir inserção para usuários autenticados
CREATE POLICY "Permitir inserção para usuários autenticados" ON public.eventos_agenda_representante
    FOR INSERT WITH CHECK (auth.role() = 'authenticated');

-- Política para permitir atualização para usuários autenticados
CREATE POLICY "Permitir atualização para usuários autenticados" ON public.eventos_agenda_representante
    FOR UPDATE USING (auth.role() = 'authenticated');

-- Política para permitir exclusão para usuários autenticados
CREATE POLICY "Permitir exclusão para usuários autenticados" ON public.eventos_agenda_representante
    FOR DELETE USING (auth.role() = 'authenticated');

-- Conceder permissões para as roles
GRANT ALL PRIVILEGES ON public.eventos_agenda_representante TO authenticated;
GRANT SELECT ON public.eventos_agenda_representante TO anon;

-- Trigger para atualizar automaticamente o campo atualizado_em
CREATE TRIGGER update_eventos_agenda_atualizado_em
    BEFORE UPDATE ON public.eventos_agenda_representante
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Comentários explicativos
COMMENT ON TABLE public.eventos_agenda_representante IS 'Tabela para armazenar eventos de agenda criados pelos representantes';
COMMENT ON COLUMN public.eventos_agenda_representante.representante_id IS 'ID do representante que criou o evento';
COMMENT ON COLUMN public.eventos_agenda_representante.condominio_id IS 'ID do condomínio relacionado ao evento';
COMMENT ON COLUMN public.eventos_agenda_representante.numero_meses_recorrencia IS 'Número de meses para recorrência (1-60 meses)';
COMMENT ON COLUMN public.eventos_agenda_representante.avisar_condominios_email IS 'Se deve enviar notificação por email para os condomínios';
COMMENT ON COLUMN public.eventos_agenda_representante.avisar_representante_email IS 'Se deve enviar notificação por email para o representante';
COMMENT ON COLUMN public.eventos_agenda_representante.status IS 'Status do evento: ativo, cancelado, concluido';

-- Log da migração
INSERT INTO public.migration_log (migration_name, executed_at, description) 
VALUES (
    '20240116000000_create_agenda_events_table',
    NOW(),
    'Criada tabela eventos_agenda_representante para eventos de agenda vinculados ao representante e condomínio'
) ON CONFLICT (migration_name) DO NOTHING;