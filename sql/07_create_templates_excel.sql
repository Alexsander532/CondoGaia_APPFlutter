-- =====================================================
-- TABELA: templates_excel
-- PROPÓSITO: Controla os templates Excel gerados para importação de dados
-- RELACIONAMENTO: N:1 com condomínios e configuracao_condominio
-- =====================================================

CREATE TABLE IF NOT EXISTS templates_excel (
    -- Chave primária
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Relacionamentos
    condominio_id UUID NOT NULL REFERENCES condominios(id) ON DELETE CASCADE,
    configuracao_id UUID NOT NULL REFERENCES configuracao_condominio(id) ON DELETE CASCADE,
    
    -- Identificação do template
    nome_template VARCHAR(255) NOT NULL,
    versao VARCHAR(10) NOT NULL DEFAULT '1.0',
    tipo_template VARCHAR(50) NOT NULL CHECK (tipo_template IN ('completo', 'proprietarios', 'inquilinos', 'imobiliarias', 'personalizado')),
    
    -- Configurações do template
    incluir_blocos BOOLEAN DEFAULT true,
    incluir_unidades BOOLEAN DEFAULT true,
    incluir_proprietarios BOOLEAN DEFAULT true,
    incluir_inquilinos BOOLEAN DEFAULT false,
    incluir_imobiliarias BOOLEAN DEFAULT false,
    
    -- Configurações específicas de campos
    campos_obrigatorios JSONB DEFAULT '[]'::jsonb, -- Lista de campos obrigatórios
    campos_opcionais JSONB DEFAULT '[]'::jsonb,    -- Lista de campos opcionais
    validacoes_customizadas JSONB DEFAULT '{}'::jsonb, -- Regras de validação específicas
    
    -- Estrutura do template
    estrutura_blocos JSONB DEFAULT '{}'::jsonb,     -- Configuração dos blocos no template
    estrutura_unidades JSONB DEFAULT '{}'::jsonb,   -- Configuração das unidades no template
    mapeamento_colunas JSONB DEFAULT '{}'::jsonb,   -- Mapeamento de colunas Excel para campos DB
    
    -- Dados do arquivo gerado
    nome_arquivo VARCHAR(255) NOT NULL,
    caminho_arquivo TEXT DEFAULT NULL,
    tamanho_arquivo BIGINT DEFAULT NULL, -- Em bytes
    hash_arquivo VARCHAR(64) DEFAULT NULL, -- SHA-256 do arquivo
    
    -- Estatísticas do template
    total_blocos INTEGER DEFAULT 0,
    total_unidades INTEGER DEFAULT 0,
    total_linhas_dados INTEGER DEFAULT 0,
    total_colunas INTEGER DEFAULT 0,
    
    -- Configurações de uso
    permite_adicionar_blocos BOOLEAN DEFAULT false,
    permite_adicionar_unidades BOOLEAN DEFAULT false,
    permite_modificar_estrutura BOOLEAN DEFAULT false,
    
    -- Instruções e ajuda
    instrucoes_uso TEXT DEFAULT NULL,
    observacoes TEXT DEFAULT NULL,
    exemplo_preenchimento TEXT DEFAULT NULL,
    
    -- Controle de versão e histórico
    baseado_em_template UUID DEFAULT NULL REFERENCES templates_excel(id),
    motivo_nova_versao TEXT DEFAULT NULL,
    
    -- Status e controle
    status VARCHAR(20) DEFAULT 'ativo' CHECK (status IN ('ativo', 'inativo', 'obsoleto', 'teste')),
    data_geracao TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    data_expiracao TIMESTAMP WITH TIME ZONE DEFAULT NULL,
    
    -- Uso e estatísticas
    total_downloads INTEGER DEFAULT 0,
    total_importacoes_sucesso INTEGER DEFAULT 0,
    total_importacoes_erro INTEGER DEFAULT 0,
    ultima_utilizacao TIMESTAMP WITH TIME ZONE DEFAULT NULL,
    
    -- Metadados
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    -- Constraints
    UNIQUE(condominio_id, nome_template, versao),
    
    -- Validações
    CONSTRAINT valid_nome_arquivo CHECK (LENGTH(TRIM(nome_arquivo)) > 0),
    CONSTRAINT valid_versao_format CHECK (versao ~ '^\d+\.\d+(\.\d+)?$'),
    CONSTRAINT valid_tamanho_arquivo CHECK (tamanho_arquivo IS NULL OR tamanho_arquivo > 0),
    CONSTRAINT valid_totals CHECK (
        total_blocos >= 0 AND 
        total_unidades >= 0 AND 
        total_linhas_dados >= 0 AND 
        total_colunas >= 0
    ),
    CONSTRAINT valid_expiracao CHECK (
        data_expiracao IS NULL OR data_expiracao > data_geracao
    )
);

