-- =====================================================
-- VIEWS E ÍNDICES PARA OTIMIZAÇÃO DO SISTEMA
-- PROPÓSITO: Criar views complexas e índices para melhorar performance
-- =====================================================

-- =====================================================
-- VIEW PRINCIPAL: ESTRUTURA COMPLETA DO CONDOMÍNIO
-- =====================================================

CREATE OR REPLACE VIEW view_estrutura_condominio AS
SELECT 
    -- Dados do condomínio
    c.id as condominio_id,
    c.nomeCondominio as nome_condominio,
    
    -- Dados da configuração
    cfg.id as configuracao_id,
    cfg.nome_configuracao,
    cfg.tipo_estrutura,
    cfg.total_blocos as config_total_blocos,
    cfg.total_unidades as config_total_unidades,
    cfg.padrao_numeracao_blocos,
    cfg.padrao_numeracao_unidades,
    cfg.ativo as configuracao_ativa,
    
    -- Estatísticas reais
    COALESCE(stats.total_blocos_criados, 0) as blocos_criados,
    COALESCE(stats.total_unidades_criadas, 0) as unidades_criadas,
    COALESCE(stats.unidades_ocupadas, 0) as unidades_ocupadas,
    COALESCE(stats.unidades_livres, 0) as unidades_livres,
    COALESCE(stats.unidades_com_proprietario, 0) as unidades_com_proprietario,
    COALESCE(stats.unidades_com_inquilino, 0) as unidades_com_inquilino,
    COALESCE(stats.unidades_com_imobiliaria, 0) as unidades_com_imobiliaria,
    
    -- Percentuais de ocupação
    CASE 
        WHEN COALESCE(stats.total_unidades_criadas, 0) = 0 THEN 0
        ELSE ROUND((stats.unidades_ocupadas::DECIMAL / stats.total_unidades_criadas) * 100, 2)
    END as percentual_ocupacao,
    
    CASE 
        WHEN COALESCE(stats.total_unidades_criadas, 0) = 0 THEN 0
        ELSE ROUND((stats.unidades_com_proprietario::DECIMAL / stats.total_unidades_criadas) * 100, 2)
    END as percentual_com_proprietario,
    
    -- Status geral
    CASE 
        WHEN cfg.total_blocos = COALESCE(stats.total_blocos_criados, 0) AND 
             cfg.total_unidades = COALESCE(stats.total_unidades_criadas, 0) THEN 'Completo'
        WHEN COALESCE(stats.total_blocos_criados, 0) = 0 THEN 'Não iniciado'
        ELSE 'Em configuração'
    END as status_estrutura,
    
    cfg.created_at as data_configuracao,
    cfg.updated_at as ultima_atualizacao

FROM condominios c
LEFT JOIN configuracao_condominio cfg ON c.id = cfg.condominio_id AND cfg.ativo = true
LEFT JOIN (
    SELECT 
        b.condominio_id,
        COUNT(DISTINCT b.id) as total_blocos_criados,
        COUNT(DISTINCT u.id) as total_unidades_criadas,
        COUNT(DISTINCT CASE WHEN u.status_ocupacao = 'ocupada' THEN u.id END) as unidades_ocupadas,
        COUNT(DISTINCT CASE WHEN u.status_ocupacao = 'livre' THEN u.id END) as unidades_livres,
        COUNT(DISTINCT CASE WHEN u.proprietario_id IS NOT NULL THEN u.id END) as unidades_com_proprietario,
        COUNT(DISTINCT CASE WHEN u.inquilino_id IS NOT NULL THEN u.id END) as unidades_com_inquilino,
        COUNT(DISTINCT CASE WHEN u.imobiliaria_id IS NOT NULL THEN u.id END) as unidades_com_imobiliaria
    FROM blocos b
    LEFT JOIN unidades u ON b.id = u.bloco_id AND u.ativo = true
    WHERE b.ativo = true
    GROUP BY b.condominio_id
) stats ON c.id = stats.condominio_id
ORDER BY c.nomeCondominio;

-- =====================================================
-- VIEW: RESUMO DE BLOCOS COM UNIDADES
-- =====================================================

