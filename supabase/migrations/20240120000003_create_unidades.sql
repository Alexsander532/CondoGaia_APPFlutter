-- =====================================================
-- MIGRAÇÃO 3: TABELA DE UNIDADES
-- =====================================================
-- Esta tabela armazena todas as unidades de cada bloco
-- com todos os campos necessários da tela

CREATE TABLE unidades (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    condominio_id UUID NOT NULL REFERENCES condominios(id) ON DELETE CASCADE,
    bloco_id UUID NOT NULL REFERENCES blocos(id) ON DELETE CASCADE,
    
    -- Identificação da Unidade
    numero VARCHAR(20) NOT NULL, -- Ex: "101", "A-101", "Torre1-101"
    
    -- Status da Unidade (para controle de relacionamentos)
    tem_proprietario BOOLEAN DEFAULT false,
    tem_inquilino BOOLEAN DEFAULT false,
    tem_imobiliaria BOOLEAN DEFAULT false,
    
    -- Status
    ativo BOOLEAN DEFAULT true,
    
    -- Metadados
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Índices para performance
CREATE INDEX idx_unidades_condominio_id ON unidades(condominio_id);
CREATE INDEX idx_unidades_bloco_id ON unidades(bloco_id);

-- Constraint: Número único por bloco
CREATE UNIQUE INDEX uk_unidades_numero ON unidades(bloco_id, numero);

-- Trigger para atualizar updated_at
CREATE TRIGGER trigger_unidades_updated_at
    BEFORE UPDATE ON unidades
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Função para gerar unidades automaticamente para um bloco
CREATE OR REPLACE FUNCTION gerar_unidades_automatico(p_bloco_id UUID)
RETURNS INTEGER AS $$
DECLARE
    bloco RECORD;
    config RECORD;
    i INTEGER;
    numero_unidade VARCHAR(20);
    unidades_criadas INTEGER := 0;
BEGIN
    -- Buscar dados do bloco e configuração
    SELECT b.condominio_id, c.unidades_por_bloco
    INTO bloco
    FROM blocos b
    JOIN configuracao_condominio c ON b.condominio_id = c.condominio_id
    WHERE b.id = p_bloco_id;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Bloco não encontrado: %', p_bloco_id;
    END IF;
    
    -- Gerar unidades baseado na configuração
    FOR i IN 1..bloco.unidades_por_bloco LOOP
        numero_unidade := (100 + i)::TEXT; -- 101, 102, 103...
        
        INSERT INTO unidades (
            condominio_id,
            bloco_id,
            numero
        ) VALUES (
            bloco.condominio_id,
            p_bloco_id,
            numero_unidade
        );
        
        unidades_criadas := unidades_criadas + 1;
    END LOOP;
    
    RETURN unidades_criadas;
END;
$$ LANGUAGE plpgsql;

-- View para facilitar consultas com número completo da unidade
CREATE VIEW vw_unidades_completas AS
SELECT 
    u.id,
    u.condominio_id,
    u.bloco_id,
    u.numero,
    b.nome || ' - ' || u.numero AS numero_completo,
    b.nome AS nome_bloco,
    b.codigo AS codigo_bloco,
    u.tem_proprietario,
    u.tem_inquilino,
    u.tem_imobiliaria,
    u.ativo,
    u.created_at,
    u.updated_at
FROM unidades u
JOIN blocos b ON u.bloco_id = b.id;

-- Função para gerar todas as unidades de um condomínio
CREATE OR REPLACE FUNCTION gerar_todas_unidades_condominio(p_condominio_id UUID)
RETURNS INTEGER AS $$
DECLARE
    bloco_record RECORD;
    total_unidades INTEGER := 0;
BEGIN
    FOR bloco_record IN 
        SELECT id FROM blocos WHERE condominio_id = p_condominio_id AND ativo = true
    LOOP
        total_unidades := total_unidades + gerar_unidades_automatico(bloco_record.id);
    END LOOP;
    
    RETURN total_unidades;
END;
$$ LANGUAGE plpgsql;