-- =====================================================
-- ÍNDICES PARA PERFORMANCE
-- =====================================================

-- Índice principal para busca por condomínio
CREATE INDEX IF NOT EXISTS idx_templates_excel_condominio_id 
ON templates_excel(condominio_id);

-- Índice para busca por configuração
CREATE INDEX IF NOT EXISTS idx_templates_excel_configuracao_id 
ON templates_excel(configuracao_id);

-- Índice para busca por tipo e status
CREATE INDEX IF NOT EXISTS idx_templates_excel_tipo_status 
ON templates_excel(condominio_id, tipo_template, status);

-- Índice para busca por nome
CREATE INDEX IF NOT EXISTS idx_templates_excel_nome 
ON templates_excel(condominio_id, nome_template);

-- Índice para busca por data de geração
CREATE INDEX IF NOT EXISTS idx_templates_excel_data_geracao 
ON templates_excel(data_geracao DESC);

-- Índice para templates ativos não expirados
CREATE INDEX IF NOT EXISTS idx_templates_excel_ativos 
ON templates_excel(condominio_id, status) 
WHERE status = 'ativo' AND (data_expiracao IS NULL OR data_expiracao > CURRENT_TIMESTAMP);

-- Índice para busca por hash (verificação de duplicatas)
CREATE INDEX IF NOT EXISTS idx_templates_excel_hash 
ON templates_excel(hash_arquivo) WHERE hash_arquivo IS NOT NULL;

-- =====================================================
-- TRIGGER PARA ATUALIZAR updated_at
-- =====================================================

CREATE OR REPLACE FUNCTION update_templates_excel_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_templates_excel_updated_at
    BEFORE UPDATE ON templates_excel
    FOR EACH ROW
    EXECUTE FUNCTION update_templates_excel_updated_at();

-- =====================================================
-- TRIGGER PARA GERAR NOME DO ARQUIVO AUTOMATICAMENTE
-- =====================================================

CREATE OR REPLACE FUNCTION gerar_nome_arquivo_template()
RETURNS TRIGGER AS $$
DECLARE
    nome_condominio VARCHAR;
    timestamp_str VARCHAR;
BEGIN
    -- Se nome_arquivo não foi fornecido, gera automaticamente
    IF NEW.nome_arquivo IS NULL OR TRIM(NEW.nome_arquivo) = '' THEN
        -- Busca nome do condomínio
        SELECT nomeCondominio INTO nome_condominio 
        FROM condominios 
        WHERE id = NEW.condominio_id;
        
        -- Gera timestamp
        timestamp_str := TO_CHAR(CURRENT_TIMESTAMP, 'YYYYMMDD_HH24MISS');
        
        -- Gera nome do arquivo
        NEW.nome_arquivo := LOWER(
            REGEXP_REPLACE(
                COALESCE(nome_condominio, 'condominio') || '_' || 
                NEW.tipo_template || '_v' || NEW.versao || '_' || 
                timestamp_str || '.xlsx',
                '[^a-zA-Z0-9._-]', '_', 'g'
            )
        );
    END IF;
    
    -- Garante extensão .xlsx
    IF NEW.nome_arquivo !~* '\.xlsx$' THEN
        NEW.nome_arquivo := NEW.nome_arquivo || '.xlsx';
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_gerar_nome_arquivo_template
    BEFORE INSERT OR UPDATE ON templates_excel
    FOR EACH ROW
    EXECUTE FUNCTION gerar_nome_arquivo_template();

-- =====================================================
-- TRIGGER PARA ATUALIZAR ESTATÍSTICAS DE USO
-- =====================================================

