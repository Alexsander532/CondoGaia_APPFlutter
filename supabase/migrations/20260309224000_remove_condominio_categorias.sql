-- Script para remover `condominio_id` da tabela `categorias_financeiras`

ALTER TABLE categorias_financeiras
DROP COLUMN condominio_id;
