-- Criação da tabela representantes
CREATE TABLE IF NOT EXISTS public.representantes (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    
    -- Dados básicos do representante
    nome_completo VARCHAR NOT NULL,
    cpf VARCHAR(14) NOT NULL UNIQUE, -- Formato: 000.000.000-00
    telefone VARCHAR(15), -- Formato: (00) 0000-0000
    celular VARCHAR(16), -- Formato: (00) 00000-0000
    email VARCHAR NOT NULL,
    endereco VARCHAR,
    uf VARCHAR(2),
    cidade VARCHAR,
    
    -- Relacionamento com condomínios (array de IDs)
    condominios_selecionados TEXT[] DEFAULT '{}',
    
    -- Checkboxes de seções principais
    todos_marcado BOOLEAN DEFAULT FALSE,
    modulos_section_marcado BOOLEAN DEFAULT FALSE,
    gestao_section_marcado BOOLEAN DEFAULT FALSE,
    
    -- Checkboxes da seção Módulos (2)
    chat_marcado BOOLEAN DEFAULT FALSE,
    reservas_marcado BOOLEAN DEFAULT FALSE,
    reservas_config_marcado BOOLEAN DEFAULT FALSE,
    leitura_marcado BOOLEAN DEFAULT FALSE,
    leitura_config_marcado BOOLEAN DEFAULT FALSE,
    diario_agenda_marcado BOOLEAN DEFAULT FALSE,
    documentos_marcado BOOLEAN DEFAULT FALSE,
    
    -- Checkboxes da seção Gestão (3)
    condominio_gestao_marcado BOOLEAN DEFAULT FALSE,
    condominio_conf_marcado BOOLEAN DEFAULT FALSE,
    relatorios_marcado BOOLEAN DEFAULT FALSE,
    portaria_marcado BOOLEAN DEFAULT FALSE,
    
    -- Checkboxes da subseção Boleto (3.4)
    boleto_marcado BOOLEAN DEFAULT FALSE,
    boleto_gerar_marcado BOOLEAN DEFAULT FALSE,
    boleto_enviar_marcado BOOLEAN DEFAULT FALSE,
    boleto_receber_marcado BOOLEAN DEFAULT FALSE,
    boleto_excluir_marcado BOOLEAN DEFAULT FALSE,
    
    -- Checkboxes da subseção Acordo (3.5)
    acordo_marcado BOOLEAN DEFAULT FALSE,
    acordo_gerar_marcado BOOLEAN DEFAULT FALSE,
    acordo_enviar_marcado BOOLEAN DEFAULT FALSE,
    
    -- Outros checkboxes da seção Gestão
    morador_unid_marcado BOOLEAN DEFAULT FALSE,
    morador_conf_marcado BOOLEAN DEFAULT FALSE,
    email_gestao_marcado BOOLEAN DEFAULT FALSE,
    desp_receita_marcado BOOLEAN DEFAULT FALSE,
    
    -- Campos de auditoria
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Habilitar RLS (Row Level Security)
ALTER TABLE public.representantes ENABLE ROW LEVEL SECURITY;

-- Política para permitir leitura para usuários autenticados
CREATE POLICY "Permitir leitura para usuários autenticados" ON public.representantes
    FOR SELECT USING (auth.role() = 'authenticated');

-- Política para permitir inserção para usuários autenticados
CREATE POLICY "Permitir inserção para usuários autenticados" ON public.representantes
    FOR INSERT WITH CHECK (auth.role() = 'authenticated');

-- Política para permitir atualização para usuários autenticados
CREATE POLICY "Permitir atualização para usuários autenticados" ON public.representantes
    FOR UPDATE USING (auth.role() = 'authenticated');

-- Política para permitir exclusão para usuários autenticados
CREATE POLICY "Permitir exclusão para usuários autenticados" ON public.representantes
    FOR DELETE USING (auth.role() = 'authenticated');

-- Conceder permissões para as roles
GRANT ALL PRIVILEGES ON public.representantes TO authenticated;
GRANT SELECT ON public.representantes TO anon;

-- Função para atualizar o campo updated_at automaticamente
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Trigger para atualizar automaticamente o campo updated_at
CREATE TRIGGER update_representantes_updated_at
    BEFORE UPDATE ON public.representantes
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Índices para melhorar performance
CREATE INDEX IF NOT EXISTS idx_representantes_cpf ON public.representantes(cpf);
CREATE INDEX IF NOT EXISTS idx_representantes_email ON public.representantes(email);
CREATE INDEX IF NOT EXISTS idx_representantes_created_at ON public.representantes(created_at);