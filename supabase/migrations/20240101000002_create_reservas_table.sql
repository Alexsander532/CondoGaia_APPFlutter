-- Migration: Create reservas table
-- Created: 2024-01-01
-- Description: Tabela para gerenciar reservas de ambientes

-- Create reservas table
CREATE TABLE IF NOT EXISTS public.reservas (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    ambiente_id UUID NOT NULL REFERENCES public.ambientes(id) ON DELETE CASCADE,
    usuario_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    data_reserva DATE NOT NULL,
    hora_inicio TIME NOT NULL,
    hora_fim TIME NOT NULL,
    observacoes TEXT,
    valor_pago DECIMAL(10,2),
    data_pagamento TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    
    -- Novos campos baseados na tela de reserva
    para VARCHAR(50) NOT NULL DEFAULT 'Condomínio', -- 'Condomínio' ou 'Bloco/Unid'
    local VARCHAR(255) NOT NULL, -- Local da reserva (ex: Salão de Festas)
    valor_locacao DECIMAL(10,2) NOT NULL DEFAULT 0.00, -- Valor da locação
    termo_locacao BOOLEAN NOT NULL DEFAULT false, -- Aceite do termo de locação
    
    -- Constraints
    CONSTRAINT reservas_hora_valida CHECK (hora_fim > hora_inicio),
    CONSTRAINT reservas_data_futura CHECK (data_reserva >= CURRENT_DATE),
    CONSTRAINT reservas_valor_positivo CHECK (valor_pago IS NULL OR valor_pago >= 0),
    CONSTRAINT reservas_valor_locacao_positivo CHECK (valor_locacao >= 0),
    CONSTRAINT reservas_para_valido CHECK (para IN ('Condomínio', 'Bloco/Unid'))
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_reservas_ambiente_id ON public.reservas(ambiente_id);
CREATE INDEX IF NOT EXISTS idx_reservas_usuario_id ON public.reservas(usuario_id);
CREATE INDEX IF NOT EXISTS idx_reservas_data_reserva ON public.reservas(data_reserva);
CREATE INDEX IF NOT EXISTS idx_reservas_data_hora ON public.reservas(data_reserva, hora_inicio, hora_fim);
CREATE INDEX IF NOT EXISTS idx_reservas_created_at ON public.reservas(created_at);
CREATE INDEX IF NOT EXISTS idx_reservas_local ON public.reservas(local);
CREATE INDEX IF NOT EXISTS idx_reservas_para ON public.reservas(para);

-- Create unique constraint to prevent overlapping reservations
CREATE UNIQUE INDEX idx_reservas_no_overlap ON public.reservas (
    ambiente_id, 
    data_reserva, 
    tsrange(
        (data_reserva + hora_inicio)::timestamp,
        (data_reserva + hora_fim)::timestamp,
        '[)'
    )
);

-- Create trigger for updated_at (reusing the function from ambientes)
CREATE TRIGGER trigger_reservas_updated_at
    BEFORE UPDATE ON public.reservas
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

-- Function to validate business rules
CREATE OR REPLACE FUNCTION public.validate_reserva()
RETURNS TRIGGER AS $$
DECLARE
    ambiente_record public.ambientes%ROWTYPE;
    dia_semana INTEGER;
    duracao_minutos INTEGER;
BEGIN
    -- Get ambiente details
    SELECT * INTO ambiente_record FROM public.ambientes WHERE id = NEW.ambiente_id;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Ambiente não encontrado';
    END IF;
    
    -- Check if day is blocked
    dia_semana := EXTRACT(DOW FROM NEW.data_reserva); -- 0=Sunday, 6=Saturday
    IF dia_semana = ANY(ambiente_record.dias_bloqueados) THEN
        RAISE EXCEPTION 'Reservas não são permitidas neste dia da semana para este ambiente';
    END IF;
    
    -- Check time limit
    IF ambiente_record.limite_horario IS NOT NULL AND NEW.hora_inicio > ambiente_record.limite_horario THEN
        RAISE EXCEPTION 'Horário de início excede o limite permitido para este ambiente';
    END IF;
    
    -- Check duration limit
    IF ambiente_record.limite_tempo_duracao IS NOT NULL THEN
        duracao_minutos := EXTRACT(EPOCH FROM (NEW.hora_fim - NEW.hora_inicio)) / 60;
        IF duracao_minutos > ambiente_record.limite_tempo_duracao THEN
            RAISE EXCEPTION 'Duração da reserva excede o limite permitido para este ambiente';
        END IF;
    END IF;
    
    -- Set valor_pago if not provided
    IF NEW.valor_pago IS NULL THEN
        NEW.valor_pago := ambiente_record.valor;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for business rules validation
CREATE TRIGGER trigger_validate_reserva
    BEFORE INSERT OR UPDATE ON public.reservas
    FOR EACH ROW
    EXECUTE FUNCTION public.validate_reserva();

-- Enable Row Level Security (RLS)
ALTER TABLE public.reservas ENABLE ROW LEVEL SECURITY;

-- Create RLS policies
-- Policy for SELECT: Usuários podem ver suas próprias reservas ou todas se admin
CREATE POLICY "Usuários podem ver suas reservas" ON public.reservas
    FOR SELECT USING (
        auth.uid() = usuario_id OR 
        EXISTS (
            SELECT 1 FROM auth.users 
            WHERE id = auth.uid() 
            AND raw_user_meta_data->>'role' = 'admin'
        )
    );

-- Policy for INSERT: Apenas usuários autenticados podem criar reservas
CREATE POLICY "Usuários autenticados podem criar reservas" ON public.reservas
    FOR INSERT WITH CHECK (
        auth.uid() IS NOT NULL AND 
        auth.uid() = usuario_id
    );

-- Policy for UPDATE: Apenas o dono da reserva ou admin pode atualizar
CREATE POLICY "Dono pode atualizar reserva" ON public.reservas
    FOR UPDATE USING (
        auth.uid() = usuario_id OR 
        EXISTS (
            SELECT 1 FROM auth.users 
            WHERE id = auth.uid() 
            AND raw_user_meta_data->>'role' = 'admin'
        )
    );

-- Policy for DELETE: Apenas o dono da reserva ou admin pode deletar
CREATE POLICY "Dono pode deletar reserva" ON public.reservas
    FOR DELETE USING (
        auth.uid() = usuario_id OR 
        EXISTS (
            SELECT 1 FROM auth.users 
            WHERE id = auth.uid() 
            AND raw_user_meta_data->>'role' = 'admin'
        )
    );

-- Grant permissions
GRANT ALL ON public.reservas TO authenticated;
GRANT SELECT ON public.reservas TO anon;

-- Add comments for documentation
COMMENT ON TABLE public.reservas IS 'Tabela para gerenciar reservas de ambientes';
COMMENT ON COLUMN public.reservas.ambiente_id IS 'Referência ao ambiente reservado';
COMMENT ON COLUMN public.reservas.usuario_id IS 'Referência ao usuário que fez a reserva';
COMMENT ON COLUMN public.reservas.data_reserva IS 'Data da reserva';
COMMENT ON COLUMN public.reservas.hora_inicio IS 'Horário de início da reserva';
COMMENT ON COLUMN public.reservas.hora_fim IS 'Horário de fim da reserva';
COMMENT ON COLUMN public.reservas.observacoes IS 'Observações adicionais sobre a reserva';
COMMENT ON COLUMN public.reservas.valor_pago IS 'Valor pago pela reserva';
COMMENT ON COLUMN public.reservas.data_pagamento IS 'Data e hora do pagamento';
COMMENT ON COLUMN public.reservas.para IS 'Tipo de reserva: Condomínio ou Bloco/Unid';
COMMENT ON COLUMN public.reservas.local IS 'Local específico da reserva (ex: Salão de Festas)';
COMMENT ON COLUMN public.reservas.valor_locacao IS 'Valor da locação do ambiente';
COMMENT ON COLUMN public.reservas.termo_locacao IS 'Indica se o termo de locação foi aceito';