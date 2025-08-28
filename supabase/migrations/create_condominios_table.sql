-- Criar tabela condominios
CREATE TABLE condominios (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    cnpj VARCHAR(18) NOT NULL UNIQUE,
    nome VARCHAR(255) NOT NULL,
    cep VARCHAR(9) NOT NULL,
    endereco VARCHAR(255) NOT NULL,
    numero VARCHAR(10),
    complemento VARCHAR(100),
    bairro VARCHAR(100) NOT NULL,
    cidade VARCHAR(100) NOT NULL,
    estado VARCHAR(2) NOT NULL,
    telefone VARCHAR(15),
    email VARCHAR(255),
    -- Campos financeiros do condomínio
    vencimento_condominio DATE,
    valor_condominio DECIMAL(10,2),
    multa_condominio DECIMAL(5,2),
    juros_condominio DECIMAL(5,2),
    desconto_condominio DECIMAL(5,2),
    -- Campos financeiros da unidade
    vencimento_unidade DATE,
    valor_unidade DECIMAL(10,2),
    multa_unidade DECIMAL(5,2),
    juros_unidade DECIMAL(5,2),
    desconto_unidade DECIMAL(5,2),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Criar índices para melhor performance
CREATE INDEX idx_condominios_cnpj ON condominios(cnpj);
CREATE INDEX idx_condominios_nome ON condominios(nome);
CREATE INDEX idx_condominios_estado ON condominios(estado);

-- Habilitar RLS (Row Level Security)
ALTER TABLE condominios ENABLE ROW LEVEL SECURITY;

-- Criar políticas de acesso
CREATE POLICY "Permitir leitura para usuários autenticados" ON condominios
    FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "Permitir inserção para usuários autenticados" ON condominios
    FOR INSERT WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Permitir atualização para usuários autenticados" ON condominios
    FOR UPDATE USING (auth.role() = 'authenticated');

CREATE POLICY "Permitir exclusão para usuários autenticados" ON condominios
    FOR DELETE USING (auth.role() = 'authenticated');

-- Conceder permissões para as roles anon e authenticated
GRANT SELECT, INSERT, UPDATE, DELETE ON condominios TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON condominios TO authenticated;

-- Criar função para atualizar updated_at automaticamente
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Criar trigger para atualizar updated_at
CREATE TRIGGER update_condominios_updated_at
    BEFORE UPDATE ON condominios
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();