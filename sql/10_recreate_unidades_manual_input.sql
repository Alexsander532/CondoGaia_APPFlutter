-- =====================================================
-- SCRIPT: 10_recreate_unidades_manual_input.sql
-- DESCRIÇÃO: Recria a tabela unidades otimizada para preenchimento manual
-- AUTOR: Sistema
-- DATA: 2024-01-15
-- =====================================================

-- Primeiro, fazer backup da tabela atual (se existir)
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'unidades') THEN
        -- Criar backup da tabela atual
        EXECUTE 'CREATE TABLE unidades_backup_' || to_char(now(), 'YYYYMMDD_HH24MISS') || ' AS SELECT * FROM unidades';
        
        -- Dropar a tabela atual
        DROP TABLE IF EXISTS unidades CASCADE;
        
        RAISE NOTICE 'Backup da tabela unidades criado e tabela original removida';
    END IF;
END $$;

-- =====================================================
-- CRIAÇÃO DA NOVA TABELA UNIDADES
-- =====================================================

CREATE TABLE unidades (
    -- Campos de identificação primária
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Campos obrigatórios da interface
    numero VARCHAR(10) NOT NULL,                    -- Unidade* (obrigatório)
    condominio_id UUID NOT NULL,                    -- Referência ao condomínio
    
    -- Campos opcionais da interface principal
    bloco VARCHAR(10),                              -- Bloco
    fracao_ideal DECIMAL(10,6),                     -- Fração Ideal (ex: 0.014000)
    area_m2 DECIMAL(10,2),                          -- Área (m²)
    vencto_dia_diferente INTEGER,                   -- Vencto dia diferente (1-31)
    pagar_valor_diferente DECIMAL(10,2),            -- Pagar valor diferente
    tipo_unidade VARCHAR(5) DEFAULT 'A',            -- Tipo (A, B, C, etc.)
    
    -- Campos de Isenção (apenas um pode ser true por vez)
    isencao_nenhum BOOLEAN DEFAULT true,            -- Nenhum (padrão)
    isencao_total BOOLEAN DEFAULT false,            -- Total
    isencao_cota BOOLEAN DEFAULT false,             -- Cota
    isencao_fundo_reserva BOOLEAN DEFAULT false,    -- Fundo Reserva
    
    -- Campos de Ação Judicial
    acao_judicial BOOLEAN DEFAULT false,            -- Sim/Não (padrão Não)
    
    -- Campos de Correios
    correios BOOLEAN DEFAULT false,                 -- Sim/Não (padrão Não)
    
    -- Campos de Nome Pagador do Boleto
    nome_pagador_boleto VARCHAR(20) DEFAULT 'proprietario' CHECK (
        nome_pagador_boleto IN ('proprietario', 'inquilino')
    ),
    
    -- Campo de Observação
    observacoes TEXT,                               -- Observação (texto livre)
    
    -- Campos de controle do sistema
    ativo BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    -- Constraints de validação
    CONSTRAINT unidades_numero_not_empty CHECK (trim(numero) != ''),
    CONSTRAINT unidades_vencto_dia_valid CHECK (
        vencto_dia_diferente IS NULL OR 
        (vencto_dia_diferente >= 1 AND vencto_dia_diferente <= 31)
    ),
    CONSTRAINT unidades_valores_positivos CHECK (
        (fracao_ideal IS NULL OR fracao_ideal > 0) AND
        (area_m2 IS NULL OR area_m2 > 0) AND
        (pagar_valor_diferente IS NULL OR pagar_valor_diferente >= 0)
    ),
    CONSTRAINT unidades_fracao_ideal_max CHECK (
        fracao_ideal IS NULL OR fracao_ideal <= 1.0
    )
);

-- =====================================================
-- FUNÇÃO PARA GARANTIR APENAS UMA ISENÇÃO ATIVA
-- =====================================================

CREATE OR REPLACE FUNCTION validate_isencao_exclusiva()
RETURNS TRIGGER AS $$
BEGIN
    -- Contar quantas isenções estão marcadas como true
    IF (CASE WHEN NEW.isencao_nenhum THEN 1 ELSE 0 END +
        CASE WHEN NEW.isencao_total THEN 1 ELSE 0 END +
        CASE WHEN NEW.isencao_cota THEN 1 ELSE 0 END +
        CASE WHEN NEW.isencao_fundo_reserva THEN 1 ELSE 0 END) > 1 THEN
        
        RAISE EXCEPTION 'Apenas uma opção de isenção pode ser selecionada por vez';
    END IF;
    
    -- Se nenhuma isenção foi marcada, marcar "nenhum" como padrão
    IF NOT (NEW.isencao_nenhum OR NEW.isencao_total OR NEW.isencao_cota OR NEW.isencao_fundo_reserva) THEN
        NEW.isencao_nenhum := true;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- TRIGGER PARA VALIDAÇÃO DE ISENÇÃO
