-- =====================================================
-- SCRIPT DE TESTE PARA VALIDAR O SISTEMA COMPLETO
-- =====================================================
-- Execute este script APÓS executar todas as migrações
-- para verificar se tudo está funcionando corretamente

-- 1. CRIAR UM CONDOMÍNIO DE TESTE
-- =====================================================
-- Primeiro, você precisa ter um condomínio criado na tabela condominios
-- (isso deve ser feito pelo seu app Flutter)

-- Exemplo de inserção de condomínio (substitua pelos dados reais):
-- INSERT INTO condominios (id, nome, endereco, cidade, estado, cep, ativo)
-- VALUES (
--     gen_random_uuid(),
--     'Condomínio Teste',
--     'Rua das Flores, 123',
--     'São Paulo',
--     'SP',
--     '01234-567',
--     true
-- );

-- 2. CONFIGURAR O CONDOMÍNIO AUTOMATICAMENTE
-- =====================================================
-- Substitua 'SEU-UUID-DO-CONDOMINIO' pelo ID real do seu condomínio
-- Este comando vai criar:
-- - Configuração do condomínio
-- - 3 blocos (A, B, C)
-- - 8 unidades por bloco (total: 24 unidades)

-- SELECT setup_condominio_completo('SEU-UUID-DO-CONDOMINIO', 3, 8, true);

-- 3. VERIFICAR SE TUDO FOI CRIADO
-- =====================================================

-- Verificar configuração criada:
-- SELECT * FROM configuracao_condominio WHERE condominio_id = 'SEU-UUID-DO-CONDOMINIO';

-- Verificar blocos criados:
-- SELECT * FROM blocos WHERE condominio_id = 'SEU-UUID-DO-CONDOMINIO' ORDER BY ordem;

-- Verificar unidades criadas:
-- SELECT * FROM unidades WHERE condominio_id = 'SEU-UUID-DO-CONDOMINIO' ORDER BY bloco_id, numero::INTEGER;

-- 4. TESTAR A VIEW DE UNIDADES COMPLETAS
-- =====================================================
-- SELECT * FROM vw_unidades_completas WHERE condominio_id = 'SEU-UUID-DO-CONDOMINIO';

-- 5. TESTAR FUNÇÕES DE CONSULTA
-- =====================================================

-- Listar todas as unidades organizadas por bloco:
-- SELECT listar_unidades_condominio('SEU-UUID-DO-CONDOMINIO');

-- Ver estatísticas do condomínio:
-- SELECT estatisticas_condominio('SEU-UUID-DO-CONDOMINIO');

-- Buscar dados completos de uma unidade específica:
-- SELECT buscar_dados_completos_unidade('UUID-DE-UMA-UNIDADE');

-- 6. TESTAR INSERÇÃO DE PROPRIETÁRIO
-- =====================================================
-- INSERT INTO proprietarios (
--     condominio_id,
--     unidade_id,
--     nome,
--     cpf_cnpj,
--     email,
--     telefone,
--     principal,
--     ativo
-- ) VALUES (
--     'SEU-UUID-DO-CONDOMINIO',
--     'UUID-DE-UMA-UNIDADE',
--     'João Silva',
--     '123.456.789-00',
--     'joao@email.com',
--     '(11) 99999-9999',
--     true,
--     true
-- );

-- 7. VERIFICAR ATUALIZAÇÃO AUTOMÁTICA DOS FLAGS
-- =====================================================
-- Após inserir um proprietário, a unidade deve ter tem_proprietario = true
-- SELECT * FROM unidades WHERE id = 'UUID-DE-UMA-UNIDADE';

-- =====================================================
-- RESULTADOS ESPERADOS
-- =====================================================
-- ✅ Configuração do condomínio criada
-- ✅ 3 blocos criados (A, B, C)
-- ✅ 24 unidades criadas (8 por bloco)
-- ✅ View vw_unidades_completas funcionando
-- ✅ Todas as funções retornando dados JSON
-- ✅ Triggers atualizando flags automaticamente
-- ✅ Políticas RLS ativas e funcionando

-- =====================================================
-- PRÓXIMOS PASSOS APÓS OS TESTES
-- =====================================================
-- 1. Atualizar modelos Dart
-- 2. Implementar consultas no Flutter
-- 3. Testar integração completa
-- 4. Implementar tela de unidade morador