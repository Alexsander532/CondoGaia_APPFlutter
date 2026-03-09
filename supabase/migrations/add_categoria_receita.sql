-- Script para adicionar `categoria_id` e `subcategoria_id` na tabela `receitas`

ALTER TABLE receitas
ADD COLUMN categoria_id UUID REFERENCES categorias_financeiras(id) ON DELETE SET NULL,
ADD COLUMN subcategoria_id UUID REFERENCES subcategorias_financeiras(id) ON DELETE SET NULL;

-- Criando índices para melhorar performance
CREATE INDEX IF NOT EXISTS idx_receitas_categoria_id ON receitas(categoria_id);
CREATE INDEX IF NOT EXISTS idx_receitas_subcategoria_id ON receitas(subcategoria_id);
