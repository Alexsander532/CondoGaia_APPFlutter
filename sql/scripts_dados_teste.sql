-- =====================================================
-- SCRIPTS PARA INSERIR DADOS DE TESTE
-- =====================================================
-- Execute estes comandos em ordem para criar dados de teste
-- IMPORTANTE: Substitua 'SEU_CONDOMINIO_ID' pelo ID real do seu condomínio

-- =====================================================
-- 1. RECRIAR A TABELA UNIDADES (caso tenha sido excluída)
-- =====================================================

-- Primeiro, vamos recriar a tabela unidades baseada na estrutura existente
CREATE TABLE IF NOT EXISTS unidades (
    -- Chave primária
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Relacionamentos
    condominio_id UUID NOT NULL REFERENCES condominios(id) ON DELETE CASCADE,
    bloco_id UUID NOT NULL REFERENCES blocos(id) ON DELETE CASCADE,
    
    -- Identificação da unidade
    identificacao VARCHAR(20) NOT NULL, -- Ex: 101-A, 102-B
    numero_unidade VARCHAR(10) NOT NULL, -- Ex: 101, 102
    andar INTEGER DEFAULT NULL,
    posicao_andar VARCHAR(10) DEFAULT NULL, -- A, B, C, etc.
    
    -- Características da unidade
    tipo_unidade VARCHAR(50) DEFAULT 'apartamento',
    area_privativa DECIMAL(8,2) DEFAULT NULL,
    area_total DECIMAL(8,2) DEFAULT NULL,
    quartos INTEGER DEFAULT NULL,
    banheiros INTEGER DEFAULT NULL,
    vagas_garagem INTEGER DEFAULT 0,
    
    -- Relacionamentos com pessoas (FKs opcionais)
    proprietario_id UUID DEFAULT NULL REFERENCES proprietarios(id) ON DELETE SET NULL,
    inquilino_id UUID DEFAULT NULL REFERENCES inquilinos(id) ON DELETE SET NULL,
    imobiliaria_id UUID DEFAULT NULL REFERENCES imobiliarias(id) ON DELETE SET NULL,
    
    -- Informações financeiras
    valor_iptu DECIMAL(10,2) DEFAULT NULL,
    valor_condominio DECIMAL(10,2) DEFAULT NULL,
    valor_aluguel DECIMAL(10,2) DEFAULT NULL,
    
    -- Status da unidade
    status_ocupacao VARCHAR(20) DEFAULT 'vago',
    tem_inquilino BOOLEAN DEFAULT false,
    tem_proprietario BOOLEAN DEFAULT false,
    
    -- Observações
    observacoes TEXT DEFAULT NULL,
    notas_internas TEXT DEFAULT NULL,
    
    -- Status e controle
    ativo BOOLEAN NOT NULL DEFAULT true,
    data_importacao TIMESTAMP WITH TIME ZONE DEFAULT NULL,
    origem_dados VARCHAR(20) DEFAULT 'manual',
    
    -- Metadados
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    -- Constraints
    UNIQUE(condominio_id, identificacao),
    UNIQUE(bloco_id, numero_unidade)
);

-- =====================================================
-- 2. INSERIR PROPRIETÁRIOS DE TESTE
-- =====================================================

-- PROPRIETÁRIO 1
INSERT INTO proprietarios (
    condominio_id,
    nome,
    cpf,
    email,
    telefone,
    celular,
    endereco_completo,
    cep,
    cidade,
    estado,
    profissao,
    renda_mensal,
    estado_civil,
    aceita_email,
    aceita_sms,
    aceita_whatsapp,
    ativo,
    origem_dados
) VALUES (
    'SEU_CONDOMINIO_ID', -- SUBSTITUA pelo ID real do seu condomínio
    'João Silva Santos',
    '123.456.789-01',
    'joao.silva@email.com',
    '(11) 3333-4444',
    '(11) 99999-1111',
    'Rua das Flores, 123, Apto 45',
    '01234-567',
    'São Paulo',
    'SP',
    'Engenheiro',
    8500.00,
    'casado',
    true,
    true,
    true,
    true,
    'manual'
);

