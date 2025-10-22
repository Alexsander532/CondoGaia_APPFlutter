-- =====================================================
-- INSERIR PROPRIETÁRIOS DE TESTE
-- =====================================================
-- Condomínio ID: 0ababacf-c924-4ee0-947c-850a0c6a46e3
-- Unidade 1 ID: 6c9197d6-8359-4f38-8e6c-8c93461fd63b
-- Unidade 2 ID: d400bc66-c270-41a3-bc6f-d04c48223411

-- =====================================================
-- PROPRIETÁRIO 1 - João Silva Santos
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
    '123.456.789-01',                        -- cpf_cnpj
    '01234-567',                             -- cep
    'Rua das Flores',                        -- endereco
    '123',                                   -- numero
    'Apto 45',                               -- complemento
    'Vila Madalena',                         -- bairro
    'São Paulo',                             -- cidade
    'SP',                                    -- estado
    '(11) 3333-4444',                        -- telefone
    '(11) 99999-1111',                       -- celular
    'joao.silva@email.com',                  -- email
    'Maria Silva Santos',                    -- conjuge
    NULL,                                    -- multiproprietarios
    'João Silva Santos, Maria Silva Santos', -- moradores
    true                                     -- ativo
);

-- =====================================================
-- PROPRIETÁRIO 2 - Maria Oliveira Costa
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
    '987.654.321-02',                        -- cpf_cnpj
    '01310-100',                             -- cep
    'Avenida Paulista',                      -- endereco
    '1000',                                  -- numero
    'Sala 501',                              -- complemento
    'Bela Vista',                            -- bairro
    'São Paulo',                             -- cidade
    'SP',                                    -- estado
    '(11) 2222-3333',                        -- telefone
    '(11) 88888-2222',                       -- celular
    'maria.oliveira@email.com',              -- email
    NULL,                                    -- conjuge (solteira)
    NULL,                                    -- multiproprietarios
    'Maria Oliveira Costa',                  -- moradores
    true                                     -- ativo
);

-- =====================================================
-- CONSULTAS DE VALIDAÇÃO
-- =====================================================

-- Verificar se os proprietários foram inseridos corretamente
SELECT 
    p.id,
    p.nome,
    p.cpf_cnpj,
    p.email,
    p.celular,
    p.endereco,
    p.numero,
    p.bairro,
    p.cidade,
    p.estado,
    p.conjuge,
    p.moradores,
    p.ativo,
    p.created_at,
    p.unidade_id
FROM public.proprietarios p
WHERE p.condominio_id = '0ababacf-c924-4ee0-947c-850a0c6a46e3'
ORDER BY p.created_at DESC;

-- Verificar a associação com as unidades
SELECT 
    p.nome as proprietario_nome,
    p.cpf_cnpj as proprietario_cpf,
    p.email as proprietario_email,
    p.unidade_id,
    u.identificacao as unidade_identificacao,
    u.numero_unidade,
    u.andar,
    u.tipo_unidade
FROM public.proprietarios p
LEFT JOIN public.unidades u ON p.unidade_id = u.id
WHERE p.condominio_id = '0ababacf-c924-4ee0-947c-850a0c6a46e3'
ORDER BY p.nome;

-- Contar total de proprietários no condomínio
SELECT 
    COUNT(*) as total_proprietarios,
    COUNT(CASE WHEN ativo = true THEN 1 END) as proprietarios_ativos
FROM public.proprietarios 
WHERE condominio_id = '0ababacf-c924-4ee0-947c-850a0c6a46e3';

-- =====================================================
-- INSTRUÇÕES DE USO:
-- =====================================================
-- 1. Execute os dois INSERTs para criar os proprietários
-- 2. Execute as consultas de validação para confirmar
-- 3. Os proprietários criados são:
--    - João Silva Santos (casado, com cônjuge)
--    - Maria Oliveira Costa (solteira)
-- 4. Ambos têm dados completos de endereço e contato
-- 5. CPFs em formato válido para passar na validação