CREATE OR REPLACE VIEW view_blocos_resumo AS
SELECT 
    b.id as bloco_id,
    b.condominio_id,
    c.nomeCondominio as nome_condominio,
    b.nome as nome_bloco,
    b.identificacao as identificacao_bloco,
    b.numero_bloco,
    b.total_andares,
    b.unidades_por_andar,
    b.total_unidades as unidades_planejadas,
    
    -- Estatísticas das unidades
    COALESCE(u.total_unidades_criadas, 0) as unidades_criadas,
    COALESCE(u.unidades_ocupadas, 0) as unidades_ocupadas,
    COALESCE(u.unidades_livres, 0) as unidades_livres,
    COALESCE(u.unidades_com_proprietario, 0) as unidades_com_proprietario,
    COALESCE(u.unidades_com_inquilino, 0) as unidades_com_inquilino,
    
    -- Percentuais
    CASE 
        WHEN b.total_unidades = 0 THEN 0
        ELSE ROUND((COALESCE(u.total_unidades_criadas, 0)::DECIMAL / b.total_unidades) * 100, 2)
    END as percentual_criacao,
    
    CASE 
        WHEN COALESCE(u.total_unidades_criadas, 0) = 0 THEN 0
        ELSE ROUND((u.unidades_ocupadas::DECIMAL / u.total_unidades_criadas) * 100, 2)
    END as percentual_ocupacao,
    
    -- Status do bloco
    CASE 
        WHEN COALESCE(u.total_unidades_criadas, 0) = 0 THEN 'Vazio'
        WHEN COALESCE(u.total_unidades_criadas, 0) = b.total_unidades THEN 'Completo'
        ELSE 'Parcial'
    END as status_criacao,
    
    b.ativo,
    b.created_at,
    b.updated_at

FROM blocos b
LEFT JOIN condominios c ON b.condominio_id = c.id
LEFT JOIN (
    SELECT 
        bloco_id,
        COUNT(*) as total_unidades_criadas,
        COUNT(CASE WHEN status_ocupacao = 'ocupada' THEN 1 END) as unidades_ocupadas,
        COUNT(CASE WHEN status_ocupacao = 'livre' THEN 1 END) as unidades_livres,
        COUNT(CASE WHEN proprietario_id IS NOT NULL THEN 1 END) as unidades_com_proprietario,
        COUNT(CASE WHEN inquilino_id IS NOT NULL THEN 1 END) as unidades_com_inquilino
    FROM unidades 
    WHERE ativo = true
    GROUP BY bloco_id
) u ON b.id = u.bloco_id
WHERE b.ativo = true
ORDER BY c.nomeCondominio, b.numero_bloco;

-- =====================================================
-- VIEW: UNIDADES COMPLETAS COM TODOS OS RELACIONAMENTOS
-- =====================================================

CREATE OR REPLACE VIEW view_unidades_completas AS
SELECT 
    -- Dados da unidade
    u.id as unidade_id,
    u.condominio_id,
    c.nomeCondominio as nome_condominio,
    u.bloco_id,
    b.nome as nome_bloco,
    b.identificacao as identificacao_bloco,
    u.identificacao as identificacao_unidade,
    u.numero_unidade,
    u.andar,
    u.posicao_andar,
    u.tipo_unidade,
    u.area_privativa,
    u.area_total,
    u.quartos,
    u.banheiros,
    u.vagas_garagem,
    u.status_ocupacao,
    u.valor_iptu,
    u.valor_condominio,
    
    -- Dados do proprietário
    p.id as proprietario_id,
    p.nome as proprietario_nome,
    p.cpf as proprietario_cpf,
    p.email as proprietario_email,
    p.telefone as proprietario_telefone,
    p.ativo as proprietario_ativo,
    
    -- Dados do inquilino
    i.id as inquilino_id,
    i.nome as inquilino_nome,
    i.cpf as inquilino_cpf,
    i.email as inquilino_email,
    i.telefone as inquilino_telefone,
    i.data_inicio_contrato,
    i.data_fim_contrato,
    i.valor_aluguel,
    i.status_contrato,
    
    -- Dados da imobiliária
    im.id as imobiliaria_id,
    im.nome as imobiliaria_nome,
    im.cnpj as imobiliaria_cnpj,
    im.email as imobiliaria_email,
    im.telefone as imobiliaria_telefone,
    im.comissao_locacao,
    
    -- Status consolidado
    CASE 
        WHEN u.proprietario_id IS NOT NULL AND u.inquilino_id IS NOT NULL THEN 'Alugada'
        WHEN u.proprietario_id IS NOT NULL AND u.inquilino_id IS NULL THEN 'Proprietário'
        WHEN u.proprietario_id IS NULL AND u.inquilino_id IS NOT NULL THEN 'Inquilino sem proprietário'
        ELSE 'Vazia'
    END as status_detalhado,
    
    -- Indicadores
    CASE WHEN i.data_fim_contrato IS NOT NULL AND i.data_fim_contrato <= CURRENT_DATE + INTERVAL '30 days' THEN true ELSE false END as contrato_vencendo,
    CASE WHEN i.data_fim_contrato IS NOT NULL AND i.data_fim_contrato < CURRENT_DATE THEN true ELSE false END as contrato_vencido,
    
    u.ativo,
    u.created_at,
    u.updated_at

