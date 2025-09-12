-- Script de migração de dados: transferir relacionamentos do array para a nova estrutura
-- Migra dados do campo condominios_selecionados (array) para representante_id (FK)
-- Data: 15/01/2024

-- IMPORTANTE: Execute este script APÓS a migração 20240115000000_add_representante_id_to_condominios.sql

DO $$
DECLARE
    representante_record RECORD;
    condominio_id TEXT;
    total_representantes INTEGER := 0;
    total_condominios_migrados INTEGER := 0;
    condominios_com_conflito INTEGER := 0;
BEGIN
    -- Log início da migração
    RAISE NOTICE 'Iniciando migração de dados dos relacionamentos representante-condomínio...';
    
    -- Contar total de representantes
    SELECT COUNT(*) INTO total_representantes FROM public.representantes;
    RAISE NOTICE 'Total de representantes encontrados: %', total_representantes;
    
    -- Iterar sobre todos os representantes que têm condomínios selecionados
    FOR representante_record IN 
        SELECT id, nome_completo, condominios_selecionados 
        FROM public.representantes 
        WHERE condominios_selecionados IS NOT NULL 
        AND array_length(condominios_selecionados, 1) > 0
    LOOP
        RAISE NOTICE 'Processando representante: % (ID: %)', representante_record.nome_completo, representante_record.id;
        
        -- Iterar sobre cada condomínio no array
        FOREACH condominio_id IN ARRAY representante_record.condominios_selecionados
        LOOP
            -- Verificar se o condomínio existe
            IF EXISTS (SELECT 1 FROM public.condominios WHERE id::text = condominio_id) THEN
                -- Verificar se o condomínio já tem um representante atribuído
                IF EXISTS (SELECT 1 FROM public.condominios WHERE id::text = condominio_id AND representante_id IS NOT NULL) THEN
                    -- Condomínio já tem representante - registrar conflito
                    condominios_com_conflito := condominios_com_conflito + 1;
                    RAISE WARNING 'Conflito: Condomínio % já possui representante atribuído', condominio_id;
                ELSE
                    -- Atribuir o representante ao condomínio
                    UPDATE public.condominios 
                    SET representante_id = representante_record.id
                    WHERE id::text = condominio_id;
                    
                    total_condominios_migrados := total_condominios_migrados + 1;
                    RAISE NOTICE 'Condomínio % atribuído ao representante %', condominio_id, representante_record.nome_completo;
                END IF;
            ELSE
                RAISE WARNING 'Condomínio com ID % não encontrado na tabela condominios', condominio_id;
            END IF;
        END LOOP;
    END LOOP;
    
    -- Log final da migração
    RAISE NOTICE 'Migração concluída!';
    RAISE NOTICE 'Total de condomínios migrados: %', total_condominios_migrados;
    RAISE NOTICE 'Total de conflitos encontrados: %', condominios_com_conflito;
    
    -- Inserir log da migração
    INSERT INTO public.migration_log (migration_name, executed_at, description) 
    VALUES (
        '20240115000001_migrate_condominios_data',
        NOW(),
        FORMAT('Migração de dados concluída. Condomínios migrados: %s, Conflitos: %s', 
               total_condominios_migrados, condominios_com_conflito)
    ) ON CONFLICT DO NOTHING;
    
EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Erro durante a migração de dados: %', SQLERRM;
END $$;

-- Verificação pós-migração: mostrar estatísticas
DO $$
DECLARE
    condominios_com_representante INTEGER;
    condominios_sem_representante INTEGER;
    representantes_com_condominios INTEGER;
    representantes_sem_condominios INTEGER;
BEGIN
    -- Contar condomínios com e sem representante
    SELECT COUNT(*) INTO condominios_com_representante 
    FROM public.condominios WHERE representante_id IS NOT NULL;
    
    SELECT COUNT(*) INTO condominios_sem_representante 
    FROM public.condominios WHERE representante_id IS NULL;
    
    -- Contar representantes com e sem condomínios
    SELECT COUNT(DISTINCT representante_id) INTO representantes_com_condominios 
    FROM public.condominios WHERE representante_id IS NOT NULL;
    
    SELECT COUNT(*) INTO representantes_sem_condominios 
    FROM public.representantes r 
    WHERE NOT EXISTS (
        SELECT 1 FROM public.condominios c WHERE c.representante_id = r.id
    );
    
    -- Exibir estatísticas
    RAISE NOTICE '=== ESTATÍSTICAS PÓS-MIGRAÇÃO ===';
    RAISE NOTICE 'Condomínios com representante: %', condominios_com_representante;
    RAISE NOTICE 'Condomínios sem representante: %', condominios_sem_representante;
    RAISE NOTICE 'Representantes com condomínios: %', representantes_com_condominios;
    RAISE NOTICE 'Representantes sem condomínios: %', representantes_sem_condominios;
END $$;

-- Query para verificar a migração manualmente (comentada)
/*
-- Verificar representantes e seus condomínios após a migração
SELECT 
    r.nome_completo as representante,
    r.condominios_selecionados as array_antigo,
    COUNT(c.id) as condominios_atribuidos,
    STRING_AGG(c.nome_condominio, ', ') as nomes_condominios
FROM public.representantes r
LEFT JOIN public.condominios c ON c.representante_id = r.id
GROUP BY r.id, r.nome_completo, r.condominios_selecionados
ORDER BY r.nome_completo;
*/