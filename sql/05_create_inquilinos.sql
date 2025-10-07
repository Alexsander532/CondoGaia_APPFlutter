-- =====================================================
-- TABELA: inquilinos
-- PROPÓSITO: Armazena dados dos inquilinos (locatários) das unidades
-- RELACIONAMENTO: 1:N com unidades (um inquilino pode ter várias unidades)
-- =====================================================

CREATE TABLE IF NOT EXISTS inquilinos (
    -- Chave primária
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Relacionamento com condomínio
    condominio_id UUID NOT NULL REFERENCES condominios(id) ON DELETE CASCADE,
    
    -- Dados pessoais básicos
    nome VARCHAR(255) NOT NULL CHECK (LENGTH(TRIM(nome)) > 0),
    cpf VARCHAR(14) DEFAULT NULL, -- Formato: 000.000.000-00
    rg VARCHAR(20) DEFAULT NULL,
    data_nascimento DATE DEFAULT NULL,
    
    -- Dados de contato
    email VARCHAR(255) DEFAULT NULL,
    telefone VARCHAR(20) DEFAULT NULL,
    celular VARCHAR(20) DEFAULT NULL,
    telefone_comercial VARCHAR(20) DEFAULT NULL,
    
    -- Endereço anterior (antes de alugar)
    endereco_anterior TEXT DEFAULT NULL,
    cep_anterior VARCHAR(10) DEFAULT NULL,
    cidade_anterior VARCHAR(100) DEFAULT NULL,
    estado_anterior VARCHAR(2) DEFAULT NULL,
    
    -- Dados profissionais
    profissao VARCHAR(100) DEFAULT NULL,
    empresa VARCHAR(255) DEFAULT NULL,
    endereco_trabalho TEXT DEFAULT NULL,
    telefone_trabalho VARCHAR(20) DEFAULT NULL,
    renda_mensal DECIMAL(10,2) DEFAULT NULL CHECK (renda_mensal IS NULL OR renda_mensal >= 0),
    renda_comprovada BOOLEAN DEFAULT false,
    
    -- Dados bancários
    banco VARCHAR(100) DEFAULT NULL,
    agencia VARCHAR(10) DEFAULT NULL,
    conta VARCHAR(20) DEFAULT NULL,
    tipo_conta VARCHAR(20) DEFAULT NULL CHECK (tipo_conta IS NULL OR tipo_conta IN ('corrente', 'poupanca', 'salario')),
    pix VARCHAR(255) DEFAULT NULL,
    
    -- Status civil e dependentes
    estado_civil VARCHAR(20) DEFAULT NULL CHECK (estado_civil IS NULL OR estado_civil IN ('solteiro', 'casado', 'divorciado', 'viuvo', 'uniao_estavel')),
    nome_conjuge VARCHAR(255) DEFAULT NULL,
    cpf_conjuge VARCHAR(14) DEFAULT NULL,
    tem_dependentes BOOLEAN DEFAULT false,
    quantidade_dependentes INTEGER DEFAULT 0 CHECK (quantidade_dependentes >= 0),
    tem_animais BOOLEAN DEFAULT false,
    quantidade_animais INTEGER DEFAULT 0 CHECK (quantidade_animais >= 0),
    
    -- Dados do contrato de locação
    data_inicio_contrato DATE DEFAULT NULL,
    data_fim_contrato DATE DEFAULT NULL,
    valor_aluguel DECIMAL(10,2) DEFAULT NULL CHECK (valor_aluguel IS NULL OR valor_aluguel >= 0),
    valor_deposito DECIMAL(10,2) DEFAULT NULL CHECK (valor_deposito IS NULL OR valor_deposito >= 0),
    dia_vencimento INTEGER DEFAULT 10 CHECK (dia_vencimento >= 1 AND dia_vencimento <= 31),
    
    -- Referências pessoais
    referencia1_nome VARCHAR(255) DEFAULT NULL,
    referencia1_telefone VARCHAR(20) DEFAULT NULL,
    referencia1_relacao VARCHAR(100) DEFAULT NULL,
    referencia2_nome VARCHAR(255) DEFAULT NULL,
    referencia2_telefone VARCHAR(20) DEFAULT NULL,
    referencia2_relacao VARCHAR(100) DEFAULT NULL,
    
    -- Fiador/Avalista
    tem_fiador BOOLEAN DEFAULT false,
    fiador_nome VARCHAR(255) DEFAULT NULL,
    fiador_cpf VARCHAR(14) DEFAULT NULL,
    fiador_telefone VARCHAR(20) DEFAULT NULL,
    fiador_endereco TEXT DEFAULT NULL,
    fiador_renda DECIMAL(10,2) DEFAULT NULL CHECK (fiador_renda IS NULL OR fiador_renda >= 0),
    
    -- Informações adicionais
    observacoes TEXT DEFAULT NULL,
    notas_internas TEXT DEFAULT NULL,
    historico_pagamentos TEXT DEFAULT NULL,
    
    -- Configurações de comunicação
    aceita_email BOOLEAN DEFAULT true,
    aceita_sms BOOLEAN DEFAULT true,
    aceita_whatsapp BOOLEAN DEFAULT true,
    
    -- Status e controle
    ativo BOOLEAN NOT NULL DEFAULT true,
    status_contrato VARCHAR(20) DEFAULT 'ativo' CHECK (status_contrato IN ('ativo', 'vencido', 'rescindido', 'renovando')),
    data_cadastro DATE DEFAULT CURRENT_DATE,
    origem_dados VARCHAR(20) DEFAULT 'manual' CHECK (origem_dados IN ('manual', 'excel', 'api', 'migracao')),
    
    -- Metadados
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    -- Constraints
    UNIQUE(condominio_id, cpf), -- Cada condomínio não pode ter inquilinos com o mesmo CPF
    
    -- Validações
    CONSTRAINT valid_email_format CHECK (
        email IS NULL OR email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'
    ),
    CONSTRAINT valid_cpf_format CHECK (
        cpf IS NULL OR cpf ~ '^\d{3}\.\d{3}\.\d{3}-\d{2}$'
    ),
    CONSTRAINT valid_dependentes_check CHECK (
        (tem_dependentes = false AND quantidade_dependentes = 0) OR
        (tem_dependentes = true AND quantidade_dependentes > 0)
    ),
    CONSTRAINT valid_animais_check CHECK (
        (tem_animais = false AND quantidade_animais = 0) OR
        (tem_animais = true AND quantidade_animais > 0)
    ),
    CONSTRAINT valid_fiador_check CHECK (
        (tem_fiador = false) OR
        (tem_fiador = true AND fiador_nome IS NOT NULL AND fiador_cpf IS NOT NULL)
    ),
    CONSTRAINT valid_contrato_datas CHECK (
        data_inicio_contrato IS NULL OR data_fim_contrato IS NULL OR 
        data_fim_contrato > data_inicio_contrato
    )
);

