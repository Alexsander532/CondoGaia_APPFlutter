# 🪣 PASSO A PASSO - Criar Bucket `qr_codes` no Supabase

**Data:** 24 de Novembro de 2025  
**Objetivo:** Criar bucket para armazenar QR Codes em cloud

---

## 📋 PRÉ-REQUISITOS

- ✅ Conta Supabase ativa
- ✅ Projeto Supabase criado
- ✅ Acesso ao Dashboard

---

## 🔑 PASSO 1: Acessar Supabase Dashboard

### Via Navegador

1. Abrir: **https://app.supabase.com**
2. Fazer login com suas credenciais
3. Selecionar seu **projeto** na lista

### Resultado Esperado
```
Dashboard do Supabase carrega
├── Menu lateral à esquerda
├── Nome do projeto no topo
└── Várias abas (Authentication, Database, Storage, etc.)
```

---

## 📁 PASSO 2: Acessar Storage

### Na Interface do Supabase

1. Menu lateral → **Storage**
2. Clique em **Storage** (não confundir com outras opções)

### Resultado Esperado
```
Página de Storage abre
├── Listagem de buckets existentes (pode estar vazia)
├── Botão "New Bucket" ou "Create Bucket"
└── Nenhum bucket chamado "qr_codes" (ainda)
```

---

## ➕ PASSO 3: Criar Novo Bucket

### Clique em "New Bucket"

1. Procure o botão **"New Bucket"** ou **"Create Bucket"**
2. Clique nele

### Dialog Aparece
```
Create a new bucket
├── Name: [campo de entrada]
├── Public bucket: [toggle/checkbox]
└── [Cancel] [Create]
```

---

## ✏️ PASSO 4: Preencher Dados do Bucket

### Campo "Name"

1. Digite exatamente: **`qr_codes`**
2. ⚠️ **Importante:** Sem espaços, sem maiúsculas, sem acentos

### Campo "Public bucket"

1. **MARQUE** a opção "Public" ou "Make it public"
2. Isso permite que URLs sejam acessadas sem autenticação
3. ✅ Necessário para compartilhamento

### Resultado
```
Name: qr_codes
Public bucket: ✅ ATIVADO
```

---

## 🚀 PASSO 5: Criar o Bucket

### Clique em "Create"

1. Botão **"Create"** ou **"Save"**
2. Aguarde carregamento

### Resultado Esperado
```
Bucket "qr_codes" criado com sucesso ✅

Storage
├── qr_codes (novo!)
│   ├── (vazio)
│   └── Pronto para receber arquivos
└── Outros buckets...
```

---

## 🔐 PASSO 6: Configurar Policies (Permissões)

### Acessar Configurações do Bucket

1. Clique no bucket **"qr_codes"**
2. Procure por **"Policies"** ou **"Access Control"**
3. Clique em **"Policies"**

### Dialog de Policies

```
Bucket Policies - qr_codes
├── SELECT (Ler)
├── INSERT (Criar)
├── UPDATE (Editar)
└── DELETE (Deletar)
```

---

## ✅ PASSO 7: Habilitar Permissões

### Habilitar SELECT (Ler)

1. Procure por linha **"SELECT"** ou **"Read"**
2. Se houver toggle, ative-a: ✅
3. Se houver botão, clique em **"Enable"** ou **"Add"**

### Resultado
```
SELECT: ✅ ENABLED
```

### Habilitar INSERT (Criar)

1. Procure por linha **"INSERT"** ou **"Create"**
2. Se houver toggle, ative-a: ✅
3. Se houver botão, clique em **"Enable"** ou **"Add"**

### Resultado
```
INSERT: ✅ ENABLED
```

### ⚠️ DELETE e UPDATE

- **DELETE:** Deixe desabilitado (segurança)
- **UPDATE:** Deixe desabilitado (segurança)

---

## 📊 VERIFICAÇÃO FINAL

### Checklist

- [x] Bucket "qr_codes" criado
- [x] Bucket é PUBLIC
- [x] SELECT habilitado
- [x] INSERT habilitado
- [x] DELETE desabilitado
- [x] UPDATE desabilitado

### Storage agora mostra

```
Buckets
├── qr_codes
│   ├── Public: ✅ SIM
│   ├── Size: 0 bytes (vazio)
│   └── Policies: SELECT ✅, INSERT ✅
└── Outros buckets...
```

---

## 🎯 RESULTADO

### URL Pública Format

Depois que o app salvar um QR Code, a URL será:

```
https://[seu-projeto].supabase.co/storage/v1/object/public/qr_codes/qr_[nome]_[timestamp].png
```

Exemplos:
```
https://abcd1234.supabase.co/storage/v1/object/public/qr_codes/qr_joaosilva_1732440000000.png
https://abcd1234.supabase.co/storage/v1/object/public/qr_codes/qr_maria_1732440001234.png
```

---

## 🔗 PRÓXIMAS ETAPAS

### 1. Compilar o App

```bash
flutter clean
flutter pub get
flutter run
```

### 2. Testar QR Code

1. Navegar para: Menu → Portaria → Autorizados
2. Ver se QR Code aparece
3. Se aparecer e tiver borda verde = sucesso! ✅
4. Botão "Compartilhar" está pronto para usar

### 3. Validar Supabase

1. Voltar ao Supabase Dashboard
2. Abrir Storage → qr_codes
3. Ver se arquivos PNG foram criados
4. Padrão de nome: `qr_[nome]_[timestamp].png`

---

## 🐛 TROUBLESHOOTING

### "Bucket já existe"

**Solução:** Use o bucket existente, não crie novo

### "Não consigo clicar em Public"

**Solução:** 
- Pode estar em outra aba (procure "Public" ou "Access")
- Tente recarregar a página

### "Não vejo botão de Policies"

**Solução:**
- Clique **dentro** do bucket (não na linha)
- Procure aba "Policies" ou "Access Control"
- Se não achar, pode estar em "Settings"

### "Bucket criado mas app não consegue salvar"

**Solução:**
1. Verificar que SELECT + INSERT estão habilitados
2. Verificar que bucket é PUBLIC
3. Verificar credenciais Supabase no app estão corretas
4. Ver logs do app (procurar por `[QR] Erro`)

---

## 📸 VISUALIZAÇÃO DO RESULTADO

### Supabase Dashboard - Após Sucesso

```
Storage
├── qr_codes (✅ PUBLIC)
│   ├── qr_joaosilva_1732440000000.png (45.2 KB)
│   ├── qr_maria_1732440001234.png (45.1 KB)
│   ├── qr_pedrosantos_1732440002567.png (44.9 KB)
│   └── ... (mais arquivos)
└── Outros buckets...
```

### App - QR Code Visível

```
┌──────────────────────────────────────┐
│  Autorizado: João Silva              │
│  CPF: 123.456.789-00                │
├──────────────────────────────────────┤
│  ┌──────────────────────────────┐    │
│  │   [QR CODE - 220x220]       │    │
│  │                              │    │
│  │  QR Code de: João Silva     │    │
│  │                              │    │
│  │  [📤 Compartilhar QR Code]  │    │
│  └──────────────────────────────┘    │
└──────────────────────────────────────┘
```

---

## ✨ CONCLUSÃO

O bucket `qr_codes` está pronto! 

**Próxima ação:** Compilar e testar o app. Os QR Codes serão salvos automaticamente neste bucket.

---

*Guia criado em 24/11/2025*
