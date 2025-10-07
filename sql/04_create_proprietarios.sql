-- =====================================================
-- TABELA: proprietarios
-- PROPÓSITO: Armazena dados dos proprietários das unidades
-- RELACIONAMENTO: 1:N com unidades (um proprietário pode ter várias unidades)
-- =====================================================

CREATE TABLE IF NOT EXISTS proprietarios (
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
    
    -- Endereço
    endereco_completo TEXT DEFAULT NULL,
    cep VARCHAR(10) DEFAULT NULL,
    cidade VARCHAR(100) DEFAULT NULL,
    estado VARCHAR(2) DEFAULT NULL,
    pais VARCHAR(50) DEFAULT 'Brasil',
    
    -- Dados profissionais
    profissao VARCHAR(100) DEFAULT NULL,
    empresa VARCHAR(255) DEFAULT NULL,
    renda_mensal DECIMAL(10,2) DEFAULT NULL CHECK (renda_mensal IS NULL OR renda_mensal >= 0),
    
    -- Dados bancários (para recebimento de aluguéis)
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
    
    -- Informações adicionais
    observacoes TEXT DEFAULT NULL,
    notas_internas TEXT DEFAULT NULL,
    
    -- Configurações de comunicação
    aceita_email BOOLEAN DEFAULT true,
    aceita_sms BOOLEAN DEFAULT true,
    aceita_whatsapp BOOLEAN DEFAULT true,
    
    -- Status e controle
    ativo BOOLEAN NOT NULL DEFAULT true,
    data_cadastro DATE DEFAULT CURRENT_DATE,
    origem_dados VARCHAR(20) DEFAULT 'manual' CHECK (origem_dados IN ('manual', 'excel', 'api', 'migracao')),
    
    -- Metadados
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    -- Constraints
    UNIQUE(condominio_id, cpf), -- Cada condomínio não pode ter proprietários com o mesmo CPF
    
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
    )
);

-- =====================================================
-- ÍNDICES PARA PERFORMANCE
-- =====================================================

-- Índice principal para busca por condomínio
CREATE INDEX IF NOT EXISTS idx_proprietarios_condominio_id 
ON proprietarios(condominio_id);

-- Índice para busca por CPF
CREATE INDEX IF NOT EXISTS idx_proprietarios_cpf 
ON proprietarios(condominio_id, cpf) WHERE cpf IS NOT NULL;

-- Índice para busca por nome
CREATE INDEX IF NOT EXISTS idx_proprietarios_nome 
ON proprietarios USING gin(to_tsvector('portuguese', nome));

-- Índice para busca por email
CREATE INDEX IF NOT EXISTS idx_proprietarios_email 
ON proprietarios(email) WHERE email IS NOT NULL;

-- Índice para busca por telefone
CREATE INDEX IF NOT EXISTS idx_proprietarios_telefone 
ON proprietarios(telefone) WHERE telefone IS NOT NULL;

-- Índice para proprietários ativos
CREATE INDEX IF NOT EXISTS idx_proprietarios_ativo 
ON proprietarios(condominio_id, ativo) WHERE ativo = true;

-- =====================================================
-- TRIGGER PARA ATUALIZAR updated_at
-- =====================================================

CREATE OR REPLACE FUNCTION update_proprietarios_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_proprietarios_updated_at
    BEFORE UPDATE ON proprietarios
    FOR EACH ROW
    EXECUTE FUNCTION update_proprietarios_updated_at();

-- =====================================================
-- FUNÇÃO PARA VALIDAR CPF
-- =====================================================

CREATE OR REPLACE FUNCTION validar_cpf(cpf_input VARCHAR)
RETURNS BOOLEAN AS $$
DECLARE
    cpf_numeros VARCHAR(11);
    soma INTEGER;
    resto INTEGER;
    digito1 INTEGER;
    digito2 INTEGER;
