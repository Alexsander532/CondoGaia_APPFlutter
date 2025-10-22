-- =====================================================
-- INSERIR INQUILINOS DE TESTE
-- =====================================================
-- Condomínio ID: 0ababacf-c924-4ee0-947c-850a0c6a46e3
-- Unidade 1 ID: 6c9197d6-8359-4f38-8e6c-8c93461fd63b (mesma do proprietário João)
-- Unidade 2 ID: d400bc66-c270-41a3-bc6f-d04c48223411 (mesma do proprietário Maria)

-- =====================================================
-- VERIFICAR SE JÁ EXISTEM INQUILINOS COM ESSES CPFs/EMAILS
-- =====================================================
SELECT 
    'Verificando CPFs e emails existentes...' as status,
    COUNT(*) as total_existentes
FROM public.inquilinos 
WHERE condominio_id = '0ababacf-c924-4ee0-947c-850a0c6a46e3' 
AND (cpf_cnpj IN ('222.333.444-55', '666.777.888-99') 
     OR email IN ('carlos.pereira@email.com', 'ana.rodrigues@email.com'));

-- =====================================================
-- INQUILINO 1 - Carlos Pereira Lima
-- =====================================================
INSERT INTO public.inquilinos (
    condominio_id,
    unidade_id,
    nome,
    cpf_cnpj,
    cep,
    endereco,
    numero,
    bairro,
    cidade,
    estado,
    telefone,
    celular,
    email,
    conjuge,
    multiproprietarios,
    moradores,
    receber_boleto_email,
    controle_locacao,
    ativo
) VALUES (
    '0ababacf-c924-4ee0-947c-850a0c6a46e3',  -- condominio_id
    '6c9197d6-8359-4f38-8e6c-8c93461fd63b',  -- unidade_id (mesma do proprietário João)
    'Carlos Pereira Lima',                    -- nome
    '222.333.444-55',                        -- cpf_cnpj (ÚNICO)
    '02468-135',                             -- cep
    'Rua dos Inquilinos',                    -- endereco
    '456',                                   -- numero
    'Apto 78',                               -- complemento (usando campo numero)
    'Jardins',                               -- bairro
    'São Paulo',                             -- cidade
    'SP',                                    -- estado
    '(11) 4444-5555',                        -- telefone
    '(11) 77777-3333',                       -- celular
    'carlos.pereira@email.com',              -- email (ÚNICO)
    'Fernanda Pereira Lima',                 -- conjuge
    NULL,                                    -- multiproprietarios
    'Carlos Pereira Lima, Fernanda Pereira Lima', -- moradores
    true,                                    -- receber_boleto_email
    true,                                    -- controle_locacao
    true                                     -- ativo
);

-- =====================================================
-- INQUILINO 2 - Ana Paula Rodrigues
-- =====================================================
INSERT INTO public.inquilinos (
    condominio_id,
    unidade_id,
    nome,
    cpf_cnpj,
    cep,
    endereco,
    numero,
    bairro,
    cidade,
    estado,
    telefone,
    celular,
    email,
    conjuge,
    multiproprietarios,
    moradores,
    receber_boleto_email,
    controle_locacao,
    ativo
) VALUES (
    '0ababacf-c924-4ee0-947c-850a0c6a46e3',  -- condominio_id
    'd400bc66-c270-41a3-bc6f-d04c48223411',  -- unidade_id (mesma do proprietário Maria)
    'Ana Paula Rodrigues',                    -- nome
    '666.777.888-99',                        -- cpf_cnpj (ÚNICO)
    '13579-246',                             -- cep
    'Avenida dos Locatários',                -- endereco
    '789',                                   -- numero
    'Casa 15',                               -- complemento (usando campo numero)
    'Moema',                                 -- bairro
    'São Paulo',                             -- cidade
    'SP',                                    -- estado
    '(11) 5555-6666',                        -- telefone
    '(11) 66666-4444',                       -- celular
    'ana.rodrigues@email.com',               -- email (ÚNICO)
    'Roberto Rodrigues Silva',               -- conjuge
    NULL,                                    -- multiproprietarios
    'Ana Paula Rodrigues, Roberto Rodrigues Silva', -- moradores
    true,                                    -- receber_boleto_email
    true,                                    -- controle_locacao
    true                                     -- ativo
);

