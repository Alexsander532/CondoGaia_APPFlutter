-- Migration: Add locacao_url column to ambientes table
-- Date: 2025-11-20
-- Description: Add URL field for rental agreement PDF in environments

ALTER TABLE ambientes
ADD COLUMN locacao_url TEXT NULL DEFAULT NULL;

-- Create index for locacao_url
CREATE INDEX idx_ambientes_locacao_url ON ambientes(locacao_url);

-- Update migration log
INSERT INTO migration_log (name, executed_at) 
VALUES ('22_add_locacao_url_to_ambientes', NOW());
