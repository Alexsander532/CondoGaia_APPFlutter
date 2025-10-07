-- =====================================================
-- TABELA: blocos
-- PROPÓSITO: Define cada bloco individual do condomínio (A, B, C, D, E, etc.)
-- RELACIONAMENTO: N:1 com configuracao_condominio (vários blocos por configuração)
-- =====================================================

CREATE TABLE IF NOT EXISTS blocos (
    -- Chave primária
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Relacionamentos
    condominio_id UUID NOT NULL REFERENCES condominios(id) ON DELETE CASCADE,
    configuracao_id UUID NOT NULL REFERENCES configuracao_condominio(id) ON DELETE CASCADE,
    
    -- Identificação do bloco
    letra VARCHAR(5) NOT NULL CHECK (LENGTH(letra) > 0), -- A, B, C, D, E, etc.
    nome VARCHAR(100) DEFAULT NULL, -- Nome opcional do bloco (ex: "Bloco Residencial A")
    descricao TEXT DEFAULT NULL, -- Descrição opcional
    
    -- Configurações específicas do bloco
    total_unidades INTEGER NOT NULL DEFAULT 0 CHECK (total_unidades >= 0),
    total_andares INTEGER DEFAULT NULL CHECK (total_andares IS NULL OR total_andares > 0),
    unidades_por_andar INTEGER DEFAULT NULL CHECK (unidades_por_andar IS NULL OR unidades_por_andar > 0),
    
    -- Numeração específica do bloco
    numero_inicial INTEGER NOT NULL DEFAULT 101 CHECK (numero_inicial > 0),
    incremento INTEGER NOT NULL DEFAULT 1 CHECK (incremento > 0),
    
    -- Localização e características
    endereco_especifico VARCHAR(255) DEFAULT NULL, -- Se o bloco tem endereço diferente
    observacoes TEXT DEFAULT NULL,
    
    -- Status e controle
    ativo BOOLEAN NOT NULL DEFAULT true,
    ordem_exibicao INTEGER NOT NULL DEFAULT 1, -- Para ordenar os blocos na interface
    
    -- Metadados
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    -- Constraints
    UNIQUE(condominio_id, letra), -- Cada condomínio não pode ter blocos com a mesma letra
    
    -- Validações lógicas
    CONSTRAINT valid_andar_bloco_config CHECK (
        (total_andares IS NULL AND unidades_por_andar IS NULL) OR 
        (total_andares IS NOT NULL AND unidades_por_andar IS NOT NULL AND 
         total_unidades = total_andares * unidades_por_andar)
    )
);

-- =====================================================
-- ÍNDICES PARA PERFORMANCE
-- =====================================================

-- Índice principal para busca por condomínio
CREATE INDEX IF NOT EXISTS idx_blocos_condominio_id 
ON blocos(condominio_id);

-- Índice para busca por configuração
CREATE INDEX IF NOT EXISTS idx_blocos_configuracao_id 
ON blocos(configuracao_id);

-- Índice para busca por letra do bloco
CREATE INDEX IF NOT EXISTS idx_blocos_letra 
ON blocos(condominio_id, letra);

-- Índice para blocos ativos ordenados
CREATE INDEX IF NOT EXISTS idx_blocos_ativo_ordem 
ON blocos(condominio_id, ativo, ordem_exibicao) WHERE ativo = true;

-- =====================================================
-- TRIGGER PARA ATUALIZAR updated_at
-- =====================================================

CREATE OR REPLACE FUNCTION update_blocos_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_blocos_updated_at
    BEFORE UPDATE ON blocos
    FOR EACH ROW
    EXECUTE FUNCTION update_blocos_updated_at();

-- =====================================================
-- FUNÇÃO PARA GERAR BLOCOS AUTOMATICAMENTE
-- =====================================================

CREATE OR REPLACE FUNCTION gerar_blocos_condominio(
    p_condominio_id UUID,
    p_configuracao_id UUID,
    p_total_blocos INTEGER
)
RETURNS INTEGER AS $$
DECLARE
    v_letra CHAR(1);
    v_ascii_code INTEGER;
    v_blocos_criados INTEGER := 0;
BEGIN
    -- Limpa blocos existentes para este condomínio
    DELETE FROM blocos WHERE condominio_id = p_condominio_id;
    
    -- Gera blocos de A até a quantidade especificada
    FOR i IN 1..p_total_blocos LOOP
        v_ascii_code := 64 + i; -- A=65, B=66, C=67, etc.
        v_letra := CHR(v_ascii_code);
        
        INSERT INTO blocos (
            condominio_id,
            configuracao_id,
            letra,
            nome,
            total_unidades,
            ordem_exibicao
        ) VALUES (
            p_condominio_id,
            p_configuracao_id,
            v_letra,
            'Bloco ' || v_letra,
            (SELECT unidades_por_bloco FROM configuracao_condominio WHERE id = p_configuracao_id),
            i
        );
        
        v_blocos_criados := v_blocos_criados + 1;
    END LOOP;
    
    RETURN v_blocos_criados;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- VIEW PARA CONSULTAS SIMPLIFICADAS
-- =====================================================

CREATE OR REPLACE VIEW view_blocos_completa AS
SELECT 
    b.id,
    b.condominio_id,
    c.nomeCondominio as nome_condominio,
    b.letra,
    b.nome,
    b.total_unidades,
    b.total_andares,
    b.unidades_por_andar,
    b.ativo,
    b.ordem_exibicao,
    b.created_at,
    -- Contagem de unidades reais criadas
    COALESCE(u.unidades_criadas, 0) as unidades_criadas,
    -- Status de completude
    CASE 
        WHEN COALESCE(u.unidades_criadas, 0) = b.total_unidades THEN 'completo'
        WHEN COALESCE(u.unidades_criadas, 0) > 0 THEN 'parcial'
        ELSE 'vazio'
    END as status_unidades
FROM blocos b
LEFT JOIN condominios c ON b.condominio_id = c.id
LEFT JOIN (
    SELECT 
        bloco_id, 
        COUNT(*) as unidades_criadas 
    FROM unidades 
    WHERE ativo = true 
    GROUP BY bloco_id
) u ON b.id = u.bloco_id
WHERE b.ativo = true
ORDER BY b.condominio_id, b.ordem_exibicao;

-- =====================================================
-- COMENTÁRIOS EXPLICATIVOS
-- =====================================================

COMMENT ON TABLE blocos IS 'Define cada bloco individual do condomínio (A, B, C, D, E, etc.)';
COMMENT ON COLUMN blocos.letra IS 'Letra identificadora do bloco (A, B, C, etc.)';
COMMENT ON COLUMN blocos.total_unidades IS 'Quantidade total de unidades neste bloco';
COMMENT ON COLUMN blocos.ordem_exibicao IS 'Ordem para exibir os blocos na interface';
COMMENT ON FUNCTION gerar_blocos_condominio IS 'Função para gerar automaticamente os blocos de um condomínio';
COMMENT ON VIEW view_blocos_completa IS 'View com informações completas dos blocos incluindo status das unidades';