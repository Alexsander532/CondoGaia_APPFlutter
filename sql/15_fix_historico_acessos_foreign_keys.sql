-- =====================================================
-- MIGRAÇÃO: Corrigir Foreign Keys da Tabela historico_acessos
-- PROPÓSITO: Permitir que visitantes da portaria também sejam registrados no histórico
-- DATA: 2024
-- =====================================================

-- Primeiro, vamos remover a constraint existente
ALTER TABLE historico_acessos 
DROP CONSTRAINT IF EXISTS historico_acessos_visitante_id_fkey;

-- Agora vamos adicionar duas novas colunas para identificar o tipo de visitante
ALTER TABLE historico_acessos 
ADD COLUMN IF NOT EXISTS tipo_visitante VARCHAR(20) DEFAULT 'inquilino' 
CHECK (tipo_visitante IN ('inquilino', 'visitante_portaria'));

-- Atualizar registros existentes para definir o tipo como 'inquilino'
UPDATE historico_acessos 
SET tipo_visitante = 'inquilino' 
WHERE tipo_visitante IS NULL;

-- Criar função para validar a foreign key baseada no tipo
CREATE OR REPLACE FUNCTION validate_visitante_foreign_key()
RETURNS TRIGGER AS $$
BEGIN
    -- Se for inquilino, verificar na tabela autorizados_inquilinos
    IF NEW.tipo_visitante = 'inquilino' THEN
        IF NOT EXISTS (
            SELECT 1 FROM autorizados_inquilinos 
            WHERE id = NEW.visitante_id
        ) THEN
            RAISE EXCEPTION 'visitante_id % não existe na tabela autorizados_inquilinos', NEW.visitante_id;
        END IF;
    -- Se for visitante da portaria, verificar na tabela autorizados_visitantes_portaria_representante
    ELSIF NEW.tipo_visitante = 'visitante_portaria' THEN
        IF NOT EXISTS (
            SELECT 1 FROM autorizados_visitantes_portaria_representante 
            WHERE id = NEW.visitante_id
        ) THEN
            RAISE EXCEPTION 'visitante_id % não existe na tabela autorizados_visitantes_portaria_representante', NEW.visitante_id;
        END IF;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Criar trigger para validar a foreign key
DROP TRIGGER IF EXISTS validate_visitante_fk_trigger ON historico_acessos;
CREATE TRIGGER validate_visitante_fk_trigger
    BEFORE INSERT OR UPDATE ON historico_acessos
    FOR EACH ROW
    EXECUTE FUNCTION validate_visitante_foreign_key();

-- Adicionar índice para melhor performance
CREATE INDEX IF NOT EXISTS idx_historico_acessos_tipo_visitante 
ON historico_acessos(tipo_visitante);

-- Comentários
COMMENT ON COLUMN historico_acessos.tipo_visitante IS 'Tipo do visitante: inquilino ou visitante_portaria';
COMMENT ON FUNCTION validate_visitante_foreign_key() IS 'Valida a foreign key baseada no tipo de visitante';

-- =====================================================
-- VERIFICAÇÕES DE INTEGRIDADE
-- =====================================================

-- Verificar se todos os registros existentes são válidos
DO $$
DECLARE
    invalid_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO invalid_count
    FROM historico_acessos h
    WHERE NOT EXISTS (
        SELECT 1 FROM autorizados_inquilinos ai 
        WHERE ai.id = h.visitante_id
    );
    
    IF invalid_count > 0 THEN
        RAISE NOTICE 'Atenção: % registros no histórico não possuem visitante_id válido na tabela autorizados_inquilinos', invalid_count;
    ELSE
        RAISE NOTICE 'Todos os registros existentes no histórico são válidos';
    END IF;
END $$;