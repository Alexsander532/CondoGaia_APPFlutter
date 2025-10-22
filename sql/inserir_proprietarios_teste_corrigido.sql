-- =====================================================
-- INSERIR PROPRIETÁRIOS DE TESTE - VERSÃO CORRIGIDA
-- =====================================================
-- Condomínio ID: 0ababacf-c924-4ee0-947c-850a0c6a46e3
-- Unidade 1 ID: 6c9197d6-8359-4f38-8e6c-8c93461fd63b
-- Unidade 2 ID: d400bc66-c270-41a3-bc6f-d04c48223411

-- =====================================================
-- VERIFICAR SE JÁ EXISTEM PROPRIETÁRIOS COM ESSES CPFs
-- =====================================================
SELECT 
    'Verificando CPFs existentes...' as status,
    COUNT(*) as total_existentes
FROM public.proprietarios 
WHERE condominio_id = '0ababacf-c924-4ee0-947c-850a0c6a46e3' 
AND cpf_cnpj IN ('111.222.333-44', '555.666.777-88');

-- =====================================================
-- PROPRIETÁRIO 1 - João Silva Santos (CPF ÚNICO)
-- =====================================================
INSERT INTO public.proprietarios (
    condominio_id,
    unidade_id,
    nome,
    cpf_cnpj,
    cep,
    endereco,
    numero,
    complemento,
    bairro,
    cidade,
    estado,
    telefone,
    celular,
    email,
    conjuge,
    multiproprietarios,
    moradores,
    ativo
) VALUES (
    '0ababacf-c924-4ee0-947c-850a0c6a46e3',  -- condominio_id
    '6c9197d6-8359-4f38-8e6c-8c93461fd63b',  -- unidade_id
    'João Silva Santos',                      -- nome
    '111.222.333-44',                        -- cpf_cnpj (ALTERADO)
    '01234-567',                             -- cep
    'Rua das Flores',                        -- endereco
    '123',                                   -- numero
    'Apto 45',                               -- complemento
    'Vila Madalena',                         -- bairro
    'São Paulo',                             -- cidade
    'SP',                                    -- estado
    '(11) 3333-4444',                        -- telefone
    '(11) 99999-1111',                       -- celular
    'joao.silva.teste@email.com',            -- email (ALTERADO)
    'Maria Silva Santos',                    -- conjuge
    NULL,                                    -- multiproprietarios
    'João Silva Santos, Maria Silva Santos', -- moradores
    true                                     -- ativo
);

-- =====================================================
-- PROPRIETÁRIO 2 - Maria Oliveira Costa (CPF ÚNICO)
-- =====================================================
INSERT INTO public.proprietarios (
    condominio_id,
    unidade_id,
    nome,
    cpf_cnpj,
    cep,
    endereco,
    numero,
    complemento,
    bairro,
    cidade,
    estado,
    telefone,
    celular,
    email,
    conjuge,
    multiproprietarios,
    moradores,
    ativo
) VALUES (
    '0ababacf-c924-4ee0-947c-850a0c6a46e3',  -- condominio_id
    'd400bc66-c270-41a3-bc6f-d04c48223411',  -- unidade_id
    'Maria Oliveira Costa',                   -- nome
    '555.666.777-88',                        -- cpf_cnpj (ALTERADO)
    '09876-543',                             -- cep
    'Avenida Paulista',                      -- endereco
    '987',                                   -- numero
    'Cobertura 12',                          -- complemento
    'Bela Vista',                            -- bairro
    'São Paulo',                             -- cidade
    'SP',                                    -- estado
    '(11) 2222-3333',                        -- telefone
    '(11) 88888-2222',                       -- celular
    'maria.oliveira@email.com',              -- email
    'Carlos Oliveira Costa',                 -- conjuge
    NULL,                                    -- multiproprietarios
    'Maria Oliveira Costa, Carlos Oliveira Costa', -- moradores
    true                                     -- ativo
);

-- =====================================================
-- VALIDAÇÃO DOS DADOS INSERIDOS
-- =====================================================
SELECT 
    'Proprietários inseridos com sucesso!' as status,
    p.id,
    p.nome,
    p.cpf_cnpj,
    p.email,
    p.unidade_id,
    u.identificacao as unidade_identificacao,
    p.ativo
FROM public.proprietarios p
LEFT JOIN public.unidades u ON u.id = p.unidade_id
WHERE p.condominio_id = '0ababacf-c924-4ee0-947c-850a0c6a46e3'
AND p.cpf_cnpj IN ('111.222.333-44', '555.666.777-88')
ORDER BY p.nome;

-- =====================================================
-- VERIFICAR SE AS UNIDADES FORAM ATUALIZADAS
-- =====================================================
SELECT 
    'Status das unidades após inserção:' as status,
    u.id,
    u.identificacao,
    u.tem_proprietario,
    u.tem_inquilino,
    p.nome as proprietario_nome
FROM public.unidades u
LEFT JOIN public.proprietarios p ON p.unidade_id = u.id AND p.ativo = true
WHERE u.id IN ('6c9197d6-8359-4f38-8e6c-8c93461fd63b', 'd400bc66-c270-41a3-bc6f-d04c48223411')
ORDER BY u.identificacao;

-- =====================================================
-- INSTRUÇÕES DE USO:
-- =====================================================
-- 1. Execute primeiro o script fix_unidades_add_tem_proprietario.sql
-- 2. Depois execute este script completo
-- 3. Os CPFs foram alterados para evitar conflitos:
--    - João Silva Santos: 111.222.333-44
--    - Maria Oliveira Costa: 555.666.777-88
-- 4. Verifique os resultados das consultas de validação