-- =====================================================
-- MIGRAÇÃO 8: POLÍTICAS RLS (ROW LEVEL SECURITY)
-- =====================================================
-- Este arquivo implementa as políticas de segurança para
-- garantir que usuários só acessem dados de seus condomínios

-- =====================================================
-- HABILITAR RLS NAS TABELAS
-- =====================================================

-- Habilitar RLS em todas as tabelas do sistema
ALTER TABLE configuracao_condominio ENABLE ROW LEVEL SECURITY;
ALTER TABLE blocos ENABLE ROW LEVEL SECURITY;
ALTER TABLE unidades ENABLE ROW LEVEL SECURITY;
ALTER TABLE proprietarios ENABLE ROW LEVEL SECURITY;
ALTER TABLE inquilinos ENABLE ROW LEVEL SECURITY;
ALTER TABLE imobiliarias ENABLE ROW LEVEL SECURITY;
ALTER TABLE imobiliarias_unidades ENABLE ROW LEVEL SECURITY;

-- =====================================================
-- FUNÇÃO AUXILIAR PARA VERIFICAR ACESSO AO CONDOMÍNIO
-- =====================================================

-- Função para verificar se o usuário tem acesso ao condomínio
CREATE OR REPLACE FUNCTION usuario_tem_acesso_condominio(condominio_uuid UUID)
RETURNS BOOLEAN AS $$
BEGIN
    -- Verificar se é um representante com acesso ao condomínio
    IF EXISTS (
        SELECT 1 FROM condominios c
        INNER JOIN representantes r ON r.id = c.representante_id
        WHERE c.id = condominio_uuid 
        AND r.user_id = auth.uid()
    ) THEN
        RETURN TRUE;
    END IF;
    
    -- Verificar se é um administrador com acesso ao condomínio
    IF EXISTS (
        SELECT 1 FROM administrators a
        INNER JOIN condominios c ON c.id = ANY(a.condominios_selecionados)
        WHERE c.id = condominio_uuid 
        AND a.user_id = auth.uid()
    ) THEN
        RETURN TRUE;
    END IF;
    
    -- Verificar se é um proprietário/inquilino da unidade
    IF EXISTS (
        SELECT 1 FROM unidades u
        WHERE u.condominio_id = condominio_uuid
        AND (
            EXISTS (SELECT 1 FROM proprietarios p WHERE p.unidade_id = u.id AND p.user_id = auth.uid())
            OR EXISTS (SELECT 1 FROM inquilinos i WHERE i.unidade_id = u.id AND i.user_id = auth.uid())
        )
    ) THEN
        RETURN TRUE;
    END IF;
    
    RETURN FALSE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- POLÍTICAS PARA CONFIGURAÇÃO DO CONDOMÍNIO
-- =====================================================

-- Política de SELECT para configuracao_condominio
CREATE POLICY "Usuários podem ver configuração de seus condomínios"
ON configuracao_condominio FOR SELECT
USING (usuario_tem_acesso_condominio(condominio_id));

-- Política de INSERT para configuracao_condominio
CREATE POLICY "Representantes e admins podem criar configuração"
ON configuracao_condominio FOR INSERT
WITH CHECK (usuario_tem_acesso_condominio(condominio_id));

-- Política de UPDATE para configuracao_condominio
CREATE POLICY "Representantes e admins podem atualizar configuração"
ON configuracao_condominio FOR UPDATE
USING (usuario_tem_acesso_condominio(condominio_id))
WITH CHECK (usuario_tem_acesso_condominio(condominio_id));

-- Política de DELETE para configuracao_condominio
CREATE POLICY "Representantes e admins podem deletar configuração"
ON configuracao_condominio FOR DELETE
USING (usuario_tem_acesso_condominio(condominio_id));

-- =====================================================
-- POLÍTICAS PARA BLOCOS
-- =====================================================

-- Política de SELECT para blocos
CREATE POLICY "Usuários podem ver blocos de seus condomínios"
ON blocos FOR SELECT
USING (usuario_tem_acesso_condominio(condominio_id));

-- Política de INSERT para blocos
CREATE POLICY "Representantes e admins podem criar blocos"
ON blocos FOR INSERT
WITH CHECK (usuario_tem_acesso_condominio(condominio_id));

-- Política de UPDATE para blocos
CREATE POLICY "Representantes e admins podem atualizar blocos"
ON blocos FOR UPDATE
USING (usuario_tem_acesso_condominio(condominio_id))
WITH CHECK (usuario_tem_acesso_condominio(condominio_id));

-- Política de DELETE para blocos
CREATE POLICY "Representantes e admins podem deletar blocos"
ON blocos FOR DELETE
USING (usuario_tem_acesso_condominio(condominio_id));

-- =====================================================
-- POLÍTICAS PARA UNIDADES
-- =====================================================

-- Política de SELECT para unidades
CREATE POLICY "Usuários podem ver unidades de seus condomínios"
ON unidades FOR SELECT
USING (usuario_tem_acesso_condominio(condominio_id));

-- Política de INSERT para unidades
CREATE POLICY "Representantes e admins podem criar unidades"
ON unidades FOR INSERT
WITH CHECK (usuario_tem_acesso_condominio(condominio_id));

