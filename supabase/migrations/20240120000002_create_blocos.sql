-- =====================================================
-- MIGRAÇÃO 2: TABELA DE BLOCOS
-- =====================================================
-- Esta tabela armazena os blocos de cada condomínio
-- baseado na configuração dinâmica

CREATE TABLE blocos (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    condominio_id UUID NOT NULL REFERENCES condominios(id) ON DELETE CASCADE,
    
    -- Identificação do Bloco
    nome VARCHAR(100) NOT NULL, -- Ex: "Bloco A", "Torre 1", "Edifício Norte"
    codigo VARCHAR(20) NOT NULL, -- Ex: "A", "1", "NORTE" (para uso interno)
    ordem INTEGER NOT NULL DEFAULT 1, -- Ordem de exibição
    
    -- Status
    ativo BOOLEAN DEFAULT true,
    
    -- Metadados
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Índices para performance
CREATE INDEX idx_blocos_condominio_id ON blocos(condominio_id);
CREATE INDEX idx_blocos_ordem ON blocos(condominio_id, ordem);

-- Constraints únicos por condomínio
CREATE UNIQUE INDEX uk_blocos_nome ON blocos(condominio_id, nome);
CREATE UNIQUE INDEX uk_blocos_codigo ON blocos(condominio_id, codigo);
CREATE UNIQUE INDEX uk_blocos_ordem ON blocos(condominio_id, ordem);

-- Trigger para atualizar updated_at
CREATE TRIGGER trigger_blocos_updated_at
    BEFORE UPDATE ON blocos
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Função para gerar blocos automaticamente baseado na configuração
CREATE OR REPLACE FUNCTION gerar_blocos_automatico(p_condominio_id UUID)
RETURNS INTEGER AS $$
DECLARE
    config RECORD;
    i INTEGER;
    nome_bloco VARCHAR(100);
    codigo_bloco VARCHAR(20);
    blocos_criados INTEGER := 0;
BEGIN
    -- Buscar configuração do condomínio
    SELECT * INTO config 
    FROM configuracao_condominio 
    WHERE condominio_id = p_condominio_id;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Configuração não encontrada para o condomínio %', p_condominio_id;
    END IF;
    
    -- Gerar blocos baseado na configuração
    FOR i IN 1..config.total_blocos LOOP
        IF config.usar_letras_blocos THEN
            codigo_bloco := CHR(64 + i); -- A, B, C, D...
            nome_bloco := 'Bloco ' || codigo_bloco;
        ELSE
            codigo_bloco := i::TEXT;
            nome_bloco := 'Bloco ' || codigo_bloco;
        END IF;
        
        INSERT INTO blocos (
            condominio_id,
            nome,
            codigo,
            ordem
        ) VALUES (
            p_condominio_id,
            nome_bloco,
            codigo_bloco,
            i
        );
        
        blocos_criados := blocos_criados + 1;
    END LOOP;
    
    RETURN blocos_criados;
END;
$$ LANGUAGE plpgsql;