-- Ajustar tabela condominios para conter apenas as colunas especificadas
-- Remover colunas extras e manter apenas os campos da tela de cadastro

-- Primeiro, vamos dropar a tabela existente e recriar com a estrutura correta
DROP TABLE IF EXISTS public.condominios CASCADE;

-- Criar tabela condominios com apenas as colunas necessárias
CREATE TABLE public.condominios (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    cnpj VARCHAR(18) UNIQUE NOT NULL,
    nome_condominio VARCHAR(255) NOT NULL,
    cep VARCHAR(9) NOT NULL,
    endereco VARCHAR(255) NOT NULL,
    numero VARCHAR(20) NOT NULL,
    bairro VARCHAR(100) NOT NULL,
    cidade VARCHAR(100) NOT NULL,
    estado VARCHAR(2) NOT NULL,
    plano_assinatura VARCHAR(100),
    pagamento VARCHAR(50),
    vencimento DATE,
    valor DECIMAL(10,2),
    instituicao_financeiro_condominio VARCHAR(255),
    token_financeiro_condominio VARCHAR(255),
    instituicao_financeiro_unidade VARCHAR(255),
    token_financeiro_unidade VARCHAR(255),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Criar índices para melhor performance
CREATE INDEX idx_condominios_cnpj ON public.condominios(cnpj);
CREATE INDEX idx_condominios_nome ON public.condominios(nome_condominio);
CREATE INDEX idx_condominios_cidade_estado ON public.condominios(cidade, estado);

-- Habilitar RLS (Row Level Security)
ALTER TABLE public.condominios ENABLE ROW LEVEL SECURITY;

-- Criar políticas de acesso
CREATE POLICY "Permitir leitura para usuários autenticados" ON public.condominios
    FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "Permitir inserção para usuários autenticados" ON public.condominios
    FOR INSERT WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Permitir atualização para usuários autenticados" ON public.condominios
    FOR UPDATE USING (auth.role() = 'authenticated');

CREATE POLICY "Permitir exclusão para usuários autenticados" ON public.condominios
    FOR DELETE USING (auth.role() = 'authenticated');

-- Conceder permissões para os roles anon e authenticated
GRANT SELECT, INSERT, UPDATE, DELETE ON public.condominios TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.condominios TO authenticated;

-- Criar trigger para atualizar updated_at automaticamente
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_condominios_updated_at
    BEFORE UPDATE ON public.condominios
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();