-- Política de UPDATE para unidades
CREATE POLICY "Representantes e admins podem atualizar unidades"
ON unidades FOR UPDATE
USING (usuario_tem_acesso_condominio(condominio_id))
WITH CHECK (usuario_tem_acesso_condominio(condominio_id));

-- Política de DELETE para unidades
CREATE POLICY "Representantes e admins podem deletar unidades"
ON unidades FOR DELETE
USING (usuario_tem_acesso_condominio(condominio_id));

-- =====================================================
-- POLÍTICAS PARA PROPRIETÁRIOS
-- =====================================================

-- Política de SELECT para proprietarios
CREATE POLICY "Usuários podem ver proprietários de seus condomínios"
ON proprietarios FOR SELECT
USING (usuario_tem_acesso_condominio(condominio_id));

-- Política de INSERT para proprietarios
CREATE POLICY "Representantes e admins podem criar proprietários"
ON proprietarios FOR INSERT
WITH CHECK (usuario_tem_acesso_condominio(condominio_id));

-- Política de UPDATE para proprietarios
CREATE POLICY "Representantes e admins podem atualizar proprietários"
ON proprietarios FOR UPDATE
USING (usuario_tem_acesso_condominio(condominio_id))
WITH CHECK (usuario_tem_acesso_condominio(condominio_id));

-- Política de DELETE para proprietarios
CREATE POLICY "Representantes e admins podem deletar proprietários"
ON proprietarios FOR DELETE
USING (usuario_tem_acesso_condominio(condominio_id));

-- =====================================================
-- POLÍTICAS PARA INQUILINOS
-- =====================================================

-- Política de SELECT para inquilinos
CREATE POLICY "Usuários podem ver inquilinos de seus condomínios"
ON inquilinos FOR SELECT
USING (usuario_tem_acesso_condominio(condominio_id));

-- Política de INSERT para inquilinos
CREATE POLICY "Representantes e admins podem criar inquilinos"
ON inquilinos FOR INSERT
WITH CHECK (usuario_tem_acesso_condominio(condominio_id));

-- Política de UPDATE para inquilinos
CREATE POLICY "Representantes e admins podem atualizar inquilinos"
ON inquilinos FOR UPDATE
USING (usuario_tem_acesso_condominio(condominio_id))
WITH CHECK (usuario_tem_acesso_condominio(condominio_id));

-- Política de DELETE para inquilinos
CREATE POLICY "Representantes e admins podem deletar inquilinos"
ON inquilinos FOR DELETE
USING (usuario_tem_acesso_condominio(condominio_id));

-- =====================================================
-- POLÍTICAS PARA IMOBILIÁRIAS
-- =====================================================

-- Política de SELECT para imobiliarias
CREATE POLICY "Usuários podem ver imobiliárias de seus condomínios"
ON imobiliarias FOR SELECT
USING (usuario_tem_acesso_condominio(condominio_id));

-- Política de INSERT para imobiliarias
CREATE POLICY "Representantes e admins podem criar imobiliárias"
ON imobiliarias FOR INSERT
WITH CHECK (usuario_tem_acesso_condominio(condominio_id));

-- Política de UPDATE para imobiliarias
CREATE POLICY "Representantes e admins podem atualizar imobiliárias"
ON imobiliarias FOR UPDATE
USING (usuario_tem_acesso_condominio(condominio_id))
WITH CHECK (usuario_tem_acesso_condominio(condominio_id));

-- Política de DELETE para imobiliarias
CREATE POLICY "Representantes e admins podem deletar imobiliárias"
ON imobiliarias FOR DELETE
USING (usuario_tem_acesso_condominio(condominio_id));

-- =====================================================
-- POLÍTICAS PARA RELACIONAMENTO IMOBILIÁRIAS-UNIDADES
-- =====================================================

-- Política de SELECT para imobiliarias_unidades
CREATE POLICY "Usuários podem ver relacionamentos de seus condomínios"
ON imobiliarias_unidades FOR SELECT
USING (usuario_tem_acesso_condominio(condominio_id));

-- Política de INSERT para imobiliarias_unidades
CREATE POLICY "Representantes e admins podem criar relacionamentos"
ON imobiliarias_unidades FOR INSERT
WITH CHECK (usuario_tem_acesso_condominio(condominio_id));

-- Política de UPDATE para imobiliarias_unidades
CREATE POLICY "Representantes e admins podem atualizar relacionamentos"
ON imobiliarias_unidades FOR UPDATE
USING (usuario_tem_acesso_condominio(condominio_id))
WITH CHECK (usuario_tem_acesso_condominio(condominio_id));

-- Política de DELETE para imobiliarias_unidades
CREATE POLICY "Representantes e admins podem deletar relacionamentos"
ON imobiliarias_unidades FOR DELETE
USING (usuario_tem_acesso_condominio(condominio_id));

-- =====================================================
-- COMENTÁRIOS E INSTRUÇÕES
-- =====================================================

-- As políticas RLS garantem que:
-- 1. Representantes só acessam dados de seus condomínios
-- 2. Administradores só acessam dados de condomínios selecionados
-- 3. Proprietários/Inquilinos só acessam dados de suas unidades
-- 4. Todas as operações respeitam a hierarquia de permissões

-- Para testar as políticas:
-- 1. Faça login como representante
-- 2. Execute: SELECT * FROM unidades; (deve retornar apenas unidades dos seus condomínios)
-- 3. Tente acessar dados de outro condomínio (deve retornar vazio)