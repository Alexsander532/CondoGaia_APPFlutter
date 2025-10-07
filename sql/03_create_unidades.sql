-- =====================================================
-- TABELA: unidades
-- PROPÓSITO: Armazena cada unidade individual do condomínio
-- RELACIONAMENTO: N:1 com blocos (várias unidades por bloco)
-- =====================================================

CREATE TABLE IF NOT EXISTS unidades (
    -- Chave primária
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Relacionamentos
    condominio_id UUID NOT NULL REFERENCES condominios(id) ON DELETE CASCADE,
    bloco_id UUID NOT NULL REFERENCES blocos(id) ON DELETE CASCADE,
    
    -- Identificação da unidade
    numero VARCHAR(20) NOT NULL, -- 101, 102, 201, etc.
    identificacao VARCHAR(50) NOT NULL, -- 101-A, 102-B, etc. (gerado automaticamente)
    andar INTEGER DEFAULT NULL CHECK (andar IS NULL OR andar > 0),
    posicao_andar INTEGER DEFAULT NULL CHECK (posicao_andar IS NULL OR posicao_andar > 0),
    
    -- Características físicas
    area_total DECIMAL(10,2) DEFAULT NULL CHECK (area_total IS NULL OR area_total > 0),
    area_privativa DECIMAL(10,2) DEFAULT NULL CHECK (area_privativa IS NULL OR area_privativa > 0),
    fracao_ideal DECIMAL(10,6) DEFAULT NULL CHECK (fracao_ideal IS NULL OR fracao_ideal > 0),
    
    -- Características da unidade
    tipo_unidade VARCHAR(50) DEFAULT 'apartamento' CHECK (tipo_unidade IN ('apartamento', 'casa', 'loja', 'sala', 'garagem', 'deposito', 'outro')),
    quartos INTEGER DEFAULT NULL CHECK (quartos IS NULL OR quartos >= 0),
    banheiros INTEGER DEFAULT NULL CHECK (banheiros IS NULL OR banheiros >= 0),
    vagas_garagem INTEGER DEFAULT 0 CHECK (vagas_garagem >= 0),
    
    -- Relacionamentos com pessoas (FKs opcionais)
    proprietario_id UUID DEFAULT NULL REFERENCES proprietarios(id) ON DELETE SET NULL,
    inquilino_id UUID DEFAULT NULL REFERENCES inquilinos(id) ON DELETE SET NULL,
    imobiliaria_id UUID DEFAULT NULL REFERENCES imobiliarias(id) ON DELETE SET NULL,
    
    -- Informações financeiras
    valor_iptu DECIMAL(10,2) DEFAULT NULL CHECK (valor_iptu IS NULL OR valor_iptu >= 0),
    valor_condominio DECIMAL(10,2) DEFAULT NULL CHECK (valor_condominio IS NULL OR valor_condominio >= 0),
    valor_aluguel DECIMAL(10,2) DEFAULT NULL CHECK (valor_aluguel IS NULL OR valor_aluguel >= 0),
    
    -- Status da unidade
    status_ocupacao VARCHAR(20) DEFAULT 'vago' CHECK (status_ocupacao IN ('vago', 'ocupado_proprietario', 'ocupado_inquilino', 'em_reforma', 'bloqueado')),
    tem_inquilino BOOLEAN DEFAULT false,
    tem_proprietario BOOLEAN DEFAULT false,
    
    -- Observações e notas
    observacoes TEXT DEFAULT NULL,
    notas_internas TEXT DEFAULT NULL,
    
    -- Status e controle
    ativo BOOLEAN NOT NULL DEFAULT true,
    data_importacao TIMESTAMP WITH TIME ZONE DEFAULT NULL, -- Quando foi importado via Excel
    origem_dados VARCHAR(20) DEFAULT 'manual' CHECK (origem_dados IN ('manual', 'excel', 'api', 'migracao')),
    
    -- Metadados
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    -- Constraints
    UNIQUE(condominio_id, identificacao), -- Cada condomínio não pode ter unidades com a mesma identificação
    UNIQUE(bloco_id, numero), -- Cada bloco não pode ter unidades com o mesmo número
    
    -- Validações lógicas
    CONSTRAINT valid_area_check CHECK (
        area_privativa IS NULL OR area_total IS NULL OR area_privativa <= area_total
    ),
    CONSTRAINT valid_ocupacao_check CHECK (
        (status_ocupacao = 'vago' AND proprietario_id IS NULL AND inquilino_id IS NULL) OR
        (status_ocupacao = 'ocupado_proprietario' AND proprietario_id IS NOT NULL) OR
        (status_ocupacao = 'ocupado_inquilino' AND inquilino_id IS NOT NULL) OR
        (status_ocupacao IN ('em_reforma', 'bloqueado'))
    )
);