CREATE OR REPLACE FUNCTION atualizar_estatisticas_template()
RETURNS TRIGGER AS $$
BEGIN
    -- Atualiza última utilização quando há download
    IF NEW.total_downloads > OLD.total_downloads THEN
        NEW.ultima_utilizacao = CURRENT_TIMESTAMP;
    END IF;
    
    -- Atualiza última utilização quando há importação
    IF NEW.total_importacoes_sucesso > OLD.total_importacoes_sucesso OR 
       NEW.total_importacoes_erro > OLD.total_importacoes_erro THEN
        NEW.ultima_utilizacao = CURRENT_TIMESTAMP;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_atualizar_estatisticas_template
    BEFORE UPDATE ON templates_excel
    FOR EACH ROW
    EXECUTE FUNCTION atualizar_estatisticas_template();

-- =====================================================
-- FUNÇÃO PARA MARCAR TEMPLATES COMO OBSOLETOS
-- =====================================================

CREATE OR REPLACE FUNCTION marcar_templates_obsoletos(
    p_condominio_id UUID,
    p_configuracao_id UUID DEFAULT NULL
)
RETURNS INTEGER AS $$
DECLARE
    templates_atualizados INTEGER;
BEGIN
    UPDATE templates_excel 
    SET 
        status = 'obsoleto',
        updated_at = CURRENT_TIMESTAMP
    WHERE condominio_id = p_condominio_id
    AND status = 'ativo'
    AND (p_configuracao_id IS NULL OR configuracao_id = p_configuracao_id);
    
    GET DIAGNOSTICS templates_atualizados = ROW_COUNT;
    
    RETURN templates_atualizados;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- FUNÇÃO PARA LIMPAR TEMPLATES EXPIRADOS
-- =====================================================

CREATE OR REPLACE FUNCTION limpar_templates_expirados()
RETURNS INTEGER AS $$
DECLARE
    templates_removidos INTEGER;
BEGIN
    UPDATE templates_excel 
    SET 
        status = 'obsoleto',
        updated_at = CURRENT_TIMESTAMP
    WHERE data_expiracao IS NOT NULL 
    AND data_expiracao < CURRENT_TIMESTAMP
    AND status = 'ativo';
    
    GET DIAGNOSTICS templates_removidos = ROW_COUNT;
    
    RETURN templates_removidos;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- VIEW PARA CONSULTAS DE TEMPLATES ATIVOS
-- =====================================================

CREATE OR REPLACE VIEW view_templates_excel_ativos AS
SELECT 
    t.id,
    t.condominio_id,
    c.nomeCondominio as nome_condominio,
    t.nome_template,
    t.versao,
    t.tipo_template,
    t.nome_arquivo,
    t.tamanho_arquivo,
    t.total_blocos,
    t.total_unidades,
    t.total_downloads,
    t.total_importacoes_sucesso,
    t.total_importacoes_erro,
    t.data_geracao,
    t.data_expiracao,
    t.ultima_utilizacao,
    -- Indicadores úteis
    CASE 
        WHEN t.data_expiracao IS NOT NULL AND t.data_expiracao < CURRENT_TIMESTAMP THEN true
        ELSE false
    END as expirado,
    CASE 
        WHEN t.ultima_utilizacao IS NULL THEN 'Nunca usado'
        WHEN t.ultima_utilizacao > CURRENT_TIMESTAMP - INTERVAL '7 days' THEN 'Usado recentemente'
        WHEN t.ultima_utilizacao > CURRENT_TIMESTAMP - INTERVAL '30 days' THEN 'Usado no último mês'
        ELSE 'Uso antigo'
    END as status_uso,
    -- Taxa de sucesso nas importações
    CASE 
        WHEN (t.total_importacoes_sucesso + t.total_importacoes_erro) = 0 THEN NULL
        ELSE ROUND(
            (t.total_importacoes_sucesso::DECIMAL / 
             (t.total_importacoes_sucesso + t.total_importacoes_erro)) * 100, 2
        )
    END as taxa_sucesso_importacao
FROM templates_excel t
LEFT JOIN condominios c ON t.condominio_id = c.id
WHERE t.status = 'ativo'
ORDER BY t.data_geracao DESC;

-- =====================================================
-- FUNÇÃO PARA BUSCAR TEMPLATES
-- =====================================================

