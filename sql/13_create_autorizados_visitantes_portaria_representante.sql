-- =====================================================
-- TABELA: autorizados_visitantes_portaria_representante
-- PROPÓSITO: Armazena dados dos visitantes autorizados pela portaria do representante
-- RELACIONAMENTO: N:1 com condominios, N:1 com unidades (opcional)
-- =====================================================

CREATE TABLE IF NOT EXISTS autorizados_visitantes_portaria_representante (
    -- Chave primária
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Relacionamento com condomínio (obrigatório)
    condominio_id UUID NOT NULL REFERENCES condominios(id) ON DELETE CASCADE,
    
    -- Relacionamento com unidade (opcional - quando visitante é para unidade específica)
    unidade_id UUID REFERENCES unidades(id) ON DELETE CASCADE,
    
    -- Dados obrigatórios do visitante
    nome VARCHAR(255) NOT NULL CHECK (LENGTH(TRIM(nome)) > 0),
    cpf VARCHAR(14) NOT NULL CHECK (LENGTH(TRIM(cpf)) > 0), -- Formato: 000.000.000-00
    celular VARCHAR(20) NOT NULL CHECK (LENGTH(TRIM(celular)) > 0),
    
    -- Tipo de autorização
    tipo_autorizacao VARCHAR(20) NOT NULL DEFAULT 'unidade' CHECK (tipo_autorizacao IN ('unidade', 'condominio')),
    
    -- Dados da autorização (quando tipo = 'condominio')
    quem_autorizou VARCHAR(255) DEFAULT NULL,
    
    -- Observações gerais
    observacoes TEXT DEFAULT NULL,
    
    -- Data e hora da visita
    data_visita DATE NOT NULL DEFAULT CURRENT_DATE,
    hora_entrada TIME DEFAULT NULL,
    hora_saida TIME DEFAULT NULL,
    
    -- Status da visita
    status_visita VARCHAR(20) DEFAULT 'agendado' CHECK (status_visita IN ('agendado', 'em_andamento', 'finalizado', 'cancelado')),
    
    -- Dados do veículo (opcionais)
    veiculo_tipo VARCHAR(50) DEFAULT NULL, -- 'carro', 'moto', 'bicicleta', etc.
    veiculo_marca VARCHAR(100) DEFAULT NULL,
    veiculo_modelo VARCHAR(100) DEFAULT NULL,
    veiculo_cor VARCHAR(50) DEFAULT NULL,
    veiculo_placa VARCHAR(10) DEFAULT NULL, -- Formato: ABC-1234 ou ABC1D23
    
    -- Controle de status
    ativo BOOLEAN DEFAULT true,
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    -- Constraints
    CONSTRAINT chk_unidade_quando_tipo_unidade 
        CHECK (
            (tipo_autorizacao = 'unidade' AND unidade_id IS NOT NULL) OR
            (tipo_autorizacao = 'condominio' AND unidade_id IS NULL)
        ),
    
    CONSTRAINT chk_quem_autorizou_quando_condominio
        CHECK (
            (tipo_autorizacao = 'condominio' AND quem_autorizou IS NOT NULL) OR
            (tipo_autorizacao = 'unidade')
        ),
    
    CONSTRAINT chk_cpf_formato 
        CHECK (cpf ~ '^[0-9]{3}\.[0-9]{3}\.[0-9]{3}-[0-9]{2}$'),
    
    CONSTRAINT chk_celular_formato 
        CHECK (celular ~ '^(\([0-9]{2}\)\s?)?[0-9]{4,5}-?[0-9]{4}$'),
    
    CONSTRAINT chk_placa_formato 
        CHECK (veiculo_placa IS NULL OR veiculo_placa ~ '^[A-Z]{3}-?[0-9]{4}$|^[A-Z]{3}[0-9][A-Z][0-9]{2}$')
);

-- =====================================================
-- ÍNDICES PARA PERFORMANCE
-- =====================================================

-- Índice para busca por condomínio
CREATE INDEX IF NOT EXISTS idx_visitantes_portaria_condominio_id 
    ON autorizados_visitantes_portaria_representante(condominio_id);

-- Índice para busca por unidade
CREATE INDEX IF NOT EXISTS idx_visitantes_portaria_unidade_id 
    ON autorizados_visitantes_portaria_representante(unidade_id);