-- =====================================================
-- ÍNDICES PARA PERFORMANCE
-- =====================================================

-- Índice principal para busca por condomínio
CREATE INDEX IF NOT EXISTS idx_inquilinos_condominio_id 
ON inquilinos(condominio_id);

-- Índice para busca por CPF
CREATE INDEX IF NOT EXISTS idx_inquilinos_cpf 
ON inquilinos(condominio_id, cpf) WHERE cpf IS NOT NULL;

-- Índice para busca por nome
CREATE INDEX IF NOT EXISTS idx_inquilinos_nome 
ON inquilinos USING gin(to_tsvector('portuguese', nome));

-- Índice para busca por email
CREATE INDEX IF NOT EXISTS idx_inquilinos_email 
ON inquilinos(email) WHERE email IS NOT NULL;

-- Índice para busca por telefone
CREATE INDEX IF NOT EXISTS idx_inquilinos_telefone 
ON inquilinos(telefone) WHERE telefone IS NOT NULL;

-- Índice para inquilinos ativos
CREATE INDEX IF NOT EXISTS idx_inquilinos_ativo 
ON inquilinos(condominio_id, ativo) WHERE ativo = true;

-- Índice para status do contrato
CREATE INDEX IF NOT EXISTS idx_inquilinos_status_contrato 
ON inquilinos(condominio_id, status_contrato);

-- Índice para vencimento de contratos
CREATE INDEX IF NOT EXISTS idx_inquilinos_data_fim_contrato 
ON inquilinos(data_fim_contrato) WHERE data_fim_contrato IS NOT NULL;

-- =====================================================
-- TRIGGER PARA ATUALIZAR updated_at
-- =====================================================

CREATE OR REPLACE FUNCTION update_inquilinos_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_inquilinos_updated_at
    BEFORE UPDATE ON inquilinos
    FOR EACH ROW
    EXECUTE FUNCTION update_inquilinos_updated_at();

-- =====================================================
-- TRIGGER PARA VALIDAR E FORMATAR CPF
-- =====================================================

