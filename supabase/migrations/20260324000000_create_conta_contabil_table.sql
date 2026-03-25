-- Create table
CREATE TABLE IF NOT EXISTS public.conta_contabil (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    condominio_id UUID NOT NULL REFERENCES public.condominios(id) ON DELETE CASCADE,
    descricao TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now())
);

-- RLS off to match other tables in this project
ALTER TABLE public.conta_contabil DISABLE ROW LEVEL SECURITY;

-- Insert default accounts for existing condominios
INSERT INTO public.conta_contabil (condominio_id, descricao)
SELECT id, 'Taxa Condominial' FROM public.condominios
UNION ALL SELECT id, 'Fundo de Reserva' FROM public.condominios
UNION ALL SELECT id, 'Gás' FROM public.condominios
UNION ALL SELECT id, 'Água' FROM public.condominios
UNION ALL SELECT id, 'Multa por Infração' FROM public.condominios
UNION ALL SELECT id, 'Juros' FROM public.condominios
UNION ALL SELECT id, 'Acordo' FROM public.condominios
UNION ALL SELECT id, 'Outros' FROM public.condominios;

-- Modify receitas table
ALTER TABLE public.receitas
DROP COLUMN IF EXISTS categoria_id,
DROP COLUMN IF EXISTS subcategoria_id,
DROP COLUMN IF EXISTS conta_contabil;

ALTER TABLE public.receitas
ADD COLUMN conta_contabil_id UUID REFERENCES public.conta_contabil(id) ON DELETE SET NULL;
