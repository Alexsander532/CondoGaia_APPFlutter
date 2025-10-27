-- =====================================================
-- TABELA: historico_acessos
-- PROPÓSITO: Armazena o histórico completo de entradas e saídas de visitantes e autorizados
-- RELACIONAMENTO: N:1 com autorizados_inquilinos
-- =====================================================

CREATE TABLE IF NOT EXISTS historico_acessos (
    -- Chave primária
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Relacionamento com visitante/autorizado
    visitante_id UUID NOT NULL REFERENCES autorizados_inquilinos(id) ON DELETE CASCADE,
    
    -- Relacionamento com condomínio (para facilitar consultas)
    condominio_id UUID NOT NULL REFERENCES condominios(id) ON DELETE CASCADE,
    
    -- Tipo de registro
    tipo_registro VARCHAR(10) NOT NULL CHECK (tipo_registro IN ('entrada', 'saida')),
    
    -- Data e hora do registro
    data_hora TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    -- Observações do registro (opcional)
    observacoes TEXT DEFAULT NULL,
    
    -- Quem registrou (porteiro, sistema, etc.)
    registrado_por VARCHAR(255) DEFAULT 'Sistema',
    
    -- Status do registro
    ativo BOOLEAN DEFAULT true,
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- ÍNDICES PARA PERFORMANCE
-- =====================================================

-- Índice para consultas por visitante
CREATE INDEX IF NOT EXISTS idx_historico_acessos_visitante_id 
ON historico_acessos(visitante_id);

-- Índice para consultas por condomínio
CREATE INDEX IF NOT EXISTS idx_historico_acessos_condominio_id 
ON historico_acessos(condominio_id);

-- Índice para consultas por data
CREATE INDEX IF NOT EXISTS idx_historico_acessos_data_hora 
ON historico_acessos(data_hora);

-- Índice composto para consultas por condomínio e data
CREATE INDEX IF NOT EXISTS idx_historico_acessos_condominio_data 
ON historico_acessos(condominio_id, data_hora);

-- Índice para consultas por tipo de registro
CREATE INDEX IF NOT EXISTS idx_historico_acessos_tipo_registro 
ON historico_acessos(tipo_registro);

-- =====================================================
-- POLÍTICAS RLS (Row Level Security)
-- =====================================================

-- =====================================================
-- TRIGGER PARA ATUALIZAR updated_at
-- =====================================================

CREATE OR REPLACE FUNCTION update_historico_acessos_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_historico_acessos_updated_at
    BEFORE UPDATE ON historico_acessos
    FOR EACH ROW
    EXECUTE FUNCTION update_historico_acessos_updated_at();

-- =====================================================
-- COMENTÁRIOS NA TABELA E COLUNAS
-- =====================================================

COMMENT ON TABLE historico_acessos IS 'Histórico completo de entradas e saídas de visitantes e autorizados';
COMMENT ON COLUMN historico_acessos.id IS 'Identificador único do registro de acesso';
COMMENT ON COLUMN historico_acessos.visitante_id IS 'Referência ao visitante/autorizado';
COMMENT ON COLUMN historico_acessos.condominio_id IS 'Referência ao condomínio';
COMMENT ON COLUMN historico_acessos.tipo_registro IS 'Tipo do registro: entrada ou saida';
COMMENT ON COLUMN historico_acessos.data_hora IS 'Data e hora do registro de acesso';
COMMENT ON COLUMN historico_acessos.observacoes IS 'Observações sobre o registro';
COMMENT ON COLUMN historico_acessos.registrado_por IS 'Quem registrou o acesso';
COMMENT ON COLUMN historico_acessos.ativo IS 'Status do registro';