CREATE OR REPLACE FUNCTION buscar_templates_excel(
    p_condominio_id UUID,
    p_tipo_template VARCHAR DEFAULT NULL,
    p_incluir_expirados BOOLEAN DEFAULT false
)
RETURNS TABLE (
    id UUID,
    nome_template VARCHAR,
    versao VARCHAR,
    tipo_template VARCHAR,
    nome_arquivo VARCHAR,
    total_blocos INTEGER,
    total_unidades INTEGER,
    data_geracao TIMESTAMP WITH TIME ZONE,
    expirado BOOLEAN,
    taxa_sucesso DECIMAL
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        t.id,
        t.nome_template,
        t.versao,
        t.tipo_template,
        t.nome_arquivo,
        t.total_blocos,
        t.total_unidades,
        t.data_geracao,
        CASE 
            WHEN t.data_expiracao IS NOT NULL AND t.data_expiracao < CURRENT_TIMESTAMP THEN true
            ELSE false
        END as expirado,
        CASE 
            WHEN (t.total_importacoes_sucesso + t.total_importacoes_erro) = 0 THEN NULL
            ELSE ROUND(
                (t.total_importacoes_sucesso::DECIMAL / 
                 (t.total_importacoes_sucesso + t.total_importacoes_erro)) * 100, 2
            )
        END as taxa_sucesso
    FROM templates_excel t
    WHERE t.condominio_id = p_condominio_id
    AND t.status = 'ativo'
    AND (p_tipo_template IS NULL OR t.tipo_template = p_tipo_template)
    AND (
        p_incluir_expirados = true OR 
        t.data_expiracao IS NULL OR 
        t.data_expiracao > CURRENT_TIMESTAMP
    )
    ORDER BY t.data_geracao DESC;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- FUNÇÃO PARA REGISTRAR DOWNLOAD DE TEMPLATE
-- =====================================================

CREATE OR REPLACE FUNCTION registrar_download_template(
    p_template_id UUID
)
RETURNS BOOLEAN AS $$
BEGIN
    UPDATE templates_excel 
    SET 
        total_downloads = total_downloads + 1,
        ultima_utilizacao = CURRENT_TIMESTAMP,
        updated_at = CURRENT_TIMESTAMP
    WHERE id = p_template_id
    AND status = 'ativo';
    
    RETURN FOUND;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- FUNÇÃO PARA REGISTRAR RESULTADO DE IMPORTAÇÃO
-- =====================================================

CREATE OR REPLACE FUNCTION registrar_importacao_template(
    p_template_id UUID,
    p_sucesso BOOLEAN
)
RETURNS BOOLEAN AS $$
BEGIN
    IF p_sucesso THEN
        UPDATE templates_excel 
        SET 
            total_importacoes_sucesso = total_importacoes_sucesso + 1,
            ultima_utilizacao = CURRENT_TIMESTAMP,
            updated_at = CURRENT_TIMESTAMP
        WHERE id = p_template_id;
    ELSE
        UPDATE templates_excel 
        SET 
            total_importacoes_erro = total_importacoes_erro + 1,
            ultima_utilizacao = CURRENT_TIMESTAMP,
            updated_at = CURRENT_TIMESTAMP
        WHERE id = p_template_id;
    END IF;
    
    RETURN FOUND;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- COMENTÁRIOS EXPLICATIVOS
-- =====================================================

COMMENT ON TABLE templates_excel IS 'Controla os templates Excel gerados para importação de dados';
COMMENT ON COLUMN templates_excel.tipo_template IS 'Tipo do template: completo, proprietarios, inquilinos, imobiliarias, personalizado';
COMMENT ON COLUMN templates_excel.campos_obrigatorios IS 'JSON com lista de campos obrigatórios no template';
COMMENT ON COLUMN templates_excel.mapeamento_colunas IS 'JSON com mapeamento de colunas Excel para campos do banco';
COMMENT ON COLUMN templates_excel.hash_arquivo IS 'Hash SHA-256 do arquivo para verificação de integridade';
COMMENT ON FUNCTION marcar_templates_obsoletos IS 'Marca templates como obsoletos quando há mudança na configuração';
COMMENT ON VIEW view_templates_excel_ativos IS 'View com templates ativos e suas estatísticas de uso';