CREATE OR REPLACE FUNCTION formatar_cpf_inquilino()
RETURNS TRIGGER AS $$
BEGIN
    -- Se CPF foi informado, valida e formata
    IF NEW.cpf IS NOT NULL AND TRIM(NEW.cpf) != '' THEN
        -- Remove formatação existente
        NEW.cpf := REGEXP_REPLACE(NEW.cpf, '[^0-9]', '', 'g');
        
        -- Valida CPF
        IF NOT validar_cpf(NEW.cpf) THEN
            RAISE EXCEPTION 'CPF inválido: %', NEW.cpf;
        END IF;
        
        -- Formata CPF
        NEW.cpf := SUBSTRING(NEW.cpf, 1, 3) || '.' || 
                   SUBSTRING(NEW.cpf, 4, 3) || '.' || 
                   SUBSTRING(NEW.cpf, 7, 3) || '-' || 
                   SUBSTRING(NEW.cpf, 10, 2);
    END IF;
    
    -- Formata CPF do cônjuge se informado
    IF NEW.cpf_conjuge IS NOT NULL AND TRIM(NEW.cpf_conjuge) != '' THEN
        NEW.cpf_conjuge := REGEXP_REPLACE(NEW.cpf_conjuge, '[^0-9]', '', 'g');
        
        IF NOT validar_cpf(NEW.cpf_conjuge) THEN
            RAISE EXCEPTION 'CPF do cônjuge inválido: %', NEW.cpf_conjuge;
        END IF;
        
        NEW.cpf_conjuge := SUBSTRING(NEW.cpf_conjuge, 1, 3) || '.' || 
                          SUBSTRING(NEW.cpf_conjuge, 4, 3) || '.' || 
                          SUBSTRING(NEW.cpf_conjuge, 7, 3) || '-' || 
                          SUBSTRING(NEW.cpf_conjuge, 10, 2);
    END IF;
    
    -- Formata CPF do fiador se informado
    IF NEW.fiador_cpf IS NOT NULL AND TRIM(NEW.fiador_cpf) != '' THEN
        NEW.fiador_cpf := REGEXP_REPLACE(NEW.fiador_cpf, '[^0-9]', '', 'g');
        
        IF NOT validar_cpf(NEW.fiador_cpf) THEN
            RAISE EXCEPTION 'CPF do fiador inválido: %', NEW.fiador_cpf;
        END IF;
        
        NEW.fiador_cpf := SUBSTRING(NEW.fiador_cpf, 1, 3) || '.' || 
                         SUBSTRING(NEW.fiador_cpf, 4, 3) || '.' || 
                         SUBSTRING(NEW.fiador_cpf, 7, 3) || '-' || 
                         SUBSTRING(NEW.fiador_cpf, 10, 2);
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_formatar_cpf_inquilino
    BEFORE INSERT OR UPDATE ON inquilinos
    FOR EACH ROW
    EXECUTE FUNCTION formatar_cpf_inquilino();

-- =====================================================
-- TRIGGER PARA ATUALIZAR STATUS DO CONTRATO
-- =====================================================

CREATE OR REPLACE FUNCTION atualizar_status_contrato()
RETURNS TRIGGER AS $$
BEGIN
    -- Atualiza status baseado na data de fim do contrato
    IF NEW.data_fim_contrato IS NOT NULL THEN
        IF NEW.data_fim_contrato < CURRENT_DATE THEN
            NEW.status_contrato := 'vencido';
        ELSIF NEW.data_fim_contrato <= CURRENT_DATE + INTERVAL '30 days' THEN
            -- Se vence em até 30 dias, mantém como ativo mas pode ser sinalizado
            IF NEW.status_contrato = 'vencido' THEN
                NEW.status_contrato := 'ativo';
            END IF;
        END IF;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_atualizar_status_contrato
    BEFORE INSERT OR UPDATE ON inquilinos
    FOR EACH ROW
    EXECUTE FUNCTION atualizar_status_contrato();

-- =====================================================
-- VIEW PARA CONSULTAS SIMPLIFICADAS
-- =====================================================

CREATE OR REPLACE VIEW view_inquilinos_resumo AS
SELECT 
    i.id,
    i.condominio_id,
    c.nomeCondominio as nome_condominio,
    i.nome,
    i.cpf,
    i.email,
    i.telefone,
    i.celular,
    i.valor_aluguel,
    i.data_inicio_contrato,
    i.data_fim_contrato,
    i.status_contrato,
    i.ativo,
    -- Contagem de unidades
    COALESCE(u.total_unidades, 0) as total_unidades,
    -- Lista de unidades
    u.unidades_lista,
    -- Dias para vencimento do contrato
    CASE 
        WHEN i.data_fim_contrato IS NULL THEN NULL
        ELSE i.data_fim_contrato - CURRENT_DATE
    END as dias_para_vencimento,
    i.created_at
