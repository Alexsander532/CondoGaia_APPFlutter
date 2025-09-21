-- Migração para alterar os campos limite_tempo_duracao e dias_bloqueados para text
-- Isso permite que o usuário digite texto livre em vez de valores estruturados

-- Alterar limite_tempo_duracao de integer para text
ALTER TABLE ambientes 
ALTER COLUMN limite_tempo_duracao TYPE text 
USING limite_tempo_duracao::text;

-- Alterar dias_bloqueados de integer[] para text
ALTER TABLE ambientes 
ALTER COLUMN dias_bloqueados TYPE text 
USING array_to_string(dias_bloqueados, ', ');

-- Comentários para documentar as mudanças
COMMENT ON COLUMN ambientes.limite_tempo_duracao IS 'Limite de tempo de duração em formato texto livre (ex: "2 horas", "30 minutos")';
COMMENT ON COLUMN ambientes.dias_bloqueados IS 'Dias bloqueados em formato texto livre (ex: "Segunda, Terça", "Fins de semana")';