FROM unidades u
LEFT JOIN condominios c ON u.condominio_id = c.id
LEFT JOIN blocos b ON u.bloco_id = b.id
LEFT JOIN proprietarios p ON u.proprietario_id = p.id AND p.ativo = true
LEFT JOIN inquilinos i ON u.inquilino_id = i.id AND i.ativo = true
LEFT JOIN imobiliarias im ON u.imobiliaria_id = im.id AND im.ativo = true
WHERE u.ativo = true
ORDER BY c.nomeCondominio, b.numero_bloco, u.andar, u.posicao_andar;

-- =====================================================
-- VIEW: DASHBOARD DE ESTATÍSTICAS
-- =====================================================

CREATE OR REPLACE VIEW view_dashboard_estatisticas AS
SELECT 
    c.id as condominio_id,
    c.nomeCondominio as nome_condominio,
    
    -- Estatísticas de estrutura
    COALESCE(blocos.total, 0) as total_blocos,
    COALESCE(unidades.total, 0) as total_unidades,
    
    -- Estatísticas de ocupação
    COALESCE(unidades.ocupadas, 0) as unidades_ocupadas,
    COALESCE(unidades.livres, 0) as unidades_livres,
    COALESCE(unidades.com_proprietario, 0) as unidades_com_proprietario,
    COALESCE(unidades.com_inquilino, 0) as unidades_com_inquilino,
    COALESCE(unidades.com_imobiliaria, 0) as unidades_com_imobiliaria,
    
    -- Estatísticas de pessoas
    COALESCE(pessoas.total_proprietarios, 0) as total_proprietarios,
    COALESCE(pessoas.total_inquilinos, 0) as total_inquilinos,
    COALESCE(pessoas.total_imobiliarias, 0) as total_imobiliarias,
    
    -- Contratos
    COALESCE(contratos.ativos, 0) as contratos_ativos,
    COALESCE(contratos.vencendo_30_dias, 0) as contratos_vencendo_30_dias,
    COALESCE(contratos.vencidos, 0) as contratos_vencidos,
    
    -- Percentuais
    CASE 
        WHEN COALESCE(unidades.total, 0) = 0 THEN 0
        ELSE ROUND((unidades.ocupadas::DECIMAL / unidades.total) * 100, 2)
    END as percentual_ocupacao,
    
    CASE 
        WHEN COALESCE(unidades.total, 0) = 0 THEN 0
        ELSE ROUND((unidades.com_proprietario::DECIMAL / unidades.total) * 100, 2)
    END as percentual_com_proprietario,
    
    -- Valores financeiros
    COALESCE(financeiro.total_iptu, 0) as total_iptu_mensal,
    COALESCE(financeiro.total_condominio, 0) as total_condominio_mensal,
    COALESCE(financeiro.total_alugueis, 0) as total_alugueis_mensal,
    
    -- Templates Excel
    COALESCE(templates.total_templates, 0) as total_templates_excel,
    COALESCE(templates.templates_ativos, 0) as templates_excel_ativos,
    
    CURRENT_TIMESTAMP as data_atualizacao

