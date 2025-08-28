-- Criar tabela administrators
CREATE TABLE administrators (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Inserir administrador padrão
INSERT INTO administrators (email, password_hash) VALUES (
    'alexsanderaugusto142019@gmail.com',
    crypt('123456', gen_salt('bf'))
);

-- Habilitar RLS (Row Level Security)
ALTER TABLE administrators ENABLE ROW LEVEL SECURITY;

-- Criar política para permitir acesso aos usuários autenticados
CREATE POLICY "Allow authenticated users to read administrators" ON administrators
    FOR SELECT USING (auth.role() = 'authenticated');

-- Permitir acesso anônimo para login
CREATE POLICY "Allow anonymous login" ON administrators
    FOR SELECT USING (true);

-- Conceder permissões
GRANT SELECT ON administrators TO anon;
GRANT SELECT ON administrators TO authenticated;