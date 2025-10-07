-- =====================================================
-- TABELA: configuracao_condominio
-- PROPÓSITO: Armazena configurações de organização de blocos e unidades
-- RELACIONAMENTO: 1:1 com condominios (cada condomínio tem uma configuração)
-- =====================================================

CREATE TABLE IF NOT EXISTS configuracao_condominio (
    -- Chave primária
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Relacionamento com condomínio (FK)
    condominio_id UUID NOT NULL REFERENCES condominios(id) ON DELETE CASCADE,
    
    -- Configurações de estrutura
    total_blocos INTEGER NOT NULL DEFAULT 1 CHECK (total_blocos > 0 AND total_blocos <= 26),
    unidades_por_bloco INTEGER NOT NULL DEFAULT 10 CHECK (unidades_por_bloco > 0 AND unidades_por_bloco <= 999),
    
    -- Padrões de numeração
    padrao_numeracao VARCHAR(20) NOT NULL DEFAULT 'sequencial' CHECK (padrao_numeracao IN ('sequencial', 'por_andar', 'personalizado')),
    formato_unidade VARCHAR(50) NOT NULL DEFAULT '{numero}-{bloco}', -- Ex: "101-A", "{bloco}{numero}", etc.
    
    -- Configurações de andares (opcional)
    tem_andares BOOLEAN DEFAULT false,
    andares_por_bloco INTEGER DEFAULT NULL CHECK (andares_por_bloco IS NULL OR andares_por_bloco > 0),
    unidades_por_andar INTEGER DEFAULT NULL CHECK (unidades_por_andar IS NULL OR unidades_por_andar > 0),
    
    -- Configurações de numeração inicial
    numero_inicial INTEGER NOT NULL DEFAULT 101 CHECK (numero_inicial > 0),
    incremento INTEGER NOT NULL DEFAULT 1 CHECK (incremento > 0),
    
    -- Status e controle
    ativo BOOLEAN NOT NULL DEFAULT true,
    estrutura_criada BOOLEAN NOT NULL DEFAULT false, -- Indica se a estrutura já foi gerada
    template_gerado BOOLEAN NOT NULL DEFAULT false, -- Indica se o template Excel já foi gerado
    
    -- Metadados
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    created_by UUID DEFAULT NULL, -- Referência ao usuário que criou
    
    -- Constraints
    UNIQUE(condominio_id), -- Cada condomínio tem apenas uma configuração
    
    -- Validações lógicas
    CONSTRAINT valid_andar_config CHECK (
        (tem_andares = false) OR 
        (tem_andares = true AND andares_por_bloco IS NOT NULL AND unidades_por_andar IS NOT NULL)
    )
);

-- =====================================================
-- ÍNDICES PARA PERFORMANCE
-- =====================================================

-- Índice principal para busca por condomínio
CREATE INDEX IF NOT EXISTS idx_configuracao_condominio_condominio_id 
ON configuracao_condominio(condominio_id);

-- Índice para configurações ativas
CREATE INDEX IF NOT EXISTS idx_configuracao_condominio_ativo 
ON configuracao_condominio(ativo) WHERE ativo = true;

-- Índice para estruturas já criadas
CREATE INDEX IF NOT EXISTS idx_configuracao_condominio_estrutura_criada 
ON configuracao_condominio(estrutura_criada);

-- =====================================================
-- TRIGGER PARA ATUALIZAR updated_at
-- =====================================================

CREATE OR REPLACE FUNCTION update_configuracao_condominio_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_configuracao_condominio_updated_at
    BEFORE UPDATE ON configuracao_condominio
    FOR EACH ROW
    EXECUTE FUNCTION update_configuracao_condominio_updated_at();

-- =====================================================
-- COMENTÁRIOS EXPLICATIVOS
-- =====================================================

COMMENT ON TABLE configuracao_condominio IS 'Configurações de organização de blocos e unidades para cada condomínio';
COMMENT ON COLUMN configuracao_condominio.condominio_id IS 'Referência ao condomínio (FK)';
COMMENT ON COLUMN configuracao_condominio.total_blocos IS 'Quantidade total de blocos (A, B, C, etc.)';
COMMENT ON COLUMN configuracao_condominio.unidades_por_bloco IS 'Quantidade de unidades por bloco';
COMMENT ON COLUMN configuracao_condominio.padrao_numeracao IS 'Tipo de numeração: sequencial, por_andar, personalizado';
COMMENT ON COLUMN configuracao_condominio.formato_unidade IS 'Template para formato da unidade (ex: {numero}-{bloco})';
COMMENT ON COLUMN configuracao_condominio.tem_andares IS 'Se o condomínio tem conceito de andares';
COMMENT ON COLUMN configuracao_condominio.estrutura_criada IS 'Se a estrutura de blocos/unidades já foi criada';
COMMENT ON COLUMN configuracao_condominio.template_gerado IS 'Se o template Excel já foi gerado';