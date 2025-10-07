-- =====================================================
-- SCRIPT COMPLETO DE EXECUÇÃO - SISTEMA UNIDADE MORADOR
-- =====================================================
-- Execute este script no Supabase para criar toda a estrutura
-- necessária para a tela de unidade morador

-- =====================================================
-- FUNÇÕES AUXILIARES PARA SETUP COMPLETO
-- =====================================================

-- Função para criar estrutura completa de um condomínio
CREATE OR REPLACE FUNCTION setup_condominio_completo(
    p_condominio_id UUID,
    p_total_blocos INTEGER DEFAULT 4,
    p_unidades_por_bloco INTEGER DEFAULT 6,
    p_usar_letras BOOLEAN DEFAULT true
)
RETURNS JSON AS $$
DECLARE
    config_id UUID;
    blocos_criados INTEGER;
    unidades_criadas INTEGER;
    resultado JSON;
BEGIN
    -- 1. Criar configuração do condomínio
    INSERT INTO configuracao_condominio (
        condominio_id,
        total_blocos,
        unidades_por_bloco,
        usar_letras_blocos
    ) VALUES (
        p_condominio_id,
        p_total_blocos,
        p_unidades_por_bloco,
        p_usar_letras
    ) RETURNING id INTO config_id;
    
    -- 2. Gerar blocos automaticamente
    blocos_criados := gerar_blocos_automatico(p_condominio_id);
    
    -- 3. Gerar unidades para todos os blocos
    unidades_criadas := gerar_todas_unidades_condominio(p_condominio_id);
    
    -- 4. Retornar resultado
    resultado := json_build_object(
        'success', true,
        'configuracao_id', config_id,
        'blocos_criados', blocos_criados,
        'unidades_criadas', unidades_criadas,
        'message', format('Condomínio configurado com %s blocos e %s unidades', blocos_criados, unidades_criadas)
    );
    
    RETURN resultado;
    
EXCEPTION WHEN OTHERS THEN
    RETURN json_build_object(
        'success', false,
        'error', SQLERRM,
        'message', 'Erro ao configurar condomínio'
    );
END;
$$ LANGUAGE plpgsql;

-- Função para buscar dados completos de uma unidade
CREATE OR REPLACE FUNCTION buscar_dados_completos_unidade(p_unidade_id UUID)
RETURNS JSON AS $$
DECLARE
    resultado JSON;
BEGIN
    SELECT json_build_object(
        'unidade', row_to_json(u.*),
        'bloco', row_to_json(b.*),
        'condominio', json_build_object(
            'id', c.id,
            'nome', c.nome_condominio,
            'cnpj', c.cnpj
        ),
        'proprietarios', COALESCE(
            (SELECT json_agg(row_to_json(p.*)) 
             FROM proprietarios p 
             WHERE p.unidade_id = p_unidade_id AND p.ativo = true), 
            '[]'::json
        ),
        'inquilinos', COALESCE(
            (SELECT json_agg(row_to_json(i.*)) 
             FROM inquilinos i 
             WHERE i.unidade_id = p_unidade_id AND i.ativo = true), 
            '[]'::json
        ),
        'imobiliarias', COALESCE(
            (SELECT json_agg(json_build_object(
                'imobiliaria', row_to_json(im.*),
                'relacionamento', json_build_object(
                    'tipo_servico', iu.tipo_servico,
                    'data_inicio', iu.data_inicio,
                    'data_fim', iu.data_fim
                )
            ))
             FROM imobiliarias_unidades iu
             JOIN imobiliarias im ON iu.imobiliaria_id = im.id
             WHERE iu.unidade_id = p_unidade_id AND iu.ativo = true AND im.ativo = true), 
            '[]'::json
        )
    ) INTO resultado
    FROM unidades u
    JOIN blocos b ON u.bloco_id = b.id
    JOIN condominios c ON u.condominio_id = c.id
    WHERE u.id = p_unidade_id;
    
    RETURN COALESCE(resultado, json_build_object('error', 'Unidade não encontrada'));
END;
$$ LANGUAGE plpgsql;

-- Função para listar todas as unidades de um condomínio
CREATE OR REPLACE FUNCTION listar_unidades_condominio(p_condominio_id UUID)
RETURNS JSON AS $$
BEGIN
    RETURN (
        SELECT json_agg(
            json_build_object(
                'bloco', json_build_object(
                    'id', b.id,
                    'nome', b.nome,
                    'codigo', b.codigo,
                    'ordem', b.ordem
                ),
                'unidades', (
                    SELECT json_agg(
                        json_build_object(
                            'id', u.id,
                            'numero', u.numero,
                            'tem_proprietario', u.tem_proprietario,
                            'tem_inquilino', u.tem_inquilino,
                            'tem_imobiliaria', u.tem_imobiliaria,
                            'ativo', u.ativo
                        ) ORDER BY u.numero::INTEGER
                    )
                    FROM unidades u
                    WHERE u.bloco_id = b.id AND u.ativo = true
                )
            ) ORDER BY b.ordem
        )
        FROM blocos b
        WHERE b.condominio_id = p_condominio_id AND b.ativo = true
    );