-- =====================================================
-- VALIDAÇÃO DOS DADOS INSERIDOS
-- =====================================================
SELECT 
    'Inquilinos inseridos com sucesso!' as status,
    i.id,
    i.nome,
    i.cpf_cnpj,
    i.email,
    i.celular,
    i.unidade_id,
    i.receber_boleto_email,
    i.controle_locacao,
    i.ativo
FROM public.inquilinos i
WHERE i.condominio_id = '0ababacf-c924-4ee0-947c-850a0c6a46e3'
AND i.cpf_cnpj IN ('222.333.444-55', '666.777.888-99')
ORDER BY i.nome;

-- =====================================================
-- VERIFICAR A ASSOCIAÇÃO COM AS UNIDADES
-- =====================================================
SELECT 
    'Associação inquilinos x unidades:' as status,
    i.nome as inquilino_nome,
    i.cpf_cnpj as inquilino_cpf,
    i.email as inquilino_email,
    i.unidade_id,
    u.identificacao as unidade_identificacao,
    u.numero_unidade,
    u.andar,
    u.tipo_unidade,
    u.tem_inquilino
FROM public.inquilinos i
LEFT JOIN public.unidades u ON i.unidade_id = u.id
WHERE i.condominio_id = '0ababacf-c924-4ee0-947c-850a0c6a46e3'
AND i.cpf_cnpj IN ('222.333.444-55', '666.777.888-99')
ORDER BY i.nome;

-- =====================================================
-- VERIFICAR STATUS DAS UNIDADES (PROPRIETÁRIOS E INQUILINOS)
-- =====================================================
SELECT 
    'Status completo das unidades:' as status,
    u.id,
    u.identificacao,
    u.tem_proprietario,
    u.tem_inquilino,
    p.nome as proprietario_nome,
    i.nome as inquilino_nome
FROM public.unidades u
LEFT JOIN public.proprietarios p ON p.unidade_id = u.id AND p.ativo = true
LEFT JOIN public.inquilinos i ON i.unidade_id = u.id AND i.ativo = true
WHERE u.id IN ('6c9197d6-8359-4f38-8e6c-8c93461fd63b', 'd400bc66-c270-41a3-bc6f-d04c48223411')
ORDER BY u.identificacao;

-- =====================================================
-- CONTAR TOTAIS NO CONDOMÍNIO
-- =====================================================
SELECT 
    'Totais no condomínio:' as status,
    COUNT(CASE WHEN p.id IS NOT NULL THEN 1 END) as total_proprietarios,
    COUNT(CASE WHEN i.id IS NOT NULL THEN 1 END) as total_inquilinos,
    COUNT(CASE WHEN p.ativo = true THEN 1 END) as proprietarios_ativos,
    COUNT(CASE WHEN i.ativo = true THEN 1 END) as inquilinos_ativos
FROM public.unidades u
LEFT JOIN public.proprietarios p ON p.unidade_id = u.id
LEFT JOIN public.inquilinos i ON i.unidade_id = u.id
WHERE u.condominio_id = '0ababacf-c924-4ee0-947c-850a0c6a46e3';

-- =====================================================
-- INSTRUÇÕES DE USO:
-- =====================================================
-- 1. Execute primeiro os scripts de correção das unidades e proprietários
-- 2. Depois execute este script completo
-- 3. Os inquilinos foram criados com dados únicos:
--    - Carlos Pereira Lima: CPF 222.333.444-55, Email carlos.pereira@email.com
--    - Ana Paula Rodrigues: CPF 666.777.888-99, Email ana.rodrigues@email.com
-- 4. Cada inquilino está associado à mesma unidade do respectivo proprietário
-- 5. Verifique os resultados das consultas de validação
-- 6. O trigger deve atualizar automaticamente o campo tem_inquilino nas unidades