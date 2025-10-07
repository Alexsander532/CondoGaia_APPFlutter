-- =====================================================
-- TABELA: imobiliarias
-- PROPÓSITO: Armazena dados das imobiliárias que gerenciam unidades
-- RELACIONAMENTO: 1:N com unidades (uma imobiliária pode gerenciar várias unidades)
-- =====================================================

CREATE TABLE IF NOT EXISTS imobiliarias (
    -- Chave primária
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Relacionamento com condomínio
    condominio_id UUID NOT NULL REFERENCES condominios(id) ON DELETE CASCADE,
    
    -- Dados da empresa
    nome VARCHAR(255) NOT NULL CHECK (LENGTH(TRIM(nome)) > 0),
    razao_social VARCHAR(255) DEFAULT NULL,
    nome_fantasia VARCHAR(255) DEFAULT NULL,
    cnpj VARCHAR(18) DEFAULT NULL, -- Formato: 00.000.000/0000-00
    inscricao_estadual VARCHAR(20) DEFAULT NULL,
    inscricao_municipal VARCHAR(20) DEFAULT NULL,
    
    -- Registro profissional
    creci VARCHAR(20) DEFAULT NULL, -- Registro no CRECI
    creci_estado VARCHAR(2) DEFAULT NULL,
    
    -- Dados de contato
    email VARCHAR(255) DEFAULT NULL,
    email_financeiro VARCHAR(255) DEFAULT NULL,
    telefone VARCHAR(20) DEFAULT NULL,
    celular VARCHAR(20) DEFAULT NULL,
    whatsapp VARCHAR(20) DEFAULT NULL,
    site VARCHAR(255) DEFAULT NULL,
    
    -- Endereço
    endereco_completo TEXT DEFAULT NULL,
    cep VARCHAR(10) DEFAULT NULL,
    cidade VARCHAR(100) DEFAULT NULL,
    estado VARCHAR(2) DEFAULT NULL,
    pais VARCHAR(50) DEFAULT 'Brasil',
    
    -- Dados bancários
    banco VARCHAR(100) DEFAULT NULL,
    agencia VARCHAR(10) DEFAULT NULL,
    conta VARCHAR(20) DEFAULT NULL,
    tipo_conta VARCHAR(20) DEFAULT NULL CHECK (tipo_conta IS NULL OR tipo_conta IN ('corrente', 'poupanca')),
    pix VARCHAR(255) DEFAULT NULL,
    
    -- Responsável/Contato principal
    responsavel_nome VARCHAR(255) DEFAULT NULL,
    responsavel_cpf VARCHAR(14) DEFAULT NULL,
    responsavel_telefone VARCHAR(20) DEFAULT NULL,
    responsavel_email VARCHAR(255) DEFAULT NULL,
    responsavel_cargo VARCHAR(100) DEFAULT NULL,
    
    -- Dados comerciais
    comissao_locacao DECIMAL(5,2) DEFAULT NULL CHECK (comissao_locacao IS NULL OR (comissao_locacao >= 0 AND comissao_locacao <= 100)),
    comissao_venda DECIMAL(5,2) DEFAULT NULL CHECK (comissao_venda IS NULL OR (comissao_venda >= 0 AND comissao_venda <= 100)),
    taxa_administracao DECIMAL(5,2) DEFAULT NULL CHECK (taxa_administracao IS NULL OR (taxa_administracao >= 0 AND taxa_administracao <= 100)),
    
    -- Serviços oferecidos
    oferece_locacao BOOLEAN DEFAULT true,
    oferece_venda BOOLEAN DEFAULT true,
    oferece_administracao BOOLEAN DEFAULT true,
    oferece_avaliacao BOOLEAN DEFAULT false,
    oferece_documentacao BOOLEAN DEFAULT false,
    
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
    data_ultimo_contato DATE DEFAULT NULL,
    origem_dados VARCHAR(20) DEFAULT 'manual' CHECK (origem_dados IN ('manual', 'excel', 'api', 'migracao')),
    
    -- Metadados
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    -- Constraints
    UNIQUE(condominio_id, cnpj), -- Cada condomínio não pode ter imobiliárias com o mesmo CNPJ
    UNIQUE(condominio_id, creci, creci_estado), -- CRECI único por estado em cada condomínio
    
    -- Validações
    CONSTRAINT valid_email_format CHECK (
        email IS NULL OR email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'
    ),
    CONSTRAINT valid_email_financeiro_format CHECK (
        email_financeiro IS NULL OR email_financeiro ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'
    ),
    CONSTRAINT valid_responsavel_email_format CHECK (
        responsavel_email IS NULL OR responsavel_email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'
    ),
    CONSTRAINT valid_cnpj_format CHECK (
        cnpj IS NULL OR cnpj ~ '^\d{2}\.\d{3}\.\d{3}/\d{4}-\d{2}$'
    ),
    CONSTRAINT valid_responsavel_cpf_format CHECK (
        responsavel_cpf IS NULL OR responsavel_cpf ~ '^\d{3}\.\d{3}\.\d{3}-\d{2}$'
    ),
    CONSTRAINT valid_site_format CHECK (
        site IS NULL OR site ~* '^https?://.*'
    )
);

