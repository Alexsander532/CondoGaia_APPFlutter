-- Migration: Create presentes_reserva table
-- Created: 2024-01-01
-- Description: Tabela para armazenar lista de presentes das reservas de forma dinâmica

-- Create presentes_reserva table
CREATE TABLE IF NOT EXISTS public.presentes_reserva (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    reserva_id UUID NOT NULL REFERENCES public.reservas(id) ON DELETE CASCADE,
    nome_presente VARCHAR(255) NOT NULL,
    ordem INTEGER NOT NULL DEFAULT 0, -- Para manter a ordem na lista
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    
    -- Constraints
    CONSTRAINT presentes_reserva_nome_nao_vazio CHECK (LENGTH(TRIM(nome_presente)) > 0),
    CONSTRAINT presentes_reserva_ordem_positiva CHECK (ordem >= 0)
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_presentes_reserva_reserva_id ON public.presentes_reserva(reserva_id);
CREATE INDEX IF NOT EXISTS idx_presentes_reserva_ordem ON public.presentes_reserva(reserva_id, ordem);
CREATE INDEX IF NOT EXISTS idx_presentes_reserva_created_at ON public.presentes_reserva(created_at);

-- Create unique constraint to prevent duplicate order within same reservation
CREATE UNIQUE INDEX idx_presentes_reserva_unique_ordem ON public.presentes_reserva(reserva_id, ordem);

-- Create trigger for updated_at (reusing the function from ambientes)
CREATE TRIGGER trigger_presentes_reserva_updated_at
    BEFORE UPDATE ON public.presentes_reserva
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

-- Function to automatically reorder presentes when one is deleted
CREATE OR REPLACE FUNCTION public.reorder_presentes_after_delete()
RETURNS TRIGGER AS $$
BEGIN
    -- Reorder remaining presentes to fill the gap
    UPDATE public.presentes_reserva 
    SET ordem = ordem - 1, updated_at = timezone('utc'::text, now())
    WHERE reserva_id = OLD.reserva_id 
    AND ordem > OLD.ordem;
    
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for automatic reordering after delete
CREATE TRIGGER trigger_reorder_presentes_after_delete
    AFTER DELETE ON public.presentes_reserva
    FOR EACH ROW
    EXECUTE FUNCTION public.reorder_presentes_after_delete();

-- Function to validate and auto-assign order on insert
CREATE OR REPLACE FUNCTION public.auto_assign_presente_order()
RETURNS TRIGGER AS $$
BEGIN
    -- If ordem is not provided or is 0, assign the next available order
    IF NEW.ordem IS NULL OR NEW.ordem = 0 THEN
        SELECT COALESCE(MAX(ordem), -1) + 1 
        INTO NEW.ordem 
        FROM public.presentes_reserva 
        WHERE reserva_id = NEW.reserva_id;
    END IF;
    
    -- Ensure the order is not already taken
    WHILE EXISTS (
        SELECT 1 FROM public.presentes_reserva 
        WHERE reserva_id = NEW.reserva_id 
        AND ordem = NEW.ordem 
        AND id != COALESCE(NEW.id, gen_random_uuid())
    ) LOOP
        NEW.ordem := NEW.ordem + 1;
    END LOOP;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for auto-assigning order
CREATE TRIGGER trigger_auto_assign_presente_order
    BEFORE INSERT ON public.presentes_reserva
    FOR EACH ROW
    EXECUTE FUNCTION public.auto_assign_presente_order();

-- Enable Row Level Security (RLS)
ALTER TABLE public.presentes_reserva ENABLE ROW LEVEL SECURITY;

-- Create RLS policies
-- Policy for SELECT: Usuários podem ver presentes de suas próprias reservas ou todas se admin
CREATE POLICY "Usuários podem ver presentes de suas reservas" ON public.presentes_reserva
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.reservas r
            WHERE r.id = reserva_id 
            AND (r.usuario_id = auth.uid() OR 
                 EXISTS (
                     SELECT 1 FROM auth.users 
                     WHERE id = auth.uid() 
                     AND raw_user_meta_data->>'role' = 'admin'
                 ))
        )
    );

-- Policy for INSERT: Apenas donos da reserva podem adicionar presentes
CREATE POLICY "Donos da reserva podem adicionar presentes" ON public.presentes_reserva
    FOR INSERT WITH CHECK (
        auth.uid() IS NOT NULL AND
        EXISTS (
            SELECT 1 FROM public.reservas r
            WHERE r.id = reserva_id 
            AND r.usuario_id = auth.uid()
        )
    );

-- Policy for UPDATE: Apenas donos da reserva ou admin podem atualizar presentes
CREATE POLICY "Donos da reserva podem atualizar presentes" ON public.presentes_reserva
    FOR UPDATE USING (
        EXISTS (
            SELECT 1 FROM public.reservas r
            WHERE r.id = reserva_id 
            AND (r.usuario_id = auth.uid() OR 
                 EXISTS (
                     SELECT 1 FROM auth.users 
                     WHERE id = auth.uid() 
                     AND raw_user_meta_data->>'role' = 'admin'
                 ))
        )
    );

-- Policy for DELETE: Apenas donos da reserva ou admin podem deletar presentes
CREATE POLICY "Donos da reserva podem deletar presentes" ON public.presentes_reserva
    FOR DELETE USING (
        EXISTS (
            SELECT 1 FROM public.reservas r
            WHERE r.id = reserva_id 
            AND (r.usuario_id = auth.uid() OR 
                 EXISTS (
                     SELECT 1 FROM auth.users 
                     WHERE id = auth.uid() 
                     AND raw_user_meta_data->>'role' = 'admin'
                 ))
        )
    );

-- Grant permissions
GRANT ALL ON public.presentes_reserva TO authenticated;
GRANT SELECT ON public.presentes_reserva TO anon;

-- Create view for easier querying of presentes with reservation info
CREATE OR REPLACE VIEW public.view_presentes_reserva AS
SELECT 
    pr.id,
    pr.reserva_id,
    pr.nome_presente,
    pr.ordem,
    pr.created_at,
    pr.updated_at,
    r.data_reserva,
    r.local,
    r.usuario_id,
    a.titulo as ambiente_titulo
FROM public.presentes_reserva pr
JOIN public.reservas r ON pr.reserva_id = r.id
JOIN public.ambientes a ON r.ambiente_id = a.id
ORDER BY pr.reserva_id, pr.ordem;

-- Grant permissions on view
GRANT SELECT ON public.view_presentes_reserva TO authenticated;
GRANT SELECT ON public.view_presentes_reserva TO anon;

-- Add comments for documentation
COMMENT ON TABLE public.presentes_reserva IS 'Tabela para armazenar lista de presentes das reservas de forma dinâmica';
COMMENT ON COLUMN public.presentes_reserva.reserva_id IS 'Referência à reserva que contém este presente';
COMMENT ON COLUMN public.presentes_reserva.nome_presente IS 'Nome do presente na lista';
COMMENT ON COLUMN public.presentes_reserva.ordem IS 'Ordem do presente na lista (para manter sequência)';

COMMENT ON VIEW public.view_presentes_reserva IS 'View que combina presentes com informações da reserva e ambiente';