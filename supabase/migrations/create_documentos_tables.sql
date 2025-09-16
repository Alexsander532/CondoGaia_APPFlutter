-- Criar tabela documentos
CREATE TABLE IF NOT EXISTS documentos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nome VARCHAR(255) NOT NULL,
    descricao TEXT,
    tipo VARCHAR(20) NOT NULL CHECK (tipo IN ('pasta', 'arquivo')),
    url TEXT,
    link_externo TEXT,
    privado BOOLEAN DEFAULT FALSE,
    pasta_id UUID REFERENCES documentos(id) ON DELETE CASCADE,
    condominio_id UUID NOT NULL REFERENCES condominios(id) ON DELETE CASCADE,
    representante_id UUID NOT NULL REFERENCES representantes(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Criar tabela balancetes
CREATE TABLE IF NOT EXISTS balancetes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nome_arquivo VARCHAR(255) NOT NULL,
    url TEXT,
    link_externo TEXT,
    mes VARCHAR(20) NOT NULL,
    ano VARCHAR(4) NOT NULL,
    privado BOOLEAN DEFAULT FALSE,
    condominio_id UUID NOT NULL REFERENCES condominios(id) ON DELETE CASCADE,
    representante_id UUID NOT NULL REFERENCES representantes(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Criar índices para melhor performance
CREATE INDEX IF NOT EXISTS idx_documentos_condominio_id ON documentos(condominio_id);
CREATE INDEX IF NOT EXISTS idx_documentos_representante_id ON documentos(representante_id);
CREATE INDEX IF NOT EXISTS idx_documentos_pasta_id ON documentos(pasta_id);
CREATE INDEX IF NOT EXISTS idx_documentos_tipo ON documentos(tipo);
CREATE INDEX IF NOT EXISTS idx_documentos_created_at ON documentos(created_at);

CREATE INDEX IF NOT EXISTS idx_balancetes_condominio_id ON balancetes(condominio_id);
CREATE INDEX IF NOT EXISTS idx_balancetes_representante_id ON balancetes(representante_id);
CREATE INDEX IF NOT EXISTS idx_balancetes_mes_ano ON balancetes(mes, ano);
CREATE INDEX IF NOT EXISTS idx_balancetes_created_at ON balancetes(created_at);

-- Função para atualizar updated_at automaticamente
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Triggers para atualizar updated_at
CREATE TRIGGER update_documentos_updated_at
    BEFORE UPDATE ON documentos
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_balancetes_updated_at
    BEFORE UPDATE ON balancetes
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();