-- =====================================================
-- ÍNDICES PARA PERFORMANCE
-- =====================================================

-- Índice principal para busca por condomínio
CREATE INDEX IF NOT EXISTS idx_imobiliarias_condominio_id 
ON imobiliarias(condominio_id);

-- Índice para busca por CNPJ
CREATE INDEX IF NOT EXISTS idx_imobiliarias_cnpj 
ON imobiliarias(condominio_id, cnpj) WHERE cnpj IS NOT NULL;

-- Índice para busca por nome
CREATE INDEX IF NOT EXISTS idx_imobiliarias_nome 
ON imobiliarias USING gin(to_tsvector('portuguese', nome));

-- Índice para busca por CRECI
CREATE INDEX IF NOT EXISTS idx_imobiliarias_creci 
ON imobiliarias(creci, creci_estado) WHERE creci IS NOT NULL;

-- Índice para busca por email
CREATE INDEX IF NOT EXISTS idx_imobiliarias_email 
ON imobiliarias(email) WHERE email IS NOT NULL;

-- Índice para busca por telefone
CREATE INDEX IF NOT EXISTS idx_imobiliarias_telefone 
ON imobiliarias(telefone) WHERE telefone IS NOT NULL;

-- Índice para imobiliárias ativas
CREATE INDEX IF NOT EXISTS idx_imobiliarias_ativo 
ON imobiliarias(condominio_id, ativo) WHERE ativo = true;

-- Índice para serviços oferecidos
CREATE INDEX IF NOT EXISTS idx_imobiliarias_servicos 
ON imobiliarias(condominio_id, oferece_locacao, oferece_venda, oferece_administracao) 
WHERE ativo = true;

-- =====================================================
-- TRIGGER PARA ATUALIZAR updated_at
-- =====================================================

CREATE OR REPLACE FUNCTION update_imobiliarias_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_imobiliarias_updated_at
    BEFORE UPDATE ON imobiliarias
    FOR EACH ROW
    EXECUTE FUNCTION update_imobiliarias_updated_at();

-- =====================================================
-- FUNÇÃO PARA VALIDAR CNPJ
-- =====================================================

CREATE OR REPLACE FUNCTION validar_cnpj(cnpj_input VARCHAR)
RETURNS BOOLEAN AS $$
DECLARE
    cnpj_numeros VARCHAR(14);
    soma INTEGER;
    resto INTEGER;
    digito1 INTEGER;
    digito2 INTEGER;
    multiplicadores1 INTEGER[] := ARRAY[5,4,3,2,9,8,7,6,5,4,3,2];
    multiplicadores2 INTEGER[] := ARRAY[6,5,4,3,2,9,8,7,6,5,4,3,2];
BEGIN
    -- Remove formatação
    cnpj_numeros := REGEXP_REPLACE(cnpj_input, '[^0-9]', '', 'g');
    
    -- Verifica se tem 14 dígitos
    IF LENGTH(cnpj_numeros) != 14 THEN
        RETURN FALSE;
    END IF;
    
    -- Verifica se todos os dígitos são iguais
    IF cnpj_numeros ~ '^(\d)\1{13}$' THEN
        RETURN FALSE;
    END IF;
    
    -- Calcula primeiro dígito verificador
    soma := 0;
    FOR i IN 1..12 LOOP
        soma := soma + (SUBSTRING(cnpj_numeros, i, 1)::INTEGER * multiplicadores1[i]);
    END LOOP;
    
    resto := soma % 11;
    IF resto < 2 THEN
        digito1 := 0;
    ELSE
        digito1 := 11 - resto;
    END IF;
    
    -- Verifica primeiro dígito
    IF digito1 != SUBSTRING(cnpj_numeros, 13, 1)::INTEGER THEN
        RETURN FALSE;
    END IF;
    
    -- Calcula segundo dígito verificador
    soma := 0;
    FOR i IN 1..13 LOOP
        soma := soma + (SUBSTRING(cnpj_numeros, i, 1)::INTEGER * multiplicadores2[i]);
    END LOOP;
    
    resto := soma % 11;
    IF resto < 2 THEN
        digito2 := 0;
    ELSE
        digito2 := 11 - resto;
    END IF;
    
    -- Verifica segundo dígito
    IF digito2 != SUBSTRING(cnpj_numeros, 14, 1)::INTEGER THEN
        RETURN FALSE;
    END IF;
    
    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- TRIGGER PARA VALIDAR E FORMATAR CNPJ/CPF
