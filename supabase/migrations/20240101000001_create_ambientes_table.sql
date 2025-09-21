-- Migration: Create ambientes table
-- Created: 2024-01-01
-- Description: Tabela para gerenciar ambientes disponíveis para reserva

-- Create ambientes table
CREATE TABLE IF NOT EXISTS public.ambientes (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    titulo VARCHAR(255) NOT NULL,
    descricao TEXT,
    valor DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    limite_horario TIME,
    limite_tempo_duracao INTEGER, -- em minutos
    dias_bloqueados INTEGER[] DEFAULT '{}', -- array de dias da semana (0=domingo, 6=sábado)
    inadiplente_podem_assinar BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    created_by UUID REFERENCES auth.users(id),
    updated_by UUID REFERENCES auth.users(id)
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_ambientes_titulo ON public.ambientes(titulo);
CREATE INDEX IF NOT EXISTS idx_ambientes_valor ON public.ambientes(valor);
CREATE INDEX IF NOT EXISTS idx_ambientes_created_at ON public.ambientes(created_at);

-- Create trigger for updated_at
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = timezone('utc'::text, now());
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_ambientes_updated_at
    BEFORE UPDATE ON public.ambientes
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

-- Enable Row Level Security (RLS)
ALTER TABLE public.ambientes ENABLE ROW LEVEL SECURITY;

-- Create RLS policies
-- Policy for SELECT: Todos podem visualizar ambientes
CREATE POLICY "Ambientes são visíveis para todos" ON public.ambientes
    FOR SELECT USING (true);

-- Policy for INSERT: Apenas usuários autenticados podem criar
CREATE POLICY "Usuários autenticados podem criar ambientes" ON public.ambientes
    FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);

-- Policy for UPDATE: Apenas o criador ou admin pode atualizar
CREATE POLICY "Criador pode atualizar ambiente" ON public.ambientes
    FOR UPDATE USING (
        auth.uid() = created_by OR 
        EXISTS (
            SELECT 1 FROM auth.users 
            WHERE id = auth.uid() 
            AND raw_user_meta_data->>'role' = 'admin'
        )
    );

-- Policy for DELETE: Apenas o criador ou admin pode deletar
CREATE POLICY "Criador pode deletar ambiente" ON public.ambientes
    FOR DELETE USING (
        auth.uid() = created_by OR 
        EXISTS (
            SELECT 1 FROM auth.users 
            WHERE id = auth.uid() 
            AND raw_user_meta_data->>'role' = 'admin'
        )
    );

-- Grant permissions
GRANT ALL ON public.ambientes TO authenticated;
GRANT SELECT ON public.ambientes TO anon;

-- Add comments for documentation
COMMENT ON TABLE public.ambientes IS 'Tabela para gerenciar ambientes disponíveis para reserva';
COMMENT ON COLUMN public.ambientes.titulo IS 'Nome/título do ambiente';
COMMENT ON COLUMN public.ambientes.descricao IS 'Descrição detalhada do ambiente';
COMMENT ON COLUMN public.ambientes.valor IS 'Valor da reserva do ambiente';
COMMENT ON COLUMN public.ambientes.limite_horario IS 'Horário limite para reservas';
COMMENT ON COLUMN public.ambientes.limite_tempo_duracao IS 'Tempo máximo de duração da reserva em minutos';
COMMENT ON COLUMN public.ambientes.dias_bloqueados IS 'Array com dias da semana bloqueados (0=domingo, 6=sábado)';
COMMENT ON COLUMN public.ambientes.inadiplente_podem_assinar IS 'Se inadimplentes podem fazer reservas neste ambiente';