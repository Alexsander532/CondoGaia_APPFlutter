# 🗂️ GUIA COMPLETO: ADICIONAR COLUNA QR_CODE_URL NO SUPABASE

**Objetivo:** Adicionar campo `qr_code_url` na tabela `autorizados_inquilinos` para evitar regeneração infinita de QR Codes

---

## 📱 **PASSO 1: ACESSAR SUPABASE DASHBOARD**

### 1.1 - Ir ao Supabase
```
1. Abra: https://supabase.com
2. Login com sua conta
3. Selecione seu projeto: CondoGaia (ou o nome do seu projeto)
```

**Tela esperada:**
```
┌─────────────────────────────────────────────────────┐
│ Supabase Dashboard                                  │
├─────────────────────────────────────────────────────┤
│ Projects                                            │
│ ├─ CondoGaia ← Seu projeto                          │
│ └─ ...                                              │
└─────────────────────────────────────────────────────┘
```

---

## 🗄️ **PASSO 2: ACESSAR TABLE EDITOR**

### 2.1 - Menu Esquerdo
```
1. Clique em "Table Editor" (no menu esquerdo)
2. Vai mostrar lista de tabelas
```

**Localização:**
```
┌─ Menu Esquerdo
├─ Home
├─ SQL Editor
├─ Table Editor ← CLIQUE AQUI!
├─ Auth
├─ Storage
└─ ...
```

### 2.2 - Encontrar Tabela `autorizados_inquilinos`
```
1. No painel "All Tables", procure por: autorizados_inquilinos
2. Clique na tabela
```

**Resultado:**
```
┌─────────────────────────────────────────────────────┐
│ Table Editor > autorizados_inquilinos               │
├─────────────────────────────────────────────────────┤
│ Colunas:                                            │
│ ├─ id (uuid) ✓ primary key                         │
│ ├─ created_at (timestamp)                          │
│ ├─ nome (text)                                     │
│ ├─ cpf (text)                                      │
│ ├─ cnpj (text)                                     │
│ ├─ telefone (text)                                 │
│ ├─ email (text)                                    │
│ ├─ tipo (text)                                     │
│ ├─ data_autorizacao (timestamp)                    │
│ ├─ data_expiracao (timestamp)                      │
│ ├─ motivo (text)                                   │
│ ├─ veiculo (text)                                  │
│ ├─ placa_veiculo (text)                            │
│ ├─ condominio_id (uuid)                            │
│ ├─ inquilino_id (uuid)                             │
│ └─ ...                                             │
└─────────────────────────────────────────────────────┘
```

---

## ➕ **PASSO 3: ADICIONAR NOVA COLUNA**

### 3.1 - Clicar no Botão "+"
```
1. Procure pelo botão "+" (Add Column) no final das colunas
2. Vai abrir um modal para criar nova coluna
```

**Visual:**
```
┌─────────────────────────────────────────────┐
│ veiculo         | text      |              │
│ placa_veiculo   | text      |              │
│ condominio_id   | uuid      |              │
│ inquilino_id    | uuid      |              │
│ [+] ← CLIQUE AQUI PARA ADICIONAR COLUNA   │
└─────────────────────────────────────────────┘
```

### 3.2 - Preencher os Dados da Coluna

**Modal que abre:**
```
┌─────────────────────────────────────────────┐
│ Add Column                              [X] │
├─────────────────────────────────────────────┤
│                                             │
│ Column name: ┌──────────────────────────┐  │
│              │ qr_code_url              │  │
│              └──────────────────────────┘  │
│                                             │
│ Column type: ┌──────────────────────────┐  │
│              │ text ▼                   │  │
│              └──────────────────────────┘  │
│                                             │
│ ☐ Set as identity                          │
│ ☐ Set as primary key                       │
│ ☐ Is nullable ☑ ← MARQUE ISTO!            │
│ ☐ Set default value                        │
│                                             │
│ [Cancel] [Save]                            │
└─────────────────────────────────────────────┘
```

### 3.3 - Preenchimento Correto

**Dados para preencher:**

| Campo | Valor | Descrição |
|-------|-------|-----------|
| **Column name** | `qr_code_url` | Nome da coluna |
| **Column type** | `text` | Tipo de dados (URL é texto) |
| **Is nullable** | ✅ SIM | Marque a checkbox (dados antigos não têm URL) |
| **Set default value** | ❌ NÃO | Deixe em branco |

**Razão de ser nullable:**
```
✅ Autorizado ANTIGOS (antes da atualização):
   qr_code_url = NULL

✅ Autorizado NOVOS (depois da atualização):
   qr_code_url = 'https://supabase.../qr_codes/qr_João_1764035780980.png'
```

---

## ✅ **PASSO 4: SALVAR COLUNA**

### 4.1 - Clicar em "Save"
```
1. Clique no botão [Save]
2. Aguarde 2-3 segundos
3. A coluna será criada
```

