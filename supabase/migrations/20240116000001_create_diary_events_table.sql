-- Migração para criar tabela de eventos de diário dos representantes
-- Data: 16/01/2024
-- Descrição: Tabela para armazenar eventos de diário criados pelos representantes

CREATE TABLE IF NOT EXISTS public.eventos_diario_representante (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    
    -- Relacionamentos obrigatórios
    representante_id UUID NOT NULL REFERENCES public.representantes(id) ON DELETE CASCADE,
    condominio_id UUID NOT NULL REFERENCES public.condominios(id) ON DELETE CASCADE,
    
    -- Dados do evento
    titulo VARCHAR(255) NOT NULL,
    descricao TEXT,
    observacoes TEXT,
    
    -- Data e horário do evento
    data_evento DATE NOT NULL,
    hora_inicio TIME,
    hora_fim TIME,
    
    -- Classificação do evento
    categoria VARCHAR(50) DEFAULT 'geral' CHECK (categoria IN ('geral', 'manutencao', 'reuniao', 'ocorrencia', 'financeiro', 'administrativo')),
    prioridade VARCHAR(20) DEFAULT 'normal' CHECK (prioridade IN ('baixa', 'normal', 'alta', 'urgente')),
    
    -- Status do evento
    status VARCHAR(20) DEFAULT 'ativo' CHECK (status IN ('ativo', 'arquivado', 'cancelado')),
    
    -- Campos de auditoria
    criado_em TIMESTAMPTZ DEFAULT NOW(),
    atualizado_em TIMESTAMPTZ DEFAULT NOW()
);

-- Criar índices para melhor performance
CREATE INDEX IF NOT EXISTS idx_eventos_diario_representante_id ON public.eventos_diario_representante(representante_id);
CREATE INDEX IF NOT EXISTS idx_eventos_diario_condominio_id ON public.eventos_diario_representante(condominio_id);
CREATE INDEX IF NOT EXISTS idx_eventos_diario_data_evento ON public.eventos_diario_representante(data_evento);
CREATE INDEX IF NOT EXISTS idx_eventos_diario_categoria ON public.eventos_diario_representante(categoria);
CREATE INDEX IF NOT EXISTS idx_eventos_diario_prioridade ON public.eventos_diario_representante(prioridade);
CREATE INDEX IF NOT EXISTS idx_eventos_diario_status ON public.eventos_diario_representante(status);
CREATE INDEX IF NOT EXISTS idx_eventos_diario_criado_em ON public.eventos_diario_representante(criado_em);

-- Índice composto para consultas por representante e data
CREATE INDEX IF NOT EXISTS idx_eventos_diario_rep_data ON public.eventos_diario_representante(representante_id, data_evento);

-- Índice composto para consultas por categoria e prioridade
CREATE INDEX IF NOT EXISTS idx_eventos_diario_cat_prior ON public.eventos_diario_representante(categoria, prioridade);

-- Habilitar RLS (Row Level Security)
ALTER TABLE public.eventos_diario_representante ENABLE ROW LEVEL SECURITY;

-- Política para permitir leitura para usuários autenticados
CREATE POLICY "Permitir leitura para usuários autenticados" ON public.eventos_diario_representante
    FOR SELECT USING (auth.role() = 'authenticated');

-- Política para permitir inserção para usuários autenticados
CREATE POLICY "Permitir inserção para usuários autenticados" ON public.eventos_diario_representante
    FOR INSERT WITH CHECK (auth.role() = 'authenticated');

-- Política para permitir atualização para usuários autenticados
CREATE POLICY "Permitir atualização para usuários autenticados" ON public.eventos_diario_representante
    FOR UPDATE USING (auth.role() = 'authenticated');

-- Política para permitir exclusão para usuários autenticados
CREATE POLICY "Permitir exclusão para usuários autenticados" ON public.eventos_diario_representante
    FOR DELETE USING (auth.role() = 'authenticated');

-- Conceder permissões para as roles
GRANT ALL PRIVILEGES ON public.eventos_diario_representante TO authenticated;
GRANT SELECT ON public.eventos_diario_representante TO anon;

-- Trigger para atualizar automaticamente o campo atualizado_em
CREATE TRIGGER update_eventos_diario_atualizado_em
    BEFORE UPDATE ON public.eventos_diario_representante
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Comentários explicativos
COMMENT ON TABLE public.eventos_diario_representante IS 'Tabela para armazenar eventos de diário criados pelos representantes';
COMMENT ON COLUMN public.eventos_diario_representante.representante_id IS 'ID do representante que criou o evento';
COMMENT ON COLUMN public.eventos_diario_representante.condominio_id IS 'ID do condomínio relacionado ao evento';
COMMENT ON COLUMN public.eventos_diario_representante.categoria IS 'Categoria do evento: geral, manutencao, reuniao, ocorrencia, financeiro, administrativo';
COMMENT ON COLUMN public.eventos_diario_representante.prioridade IS 'Prioridade do evento: baixa, normal, alta, urgente';
COMMENT ON COLUMN public.eventos_diario_representante.status IS 'Status do evento: ativo, arquivado, cancelado';

-- Log da migração
INSERT INTO public.migration_log (migration_name, executed_at, description) 
VALUES (
    '20240116000001_create_diary_events_table',
    NOW(),
    'Criada tabela eventos_diario_representante para eventos de diário vinculados ao representante e condomínio'
) ON CONFLICT (migration_name) DO NOTHING;