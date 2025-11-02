-- =====================================================
-- TABELA: encomendas
-- PROPÓSITO: Armazena encomendas recebidas pela portaria
-- RELACIONAMENTO: N:1 com condominios, representantes, unidades
-- RELACIONAMENTO: N:1 com proprietarios OU inquilinos (exclusivo)
-- =====================================================

CREATE TABLE IF NOT EXISTS encomendas (
    -- Chave primária
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Relacionamentos obrigatórios
    condominio_id UUID NOT NULL REFERENCES condominios(id) ON DELETE CASCADE,
    representante_id UUID NOT NULL REFERENCES representantes(id) ON DELETE CASCADE,
    unidade_id UUID NOT NULL REFERENCES unidades(id) ON DELETE CASCADE,
    
    -- Pessoa selecionada (proprietário OU inquilino - exclusivo)
    proprietario_id UUID REFERENCES proprietarios(id) ON DELETE CASCADE,
    inquilino_id UUID REFERENCES inquilinos(id) ON DELETE CASCADE,
    
    -- Informações da encomenda
    foto_url TEXT DEFAULT NULL,                 -- URL da foto no Supabase Storage
    notificar_unidade BOOLEAN DEFAULT false,    -- Checkbox de notificação
    
    -- Status da encomenda
    recebido BOOLEAN DEFAULT false NOT NULL,    -- Para uso posterior
    
    -- Timestamps automáticos (horário de Brasília)
    data_cadastro TIMESTAMPTZ NOT NULL DEFAULT (NOW() AT TIME ZONE 'America/Sao_Paulo'),
    data_recebimento TIMESTAMPTZ DEFAULT NULL,  -- Quando foi marcada como recebida
    
    -- Campos de controle do sistema
    ativo BOOLEAN DEFAULT true NOT NULL,
    created_at TIMESTAMPTZ DEFAULT (NOW() AT TIME ZONE 'America/Sao_Paulo') NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT (NOW() AT TIME ZONE 'America/Sao_Paulo') NOT NULL,
    
    -- Constraint: deve ter OU proprietário OU inquilino (não ambos)
    CONSTRAINT chk_encomendas_pessoa_selecionada CHECK (
        (proprietario_id IS NOT NULL AND inquilino_id IS NULL) OR
        (proprietario_id IS NULL AND inquilino_id IS NOT NULL)
    )
);

-- =====================================================
-- ÍNDICES PARA PERFORMANCE
-- =====================================================

-- Índices para consultas frequentes
CREATE INDEX IF NOT EXISTS idx_encomendas_condominio ON encomendas(condominio_id);
CREATE INDEX IF NOT EXISTS idx_encomendas_representante ON encomendas(representante_id);
CREATE INDEX IF NOT EXISTS idx_encomendas_unidade ON encomendas(unidade_id);
CREATE INDEX IF NOT EXISTS idx_encomendas_proprietario ON encomendas(proprietario_id);
CREATE INDEX IF NOT EXISTS idx_encomendas_inquilino ON encomendas(inquilino_id);

-- Índices para filtros de status
CREATE INDEX IF NOT EXISTS idx_encomendas_recebido ON encomendas(recebido);
CREATE INDEX IF NOT EXISTS idx_encomendas_ativo ON encomendas(ativo);

-- Índices para ordenação por data
CREATE INDEX IF NOT EXISTS idx_encomendas_data_cadastro ON encomendas(data_cadastro);
CREATE INDEX IF NOT EXISTS idx_encomendas_data_recebimento ON encomendas(data_recebimento);

-- Índice composto para consultas por condomínio e status
CREATE INDEX IF NOT EXISTS idx_encomendas_condominio_recebido ON encomendas(condominio_id, recebido);

-- =====================================================
-- FUNÇÃO PARA ATUALIZAR updated_at AUTOMATICAMENTE
-- =====================================================

-- Criar função se não existir
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW() AT TIME ZONE 'America/Sao_Paulo';
    RETURN NEW;
END;
$$ language 'plpgsql';

-- =====================================================
-- TRIGGER PARA ATUALIZAR updated_at
-- =====================================================

CREATE TRIGGER trigger_encomendas_updated_at
    BEFORE UPDATE ON encomendas
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- =====================================================
-- COMENTÁRIOS PARA DOCUMENTAÇÃO
-- =====================================================

COMMENT ON TABLE encomendas IS 'Tabela para armazenar encomendas recebidas pela portaria';
COMMENT ON COLUMN encomendas.id IS 'Identificador único da encomenda';
COMMENT ON COLUMN encomendas.condominio_id IS 'Referência ao condomínio';
COMMENT ON COLUMN encomendas.representante_id IS 'Representante que cadastrou a encomenda';
COMMENT ON COLUMN encomendas.unidade_id IS 'Unidade destinatária da encomenda';
COMMENT ON COLUMN encomendas.proprietario_id IS 'Proprietário destinatário (exclusivo com inquilino_id)';
COMMENT ON COLUMN encomendas.inquilino_id IS 'Inquilino destinatário (exclusivo com proprietario_id)';
COMMENT ON COLUMN encomendas.foto_url IS 'URL da foto da encomenda no Supabase Storage';
COMMENT ON COLUMN encomendas.notificar_unidade IS 'Se deve notificar a unidade sobre a encomenda';
COMMENT ON COLUMN encomendas.recebido IS 'Se a encomenda foi retirada pelo destinatário';
COMMENT ON COLUMN encomendas.data_cadastro IS 'Data e hora do cadastro da encomenda (horário de Brasília)';
COMMENT ON COLUMN encomendas.data_recebimento IS 'Data e hora da retirada da encomenda (horário de Brasília)';
COMMENT ON COLUMN encomendas.ativo IS 'Se o registro está ativo no sistema';
COMMENT ON COLUMN encomendas.created_at IS 'Data de criação do registro';
COMMENT ON COLUMN encomendas.updated_at IS 'Data da última atualização do registro';

-- =====================================================
-- MENSAGEM DE SUCESSO
-- =====================================================

DO $$
BEGIN
    RAISE NOTICE 'Tabela encomendas criada com sucesso!';
    RAISE NOTICE 'Índices criados para otimização de consultas';
    RAISE NOTICE 'Trigger configurado para atualização automática de updated_at';
    RAISE NOTICE 'Constraint configurada: deve ter OU proprietário OU inquilino';
    RAISE NOTICE 'Timezone configurado para America/Sao_Paulo (horário de Brasília)';
END $$;