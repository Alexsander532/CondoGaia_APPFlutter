-- =====================================================
-- CORREÇÃO: ADICIONAR COLUNA tem_proprietario NA TABELA UNIDADES
-- =====================================================
-- Este script corrige o erro: column "tem_proprietario" of relation "unidades" does not exist

-- =====================================================
-- 1. ADICIONAR A COLUNA tem_proprietario
-- =====================================================
ALTER TABLE public.unidades 
ADD COLUMN IF NOT EXISTS tem_proprietario BOOLEAN DEFAULT false;

-- =====================================================
-- 2. ADICIONAR A COLUNA tem_inquilino (caso também não exista)
-- =====================================================
ALTER TABLE public.unidades 
ADD COLUMN IF NOT EXISTS tem_inquilino BOOLEAN DEFAULT false;

-- =====================================================
-- 3. ATUALIZAR OS VALORES EXISTENTES
-- =====================================================
-- Atualizar tem_proprietario baseado nos proprietários existentes
UPDATE public.unidades 
SET tem_proprietario = EXISTS(
    SELECT 1 FROM public.proprietarios 
    WHERE proprietarios.unidade_id = unidades.id 
    AND proprietarios.ativo = true
);

-- Atualizar tem_inquilino baseado nos inquilinos existentes (se a tabela existir)
UPDATE public.unidades 
SET tem_inquilino = EXISTS(
    SELECT 1 FROM public.inquilinos 
    WHERE inquilinos.unidade_id = unidades.id 
    AND inquilinos.ativo = true
)
WHERE EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'inquilinos');

-- =====================================================
-- 4. RECRIAR A FUNÇÃO DE TRIGGER (caso necessário)
-- =====================================================
CREATE OR REPLACE FUNCTION update_unidade_tem_proprietario()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' OR TG_OP = 'UPDATE' THEN
        -- Atualizar flag tem_proprietario na unidade
        UPDATE unidades 
        SET tem_proprietario = EXISTS(
            SELECT 1 FROM proprietarios 
            WHERE unidade_id = NEW.unidade_id AND ativo = true
        )
        WHERE id = NEW.unidade_id;
        
        RETURN NEW;
    ELSIF TG_OP = 'DELETE' THEN
        -- Atualizar flag tem_proprietario na unidade
        UPDATE unidades 
        SET tem_proprietario = EXISTS(
            SELECT 1 FROM proprietarios 
            WHERE unidade_id = OLD.unidade_id AND ativo = true
        )
        WHERE id = OLD.unidade_id;
        
        RETURN OLD;
    END IF;
    
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- 5. RECRIAR O TRIGGER
-- =====================================================
DROP TRIGGER IF EXISTS trigger_update_unidade_tem_proprietario ON proprietarios;

CREATE TRIGGER trigger_update_unidade_tem_proprietario
    AFTER INSERT OR UPDATE OR DELETE ON proprietarios
    FOR EACH ROW
    EXECUTE FUNCTION update_unidade_tem_proprietario();

-- =====================================================
-- 6. VERIFICAR SE AS COLUNAS FORAM ADICIONADAS
-- =====================================================
SELECT 
    column_name, 
    data_type, 
    is_nullable, 
    column_default
FROM information_schema.columns 
WHERE table_name = 'unidades' 
AND column_name IN ('tem_proprietario', 'tem_inquilino')
ORDER BY column_name;

-- =====================================================
-- 7. TESTAR A ATUALIZAÇÃO
-- =====================================================
-- Verificar se os valores foram atualizados corretamente
SELECT 
    u.id,
    u.identificacao,
    u.tem_proprietario,
    u.tem_inquilino,
    p.nome as proprietario_nome,
    p.cpf_cnpj as proprietario_cpf
FROM public.unidades u
LEFT JOIN public.proprietarios p ON p.unidade_id = u.id AND p.ativo = true
ORDER BY u.identificacao;

-- =====================================================
-- INSTRUÇÕES DE USO:
-- =====================================================
-- 1. Execute este script completo no seu banco de dados
-- 2. Isso irá adicionar as colunas necessárias na tabela unidades
-- 3. Atualizar os valores baseados nos dados existentes
-- 4. Recriar a função e trigger corretamente
-- 5. Após isso, você poderá inserir os proprietários sem erro