FROM condominios c
LEFT JOIN (
    SELECT condominio_id, COUNT(*) as total
    FROM blocos 
    WHERE ativo = true
    GROUP BY condominio_id
) blocos ON c.id = blocos.condominio_id
LEFT JOIN (
    SELECT 
        condominio_id,
        COUNT(*) as total,
        COUNT(CASE WHEN status_ocupacao = 'ocupada' THEN 1 END) as ocupadas,
        COUNT(CASE WHEN status_ocupacao = 'livre' THEN 1 END) as livres,
        COUNT(CASE WHEN proprietario_id IS NOT NULL THEN 1 END) as com_proprietario,
        COUNT(CASE WHEN inquilino_id IS NOT NULL THEN 1 END) as com_inquilino,
        COUNT(CASE WHEN imobiliaria_id IS NOT NULL THEN 1 END) as com_imobiliaria
    FROM unidades 
    WHERE ativo = true
    GROUP BY condominio_id
) unidades ON c.id = unidades.condominio_id
LEFT JOIN (
    SELECT 
        condominio_id,
        COUNT(DISTINCT p.id) as total_proprietarios,
        COUNT(DISTINCT i.id) as total_inquilinos,
        COUNT(DISTINCT im.id) as total_imobiliarias
    FROM unidades u
    LEFT JOIN proprietarios p ON u.proprietario_id = p.id AND p.ativo = true
    LEFT JOIN inquilinos i ON u.inquilino_id = i.id AND i.ativo = true
    LEFT JOIN imobiliarias im ON u.imobiliaria_id = im.id AND im.ativo = true
    WHERE u.ativo = true
    GROUP BY condominio_id
) pessoas ON c.id = pessoas.condominio_id
LEFT JOIN (
    SELECT 
        u.condominio_id,
        COUNT(CASE WHEN i.status_contrato = 'ativo' THEN 1 END) as ativos,
        COUNT(CASE WHEN i.data_fim_contrato BETWEEN CURRENT_DATE AND CURRENT_DATE + INTERVAL '30 days' THEN 1 END) as vencendo_30_dias,
        COUNT(CASE WHEN i.data_fim_contrato < CURRENT_DATE AND i.status_contrato = 'ativo' THEN 1 END) as vencidos
    FROM unidades u
    LEFT JOIN inquilinos i ON u.inquilino_id = i.id AND i.ativo = true
    WHERE u.ativo = true
    GROUP BY u.condominio_id
) contratos ON c.id = contratos.condominio_id
LEFT JOIN (
    SELECT 
        condominio_id,
        SUM(COALESCE(valor_iptu, 0)) as total_iptu,
        SUM(COALESCE(valor_condominio, 0)) as total_condominio,
        SUM(CASE WHEN i.valor_aluguel IS NOT NULL AND i.status_contrato = 'ativo' THEN i.valor_aluguel ELSE 0 END) as total_alugueis
    FROM unidades u
    LEFT JOIN inquilinos i ON u.inquilino_id = i.id AND i.ativo = true
    WHERE u.ativo = true
    GROUP BY condominio_id
) financeiro ON c.id = financeiro.condominio_id
LEFT JOIN (
    SELECT 
        condominio_id,
        COUNT(*) as total_templates,
        COUNT(CASE WHEN status = 'ativo' THEN 1 END) as templates_ativos
    FROM templates_excel
    GROUP BY condominio_id
) templates ON c.id = templates.condominio_id
ORDER BY c.nomeCondominio;

-- =====================================================
-- ÍNDICES ADICIONAIS PARA PERFORMANCE
-- =====================================================

-- Índices compostos para consultas frequentes
CREATE INDEX IF NOT EXISTS idx_unidades_condominio_bloco_ativo 
ON unidades(condominio_id, bloco_id, ativo) WHERE ativo = true;

CREATE INDEX IF NOT EXISTS idx_unidades_status_ocupacao 
ON unidades(condominio_id, status_ocupacao) WHERE ativo = true;