BEGIN
    -- Remove formatação
    cpf_numeros := REGEXP_REPLACE(cpf_input, '[^0-9]', '', 'g');
    
    -- Verifica se tem 11 dígitos
    IF LENGTH(cpf_numeros) != 11 THEN
        RETURN FALSE;
    END IF;
    
    -- Verifica se todos os dígitos são iguais
    IF cpf_numeros ~ '^(\d)\1{10}$' THEN
        RETURN FALSE;
    END IF;
    
    -- Calcula primeiro dígito verificador
    soma := 0;
    FOR i IN 1..9 LOOP
        soma := soma + (SUBSTRING(cpf_numeros, i, 1)::INTEGER * (11 - i));
    END LOOP;
    
    resto := soma % 11;
    IF resto < 2 THEN
        digito1 := 0;
    ELSE
        digito1 := 11 - resto;
    END IF;
    
    -- Verifica primeiro dígito
    IF digito1 != SUBSTRING(cpf_numeros, 10, 1)::INTEGER THEN
        RETURN FALSE;
    END IF;
    
    -- Calcula segundo dígito verificador
    soma := 0;
    FOR i IN 1..10 LOOP
        soma := soma + (SUBSTRING(cpf_numeros, i, 1)::INTEGER * (12 - i));
    END LOOP;
    
    resto := soma % 11;
    IF resto < 2 THEN
        digito2 := 0;
    ELSE
        digito2 := 11 - resto;
    END IF;
    
    -- Verifica segundo dígito
    IF digito2 != SUBSTRING(cpf_numeros, 11, 1)::INTEGER THEN
        RETURN FALSE;
    END IF;
    
    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- TRIGGER PARA VALIDAR E FORMATAR CPF
-- =====================================================

CREATE OR REPLACE FUNCTION formatar_cpf_proprietario()
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
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_formatar_cpf_proprietario
    BEFORE INSERT OR UPDATE ON proprietarios
    FOR EACH ROW
    EXECUTE FUNCTION formatar_cpf_proprietario();

-- =====================================================
-- VIEW PARA CONSULTAS SIMPLIFICADAS
-- =====================================================

CREATE OR REPLACE VIEW view_proprietarios_resumo AS
SELECT 
    p.id,
    p.condominio_id,
    c.nomeCondominio as nome_condominio,
    p.nome,
    p.cpf,
    p.email,
    p.telefone,
    p.celular,
    p.ativo,
    -- Contagem de unidades
    COALESCE(u.total_unidades, 0) as total_unidades,
    -- Lista de unidades
    u.unidades_lista,
    p.created_at
FROM proprietarios p
LEFT JOIN condominios c ON p.condominio_id = c.id
LEFT JOIN (
    SELECT 
        proprietario_id,
        COUNT(*) as total_unidades,
        STRING_AGG(identificacao, ', ' ORDER BY identificacao) as unidades_lista
    FROM unidades 
    WHERE ativo = true AND proprietario_id IS NOT NULL
    GROUP BY proprietario_id
) u ON p.id = u.proprietario_id
WHERE p.ativo = true
ORDER BY c.nomeCondominio, p.nome;

-- =====================================================
-- FUNÇÃO PARA BUSCAR PROPRIETÁRIOS
-- =====================================================

CREATE OR REPLACE FUNCTION buscar_proprietarios(
    p_condominio_id UUID,
    p_termo_busca VARCHAR DEFAULT NULL
)
RETURNS TABLE (
    id UUID,
    nome VARCHAR,
    cpf VARCHAR,
    email VARCHAR,
    telefone VARCHAR,
    total_unidades BIGINT,
    unidades_lista TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        p.id,
        p.nome,
        p.cpf,
        p.email,
        p.telefone,
        COALESCE(u.total_unidades, 0) as total_unidades,
        u.unidades_lista
    FROM proprietarios p
    LEFT JOIN (
        SELECT 
            proprietario_id,
            COUNT(*) as total_unidades,
            STRING_AGG(identificacao, ', ' ORDER BY identificacao) as unidades_lista
        FROM unidades 
        WHERE ativo = true AND proprietario_id IS NOT NULL
        GROUP BY proprietario_id
    ) u ON p.id = u.proprietario_id
    WHERE p.condominio_id = p_condominio_id
    AND p.ativo = true
    AND (
        p_termo_busca IS NULL OR
        p.nome ILIKE '%' || p_termo_busca || '%' OR
        p.cpf ILIKE '%' || p_termo_busca || '%' OR
        p.email ILIKE '%' || p_termo_busca || '%' OR
        p.telefone ILIKE '%' || p_termo_busca || '%'
    )
    ORDER BY p.nome;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- COMENTÁRIOS EXPLICATIVOS
-- =====================================================

COMMENT ON TABLE proprietarios IS 'Armazena dados dos proprietários das unidades';
COMMENT ON COLUMN proprietarios.cpf IS 'CPF formatado (000.000.000-00)';
COMMENT ON COLUMN proprietarios.origem_dados IS 'Origem dos dados (manual, excel, api, migracao)';
COMMENT ON FUNCTION validar_cpf IS 'Função para validar CPF usando algoritmo oficial';
COMMENT ON VIEW view_proprietarios_resumo IS 'View com resumo dos proprietários incluindo suas unidades';
COMMENT ON FUNCTION buscar_proprietarios IS 'Função para buscar proprietários por termo';