-- =====================================================

CREATE TRIGGER trigger_validate_isencao_exclusiva
    BEFORE INSERT OR UPDATE ON unidades
    FOR EACH ROW
    EXECUTE FUNCTION validate_isencao_exclusiva();

-- =====================================================
-- TRIGGER PARA ATUALIZAR updated_at
-- =====================================================

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_unidades_updated_at
    BEFORE UPDATE ON unidades
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- =====================================================
-- ÍNDICES PARA PERFORMANCE
-- =====================================================

-- Índice único para evitar duplicação de unidades no mesmo condomínio
CREATE UNIQUE INDEX idx_unidades_numero_condominio 
ON unidades (numero, condominio_id) 
WHERE ativo = true;

-- Índice para consultas por bloco
CREATE INDEX idx_unidades_bloco 
ON unidades (bloco) 
WHERE ativo = true;

-- Índice para consultas por condomínio
CREATE INDEX idx_unidades_condominio 
ON unidades (condominio_id) 
WHERE ativo = true;

-- Índice para consultas por tipo
CREATE INDEX idx_unidades_tipo 
ON unidades (tipo_unidade) 
WHERE ativo = true;

-- Índice para consultas por isenções
CREATE INDEX idx_unidades_isencoes 
ON unidades (isencao_total, isencao_cota, isencao_fundo_reserva) 
WHERE ativo = true;

-- =====================================================
-- COMENTÁRIOS EXPLICATIVOS
-- =====================================================

COMMENT ON TABLE unidades IS 'Tabela para armazenar dados de unidades preenchidos manualmente na interface do aplicativo';

COMMENT ON COLUMN unidades.numero IS 'Número/identificação da unidade (obrigatório)';
COMMENT ON COLUMN unidades.bloco IS 'Identificação do bloco onde a unidade está localizada';
COMMENT ON COLUMN unidades.fracao_ideal IS 'Fração ideal da unidade (valor entre 0 e 1)';
COMMENT ON COLUMN unidades.area_m2 IS 'Área da unidade em metros quadrados';
COMMENT ON COLUMN unidades.vencto_dia_diferente IS 'Dia específico de vencimento (1-31)';
COMMENT ON COLUMN unidades.pagar_valor_diferente IS 'Valor específico a ser pago pela unidade';
COMMENT ON COLUMN unidades.tipo_unidade IS 'Tipo da unidade (A, B, C, etc.)';
COMMENT ON COLUMN unidades.isencao_nenhum IS 'Indica se a unidade não possui isenção (padrão)';
COMMENT ON COLUMN unidades.isencao_total IS 'Indica se a unidade possui isenção total';
COMMENT ON COLUMN unidades.isencao_cota IS 'Indica se a unidade possui isenção de cota';
COMMENT ON COLUMN unidades.isencao_fundo_reserva IS 'Indica se a unidade possui isenção de fundo de reserva';
COMMENT ON COLUMN unidades.acao_judicial IS 'Indica se a unidade está em ação judicial';
COMMENT ON COLUMN unidades.correios IS 'Indica se a unidade recebe correspondência pelos correios';
COMMENT ON COLUMN unidades.nome_pagador_boleto IS 'Define quem é o pagador do boleto (proprietario ou inquilino)';
COMMENT ON COLUMN unidades.observacoes IS 'Campo livre para observações sobre a unidade';

-- =====================================================
-- DADOS DE EXEMPLO (OPCIONAL)
-- =====================================================

-- Inserir algumas unidades de exemplo para teste
-- (Descomente as linhas abaixo se quiser dados de exemplo)

/*
INSERT INTO unidades (
    numero, 
    condominio_id, 
    bloco, 
    fracao_ideal, 
    area_m2, 
    tipo_unidade,
    observacoes
) VALUES 
    ('101', (SELECT id FROM configuracao_condominio LIMIT 1), 'A', 0.014, 65.50, 'A', 'Unidade padrão'),
    ('102', (SELECT id FROM configuracao_condominio LIMIT 1), 'A', 0.014, 65.50, 'A', NULL),
    ('201', (SELECT id FROM configuracao_condominio LIMIT 1), 'B', 0.016, 75.00, 'B', 'Unidade com varanda');
*/

-- =====================================================
-- VERIFICAÇÃO FINAL
-- =====================================================

-- Verificar se a tabela foi criada corretamente
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'unidades') THEN
        RAISE NOTICE 'Tabela unidades criada com sucesso!';
        RAISE NOTICE 'Campos disponíveis: numero, bloco, fracao_ideal, area_m2, vencto_dia_diferente, pagar_valor_diferente, tipo_unidade, isencoes, acao_judicial, correios, nome_pagador_boleto, observacoes';
    ELSE
        RAISE EXCEPTION 'Erro: Tabela unidades não foi criada!';
    END IF;
END $$;