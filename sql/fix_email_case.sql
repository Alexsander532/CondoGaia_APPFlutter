-- Script para corrigir inconsistência de maiúsculas/minúsculas nos emails
-- Este script converte todos os emails para minúsculas para manter consistência

-- Atualizar emails dos representantes para minúsculas
UPDATE representantes 
SET email = LOWER(email)
WHERE email != LOWER(email);

-- Verificar se a atualização funcionou
SELECT email, nome_completo 
FROM representantes 
WHERE email LIKE '%representante%'
ORDER BY email;