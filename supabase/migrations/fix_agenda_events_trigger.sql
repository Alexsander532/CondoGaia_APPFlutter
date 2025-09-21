-- Migração para corrigir o trigger da tabela eventos_agenda_representante
-- Data: 16/01/2025
-- Descrição: Corrige o trigger que estava tentando usar 'updated_at' em vez de 'atualizado_em'

-- Primeiro, remover o trigger existente que está causando erro
DROP TRIGGER IF EXISTS update_eventos_agenda_atualizado_em ON public.eventos_agenda_representante;

-- Criar uma função específica para atualizar o campo atualizado_em
CREATE OR REPLACE FUNCTION update_atualizado_em_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.atualizado_em = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Criar o novo trigger com a função correta
CREATE TRIGGER update_eventos_agenda_atualizado_em
    BEFORE UPDATE ON public.eventos_agenda_representante
    FOR EACH ROW
    EXECUTE FUNCTION update_atualizado_em_column();

-- Log da migração
INSERT INTO public.migration_log (migration_name, executed_at, description) 
VALUES (
    'fix_agenda_events_trigger',
    NOW(),
    'Corrigido trigger da tabela eventos_agenda_representante para usar atualizado_em em vez de updated_at'
) ON CONFLICT (migration_name) DO NOTHING;