END;
$$ LANGUAGE plpgsql;

-- Função para estatísticas do condomínio
CREATE OR REPLACE FUNCTION estatisticas_condominio(p_condominio_id UUID)
RETURNS JSON AS $$
BEGIN
    RETURN (
        SELECT json_build_object(
            'total_blocos', (
                SELECT COUNT(*) FROM blocos 
                WHERE condominio_id = p_condominio_id AND ativo = true
            ),
            'total_unidades', (
                SELECT COUNT(*) FROM unidades 
                WHERE condominio_id = p_condominio_id AND ativo = true
            ),
            'unidades_com_moradores', (
                SELECT COUNT(*) FROM unidades 
                WHERE condominio_id = p_condominio_id AND (tem_proprietario = true OR tem_inquilino = true) AND ativo = true
            ),
            'unidades_com_proprietario', (
                SELECT COUNT(*) FROM unidades 
                WHERE condominio_id = p_condominio_id AND tem_proprietario = true AND ativo = true
            ),
            'unidades_com_inquilino', (
                SELECT COUNT(*) FROM unidades 
                WHERE condominio_id = p_condominio_id AND tem_inquilino = true AND ativo = true
            ),
            'unidades_com_imobiliaria', (
                SELECT COUNT(*) FROM unidades 
                WHERE condominio_id = p_condominio_id AND tem_imobiliaria = true AND ativo = true
            ),
            'total_proprietarios', (
                SELECT COUNT(*) FROM proprietarios 
                WHERE condominio_id = p_condominio_id AND ativo = true
            ),
            'total_inquilinos', (
                SELECT COUNT(*) FROM inquilinos 
                WHERE condominio_id = p_condominio_id AND ativo = true
            ),
            'total_imobiliarias', (
                SELECT COUNT(DISTINCT i.id) FROM imobiliarias i
                JOIN imobiliarias_unidades iu ON i.id = iu.imobiliaria_id
                JOIN unidades u ON iu.unidade_id = u.id
                WHERE u.condominio_id = p_condominio_id AND i.ativo = true AND iu.ativo = true
            )
        )
    );
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- VIEWS PARA FACILITAR CONSULTAS
-- =====================================================

-- View para listar unidades com informações completas
CREATE OR REPLACE VIEW view_unidades_completas AS
SELECT 
    u.id as unidade_id,
    u.numero,
    u.tem_proprietario,
    u.tem_inquilino,
    u.tem_imobiliaria,
    u.ativo as unidade_ativa,
    
    -- Dados do Bloco
    b.id as bloco_id,
    b.nome as bloco_nome,
    b.codigo as bloco_codigo,
    b.ordem as bloco_ordem,
    
    -- Dados do Condomínio
    c.id as condominio_id,
    c.nome_condominio as condominio_nome,
    c.cnpj as condominio_cnpj,
    
    -- Proprietário (primeiro encontrado ativo)
    p.id as proprietario_id,
    p.nome as proprietario_nome,
    p.cpf_cnpj as proprietario_cpf_cnpj,
    p.telefone as proprietario_telefone,
    p.email as proprietario_email,
    
    -- Inquilino (primeiro encontrado ativo)
    i.id as inquilino_id,
    i.nome as inquilino_nome,
    i.cpf_cnpj as inquilino_cpf_cnpj,
    i.telefone as inquilino_telefone,
    i.email as inquilino_email
    
FROM unidades u
JOIN blocos b ON u.bloco_id = b.id
JOIN condominios c ON u.condominio_id = c.id
LEFT JOIN proprietarios p ON u.id = p.unidade_id AND p.ativo = true
LEFT JOIN inquilinos i ON u.id = i.unidade_id AND i.ativo = true
WHERE u.ativo = true AND b.ativo = true;

-- =====================================================
-- COMENTÁRIOS FINAIS E INSTRUÇÕES
-- =====================================================

-- Para usar o sistema após executar as migrações:

-- 1. Configurar um condomínio existente:
-- SELECT setup_condominio_completo('uuid-do-condominio', 4, 6, true);

-- 2. Listar unidades de um condomínio:
-- SELECT listar_unidades_condominio('uuid-do-condominio');

-- 3. Buscar dados completos de uma unidade:
-- SELECT buscar_dados_completos_unidade('uuid-da-unidade');

-- 4. Ver estatísticas do condomínio:
-- SELECT estatisticas_condominio('uuid-do-condominio');

-- 5. Consultar view de unidades completas:
-- SELECT * FROM view_unidades_completas WHERE condominio_id = 'uuid-do-condominio';