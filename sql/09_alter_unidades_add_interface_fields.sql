-- =====================================================
-- MIGRAÇÃO: Adicionar campos da interface de unidades
-- PROPÓSITO: Adicionar campos específicos da tela de detalhes da unidade
-- DATA: 2024-01-20
-- =====================================================

-- Adicionar campos de vencimento e pagamento
ALTER TABLE unidades 
ADD COLUMN IF NOT EXISTS vencto_dia_diferente INTEGER DEFAULT NULL 
CHECK (vencto_dia_diferente IS NULL OR (vencto_dia_diferente >= 1 AND vencto_dia_diferente <= 31));

ALTER TABLE unidades 
ADD COLUMN IF NOT EXISTS pagar_valor_diferente DECIMAL(10,2) DEFAULT NULL 
CHECK (pagar_valor_diferente IS NULL OR pagar_valor_diferente >= 0);

-- Adicionar campos de isenção (checkboxes)
ALTER TABLE unidades 
ADD COLUMN IF NOT EXISTS isencao_nenhum BOOLEAN DEFAULT true;

ALTER TABLE unidades 
ADD COLUMN IF NOT EXISTS isencao_total BOOLEAN DEFAULT false;

ALTER TABLE unidades 
ADD COLUMN IF NOT EXISTS isencao_cota BOOLEAN DEFAULT false;

ALTER TABLE unidades 
ADD COLUMN IF NOT EXISTS isencao_fundo_reserva BOOLEAN DEFAULT false;

-- Adicionar campos de configurações adicionais
ALTER TABLE unidades 
ADD COLUMN IF NOT EXISTS acao_judicial BOOLEAN DEFAULT false;

ALTER TABLE unidades 
ADD COLUMN IF NOT EXISTS correios BOOLEAN DEFAULT false;

ALTER TABLE unidades 
ADD COLUMN IF NOT EXISTS nome_pagador_boleto VARCHAR(20) DEFAULT 'proprietario' 
CHECK (nome_pagador_boleto IN ('proprietario', 'inquilino'));

-- =====================================================
-- TRIGGER PARA VALIDAR ISENÇÕES (apenas uma pode ser true)
-- =====================================================

CREATE OR REPLACE FUNCTION validar_isencoes_unidade()
RETURNS TRIGGER AS $$
BEGIN
    -- Conta quantas isenções estão marcadas como true
    IF (
        (NEW.isencao_nenhum::int + NEW.isencao_total::int + 
         NEW.isencao_cota::int + NEW.isencao_fundo_reserva::int) > 1
    ) THEN
        RAISE EXCEPTION 'Apenas uma opção de isenção pode ser selecionada por vez';
    END IF;
    
    -- Se nenhuma isenção está marcada, marca "nenhum" como true
    IF NOT (NEW.isencao_nenhum OR NEW.isencao_total OR NEW.isencao_cota OR NEW.isencao_fundo_reserva) THEN
        NEW.isencao_nenhum := true;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_validar_isencoes_unidade
    BEFORE INSERT OR UPDATE ON unidades
    FOR EACH ROW
    EXECUTE FUNCTION validar_isencoes_unidade();

-- =====================================================
-- ATUALIZAR VIEW PARA INCLUIR NOVOS CAMPOS
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
    -- Novos campos da interface
    u.vencto_dia_diferente,
    u.pagar_valor_diferente,
    u.isencao_nenhum,
    u.isencao_total,
    u.isencao_cota,
    u.isencao_fundo_reserva,
    u.acao_judicial,
    u.correios,
    u.nome_pagador_boleto,
    u.observacoes,
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
-- COMENTÁRIOS EXPLICATIVOS DOS NOVOS CAMPOS
-- =====================================================

COMMENT ON COLUMN unidades.vencto_dia_diferente IS 'Dia específico de vencimento para esta unidade (1-31)';
COMMENT ON COLUMN unidades.pagar_valor_diferente IS 'Valor diferenciado de cobrança para esta unidade';
COMMENT ON COLUMN unidades.isencao_nenhum IS 'Unidade sem isenção (padrão)';
COMMENT ON COLUMN unidades.isencao_total IS 'Unidade com isenção total de taxas';
COMMENT ON COLUMN unidades.isencao_cota IS 'Unidade com isenção de cota condominial';
COMMENT ON COLUMN unidades.isencao_fundo_reserva IS 'Unidade com isenção de fundo de reserva';
COMMENT ON COLUMN unidades.acao_judicial IS 'Unidade possui ação judicial em andamento';
COMMENT ON COLUMN unidades.correios IS 'Unidade recebe correspondência pelos correios';
COMMENT ON COLUMN unidades.nome_pagador_boleto IS 'Quem deve ser o pagador do boleto (proprietario ou inquilino)';

-- =====================================================
-- ÍNDICES PARA OS NOVOS CAMPOS
-- =====================================================

-- Índice para buscar unidades com isenções
CREATE INDEX IF NOT EXISTS idx_unidades_isencoes 
ON unidades(condominio_id) 
WHERE isencao_total = true OR isencao_cota = true OR isencao_fundo_reserva = true;

-- Índice para unidades com ação judicial
CREATE INDEX IF NOT EXISTS idx_unidades_acao_judicial 
ON unidades(condominio_id, acao_judicial) 
WHERE acao_judicial = true;

-- Índice para unidades com vencimento diferente
CREATE INDEX IF NOT EXISTS idx_unidades_vencto_diferente 
ON unidades(condominio_id, vencto_dia_diferente) 
WHERE vencto_dia_diferente IS NOT NULL;

-- =====================================================
-- SCRIPT CONCLUÍDO
-- =====================================================

-- Para aplicar esta migração, execute este arquivo no seu banco de dados
-- Todos os campos serão adicionados com valores padrão seguros
-- As unidades existentes terão isencao_nenhum = true por padrão