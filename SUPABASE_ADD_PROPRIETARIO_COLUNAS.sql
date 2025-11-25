-- ============================================================================
-- SQL: ADICIONAR COLUNAS agrupar_boletos E matricula_imovel NA TABELA proprietarios
-- ============================================================================
-- Estas colunas armazenam as opções de "Agrupar boletos" e "Matrícula do Imóvel"
-- Padrão: false (Não selecionado)

-- Adicionar coluna agrupar_boletos
ALTER TABLE public.proprietarios
ADD COLUMN agrupar_boletos BOOLEAN DEFAULT false;

COMMENT ON COLUMN public.proprietarios.agrupar_boletos IS 
'Indica se os boletos devem ser agrupados. Padrão: false (Não)';

-- Adicionar coluna matricula_imovel
ALTER TABLE public.proprietarios
ADD COLUMN matricula_imovel BOOLEAN DEFAULT false;

COMMENT ON COLUMN public.proprietarios.matricula_imovel IS 
'Indica se há matrícula do imóvel para fazer upload. Padrão: false (Não)';

-- ============================================================================
-- COMO EXECUTAR NO SUPABASE:
-- ============================================================================

/*
1. Abra: https://supabase.com
2. Selecione seu projeto CondoGaia
3. Menu esquerdo: SQL Editor
4. Clique em: New Query (ou + New Query)
5. Cole o comando acima (linhas 1-20)
6. Clique em: [Run] ou pressione [Ctrl + Enter]
7. Veja a mensagem: "Success. No rows returned."
8. Pronto! Colunas criadas com padrão false ✅
*/

-- ============================================================================
-- VERIFICAR SE AS COLUNAS FORAM CRIADAS:
-- ============================================================================

/*
Execute este comando para confirmar:

SELECT column_name, data_type, column_default, is_nullable 
FROM information_schema.columns 
WHERE table_name = 'proprietarios' 
AND column_name IN ('agrupar_boletos', 'matricula_imovel')
ORDER BY column_name;

Resultado esperado:
┌──────────────────┬───────────┬────────────────┬─────────────┐
│ column_name      │ data_type │ column_default │ is_nullable │
├──────────────────┼───────────┼────────────────┼─────────────┤
│ agrupar_boletos  │ boolean   │ false          │ true        │
│ matricula_imovel │ boolean   │ false          │ true        │
└──────────────────┴───────────┴────────────────┴─────────────┘
*/
