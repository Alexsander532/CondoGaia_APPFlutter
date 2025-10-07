-- =====================================================
-- MIGRAÇÃO 5: TABELA DE INQUILINOS
-- =====================================================
-- Esta tabela armazena apenas os dados dos inquilinos
-- que aparecem na tela de detalhes da unidade

CREATE TABLE inquilinos (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    condominio_id UUID NOT NULL REFERENCES condominios(id) ON DELETE CASCADE,
    unidade_id UUID NOT NULL REFERENCES unidades(id) ON DELETE CASCADE,
    
    -- Dados Pessoais (campos da tela)
    nome VARCHAR(200) NOT NULL,
    cpf_cnpj VARCHAR(20) NOT NULL,
    
    -- Endereço (campos da tela)
    cep VARCHAR(10),
    endereco VARCHAR(300),
    numero VARCHAR(20),
    bairro VARCHAR(100),
    cidade VARCHAR(100),
    estado VARCHAR(2),
    
    -- Contatos (campos da tela)
    telefone VARCHAR(20),
    celular VARCHAR(20),
    email VARCHAR(200),
    
    -- Informações Familiares (campos da tela)
    conjuge VARCHAR(200),
    multiproprietarios TEXT,
    moradores TEXT,
    
    -- Configurações específicas da tela
    receber_boleto_email BOOLEAN DEFAULT true,
    controle_locacao BOOLEAN DEFAULT true,
    
    -- Status
    ativo BOOLEAN DEFAULT true,
    
    -- Metadados
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Índices para performance
CREATE INDEX idx_inquilinos_condominio ON inquilinos(condominio_id);
CREATE INDEX idx_inquilinos_unidade ON inquilinos(unidade_id);
CREATE INDEX idx_inquilinos_cpf_cnpj ON inquilinos(cpf_cnpj);
CREATE INDEX idx_inquilinos_email ON inquilinos(email);
CREATE INDEX idx_inquilinos_ativo ON inquilinos(ativo);

-- Constraints UNIQUE
ALTER TABLE inquilinos ADD CONSTRAINT uk_inquilinos_cpf_cnpj_condominio 
    UNIQUE (cpf_cnpj, condominio_id);
ALTER TABLE inquilinos ADD CONSTRAINT uk_inquilinos_email_condominio 
    UNIQUE (email, condominio_id);

-- Trigger para atualizar updated_at
CREATE TRIGGER trigger_inquilinos_updated_at
    BEFORE UPDATE ON inquilinos
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Trigger para atualizar status tem_inquilino na tabela unidades
CREATE OR REPLACE FUNCTION atualizar_status_inquilino_unidade()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' OR TG_OP = 'UPDATE' THEN
        -- Atualizar status tem_inquilino na unidade
        UPDATE unidades 
        SET 
            tem_inquilino = EXISTS(
                SELECT 1 FROM inquilinos 
                WHERE unidade_id = NEW.unidade_id 
                AND ativo = true
            ),
            updated_at = NOW()
        WHERE id = NEW.unidade_id;
        
        RETURN NEW;
    END IF;
    
    IF TG_OP = 'DELETE' THEN
        -- Atualizar status tem_inquilino na unidade
        UPDATE unidades 
        SET 
            tem_inquilino = EXISTS(
                SELECT 1 FROM inquilinos 
                WHERE unidade_id = OLD.unidade_id 
                AND ativo = true
            ),
            updated_at = NOW()
        WHERE id = OLD.unidade_id;
        
        RETURN OLD;
    END IF;
    
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_atualizar_status_inquilino_unidade
    AFTER INSERT OR UPDATE OR DELETE ON inquilinos
    FOR EACH ROW
    EXECUTE FUNCTION atualizar_status_inquilino_unidade();

-- Constraint para validar CPF/CNPJ (reutiliza a função criada anteriormente)
ALTER TABLE inquilinos 
ADD CONSTRAINT check_inquilino_cpf_cnpj_valido 
CHECK (validar_cpf_cnpj(cpf_cnpj));