-- PROPRIETÁRIO 2
INSERT INTO proprietarios (
    condominio_id,
    nome,
    cpf,
    email,
    telefone,
    celular,
    endereco_completo,
    cep,
    cidade,
    estado,
    profissao,
    renda_mensal,
    estado_civil,
    aceita_email,
    aceita_sms,
    aceita_whatsapp,
    ativo,
    origem_dados
) VALUES (
    'SEU_CONDOMINIO_ID', -- SUBSTITUA pelo ID real do seu condomínio
    'Maria Oliveira Costa',
    '987.654.321-02',
    'maria.oliveira@email.com',
    '(11) 2222-3333',
    '(11) 88888-2222',
    'Avenida Paulista, 1000, Sala 501',
    '01310-100',
    'São Paulo',
    'SP',
    'Advogada',
    12000.00,
    'solteiro',
    true,
    false,
    true,
    true,
    'manual'
);

-- =====================================================
-- 3. INSERIR INQUILINOS DE TESTE
-- =====================================================

-- INQUILINO 1
INSERT INTO inquilinos (
    condominio_id,
    nome,
    cpf,
    email,
    telefone,
    celular,
    endereco_anterior,
    cep_anterior,
    cidade_anterior,
    estado_anterior,
    profissao,
    empresa,
    renda_mensal,
    data_inicio_contrato,
    data_fim_contrato,
    valor_aluguel,
    status_contrato,
    dia_vencimento,
    aceita_email,
    aceita_sms,
    aceita_whatsapp,
    ativo,
    origem_dados
) VALUES (
    'SEU_CONDOMINIO_ID', -- SUBSTITUA pelo ID real do seu condomínio
    'Carlos Pereira Lima',
    '456.789.123-03',
    'carlos.pereira@email.com',
    '(11) 4444-5555',
    '(11) 77777-3333',
    'Rua dos Pinheiros, 456, Apto 78',
    '05422-001',
    'São Paulo',
    'SP',
    'Analista de Sistemas',
    'Tech Solutions Ltda',
    6500.00,
    '2024-01-15',
    '2025-01-14',
    2800.00,
    'ativo',
    10,
    true,
    true,
    true,
    true,
    'manual'
);

-- INQUILINO 2
INSERT INTO inquilinos (
    condominio_id,
    nome,
    cpf,
    email,
    telefone,
    celular,
    endereco_anterior,
    cep_anterior,
    cidade_anterior,
    estado_anterior,
    profissao,
    empresa,
    renda_mensal,
    data_inicio_contrato,
    data_fim_contrato,
    valor_aluguel,
    status_contrato,
    dia_vencimento,
    aceita_email,
    aceita_sms,
    aceita_whatsapp,
    ativo,
    origem_dados
) VALUES (
    'SEU_CONDOMINIO_ID', -- SUBSTITUA pelo ID real do seu condomínio
    'Ana Paula Rodrigues',
    '789.123.456-04',
    'ana.paula@email.com',
    '(11) 5555-6666',
    '(11) 66666-4444',
    'Alameda Santos, 789, Apto 12',
    '01419-001',
    'São Paulo',
    'SP',
    'Designer Gráfica',
    'Creative Agency',
    4800.00,
    '2024-02-01',
    '2025-01-31',
    2200.00,
    'ativo',
    5,
    true,
    false,
    true,
    true,
    'manual'
);

-- =====================================================
-- 4. INSERIR UNIDADES DE TESTE
-- =====================================================

-- UNIDADE 1 - Associada ao Proprietário 1
INSERT INTO unidades (
    condominio_id,
    bloco_id,
    identificacao,
    numero_unidade,
    andar,
    posicao_andar,
    tipo_unidade,
    area_privativa,
    area_total,
    quartos,
    banheiros,
    vagas_garagem,
    proprietario_id,
    valor_iptu,
    valor_condominio,
    status_ocupacao,
    tem_proprietario,
    tem_inquilino,
    observacoes,
    ativo,
    origem_dados
) VALUES (
    'SEU_CONDOMINIO_ID', -- SUBSTITUA pelo ID real do seu condomínio
    'SEU_BLOCO_ID', -- SUBSTITUA pelo ID real de um bloco
    '101-A',
    '101',
    1,
    'A',
    'apartamento',
    85.50,
    95.00,
    3,
    2,
    1,
    (SELECT id FROM proprietarios WHERE cpf = '123.456.789-01' AND condominio_id = 'SEU_CONDOMINIO_ID'),
    450.00,
    380.00,
    'ocupado_proprietario',
    true,
    false,
    'Unidade de teste - Proprietário João Silva',
    true,
    'manual'
);

