-- Criar função para verificar senhas
CREATE OR REPLACE FUNCTION verify_password(input_password TEXT, stored_hash TEXT)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN stored_hash = crypt(input_password, stored_hash);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Conceder permissões para usar a função
GRANT EXECUTE ON FUNCTION verify_password(TEXT, TEXT) TO anon;
GRANT EXECUTE ON FUNCTION verify_password(TEXT, TEXT) TO authenticated;