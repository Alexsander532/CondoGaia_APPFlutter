-- ============================================================================
-- CORREÇÃO: Ajustar CONSTRAINT para permitir múltiplos blocos com mesmo número
-- ============================================================================
-- PROBLEMA: O índice único idx_unidades_numero_condominio força unicidade 
-- apenas por (numero, condominio_id), impedindo criar unidade 101 em bloco B
-- se já existe 101 em bloco A
-- 
-- SOLUÇÃO: Remover o índice antigo e criar novo com (bloco, numero, condominio_id)
-- ============================================================================

-- PASSO 1: Remover o índice UNIQUE antigo (que não inclui bloco)
DROP INDEX IF EXISTS public.idx_unidades_numero_condominio CASCADE;

-- PASSO 2: Criar novo índice UNIQUE que inclui bloco
-- Agora cada bloco pode ter seu próprio número 101, 102, etc.
CREATE UNIQUE INDEX IF NOT EXISTS idx_unidades_numero_bloco_condominio 
ON public.unidades USING btree (bloco, numero, condominio_id) 
TABLESPACE pg_default
WHERE (ativo = true);

-- PASSO 3: Manter índice simples por bloco para queries rápidas
CREATE INDEX IF NOT EXISTS idx_unidades_bloco 
ON public.unidades USING btree (bloco) 
TABLESPACE pg_default
WHERE (ativo = true);

-- ============================================================================
-- COMO EXECUTAR NO SUPABASE:
-- ============================================================================

/*
1. Abra: https://supabase.com
2. Selecione seu projeto CondoGaia
3. Menu esquerdo: SQL Editor
4. Clique em: New Query (ou + New Query)
5. Cole os comandos acima (linhas 1-35)
6. Clique em: [Run] ou pressione [Ctrl + Enter]
7. Veja a mensagem: "Success. No rows returned."
8. Pronto! Constraint corrigida ✅

Agora você conseguirá criar:
- Unidade 101 no Bloco A
- Unidade 101 no Bloco B
- Unidade 101 no Bloco C
- Etc...
*/

-- ============================================================================
-- VERIFICAÇÃO: Confirmar que o índice foi criado corretamente
-- ============================================================================

/*
Execute este comando para confirmar:

SELECT 
    indexname,
    indexdef
FROM pg_indexes
WHERE tablename = 'unidades'
AND indexname LIKE '%numero%'
ORDER BY indexname;

Resultado esperado:
- idx_unidades_numero_bloco_condominio (UNIQUE, inclui numero, bloco, condominio_id)
- idx_unidades_numero_condominio (deve estar REMOVIDO)
*/

-- ============================================================================
-- TESTE: Tentar criar unidades com mesmo número em blocos diferentes
-- ============================================================================

/*
Após aplicar a correção, teste no app criando:
1. Unidade 101 no Bloco A → ✅ Deve funcionar
2. Unidade 101 no Bloco B → ✅ Deve funcionar (agora sem erro!)
3. Unidade 102 no Bloco A → ✅ Deve funcionar

Se tentar criar 101 no mesmo Bloco A novamente → ❌ Corretamente rejeitado
*/