-- UNIDADE 2 - Associada ao Inquilino 1
INSERT INTO unidades (
    condominio_id,
    bloco_id,
    identificacao,
    numero_unidade,
    andar,
    posicao_andar,
    tipo_unidade,
    area_privativa,
    area_total,
    quartos,
    banheiros,
    vagas_garagem,
    inquilino_id,
    valor_iptu,
    valor_condominio,
    valor_aluguel,
    status_ocupacao,
    tem_proprietario,
    tem_inquilino,
    observacoes,
    ativo,
    origem_dados
) VALUES (
    'SEU_CONDOMINIO_ID', -- SUBSTITUA pelo ID real do seu condomínio
    'SEU_BLOCO_ID', -- SUBSTITUA pelo ID real de um bloco
    '102-A',
    '102',
    1,
    'A',
    'apartamento',
    78.00,
    88.50,
    2,
    2,
    1,
    (SELECT id FROM inquilinos WHERE cpf = '456.789.123-03' AND condominio_id = 'SEU_CONDOMINIO_ID'),
    420.00,
    380.00,
    2800.00,
    'ocupado_inquilino',
    false,
    true,
    'Unidade de teste - Inquilino Carlos Pereira',
    true,
    'manual'
);

-- =====================================================
-- 5. SCRIPTS DE CONSULTA PARA VALIDAÇÃO
-- =====================================================

-- Consultar proprietários inseridos
SELECT 
    id,
    nome,
    cpf,
    email,
    celular,
    profissao,
    renda_mensal,
    created_at
FROM proprietarios 
WHERE condominio_id = 'SEU_CONDOMINIO_ID'
AND origem_dados = 'manual'
ORDER BY nome;

-- Consultar inquilinos inseridos
SELECT 
    id,
    nome,
    cpf,
    email,
    celular,
    profissao,
    empresa,
    valor_aluguel,
    status_contrato,
    created_at
FROM inquilinos 
WHERE condominio_id = 'SEU_CONDOMINIO_ID'
AND origem_dados = 'manual'
ORDER BY nome;

-- Consultar unidades inseridas com relacionamentos
SELECT 
    u.id,
    u.identificacao,
    u.numero_unidade,
    u.tipo_unidade,
    u.area_privativa,
    u.quartos,
    u.banheiros,
    u.status_ocupacao,
    p.nome as proprietario_nome,
    p.cpf as proprietario_cpf,
    i.nome as inquilino_nome,
    i.cpf as inquilino_cpf,
    u.created_at
FROM unidades u
LEFT JOIN proprietarios p ON u.proprietario_id = p.id
LEFT JOIN inquilinos i ON u.inquilino_id = i.id
WHERE u.condominio_id = 'SEU_CONDOMINIO_ID'
AND u.origem_dados = 'manual'
ORDER BY u.identificacao;

-- =====================================================
-- 6. COMANDOS PARA OBTER IDs NECESSÁRIOS
-- =====================================================

-- Para obter o ID do seu condomínio
SELECT id, nome_condominio, cnpj 
FROM condominios 
ORDER BY created_at DESC;

-- Para obter o ID de um bloco
SELECT id, letra, nome, total_unidades 
FROM blocos 
WHERE condominio_id = 'SEU_CONDOMINIO_ID'
ORDER BY ordem_exibicao;

-- =====================================================
-- INSTRUÇÕES DE USO:
-- =====================================================
-- 1. Execute primeiro: SELECT id FROM condominios; para obter o ID do condomínio
-- 2. Execute: SELECT id FROM blocos WHERE condominio_id = 'ID_OBTIDO'; para obter o ID do bloco
-- 3. Substitua 'SEU_CONDOMINIO_ID' e 'SEU_BLOCO_ID' pelos valores reais
-- 4. Execute os INSERTs na ordem: proprietários, inquilinos, unidades
-- 5. Execute as consultas de validação para confirmar os dados