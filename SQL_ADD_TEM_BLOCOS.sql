-- ============================================================================
-- SQL para adicionar coluna 'tem_blocos' à tabela 'condominios'
-- ============================================================================
-- Descrição: Esta coluna define se o condomínio utiliza blocos ou não
-- - tem_blocos = true: Exibe unidades agrupadas por blocos (Bloco A, B, C...)
-- - tem_blocos = false: Exibe apenas os números das unidades (101, 102, 103...)
-- 
-- Default: false - Mantém compatibilidade com condominios existentes
-- ============================================================================

-- 1. Adicionar coluna tem_blocos à tabela condominios
ALTER TABLE condominios
ADD COLUMN tem_blocos boolean DEFAULT false NOT NULL;

-- 2. Adicionar comentário na coluna (opcional, mas útil para documentação)
COMMENT ON COLUMN condominios.tem_blocos IS 'Define se o condomínio utiliza blocos (true) ou não (false)';

-- ============================================================================
-- Verificação (Execute para confirmar que a coluna foi criada)
-- ============================================================================
-- SELECT column_name, data_type, is_nullable, column_default
-- FROM information_schema.columns
-- WHERE table_name = 'condominios' AND column_name = 'tem_blocos';

-- ============================================================================
-- Script de rollback (caso precise reverter)
-- ============================================================================
-- ALTER TABLE condominios DROP COLUMN tem_blocos;