-- Índice para busca por CPF
CREATE INDEX IF NOT EXISTS idx_visitantes_portaria_cpf 
    ON autorizados_visitantes_portaria_representante(cpf);

-- Índice para busca por data de visita
CREATE INDEX IF NOT EXISTS idx_visitantes_portaria_data_visita 
    ON autorizados_visitantes_portaria_representante(data_visita);

-- Índice para busca por status
CREATE INDEX IF NOT EXISTS idx_visitantes_portaria_status 
    ON autorizados_visitantes_portaria_representante(status_visita);

-- Índice composto para busca por condomínio e data
CREATE INDEX IF NOT EXISTS idx_visitantes_portaria_condominio_data 
    ON autorizados_visitantes_portaria_representante(condominio_id, data_visita);

-- Índice para busca por nome (case insensitive)
CREATE INDEX IF NOT EXISTS idx_visitantes_portaria_nome_lower 
    ON autorizados_visitantes_portaria_representante(LOWER(nome));

-- =====================================================
-- TRIGGER PARA ATUALIZAR updated_at
-- =====================================================

CREATE OR REPLACE FUNCTION update_visitantes_portaria_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_visitantes_portaria_updated_at
    BEFORE UPDATE ON autorizados_visitantes_portaria_representante
    FOR EACH ROW
    EXECUTE FUNCTION update_visitantes_portaria_updated_at();

-- =====================================================
-- COMENTÁRIOS NA TABELA E COLUNAS
-- =====================================================

COMMENT ON TABLE autorizados_visitantes_portaria_representante IS 'Tabela para armazenar visitantes autorizados pela portaria do representante';

COMMENT ON COLUMN autorizados_visitantes_portaria_representante.id IS 'Identificador único do visitante';
COMMENT ON COLUMN autorizados_visitantes_portaria_representante.condominio_id IS 'ID do condomínio (obrigatório)';
COMMENT ON COLUMN autorizados_visitantes_portaria_representante.unidade_id IS 'ID da unidade (opcional, apenas quando tipo_autorizacao = unidade)';
COMMENT ON COLUMN autorizados_visitantes_portaria_representante.nome IS 'Nome completo do visitante (obrigatório)';
COMMENT ON COLUMN autorizados_visitantes_portaria_representante.cpf IS 'CPF do visitante no formato 000.000.000-00 (obrigatório)';
COMMENT ON COLUMN autorizados_visitantes_portaria_representante.celular IS 'Número de celular do visitante (obrigatório)';
COMMENT ON COLUMN autorizados_visitantes_portaria_representante.tipo_autorizacao IS 'Tipo de autorização: unidade ou condominio';
COMMENT ON COLUMN autorizados_visitantes_portaria_representante.quem_autorizou IS 'Nome de quem autorizou (obrigatório quando tipo = condominio)';
COMMENT ON COLUMN autorizados_visitantes_portaria_representante.observacoes IS 'Observações gerais sobre a visita';
COMMENT ON COLUMN autorizados_visitantes_portaria_representante.data_visita IS 'Data da visita';
COMMENT ON COLUMN autorizados_visitantes_portaria_representante.hora_entrada IS 'Hora de entrada do visitante';
COMMENT ON COLUMN autorizados_visitantes_portaria_representante.hora_saida IS 'Hora de saída do visitante';
COMMENT ON COLUMN autorizados_visitantes_portaria_representante.status_visita IS 'Status atual da visita';

-- =====================================================
-- POLÍTICAS RLS (Row Level Security) - OPCIONAL
-- =====================================================

-- Habilitar RLS na tabela (descomente se necessário)
-- ALTER TABLE autorizados_visitantes_portaria_representante ENABLE ROW LEVEL SECURITY;

-- Política para permitir acesso apenas aos dados do próprio condomínio
-- CREATE POLICY visitantes_portaria_condominio_policy ON autorizados_visitantes_portaria_representante
--     FOR ALL USING (condominio_id = current_setting('app.current_condominio_id')::UUID);

-- =====================================================
-- GRANTS DE PERMISSÃO (AJUSTAR CONFORME NECESSÁRIO)
-- =====================================================

-- Conceder permissões para o usuário da aplicação (ajustar nome do usuário)
-- GRANT SELECT, INSERT, UPDATE, DELETE ON autorizados_visitantes_portaria_representante TO app_user;
-- GRANT USAGE ON SEQUENCE autorizados_visitantes_portaria_representante_id_seq TO app_user;