-- =====================================================
-- ÍNDICES PARA PERFORMANCE
-- =====================================================

-- Índice principal para busca por condomínio
CREATE INDEX IF NOT EXISTS idx_unidades_condominio_id 
ON unidades(condominio_id);

-- Índice para busca por bloco
CREATE INDEX IF NOT EXISTS idx_unidades_bloco_id 
ON unidades(bloco_id);

-- Índice para busca por identificação
CREATE INDEX IF NOT EXISTS idx_unidades_identificacao 
ON unidades(condominio_id, identificacao);

-- Índice para busca por proprietário
CREATE INDEX IF NOT EXISTS idx_unidades_proprietario_id 
ON unidades(proprietario_id) WHERE proprietario_id IS NOT NULL;

-- Índice para busca por inquilino
CREATE INDEX IF NOT EXISTS idx_unidades_inquilino_id 
ON unidades(inquilino_id) WHERE inquilino_id IS NOT NULL;

-- Índice para busca por imobiliária
CREATE INDEX IF NOT EXISTS idx_unidades_imobiliaria_id 
ON unidades(imobiliaria_id) WHERE imobiliaria_id IS NOT NULL;

-- Índice para status de ocupação
CREATE INDEX IF NOT EXISTS idx_unidades_status_ocupacao 
ON unidades(condominio_id, status_ocupacao);

-- Índice para unidades ativas
CREATE INDEX IF NOT EXISTS idx_unidades_ativo 
ON unidades(condominio_id, ativo) WHERE ativo = true;

-- =====================================================
-- TRIGGER PARA ATUALIZAR updated_at
-- =====================================================

CREATE OR REPLACE FUNCTION update_unidades_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_unidades_updated_at
    BEFORE UPDATE ON unidades
    FOR EACH ROW
    EXECUTE FUNCTION update_unidades_updated_at();

-- =====================================================
-- TRIGGER PARA GERAR IDENTIFICAÇÃO AUTOMATICAMENTE
-- =====================================================

CREATE OR REPLACE FUNCTION gerar_identificacao_unidade()
RETURNS TRIGGER AS $$
DECLARE
    v_letra_bloco VARCHAR(5);
    v_formato VARCHAR(50);
BEGIN
    -- Busca a letra do bloco e formato da configuração
    SELECT 
        b.letra,
        c.formato_unidade
    INTO v_letra_bloco, v_formato
    FROM blocos b
    JOIN configuracao_condominio c ON b.configuracao_id = c.id
    WHERE b.id = NEW.bloco_id;
    
    -- Gera a identificação baseada no formato
    NEW.identificacao := REPLACE(
        REPLACE(v_formato, '{numero}', NEW.numero),
        '{bloco}', v_letra_bloco
    );
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_gerar_identificacao_unidade
    BEFORE INSERT OR UPDATE ON unidades
    FOR EACH ROW
    EXECUTE FUNCTION gerar_identificacao_unidade();

-- =====================================================
-- TRIGGER PARA ATUALIZAR STATUS DE OCUPAÇÃO
-- =====================================================

CREATE OR REPLACE FUNCTION atualizar_status_ocupacao()
RETURNS TRIGGER AS $$
BEGIN
    -- Atualiza flags booleanas
    NEW.tem_proprietario := (NEW.proprietario_id IS NOT NULL);
    NEW.tem_inquilino := (NEW.inquilino_id IS NOT NULL);
    
    -- Atualiza status de ocupação automaticamente
    IF NEW.inquilino_id IS NOT NULL THEN
        NEW.status_ocupacao := 'ocupado_inquilino';
    ELSIF NEW.proprietario_id IS NOT NULL THEN
        NEW.status_ocupacao := 'ocupado_proprietario';
    ELSIF NEW.status_ocupacao NOT IN ('em_reforma', 'bloqueado') THEN
        NEW.status_ocupacao := 'vago';
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_atualizar_status_ocupacao
    BEFORE INSERT OR UPDATE ON unidades
    FOR EACH ROW
    EXECUTE FUNCTION atualizar_status_ocupacao();

