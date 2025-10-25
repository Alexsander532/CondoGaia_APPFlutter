-- =====================================================
-- TABELA: autorizados_inquilinos
-- PROPÓSITO: Armazena dados dos autorizados pelos inquilinos/proprietários
-- RELACIONAMENTO: N:1 com unidades (vários autorizados por unidade)
-- =====================================================

CREATE TABLE IF NOT EXISTS autorizados_inquilinos (
    -- Chave primária
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Relacionamento com unidade
    unidade_id UUID NOT NULL REFERENCES unidades(id) ON DELETE CASCADE,
    
    -- Relacionamento com inquilino ou proprietário (flexível)
    inquilino_id UUID REFERENCES inquilinos(id) ON DELETE CASCADE,
    proprietario_id UUID REFERENCES proprietarios(id) ON DELETE CASCADE,
    
    -- Dados obrigatórios do autorizado
    nome VARCHAR(255) NOT NULL CHECK (LENGTH(TRIM(nome)) > 0),
    cpf VARCHAR(14) NOT NULL CHECK (LENGTH(TRIM(cpf)) > 0), -- Formato: 000.000.000-00
    
    -- Dados opcionais do autorizado
    parentesco VARCHAR(100) DEFAULT NULL,
    
    -- Configurações de permissão de acesso
    acesso_qualquer_horario BOOLEAN DEFAULT true,
    acesso_determinado_horario BOOLEAN DEFAULT false,
    
    -- Horários específicos (quando acesso_determinado_horario = true)
    horario_inicio TIME DEFAULT NULL,
    horario_fim TIME DEFAULT NULL,
    
    -- Dias da semana permitidos (array de inteiros: 1=Segunda, 2=Terça, ..., 7=Domingo)
    dias_semana_permitidos INTEGER[] DEFAULT NULL,
    
    -- Dados do veículo (opcionais)
    veiculo_tipo VARCHAR(50) DEFAULT NULL, -- 'carro' ou 'moto'
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
    CONSTRAINT chk_autorizado_vinculo CHECK (
        (inquilino_id IS NOT NULL AND proprietario_id IS NULL) OR 
        (inquilino_id IS NULL AND proprietario_id IS NOT NULL)
    ),
    CONSTRAINT chk_horario_valido CHECK (
        (acesso_determinado_horario = false) OR 
        (acesso_determinado_horario = true AND horario_inicio IS NOT NULL AND horario_fim IS NOT NULL)
    ),
    CONSTRAINT chk_dias_semana_validos CHECK (
        dias_semana_permitidos IS NULL OR 
        array_length(dias_semana_permitidos, 1) > 0
    ),
    CONSTRAINT chk_veiculo_placa_formato CHECK (
        veiculo_placa IS NULL OR 
        veiculo_placa ~ '^[A-Z]{3}-?[0-9]{4}$|^[A-Z]{3}[0-9][A-Z][0-9]{2}$'
    )
);

-- =====================================================
-- ÍNDICES PARA PERFORMANCE
-- =====================================================

-- Índice principal para busca por unidade
CREATE INDEX IF NOT EXISTS idx_autorizados_inquilinos_unidade_id 
ON autorizados_inquilinos(unidade_id);

-- Índice para busca por inquilino
CREATE INDEX IF NOT EXISTS idx_autorizados_inquilinos_inquilino_id 
ON autorizados_inquilinos(inquilino_id) WHERE inquilino_id IS NOT NULL;

-- Índice para busca por proprietário
CREATE INDEX IF NOT EXISTS idx_autorizados_inquilinos_proprietario_id 
ON autorizados_inquilinos(proprietario_id) WHERE proprietario_id IS NOT NULL;

-- Índice para busca por CPF (único por unidade)
CREATE UNIQUE INDEX IF NOT EXISTS idx_autorizados_inquilinos_cpf_unidade 
ON autorizados_inquilinos(cpf, unidade_id);

-- Índice para busca por status ativo
CREATE INDEX IF NOT EXISTS idx_autorizados_inquilinos_ativo 
ON autorizados_inquilinos(ativo) WHERE ativo = true;

-- Índice para busca por placa de veículo
CREATE INDEX IF NOT EXISTS idx_autorizados_inquilinos_veiculo_placa 
ON autorizados_inquilinos(veiculo_placa) WHERE veiculo_placa IS NOT NULL;

-- =====================================================
-- TRIGGER PARA ATUALIZAR updated_at
-- =====================================================

CREATE OR REPLACE FUNCTION update_autorizados_inquilinos_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_autorizados_inquilinos_updated_at
    BEFORE UPDATE ON autorizados_inquilinos
    FOR EACH ROW
    EXECUTE FUNCTION update_autorizados_inquilinos_updated_at();

-- =====================================================
-- COMENTÁRIOS PARA DOCUMENTAÇÃO
-- =====================================================

COMMENT ON TABLE autorizados_inquilinos IS 'Tabela para armazenar autorizados pelos inquilinos e proprietários';
COMMENT ON COLUMN autorizados_inquilinos.unidade_id IS 'Referência à unidade do condomínio';
COMMENT ON COLUMN autorizados_inquilinos.inquilino_id IS 'Referência ao inquilino (quando aplicável)';
COMMENT ON COLUMN autorizados_inquilinos.proprietario_id IS 'Referência ao proprietário (quando aplicável)';
COMMENT ON COLUMN autorizados_inquilinos.nome IS 'Nome completo do autorizado';
COMMENT ON COLUMN autorizados_inquilinos.cpf IS 'CPF do autorizado (obrigatório)';
COMMENT ON COLUMN autorizados_inquilinos.parentesco IS 'Grau de parentesco ou relação com o morador';
COMMENT ON COLUMN autorizados_inquilinos.acesso_qualquer_horario IS 'Permite acesso a qualquer horário';
COMMENT ON COLUMN autorizados_inquilinos.acesso_determinado_horario IS 'Restringe acesso a horários específicos';
COMMENT ON COLUMN autorizados_inquilinos.horario_inicio IS 'Horário de início do acesso (quando restrito)';
COMMENT ON COLUMN autorizados_inquilinos.horario_fim IS 'Horário de fim do acesso (quando restrito)';
COMMENT ON COLUMN autorizados_inquilinos.dias_semana_permitidos IS 'Array com os dias da semana permitidos (1-7)';
COMMENT ON COLUMN autorizados_inquilinos.veiculo_tipo IS 'Tipo do veículo (carro/moto)';
COMMENT ON COLUMN autorizados_inquilinos.veiculo_placa IS 'Placa do veículo (formato brasileiro)';
COMMENT ON COLUMN autorizados_inquilinos.ativo IS 'Status do autorizado (ativo/inativo)';