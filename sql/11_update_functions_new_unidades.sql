-- =====================================================
-- SCRIPT: 11_update_functions_new_unidades.sql
-- DESCRIÇÃO: Atualiza funções SQL para compatibilidade com nova estrutura da tabela unidades
-- AUTOR: Sistema
-- DATA: 2024-01-15
-- =====================================================

-- =====================================================
-- FUNÇÃO: listar_unidades_condominio (ATUALIZADA)
-- =====================================================

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
                            'bloco', u.bloco,
                            'tipo_unidade', u.tipo_unidade,
                            'ativo', u.ativo
                        ) ORDER BY u.numero::INTEGER
                    )
                    FROM unidades u
                    WHERE u.bloco = b.nome AND u.condominio_id = p_condominio_id AND u.ativo = true
                )
            ) ORDER BY b.ordem
        )
        FROM blocos b
        WHERE b.condominio_id = p_condominio_id AND b.ativo = true
    );
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- FUNÇÃO: buscar_dados_completos_unidade (ATUALIZADA)
-- =====================================================

CREATE OR REPLACE FUNCTION buscar_dados_completos_unidade(p_unidade_id UUID)
RETURNS JSON AS $$
BEGIN
    RETURN (
        SELECT json_build_object(
            'unidade', json_build_object(
                'id', u.id,
                'numero', u.numero,
                'condominio_id', u.condominio_id,
                'bloco', u.bloco,
                'fracao_ideal', u.fracao_ideal,
                'area_m2', u.area_m2,
                'vencto_dia_diferente', u.vencto_dia_diferente,
                'pagar_valor_diferente', u.pagar_valor_diferente,
                'tipo_unidade', u.tipo_unidade,
                'isencao_nenhum', u.isencao_nenhum,
                'isencao_total', u.isencao_total,
                'isencao_cota', u.isencao_cota,
                'isencao_fundo_reserva', u.isencao_fundo_reserva,
                'acao_judicial', u.acao_judicial,
                'correios', u.correios,
                'nome_pagador_boleto', u.nome_pagador_boleto,
                'observacoes', u.observacoes,
                'ativo', u.ativo,
                'created_at', u.created_at,
                'updated_at', u.updated_at
            )
        )
        FROM unidades u
        WHERE u.id = p_unidade_id AND u.ativo = true
    );
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- FUNÇÃO: estatisticas_condominio (ATUALIZADA)
-- =====================================================

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
            'unidades_ocupadas', (
                SELECT COUNT(*) FROM unidades 
                WHERE condominio_id = p_condominio_id AND ativo = true AND numero IS NOT NULL AND trim(numero) != ''
            ),
            'unidades_vazias', (
                SELECT COUNT(*) FROM unidades 
                WHERE condominio_id = p_condominio_id AND ativo = true AND (numero IS NULL OR trim(numero) = '')
            ),
            'unidades_com_isencao_total', (
                SELECT COUNT(*) FROM unidades 
                WHERE condominio_id = p_condominio_id AND isencao_total = true AND ativo = true
            ),
            'unidades_com_acao_judicial', (
                SELECT COUNT(*) FROM unidades 
                WHERE condominio_id = p_condominio_id AND acao_judicial = true AND ativo = true
            ),
            'unidades_tipo_a', (
                SELECT COUNT(*) FROM unidades 
                WHERE condominio_id = p_condominio_id AND tipo_unidade = 'A' AND ativo = true
            ),
            'unidades_tipo_b', (
                SELECT COUNT(*) FROM unidades 
                WHERE condominio_id = p_condominio_id AND tipo_unidade = 'B' AND ativo = true
            ),
            'unidades_tipo_c', (
                SELECT COUNT(*) FROM unidades 
                WHERE condominio_id = p_condominio_id AND tipo_unidade = 'C' AND ativo = true
            ),
            'unidades_tipo_d', (
                SELECT COUNT(*) FROM unidades 
                WHERE condominio_id = p_condominio_id AND tipo_unidade = 'D' AND ativo = true
            )
        )
    );
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- FUNÇÃO: setup_condominio_completo (ATUALIZADA)
-- =====================================================

CREATE OR REPLACE FUNCTION setup_condominio_completo(
    p_condominio_id UUID,
    p_total_blocos INTEGER DEFAULT 4,
    p_unidades_por_bloco INTEGER DEFAULT 6,
    p_usar_letras BOOLEAN DEFAULT true
)
RETURNS JSON AS $$
DECLARE
    v_bloco_nome VARCHAR(10);
    v_bloco_id UUID;
    v_unidade_numero VARCHAR(10);
    v_contador INTEGER;
    v_resultado JSON;
BEGIN
    -- Limpar dados existentes do condomínio
    DELETE FROM unidades WHERE condominio_id = p_condominio_id;
    DELETE FROM blocos WHERE condominio_id = p_condominio_id;
    
    -- Criar blocos
    FOR i IN 1..p_total_blocos LOOP
        IF p_usar_letras THEN
            v_bloco_nome := chr(64 + i); -- A, B, C, D...
        ELSE
            v_bloco_nome := i::VARCHAR;
        END IF;
        
        INSERT INTO blocos (condominio_id, nome, codigo, ordem)
        VALUES (p_condominio_id, v_bloco_nome, v_bloco_nome, i)
        RETURNING id INTO v_bloco_id;
        
        -- Criar unidades para este bloco
        FOR j IN 1..p_unidades_por_bloco LOOP
            v_unidade_numero := (j * 100 + i)::VARCHAR; -- Ex: 101, 102, 201, 202...
            
            INSERT INTO unidades (
                condominio_id, 
                numero, 
                bloco,
                tipo_unidade,
                isencao_nenhum,
                ativo
            )
            VALUES (
                p_condominio_id, 
                v_unidade_numero, 
                v_bloco_nome,
                'A', -- Tipo padrão
                true, -- Isenção nenhum por padrão
                true
            );
        END LOOP;
    END LOOP;
    
    -- Retornar estatísticas
    SELECT json_build_object(
        'condominio_id', p_condominio_id,
        'blocos_criados', p_total_blocos,
        'unidades_por_bloco', p_unidades_por_bloco,
        'total_unidades', p_total_blocos * p_unidades_por_bloco,
        'usar_letras', p_usar_letras,
        'status', 'sucesso'
    ) INTO v_resultado;
    
    RETURN v_resultado;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- COMENTÁRIOS E LOGS
-- =====================================================

-- Log da atualização
DO $$
BEGIN
    RAISE NOTICE 'Funções SQL atualizadas para compatibilidade com nova estrutura da tabela unidades';
    RAISE NOTICE 'Funções atualizadas: listar_unidades_condominio, buscar_dados_completos_unidade, estatisticas_condominio, setup_condominio_completo';
    RAISE NOTICE 'Data: %', now();
END $$;