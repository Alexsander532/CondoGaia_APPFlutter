-- =====================================================
-- MIGRAÇÃO 1: CONFIGURAÇÃO DINÂMICA DO CONDOMÍNIO
-- =====================================================
-- Esta tabela permite que cada condomínio configure
-- dinamicamente quantos blocos e unidades terá

CREATE TABLE configuracao_condominio (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    condominio_id UUID NOT NULL REFERENCES condominios(id) ON DELETE CASCADE,
    
    -- Configuração básica de estrutura
    total_blocos INTEGER NOT NULL DEFAULT 4,
    unidades_por_bloco INTEGER NOT NULL DEFAULT 6,
    usar_letras_blocos BOOLEAN DEFAULT true, -- true = A,B,C | false = 1,2,3
    
    -- Metadados
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Índices para performance
CREATE INDEX idx_configuracao_condominio_id ON configuracao_condominio(condominio_id);

-- Constraint: Um condomínio só pode ter uma configuração
CREATE UNIQUE INDEX idx_configuracao_condominio_unique ON configuracao_condominio(condominio_id);

-- Trigger para atualizar updated_at
CREATE TRIGGER trigger_configuracao_condominio_updated_at
    BEFORE UPDATE ON configuracao_condominio
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Função para gerar configuração padrão
CREATE OR REPLACE FUNCTION criar_configuracao_padrao_condominio(p_condominio_id UUID)
RETURNS UUID AS $$
DECLARE
    config_id UUID;
BEGIN
    INSERT INTO configuracao_condominio (
        condominio_id,
        total_blocos,
        unidades_por_bloco,
        usar_letras_blocos
    ) VALUES (
        p_condominio_id,
        4, -- 4 blocos padrão (A, B, C, D)
        6, -- 6 unidades por bloco
        true -- Usar letras para blocos
    ) RETURNING id INTO config_id;
    
    RETURN config_id;
END;
$$ LANGUAGE plpgsql;