FROM inquilinos i
LEFT JOIN condominios c ON i.condominio_id = c.id
LEFT JOIN (
    SELECT 
        inquilino_id,
        COUNT(*) as total_unidades,
        STRING_AGG(identificacao, ', ' ORDER BY identificacao) as unidades_lista
    FROM unidades 
    WHERE ativo = true AND inquilino_id IS NOT NULL
    GROUP BY inquilino_id
) u ON i.id = u.inquilino_id
WHERE i.ativo = true
ORDER BY c.nomeCondominio, i.nome;

-- =====================================================
-- FUNÇÃO PARA BUSCAR CONTRATOS VENCENDO
-- =====================================================

CREATE OR REPLACE FUNCTION buscar_contratos_vencendo(
    p_condominio_id UUID,
    p_dias_antecedencia INTEGER DEFAULT 30
)
RETURNS TABLE (
    id UUID,
    nome VARCHAR,
    cpf VARCHAR,
    telefone VARCHAR,
    data_fim_contrato DATE,
    dias_para_vencimento INTEGER,
    unidades_lista TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        i.id,
        i.nome,
        i.cpf,
        i.telefone,
        i.data_fim_contrato,
        (i.data_fim_contrato - CURRENT_DATE)::INTEGER as dias_para_vencimento,
        u.unidades_lista
    FROM inquilinos i
    LEFT JOIN (
        SELECT 
            inquilino_id,
            STRING_AGG(identificacao, ', ' ORDER BY identificacao) as unidades_lista
        FROM unidades 
        WHERE ativo = true AND inquilino_id IS NOT NULL
        GROUP BY inquilino_id
    ) u ON i.id = u.inquilino_id
    WHERE i.condominio_id = p_condominio_id
    AND i.ativo = true
    AND i.data_fim_contrato IS NOT NULL
    AND i.data_fim_contrato <= CURRENT_DATE + (p_dias_antecedencia || ' days')::INTERVAL
    AND i.data_fim_contrato >= CURRENT_DATE
    ORDER BY i.data_fim_contrato;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- FUNÇÃO PARA BUSCAR INQUILINOS
-- =====================================================

CREATE OR REPLACE FUNCTION buscar_inquilinos(
    p_condominio_id UUID,
    p_termo_busca VARCHAR DEFAULT NULL
)
RETURNS TABLE (
    id UUID,
    nome VARCHAR,
    cpf VARCHAR,
    email VARCHAR,
    telefone VARCHAR,
    status_contrato VARCHAR,
    total_unidades BIGINT,
    unidades_lista TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        i.id,
        i.nome,
        i.cpf,
        i.email,
        i.telefone,
        i.status_contrato,
        COALESCE(u.total_unidades, 0) as total_unidades,
        u.unidades_lista
    FROM inquilinos i
    LEFT JOIN (
        SELECT 
            inquilino_id,
            COUNT(*) as total_unidades,
            STRING_AGG(identificacao, ', ' ORDER BY identificacao) as unidades_lista
        FROM unidades 
        WHERE ativo = true AND inquilino_id IS NOT NULL
        GROUP BY inquilino_id
    ) u ON i.id = u.inquilino_id
    WHERE i.condominio_id = p_condominio_id
    AND i.ativo = true
    AND (
        p_termo_busca IS NULL OR
        i.nome ILIKE '%' || p_termo_busca || '%' OR
        i.cpf ILIKE '%' || p_termo_busca || '%' OR
        i.email ILIKE '%' || p_termo_busca || '%' OR
        i.telefone ILIKE '%' || p_termo_busca || '%'
    )
    ORDER BY i.nome;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- COMENTÁRIOS EXPLICATIVOS
-- =====================================================

COMMENT ON TABLE inquilinos IS 'Armazena dados dos inquilinos (locatários) das unidades';
COMMENT ON COLUMN inquilinos.status_contrato IS 'Status do contrato (ativo, vencido, rescindido, renovando)';
COMMENT ON COLUMN inquilinos.dia_vencimento IS 'Dia do mês para vencimento do aluguel';
COMMENT ON FUNCTION buscar_contratos_vencendo IS 'Função para buscar contratos que vencem em X dias';
COMMENT ON VIEW view_inquilinos_resumo IS 'View com resumo dos inquilinos incluindo suas unidades e status do contrato';