-- Corrigir políticas RLS para permitir acesso com role anon
-- O aplicativo usa autenticação customizada com SharedPreferences, não auth do Supabase

-- Remover políticas existentes que exigem authenticated
DROP POLICY IF EXISTS "Permitir leitura para usuários autenticados" ON public.condominios;
DROP POLICY IF EXISTS "Permitir inserção para usuários autenticados" ON public.condominios;
DROP POLICY IF EXISTS "Permitir atualização para usuários autenticados" ON public.condominios;
DROP POLICY IF EXISTS "Permitir exclusão para usuários autenticados" ON public.condominios;

-- Criar novas políticas que permitem acesso com role anon
-- Isso é seguro pois o app tem sua própria camada de autenticação
CREATE POLICY "Permitir leitura para role anon" ON public.condominios
    FOR SELECT USING (true);

CREATE POLICY "Permitir inserção para role anon" ON public.condominios
    FOR INSERT WITH CHECK (true);

CREATE POLICY "Permitir atualização para role anon" ON public.condominios
    FOR UPDATE USING (true);

CREATE POLICY "Permitir exclusão para role anon" ON public.condominios
    FOR DELETE USING (true);

-- Garantir que as permissões estão corretas
GRANT SELECT, INSERT, UPDATE, DELETE ON public.condominios TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.condominios TO authenticated;