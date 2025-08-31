-- Desabilitar RLS (Row Level Security) para a tabela representantes
-- Esta migration remove todas as políticas RLS e desabilita a segurança de linha

-- Remover todas as políticas existentes da tabela representantes
DROP POLICY IF EXISTS "Permitir leitura para usuários autenticados" ON public.representantes;
DROP POLICY IF EXISTS "Permitir inserção para usuários autenticados" ON public.representantes;
DROP POLICY IF EXISTS "Permitir atualização para usuários autenticados" ON public.representantes;
DROP POLICY IF EXISTS "Permitir exclusão para usuários autenticados" ON public.representantes;

-- Desabilitar RLS na tabela representantes
ALTER TABLE public.representantes DISABLE ROW LEVEL SECURITY;

-- Garantir que as permissões estão corretas para acesso público
GRANT ALL PRIVILEGES ON public.representantes TO anon;
GRANT ALL PRIVILEGES ON public.representantes TO authenticated;
GRANT ALL PRIVILEGES ON public.representantes TO service_role;

-- Comentário explicativo
COMMENT ON TABLE public.representantes IS 'Tabela de representantes com RLS desabilitado para permitir inserções diretas via anon key';