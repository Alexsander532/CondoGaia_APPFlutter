-- =====================================================
-- MIGRAÇÃO 4: TABELA DE PROPRIETÁRIOS
-- =====================================================
-- Esta tabela armazena todos os dados dos proprietários
-- conforme os campos da tela de detalhes da unidade

CREATE TABLE proprietarios (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    condominio_id UUID NOT NULL REFERENCES condominios(id) ON DELETE CASCADE,
    unidade_id UUID NOT NULL REFERENCES unidades(id) ON DELETE CASCADE,
    
    -- Dados Pessoais/Empresariais
    nome VARCHAR(200) NOT NULL,
    cpf_cnpj VARCHAR(20) NOT NULL,
    
    -- Endereço Completo
    cep VARCHAR(10),
    endereco VARCHAR(300),
    numero VARCHAR(20),
    complemento VARCHAR(100),
    bairro VARCHAR(100),
    cidade VARCHAR(100),
    estado VARCHAR(2),
    
    -- Contatos
    telefone VARCHAR(20),
    celular VARCHAR(20),
    email VARCHAR(200),
    
    -- Informações Familiares/Societárias
    conjuge VARCHAR(200), -- Nome do cônjuge ou sócio
    multiproprietarios TEXT, -- Lista de outros proprietários
    moradores TEXT, -- Lista de moradores autorizados
    
    -- Status
    ativo BOOLEAN DEFAULT true,
    
    -- Metadados
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Índices para performance
CREATE INDEX idx_proprietarios_condominio_id ON proprietarios(condominio_id);
CREATE INDEX idx_proprietarios_unidade_id ON proprietarios(unidade_id);

-- Constraints únicos por condomínio
CREATE UNIQUE INDEX uk_proprietarios_cpf_cnpj ON proprietarios(condominio_id, cpf_cnpj);
CREATE UNIQUE INDEX uk_proprietarios_email ON proprietarios(condominio_id, email) 
WHERE email IS NOT NULL AND email != '';

-- Trigger para atualizar updated_at
CREATE TRIGGER trigger_proprietarios_updated_at
    BEFORE UPDATE ON proprietarios
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Trigger para atualizar status da unidade
CREATE OR REPLACE FUNCTION update_unidade_tem_proprietario()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' OR TG_OP = 'UPDATE' THEN
        -- Atualizar flag tem_proprietario na unidade
        UPDATE unidades 
        SET tem_proprietario = EXISTS(
            SELECT 1 FROM proprietarios 
            WHERE unidade_id = NEW.unidade_id AND ativo = true
        )
        WHERE id = NEW.unidade_id;
        
        RETURN NEW;
    ELSIF TG_OP = 'DELETE' THEN
        -- Atualizar flag tem_proprietario na unidade
        UPDATE unidades 
        SET tem_proprietario = EXISTS(
            SELECT 1 FROM proprietarios 
            WHERE unidade_id = OLD.unidade_id AND ativo = true
        )
        WHERE id = OLD.unidade_id;
        
        RETURN OLD;
    END IF;
    
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_unidade_tem_proprietario
    AFTER INSERT OR UPDATE OR DELETE ON proprietarios
    FOR EACH ROW
    EXECUTE FUNCTION update_unidade_tem_proprietario();

-- Função para validar CPF/CNPJ
CREATE OR REPLACE FUNCTION validar_cpf_cnpj(documento VARCHAR(20))
RETURNS BOOLEAN AS $$
BEGIN
    -- Remove caracteres especiais
    documento := REGEXP_REPLACE(documento, '[^0-9]', '', 'g');
    
    -- Verifica se tem 11 dígitos (CPF) ou 14 dígitos (CNPJ)
    IF LENGTH(documento) NOT IN (11, 14) THEN
        RETURN false;
    END IF;
    
    -- Verifica se não são todos os dígitos iguais
    IF documento ~ '^(.)\1*$' THEN
        RETURN false;
    END IF;
    
    -- Aqui você pode implementar a validação completa do CPF/CNPJ
    -- Por simplicidade, estamos apenas fazendo validações básicas
    
    RETURN true;
END;
$$ LANGUAGE plpgsql;

-- Constraint para validar CPF/CNPJ
ALTER TABLE proprietarios 
ADD CONSTRAINT check_cpf_cnpj_valido 
CHECK (validar_cpf_cnpj(cpf_cnpj));