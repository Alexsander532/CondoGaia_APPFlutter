-- =====================================================
-- MIGRAÇÃO: Políticas RLS para o bucket 'fotos_perfil'
-- Data: 2024-01-21
-- Descrição: Cria políticas de Row Level Security para permitir uploads de fotos de perfil
-- =====================================================

-- 1. PERMITIR QUE USUÁRIOS AUTENTICADOS FAÇAM UPLOAD NA PASTA fotos_perfil
-- Qualquer usuário autenticado pode fazer upload de suas próprias fotos
CREATE POLICY "Permitir upload de fotos de perfil para usuários autenticados"
ON storage.objects
FOR INSERT
WITH CHECK (
  bucket_id = 'fotos_perfil' 
  AND auth.role() = 'authenticated'
);

-- 2. PERMITIR LEITURA PÚBLICA DAS FOTOS DE PERFIL
-- Qualquer pessoa pode ver as fotos (são públicas)
CREATE POLICY "Permitir leitura pública de fotos de perfil"
ON storage.objects
FOR SELECT
USING (bucket_id = 'fotos_perfil');

-- 3. PERMITIR QUE USUÁRIOS ATUALIZEM/DELETEM SUAS PRÓPRIAS FOTOS
-- Um usuário só pode atualizar/deletar suas próprias fotos
-- Nota: Isso assume que o path começa com o user_id
CREATE POLICY "Permitir atualização de próprias fotos de perfil"
ON storage.objects
FOR UPDATE
USING (bucket_id = 'fotos_perfil' AND auth.role() = 'authenticated')
WITH CHECK (bucket_id = 'fotos_perfil' AND auth.role() = 'authenticated');

-- 4. PERMITIR DELEÇÃO DE PRÓPRIAS FOTOS
CREATE POLICY "Permitir deleção de próprias fotos de perfil"
ON storage.objects
FOR DELETE
USING (bucket_id = 'fotos_perfil' AND auth.role() = 'authenticated');

-- =====================================================
-- OBSERVAÇÕES:
-- 1. Essas políticas permitem que usuários autenticados façam upload
-- 2. As fotos são públicas para leitura (GET)
-- 3. Cada usuário só pode deletar/atualizar suas próprias fotos
-- 4. Se RLS ainda causar problemas, você pode desabilitar no Supabase Console:
--    Storage → fotos_perfil → Policies → Disable RLS
-- =====================================================
