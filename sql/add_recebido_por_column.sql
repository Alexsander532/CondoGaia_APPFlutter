-- =====================================================
-- ADICIONAR COLUNA recebido_por NA TABELA encomendas
-- PROPÓSITO: Registrar quem recebeu a encomenda
-- =====================================================

-- Adicionar a coluna recebido_por
ALTER TABLE encomendas 
ADD COLUMN IF NOT EXISTS recebido_por TEXT DEFAULT NULL;

-- Adicionar comentário para documentação
COMMENT ON COLUMN encomendas.recebido_por IS 'Nome da pessoa que recebeu a encomenda';

-- Criar índice para consultas por quem recebeu
CREATE INDEX IF NOT EXISTS idx_encomendas_recebido_por ON encomendas(recebido_por);

-- =====================================================
-- MENSAGEM DE SUCESSO
-- =====================================================

DO $$
BEGIN
    RAISE NOTICE 'Coluna recebido_por adicionada com sucesso na tabela encomendas!';
    RAISE NOTICE 'Índice criado para otimização de consultas por recebido_por';
END $$;