**Confirmação:**
```
✅ Coluna criada com sucesso!

Tabela atualizada:
├─ id (uuid)
├─ nome (text)
├─ cpf (text)
├─ ...
└─ qr_code_url (text, nullable) ← NOVA COLUNA! 🎉
```

---

## 🔍 **PASSO 5: VERIFICAR A COLUNA**

### 5.1 - Confirmar Visualmente
```
Ao lado das outras colunas, deve aparecer:

qr_code_url    | text      | (vazio ou NULL para registros antigos)
```

### 5.2 - Estrutura Final da Tabela
```
autorizados_inquilinos {
  id: UUID
  created_at: TIMESTAMP
  nome: TEXT
  cpf: TEXT
  cnpj: TEXT
  telefone: TEXT
  email: TEXT
  tipo: TEXT
  data_autorizacao: TIMESTAMP
  data_expiracao: TIMESTAMP
  motivo: TEXT
  veiculo: TEXT
  placa_veiculo: TEXT
  condominio_id: UUID
  inquilino_id: UUID
  qr_code_url: TEXT (nullable) ← NOVA! 🆕
}
```

---

## 📊 **RESUMO VISUAL ANTES E DEPOIS**

### ANTES (SEM QR_CODE_URL)
```
┌────────────────────────────────────┐
│ Autorizado: João Silva             │
├────────────────────────────────────┤
│ CPF: 123.456.789-00                │
│ Tipo: Inquilino                    │
│ Veículo: Honda Civic               │
│ Data Autorização: 24/11/2025       │
├────────────────────────────────────┤
│ [Gera QR SEMPRE que abre] ❌       │
└────────────────────────────────────┘
```

### DEPOIS (COM QR_CODE_URL)
```
┌────────────────────────────────────┐
│ Autorizado: João Silva             │
├────────────────────────────────────┤
│ CPF: 123.456.789-00                │
│ Tipo: Inquilino                    │
│ Veículo: Honda Civic               │
│ Data Autorização: 24/11/2025       │
│ QR Code URL: https://supabase...   │ ← ARMAZENADO!
├────────────────────────────────────┤
│ [Carrega QR da tabela] ✅          │
└────────────────────────────────────┘
```

---

## 🎯 **O QUE MUDA NO FLUXO**

### ANTES (Regenera sempre)
```
User abre card
  ↓
QrCodeWidget.initState()
  ↓
Gera QR Code NOVO
  ↓
Salva Supabase NOVAMENTE
  ↓
Sem atualizar tabela ❌
  ↓
Próxima vez: Gera OUTRO novo ❌
```

### DEPOIS (Reutiliza da tabela)
```
User CRIA novo autorizado
  ↓
Service gera QR Code UMA VEZ
  ↓
Salva URL na coluna qr_code_url
  ↓
Fecha modal
  ↓
User abre card
  ↓
QrCodeWidget carrega qr_code_url da tabela
  ↓
Exibe imagem direto (SEM regenerar) ✅
  ↓
Próxima vez: Mesma URL ✅
```

---

## ⚙️ **CONFIGURAÇÃO SUPABASE (OPCIONAL)**

Se quiser adicionar comentários ou descrição:

```sql
COMMENT ON COLUMN autorizados_inquilinos.qr_code_url IS 
'URL pública da imagem QR Code salva em Supabase Storage (bucket: qr_codes). Gerada uma vez ao criar autorizado.';
```

Mas isso é opcional! 😊

---

## ✨ **RESULTADO ESPERADO**

Após completar todos os passos:

```
✅ Coluna qr_code_url criada
✅ Tipo: TEXT
✅ Nullable: SIM
✅ Padrão: NULL (para compatibilidade com dados antigos)
✅ Pronto para usar!
```

**Próximo passo:** Atualizar o Model Flutter para incluir este campo! 🚀

---

## 🆘 **TROUBLESHOOTING**

### ❌ "Coluna não aparece"
```
Solução:
1. Recarregue a página (F5)
2. Desconecte e conecte novamente ao Supabase
3. Verifique se o projeto está selecionado corretamente
```

### ❌ "Erro ao salvar"
```
Solução:
1. Verifique se o nome não tem espaços: qr_code_url ✅
2. Não use caracteres especiais
3. Deixe "Is nullable" marcado
```

### ❌ "Tipo errado"
```
Correto:
- Coluna: qr_code_url (text)

Errado:
- qr_code_url (uuid) ❌
- qr_code_url (json) ❌
- qr_code_url (varchar) ❌
```

---

## 📝 **CHECKLIST**

- [ ] Acessei Supabase Dashboard
- [ ] Entrei em Table Editor
- [ ] Encontrei tabela `autorizados_inquilinos`
- [ ] Cliquei no botão "+" para adicionar coluna
- [ ] Preenchi:
  - [ ] Column name: `qr_code_url`
  - [ ] Column type: `text`
  - [ ] Is nullable: ☑️ SIM
- [ ] Cliquei em [Save]
- [ ] Confirmei que coluna apareceu na tabela
- [ ] Coluna está funcionando ✅

**Depois disso, avise para atualizar o Model!** 🚀
