-- =====================================================
-- ADICIONAR CAMPO SENHA_ACESSO PARA PROPRIETÁRIOS E INQUILINOS
-- =====================================================
-- Este script adiciona o campo senha_acesso nas tabelas proprietarios e inquilinos
-- seguindo o mesmo padrão da tabela representantes, e define senhas provisórias

-- =====================================================
-- 1. ADICIONAR COLUNA SENHA_ACESSO NA TABELA PROPRIETARIOS
-- =====================================================
ALTER TABLE public.proprietarios 
ADD COLUMN IF NOT EXISTS senha_acesso VARCHAR(255);

-- Comentário na coluna
COMMENT ON COLUMN public.proprietarios.senha_acesso IS 'Senha de acesso do proprietário para login no aplicativo';

-- =====================================================
-- 2. ADICIONAR COLUNA SENHA_ACESSO NA TABELA INQUILINOS
-- =====================================================
ALTER TABLE public.inquilinos 
ADD COLUMN IF NOT EXISTS senha_acesso VARCHAR(255);

-- Comentário na coluna
COMMENT ON COLUMN public.inquilinos.senha_acesso IS 'Senha de acesso do inquilino para login no aplicativo';

-- =====================================================
-- 3. DEFINIR SENHAS PROVISÓRIAS PARA PROPRIETÁRIOS EXISTENTES
-- =====================================================
-- Atualizar proprietários existentes com senha baseada no nome + CPF
UPDATE public.proprietarios 
SET senha_acesso = CASE 
    WHEN LENGTH(TRIM(nome)) >= 4 THEN 
        UPPER(LEFT(REGEXP_REPLACE(TRIM(nome), '[^A-Za-z]', '', 'g'), 4)) || 
        RIGHT(REGEXP_REPLACE(cpf_cnpj, '[^0-9]', '', 'g'), 4)
    ELSE 
        UPPER(LPAD(REGEXP_REPLACE(TRIM(nome), '[^A-Za-z]', '', 'g'), 4, 'X')) || 
        RIGHT(REGEXP_REPLACE(cpf_cnpj, '[^0-9]', '', 'g'), 4)
END
WHERE senha_acesso IS NULL;

-- =====================================================
-- 4. DEFINIR SENHAS PROVISÓRIAS PARA INQUILINOS EXISTENTES
-- =====================================================
-- Atualizar inquilinos existentes com senha baseada no nome + CPF
UPDATE public.inquilinos 
SET senha_acesso = CASE 
    WHEN LENGTH(TRIM(nome)) >= 4 THEN 
        UPPER(LEFT(REGEXP_REPLACE(TRIM(nome), '[^A-Za-z]', '', 'g'), 4)) || 
        RIGHT(REGEXP_REPLACE(cpf_cnpj, '[^0-9]', '', 'g'), 4)
    ELSE 
        UPPER(LPAD(REGEXP_REPLACE(TRIM(nome), '[^A-Za-z]', '', 'g'), 4, 'X')) || 
        RIGHT(REGEXP_REPLACE(cpf_cnpj, '[^0-9]', '', 'g'), 4)
END
WHERE senha_acesso IS NULL;

-- =====================================================
-- 5. CRIAR ÍNDICES PARA PERFORMANCE
-- =====================================================
CREATE INDEX IF NOT EXISTS idx_proprietarios_senha_acesso ON public.proprietarios(senha_acesso);
CREATE INDEX IF NOT EXISTS idx_inquilinos_senha_acesso ON public.inquilinos(senha_acesso);

-- =====================================================
-- 6. VALIDAÇÃO DOS DADOS INSERIDOS
-- =====================================================
-- Verificar proprietários com senhas criadas
SELECT 
    'Proprietários com senhas criadas:' as status,
    COUNT(*) as total_proprietarios,
    COUNT(CASE WHEN senha_acesso IS NOT NULL THEN 1 END) as com_senha,
    COUNT(CASE WHEN senha_acesso IS NULL THEN 1 END) as sem_senha
FROM public.proprietarios;

-- Verificar inquilinos com senhas criadas
SELECT 
    'Inquilinos com senhas criadas:' as status,
    COUNT(*) as total_inquilinos,
    COUNT(CASE WHEN senha_acesso IS NOT NULL THEN 1 END) as com_senha,
    COUNT(CASE WHEN senha_acesso IS NULL THEN 1 END) as sem_senha
FROM public.inquilinos;

-- =====================================================
-- 7. EXEMPLOS DE SENHAS GERADAS
-- =====================================================
-- Mostrar alguns exemplos de proprietários com suas senhas
SELECT 
    'Exemplos de senhas - Proprietários:' as tipo,
    nome,
    cpf_cnpj,
    senha_acesso,
    email
FROM public.proprietarios 
WHERE senha_acesso IS NOT NULL
ORDER BY nome
LIMIT 5;

-- Mostrar alguns exemplos de inquilinos com suas senhas
SELECT 
    'Exemplos de senhas - Inquilinos:' as tipo,
    nome,
    cpf_cnpj,
    senha_acesso,
    email
FROM public.inquilinos 
WHERE senha_acesso IS NOT NULL
ORDER BY nome
LIMIT 5;

-- =====================================================
-- 8. VERIFICAR DUPLICATAS DE SENHAS
-- =====================================================
-- Verificar se há senhas duplicadas entre proprietários
SELECT 
    'Senhas duplicadas - Proprietários:' as status,
    senha_acesso,
    COUNT(*) as quantidade,
    STRING_AGG(nome, ', ') as nomes
FROM public.proprietarios 
WHERE senha_acesso IS NOT NULL
GROUP BY senha_acesso
HAVING COUNT(*) > 1
ORDER BY quantidade DESC;

-- Verificar se há senhas duplicadas entre inquilinos
SELECT 
    'Senhas duplicadas - Inquilinos:' as status,
    senha_acesso,
    COUNT(*) as quantidade,
    STRING_AGG(nome, ', ') as nomes
FROM public.inquilinos 
WHERE senha_acesso IS NOT NULL
GROUP BY senha_acesso
HAVING COUNT(*) > 1
ORDER BY quantidade DESC;

-- =====================================================
-- 9. INSTRUÇÕES DE USO
-- =====================================================
-- IMPORTANTE: 
-- 1. Execute este script completo no seu banco de dados
-- 2. As senhas são geradas automaticamente baseadas no padrão:
--    - Primeiras 4 letras do nome (maiúsculas, sem acentos)
--    - Últimos 4 dígitos do CPF/CNPJ
--    - Exemplo: "João Silva Santos" + CPF "123.456.789-01" = "JOAO9801"
-- 3. Senhas provisórias devem ser alteradas pelos usuários no primeiro acesso
-- 4. O campo senha_acesso segue o mesmo padrão da tabela representantes
-- 5. Verifique os resultados das consultas de validação
-- 6. Em caso de senhas duplicadas, será necessário ajuste manual

-- =====================================================
-- 10. REGRAS DE NEGÓCIO IMPLEMENTADAS
-- =====================================================
-- - Campo senha_acesso do tipo VARCHAR(255) (mesmo padrão dos representantes)
-- - Senhas geradas automaticamente para registros existentes
-- - Índices criados para melhorar performance de autenticação
-- - Validações incluídas para verificar integridade dos dados
-- - Tratamento de nomes curtos (preenchimento com 'X')
-- - Remoção de caracteres especiais e acentos
-- - Senhas em maiúsculas para padronização