CREATE INDEX IF NOT EXISTS idx_unidades_proprietario_inquilino 
ON unidades(proprietario_id, inquilino_id) WHERE ativo = true;

CREATE INDEX IF NOT EXISTS idx_blocos_condominio_numero 
ON blocos(condominio_id, numero_bloco) WHERE ativo = true;

-- Índices para busca de texto
CREATE INDEX IF NOT EXISTS idx_proprietarios_busca_texto 
ON proprietarios USING gin(to_tsvector('portuguese', nome || ' ' || COALESCE(email, '') || ' ' || COALESCE(cpf, ''))) 
WHERE ativo = true;

CREATE INDEX IF NOT EXISTS idx_inquilinos_busca_texto 
ON inquilinos USING gin(to_tsvector('portuguese', nome || ' ' || COALESCE(email, '') || ' ' || COALESCE(cpf, ''))) 
WHERE ativo = true;

CREATE INDEX IF NOT EXISTS idx_imobiliarias_busca_texto 
ON imobiliarias USING gin(to_tsvector('portuguese', nome || ' ' || COALESCE(razao_social, '') || ' ' || COALESCE(cnpj, ''))) 
WHERE ativo = true;

-- Índices para datas e contratos
CREATE INDEX IF NOT EXISTS idx_inquilinos_data_fim_contrato 
ON inquilinos(data_fim_contrato) WHERE ativo = true AND status_contrato = 'ativo';

CREATE INDEX IF NOT EXISTS idx_inquilinos_contratos_vencendo 
ON inquilinos(condominio_id, data_fim_contrato) 
WHERE ativo = true AND status_contrato = 'ativo' AND data_fim_contrato >= CURRENT_DATE;

-- Índices para valores financeiros
CREATE INDEX IF NOT EXISTS idx_unidades_valores 
ON unidades(condominio_id, valor_iptu, valor_condominio) WHERE ativo = true;

CREATE INDEX IF NOT EXISTS idx_inquilinos_valor_aluguel 
ON inquilinos(condominio_id, valor_aluguel) WHERE ativo = true AND status_contrato = 'ativo';

-- =====================================================
-- FUNÇÃO PARA ATUALIZAR ESTATÍSTICAS
-- =====================================================

CREATE OR REPLACE FUNCTION atualizar_estatisticas_condominio(
    p_condominio_id UUID
)
RETURNS TABLE (
    total_blocos INTEGER,
    total_unidades INTEGER,
    unidades_ocupadas INTEGER,
    percentual_ocupacao DECIMAL
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        COALESCE(b.total, 0)::INTEGER as total_blocos,
        COALESCE(u.total, 0)::INTEGER as total_unidades,
        COALESCE(u.ocupadas, 0)::INTEGER as unidades_ocupadas,
        CASE 
            WHEN COALESCE(u.total, 0) = 0 THEN 0::DECIMAL
            ELSE ROUND((u.ocupadas::DECIMAL / u.total) * 100, 2)
        END as percentual_ocupacao
    FROM (SELECT 1) dummy
    LEFT JOIN (
        SELECT COUNT(*) as total
        FROM blocos 
        WHERE condominio_id = p_condominio_id AND ativo = true
    ) b ON true
    LEFT JOIN (
        SELECT 
            COUNT(*) as total,
            COUNT(CASE WHEN status_ocupacao = 'ocupada' THEN 1 END) as ocupadas
        FROM unidades 
        WHERE condominio_id = p_condominio_id AND ativo = true
    ) u ON true;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- COMENTÁRIOS EXPLICATIVOS
-- =====================================================

COMMENT ON VIEW view_estrutura_condominio IS 'View principal com estrutura completa e estatísticas do condomínio';
COMMENT ON VIEW view_blocos_resumo IS 'View com resumo de blocos incluindo estatísticas de unidades';
COMMENT ON VIEW view_unidades_completas IS 'View com dados completos das unidades e todos os relacionamentos';
COMMENT ON VIEW view_dashboard_estatisticas IS 'View para dashboard com todas as estatísticas consolidadas';
COMMENT ON FUNCTION atualizar_estatisticas_condominio IS 'Função para calcular estatísticas atualizadas de um condomínio';