-- =====================================================
-- FUNÇÃO PARA GERAR UNIDADES DE UM BLOCO
-- =====================================================

CREATE OR REPLACE FUNCTION gerar_unidades_bloco(
    p_bloco_id UUID,
    p_condominio_id UUID
)
RETURNS INTEGER AS $$
DECLARE
    v_config RECORD;
    v_bloco RECORD;
    v_numero INTEGER;
    v_andar INTEGER;
    v_posicao INTEGER;
    v_unidades_criadas INTEGER := 0;
BEGIN
    -- Busca configurações
    SELECT 
        c.*,
        b.letra,
        b.total_unidades,
        b.numero_inicial,
        b.incremento
    INTO v_config
    FROM configuracao_condominio c
    JOIN blocos b ON c.id = b.configuracao_id
    WHERE b.id = p_bloco_id;
    
    -- Limpa unidades existentes deste bloco
    DELETE FROM unidades WHERE bloco_id = p_bloco_id;
    
    -- Gera unidades baseado na configuração
    FOR i IN 1..v_config.total_unidades LOOP
        v_numero := v_config.numero_inicial + ((i - 1) * v_config.incremento);
        
        -- Calcula andar e posição se configurado
        IF v_config.tem_andares THEN
            v_andar := CEIL(i::DECIMAL / v_config.unidades_por_andar);
            v_posicao := ((i - 1) % v_config.unidades_por_andar) + 1;
        ELSE
            v_andar := NULL;
            v_posicao := NULL;
        END IF;
        
        INSERT INTO unidades (
            condominio_id,
            bloco_id,
            numero,
            andar,
            posicao_andar,
            origem_dados
        ) VALUES (
            p_condominio_id,
            p_bloco_id,
            v_numero::VARCHAR,
            v_andar,
            v_posicao,
            'manual'
        );
        
        v_unidades_criadas := v_unidades_criadas + 1;
    END LOOP;
    
    RETURN v_unidades_criadas;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- VIEW PARA CONSULTAS COMPLETAS
-- =====================================================

CREATE OR REPLACE VIEW view_unidades_completa AS
SELECT 
    u.id,
    u.condominio_id,
    c.nomeCondominio as nome_condominio,
    u.bloco_id,
    b.letra as letra_bloco,
    u.numero,
    u.identificacao,
    u.andar,
    u.area_total,
    u.fracao_ideal,
    u.tipo_unidade,
    u.status_ocupacao,
    u.tem_proprietario,
    u.tem_inquilino,
    -- Dados do proprietário
    p.nome as nome_proprietario,
    p.cpf as cpf_proprietario,
    p.telefone as telefone_proprietario,
    -- Dados do inquilino
    i.nome as nome_inquilino,
    i.cpf as cpf_inquilino,
    i.telefone as telefone_inquilino,
    -- Dados da imobiliária
    im.nome as nome_imobiliaria,
    im.telefone as telefone_imobiliaria,
    -- Valores
    u.valor_condominio,
    u.valor_aluguel,
    u.ativo,
    u.created_at
FROM unidades u
LEFT JOIN condominios c ON u.condominio_id = c.id
LEFT JOIN blocos b ON u.bloco_id = b.id
LEFT JOIN proprietarios p ON u.proprietario_id = p.id
LEFT JOIN inquilinos i ON u.inquilino_id = i.id
LEFT JOIN imobiliarias im ON u.imobiliaria_id = im.id
WHERE u.ativo = true
ORDER BY c.nomeCondominio, b.ordem_exibicao, u.numero::INTEGER;

-- =====================================================
-- COMENTÁRIOS EXPLICATIVOS
-- =====================================================

COMMENT ON TABLE unidades IS 'Armazena cada unidade individual do condomínio vinculada aos blocos';
COMMENT ON COLUMN unidades.identificacao IS 'Identificação completa da unidade (ex: 101-A, 102-B)';
COMMENT ON COLUMN unidades.status_ocupacao IS 'Status atual da unidade (vago, ocupado_proprietario, ocupado_inquilino, etc.)';
COMMENT ON FUNCTION gerar_unidades_bloco IS 'Função para gerar automaticamente todas as unidades de um bloco';
COMMENT ON VIEW view_unidades_completa IS 'View com informações completas das unidades incluindo dados de pessoas';