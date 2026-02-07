-- =====================================================
-- MIGRAÇÃO: LEITURA DE MEDIDORES (ÁGUA, GÁS)
-- =====================================================
-- Configurações por condomínio/tipo e registros de leitura

-- Tabela: leitura_configuracoes
-- Uma configuração por (condominio_id, tipo)
CREATE TABLE leitura_configuracoes (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    condominio_id UUID NOT NULL REFERENCES condominios(id) ON DELETE CASCADE,
    tipo VARCHAR(50) NOT NULL,  -- 'Agua', 'Gas', etc.
    unidade_medida VARCHAR(10) NOT NULL DEFAULT 'M³',  -- M³, KG, L
    valor_base DECIMAL(10, 2) NOT NULL DEFAULT 0,  -- valor por 1 unidade
    faixas JSONB DEFAULT '[]'::jsonb,  -- [{ "inicio": 0, "fim": 10, "valor": 5.00 }, ...]
    cobranca_tipo INTEGER NOT NULL DEFAULT 1,  -- 1 = junto com taxa, 2 = avulso
    vencimento_avulso DATE,  -- quando cobranca_tipo = 2
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT uk_leitura_config_condominio_tipo UNIQUE (condominio_id, tipo)
);

CREATE INDEX idx_leitura_config_condominio_id ON leitura_configuracoes(condominio_id);
CREATE INDEX idx_leitura_config_tipo ON leitura_configuracoes(tipo);

CREATE TRIGGER trigger_leitura_configuracoes_updated_at
    BEFORE UPDATE ON leitura_configuracoes
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

COMMENT ON TABLE leitura_configuracoes IS 'Configuração de leitura por tipo (água, gás) por condomínio';
COMMENT ON COLUMN leitura_configuracoes.faixas IS 'Array JSON: [{inicio, fim, valor}] para cálculo por faixa de consumo';

-- Tabela: leituras
-- Registro de cada leitura por unidade/mês/tipo
CREATE TABLE leituras (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    condominio_id UUID NOT NULL REFERENCES condominios(id) ON DELETE CASCADE,
    unidade_id UUID NOT NULL REFERENCES unidades(id) ON DELETE CASCADE,
    tipo VARCHAR(50) NOT NULL,
    data_leitura DATE NOT NULL,
    leitura_anterior DECIMAL(12, 3) NOT NULL DEFAULT 0,
    leitura_atual DECIMAL(12, 3) NOT NULL,
    valor DECIMAL(10, 2) NOT NULL DEFAULT 0,
    imagem_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT uk_leituras_unidade_tipo_data UNIQUE (unidade_id, tipo, data_leitura),
    CONSTRAINT chk_leituras_valores CHECK (leitura_atual >= leitura_anterior AND valor >= 0)
);

CREATE INDEX idx_leituras_condominio_id ON leituras(condominio_id);
CREATE INDEX idx_leituras_unidade_id ON leituras(unidade_id);
CREATE INDEX idx_leituras_tipo ON leituras(tipo);
CREATE INDEX idx_leituras_data ON leituras(data_leitura);
CREATE INDEX idx_leituras_condominio_tipo_data ON leituras(condominio_id, tipo, data_leitura);

CREATE TRIGGER trigger_leituras_updated_at
    BEFORE UPDATE ON leituras
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

COMMENT ON TABLE leituras IS 'Registros de leitura de medidores (água, gás) por unidade';
