-- Adiciona coluna 'ativo' na tabela condominios
-- Esta coluna indica se o condomínio está ativo (true) ou desativado (false)

-- Adicionar a coluna 'ativo' do tipo boolean com valor padrão true
ALTER TABLE condominios 
ADD COLUMN ativo BOOLEAN NOT NULL DEFAULT true;

-- Atualizar todos os registros existentes para ativo = true
UPDATE condominios 
SET ativo = true 
WHERE ativo IS NULL;

-- Comentário sobre a coluna
COMMENT ON COLUMN condominios.ativo IS 'Indica se o condomínio está ativo (true) ou desativado (false)';