-- =====================================================

CREATE OR REPLACE FUNCTION formatar_documentos_imobiliaria()
RETURNS TRIGGER AS $$
BEGIN
    -- Se CNPJ foi informado, valida e formata
    IF NEW.cnpj IS NOT NULL AND TRIM(NEW.cnpj) != '' THEN
        -- Remove formatação existente
        NEW.cnpj := REGEXP_REPLACE(NEW.cnpj, '[^0-9]', '', 'g');
        
        -- Valida CNPJ
        IF NOT validar_cnpj(NEW.cnpj) THEN
            RAISE EXCEPTION 'CNPJ inválido: %', NEW.cnpj;
        END IF;
        
        -- Formata CNPJ
        NEW.cnpj := SUBSTRING(NEW.cnpj, 1, 2) || '.' || 
                    SUBSTRING(NEW.cnpj, 3, 3) || '.' || 
                    SUBSTRING(NEW.cnpj, 6, 3) || '/' || 
                    SUBSTRING(NEW.cnpj, 9, 4) || '-' || 
                    SUBSTRING(NEW.cnpj, 13, 2);
    END IF;
    
    -- Se CPF do responsável foi informado, valida e formata
    IF NEW.responsavel_cpf IS NOT NULL AND TRIM(NEW.responsavel_cpf) != '' THEN
        NEW.responsavel_cpf := REGEXP_REPLACE(NEW.responsavel_cpf, '[^0-9]', '', 'g');
        
        IF NOT validar_cpf(NEW.responsavel_cpf) THEN
            RAISE EXCEPTION 'CPF do responsável inválido: %', NEW.responsavel_cpf;
        END IF;
        
        NEW.responsavel_cpf := SUBSTRING(NEW.responsavel_cpf, 1, 3) || '.' || 
                              SUBSTRING(NEW.responsavel_cpf, 4, 3) || '.' || 
                              SUBSTRING(NEW.responsavel_cpf, 7, 3) || '-' || 
                              SUBSTRING(NEW.responsavel_cpf, 10, 2);
    END IF;
    
    -- Formata site se informado
    IF NEW.site IS NOT NULL AND TRIM(NEW.site) != '' THEN
        NEW.site := TRIM(NEW.site);
        -- Adiciona https:// se não tiver protocolo
        IF NEW.site !~* '^https?://' THEN
            NEW.site := 'https://' || NEW.site;
        END IF;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_formatar_documentos_imobiliaria
    BEFORE INSERT OR UPDATE ON imobiliarias
    FOR EACH ROW
    EXECUTE FUNCTION formatar_documentos_imobiliaria();

-- =====================================================
-- VIEW PARA CONSULTAS SIMPLIFICADAS
-- =====================================================

CREATE OR REPLACE VIEW view_imobiliarias_resumo AS
SELECT 
    i.id,
    i.condominio_id,
    c.nomeCondominio as nome_condominio,
    i.nome,
    i.razao_social,
    i.cnpj,
    i.creci,
    i.email,
    i.telefone,
    i.responsavel_nome,
    i.responsavel_telefone,
    i.comissao_locacao,
    i.comissao_venda,
    i.oferece_locacao,
    i.oferece_venda,
    i.oferece_administracao,
    i.ativo,
    -- Contagem de unidades gerenciadas
    COALESCE(u.total_unidades, 0) as total_unidades,
    -- Lista de unidades
    u.unidades_lista,
    i.created_at
FROM imobiliarias i
LEFT JOIN condominios c ON i.condominio_id = c.id
LEFT JOIN (
    SELECT 
        imobiliaria_id,
        COUNT(*) as total_unidades,
        STRING_AGG(identificacao, ', ' ORDER BY identificacao) as unidades_lista
    FROM unidades 
    WHERE ativo = true AND imobiliaria_id IS NOT NULL
    GROUP BY imobiliaria_id
) u ON i.id = u.imobiliaria_id
WHERE i.ativo = true
ORDER BY c.nomeCondominio, i.nome;

