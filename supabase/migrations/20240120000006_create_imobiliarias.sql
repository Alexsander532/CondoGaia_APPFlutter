-- =====================================================
-- MIGRAÇÃO 6: TABELA DE IMOBILIÁRIAS
-- =====================================================
-- Esta tabela armazena apenas os dados das imobiliárias
-- que aparecem na tela de detalhes da unidade

CREATE TABLE imobiliarias (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    condominio_id UUID NOT NULL REFERENCES condominios(id) ON DELETE CASCADE,
    
    -- Dados da Empresa (campos da tela)
    nome VARCHAR(200) NOT NULL,
    cnpj VARCHAR(20) NOT NULL,
    
    -- Contatos (campos da tela)
    telefone VARCHAR(20),
    celular VARCHAR(20),
    email VARCHAR(200),
    
    -- Status
    ativo BOOLEAN DEFAULT true,
    
    -- Metadados
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabela de relacionamento entre imobiliárias e unidades
-- Uma imobiliária pode gerenciar várias unidades
CREATE TABLE imobiliarias_unidades (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    imobiliaria_id UUID NOT NULL REFERENCES imobiliarias(id) ON DELETE CASCADE,
    unidade_id UUID NOT NULL REFERENCES unidades(id) ON DELETE CASCADE,
    condominio_id UUID NOT NULL REFERENCES condominios(id) ON DELETE CASCADE,
    
    -- Status
    ativo BOOLEAN DEFAULT true,
    
    -- Metadados
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Índices para performance
CREATE INDEX idx_imobiliarias_condominio ON imobiliarias(condominio_id);
CREATE INDEX idx_imobiliarias_cnpj ON imobiliarias(cnpj);
CREATE INDEX idx_imobiliarias_email ON imobiliarias(email);
CREATE INDEX idx_imobiliarias_ativo ON imobiliarias(ativo);

CREATE INDEX idx_imobiliarias_unidades_imobiliaria ON imobiliarias_unidades(imobiliaria_id);
CREATE INDEX idx_imobiliarias_unidades_unidade ON imobiliarias_unidades(unidade_id);
CREATE INDEX idx_imobiliarias_unidades_condominio ON imobiliarias_unidades(condominio_id);
CREATE INDEX idx_imobiliarias_unidades_ativo ON imobiliarias_unidades(ativo);

-- Constraints UNIQUE
ALTER TABLE imobiliarias ADD CONSTRAINT uk_imobiliarias_cnpj_condominio 
    UNIQUE (cnpj, condominio_id);
ALTER TABLE imobiliarias ADD CONSTRAINT uk_imobiliarias_email_condominio 
    UNIQUE (email, condominio_id);

-- Constraint para garantir uma imobiliária ativa por unidade
ALTER TABLE imobiliarias_unidades ADD CONSTRAINT uk_imobiliarias_unidades_ativa 
    UNIQUE (unidade_id, ativo) DEFERRABLE INITIALLY DEFERRED;

-- Trigger para atualizar updated_at - Imobiliárias
CREATE TRIGGER trigger_imobiliarias_updated_at
    BEFORE UPDATE ON imobiliarias
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Trigger para atualizar updated_at - Relacionamento
CREATE TRIGGER trigger_imobiliarias_unidades_updated_at
    BEFORE UPDATE ON imobiliarias_unidades
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Trigger para atualizar status tem_imobiliaria na tabela unidades
CREATE OR REPLACE FUNCTION atualizar_status_imobiliaria_unidade()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' OR TG_OP = 'UPDATE' THEN
        -- Atualizar flag tem_imobiliaria na unidade
        UPDATE unidades 
        SET tem_imobiliaria = EXISTS(
            SELECT 1 FROM imobiliarias_unidades iu
            JOIN imobiliarias i ON iu.imobiliaria_id = i.id
            WHERE iu.unidade_id = NEW.unidade_id 
            AND iu.ativo = true 
            AND i.ativo = true
        ),
        updated_at = NOW()
        WHERE id = NEW.unidade_id;
        
        RETURN NEW;
    END IF;
    
    IF TG_OP = 'DELETE' THEN
        -- Atualizar flag tem_imobiliaria na unidade
        UPDATE unidades 
        SET tem_imobiliaria = EXISTS(
            SELECT 1 FROM imobiliarias_unidades iu
            JOIN imobiliarias i ON iu.imobiliaria_id = i.id
            WHERE iu.unidade_id = OLD.unidade_id 
            AND iu.ativo = true 
            AND i.ativo = true
        ),
        updated_at = NOW()
        WHERE id = OLD.unidade_id;
        
        RETURN OLD;
    END IF;
    
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_atualizar_status_imobiliaria_unidade
    AFTER INSERT OR UPDATE OR DELETE ON imobiliarias_unidades
    FOR EACH ROW
    EXECUTE FUNCTION atualizar_status_imobiliaria_unidade();

-- Constraint para validar CNPJ (reutiliza a função criada anteriormente)
ALTER TABLE imobiliarias ADD CONSTRAINT chk_imobiliarias_cnpj_valido 
    CHECK (validar_cpf_cnpj(cnpj));