-- =====================================================
-- FUNÇÃO PARA BUSCAR IMOBILIÁRIAS POR SERVIÇO
-- =====================================================

CREATE OR REPLACE FUNCTION buscar_imobiliarias_por_servico(
    p_condominio_id UUID,
    p_tipo_servico VARCHAR DEFAULT NULL -- 'locacao', 'venda', 'administracao'
)
RETURNS TABLE (
    id UUID,
    nome VARCHAR,
    cnpj VARCHAR,
    telefone VARCHAR,
    email VARCHAR,
    comissao DECIMAL,
    total_unidades BIGINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        i.id,
        i.nome,
        i.cnpj,
        i.telefone,
        i.email,
        CASE 
            WHEN p_tipo_servico = 'locacao' THEN i.comissao_locacao
            WHEN p_tipo_servico = 'venda' THEN i.comissao_venda
            ELSE i.taxa_administracao
        END as comissao,
        COALESCE(u.total_unidades, 0) as total_unidades
    FROM imobiliarias i
    LEFT JOIN (
        SELECT 
            imobiliaria_id,
            COUNT(*) as total_unidades
        FROM unidades 
        WHERE ativo = true AND imobiliaria_id IS NOT NULL
        GROUP BY imobiliaria_id
    ) u ON i.id = u.imobiliaria_id
    WHERE i.condominio_id = p_condominio_id
    AND i.ativo = true
    AND (
        p_tipo_servico IS NULL OR
        (p_tipo_servico = 'locacao' AND i.oferece_locacao = true) OR
        (p_tipo_servico = 'venda' AND i.oferece_venda = true) OR
        (p_tipo_servico = 'administracao' AND i.oferece_administracao = true)
    )
    ORDER BY i.nome;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- FUNÇÃO PARA BUSCAR IMOBILIÁRIAS
-- =====================================================

CREATE OR REPLACE FUNCTION buscar_imobiliarias(
    p_condominio_id UUID,
    p_termo_busca VARCHAR DEFAULT NULL
)
RETURNS TABLE (
    id UUID,
    nome VARCHAR,
    cnpj VARCHAR,
    email VARCHAR,
    telefone VARCHAR,
    creci VARCHAR,
    total_unidades BIGINT,
    unidades_lista TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        i.id,
        i.nome,
        i.cnpj,
        i.email,
        i.telefone,
        i.creci,
        COALESCE(u.total_unidades, 0) as total_unidades,
        u.unidades_lista
    FROM imobiliarias i
    LEFT JOIN (
        SELECT 
            imobiliaria_id,
            COUNT(*) as total_unidades,
            STRING_AGG(identificacao, ', ' ORDER BY identificacao) as unidades_lista
        FROM unidades 
        WHERE ativo = true AND imobiliaria_id IS NOT NULL
        GROUP BY imobiliaria_id
    ) u ON i.id = u.imobiliaria_id
    WHERE i.condominio_id = p_condominio_id
    AND i.ativo = true
    AND (
        p_termo_busca IS NULL OR
        i.nome ILIKE '%' || p_termo_busca || '%' OR
        i.razao_social ILIKE '%' || p_termo_busca || '%' OR
        i.cnpj ILIKE '%' || p_termo_busca || '%' OR
        i.creci ILIKE '%' || p_termo_busca || '%' OR
        i.email ILIKE '%' || p_termo_busca || '%' OR
        i.telefone ILIKE '%' || p_termo_busca || '%'
    )
    ORDER BY i.nome;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- COMENTÁRIOS EXPLICATIVOS
-- =====================================================

COMMENT ON TABLE imobiliarias IS 'Armazena dados das imobiliárias que gerenciam unidades';
COMMENT ON COLUMN imobiliarias.cnpj IS 'CNPJ formatado (00.000.000/0000-00)';
COMMENT ON COLUMN imobiliarias.creci IS 'Registro no Conselho Regional de Corretores de Imóveis';
COMMENT ON COLUMN imobiliarias.comissao_locacao IS 'Percentual de comissão para locação';
COMMENT ON COLUMN imobiliarias.comissao_venda IS 'Percentual de comissão para venda';
COMMENT ON FUNCTION validar_cnpj IS 'Função para validar CNPJ usando algoritmo oficial';
COMMENT ON VIEW view_imobiliarias_resumo IS 'View com resumo das imobiliárias incluindo suas unidades';
COMMENT ON FUNCTION buscar_imobiliarias_por_servico IS 'Função para buscar imobiliárias que oferecem determinado serviço';