# 🎯 RESUMO DO PLANO: QR CODES PARA 4 ENTIDADES

## ✨ O QUE VAI SER FEITO

Quando você criar uma **Unidade**, **Proprietário**, **Inquilino** ou **Imobiliária**, um QR code será gerado **automaticamente** e salvo no banco de dados.

```
Criar Unidade 101
      ↓
Sistema gera QR Code
      ↓
Faz upload para bucket "qr_codes"
      ↓
Salva URL na coluna "qr_code_url"
      ↓
QR code aparece no card da unidade ✅
```

---

## 📋 TAREFAS A FAZER

### 1️⃣ Estender o Serviço de QR Code (30 min)
**Arquivo:** `qr_code_generation_service.dart`

Adicionar novo método genérico:
```
gerarESalvarQRCodeGenerico({
  tipo: 'unidade'/'proprietario'/'inquilino'/'imobiliaria',
  id: ID do registro,
  nome: Nome/numero do registro,
  tabelaNome: Nome da tabela,
  dados: dados adicionais
})
```

### 2️⃣ Integrar em 4 Services (60 min)

#### a) `unidade_service.dart`
- Após criar unidade → gerar QR code
- Tipo: `'unidade'`
- Dados: numero, bloco, condominio_id

#### b) `proprietario_service.dart`
- Após criar proprietário → gerar QR code
- Tipo: `'proprietario'`
- Dados: nome, cpf (últimos 4), email, telefone

#### c) `inquilino_service.dart`
- Após criar inquilino → gerar QR code
- Tipo: `'inquilino'`
- Dados: nome, cpf (últimos 4), email, telefone

#### d) `imobiliaria_service.dart`
- Após criar imobiliária → gerar QR code
- Tipo: `'imobiliaria'`
- Dados: nome, cnpj (últimos 4), email, telefone

### 3️⃣ Criar Widgets de Exibição (45 min)
- Adicionar QR code aos cards de:
  - 🏠 Unidades
  - 👤 Proprietários
  - 👤 Inquilinos
  - 🏢 Imobiliárias
- Botão de compartilhar em cada um

### 4️⃣ Testar (30 min)
- Criar unidade → QR code aparece ✓
- Criar proprietário → QR code aparece ✓
- Criar inquilino → QR code aparece ✓
- Criar imobiliária → QR code aparece ✓

---

## 🗂️ ESTRUTURA DO QR CODE

Cada QR code conterá um JSON com dados da entidade:

### Para Unidade:
```json
{
  "tipo": "unidade",
  "numero": "101",
  "bloco": "A",
  "condominio_id": "cond-123",
  "data_criacao": "2025-11-25T10:30:00Z"
}
```

### Para Proprietário:
```json
{
  "tipo": "proprietario",
  "nome": "João Silva",
  "cpf": "****-****-****-12",
  "email": "joao@email.com",
  "data_criacao": "2025-11-25T10:30:00Z"
}
```

### Para Inquilino:
```json
{
  "tipo": "inquilino",
  "nome": "Maria Santos",
  "cpf": "****-****-****-45",
  "email": "maria@email.com",
  "data_criacao": "2025-11-25T10:30:00Z"
}
```

### Para Imobiliária:
```json
{
  "tipo": "imobiliaria",
  "nome": "XYZ Imobiliária",
  "cnpj": "****-****-****-89",
  "email": "contato@xyz.com",
  "data_criacao": "2025-11-25T10:30:00Z"
}
```

---

## 📁 ARQUIVOS NO BUCKET

Será criado no bucket `qr_codes`:

```
qr_codes/
├── qr_unidade_101_A_1732516200_a7f3.png
├── qr_unidade_102_A_1732516300_b8g4.png
├── qr_proprietario_joao_silva_1732516400_c9h5.png
├── qr_inquilino_maria_santos_1732516500_d0i6.png
├── qr_imobiliaria_xyz_1732516600_e1j7.png
```

Padrão: `qr_{tipo}_{identificador}_{timestamp}_{uuid}.png`

---

## 🔗 URLS ARMAZENADAS

Cada tabela terá uma coluna `qr_code_url` com:

```
https://tukpgefrddfchmvtiujp.supabase.co/storage/v1/object/public/qr_codes/qr_unidade_101_A_1732516200_a7f3.png
```

---

## ✅ BENEFÍCIOS

| Benefício | Descrição |
|-----------|-----------|
| **Automático** | Gerado quando cria o registro |
| **Único** | Cada entidade tem seu próprio código |
| **Identificável** | QR contém dados da entidade |
| **Compartilhável** | Pode enviar via WhatsApp, email, etc |
| **Seguro** | Armazenado em Supabase Storage |
| **Escalável** | Mesmo padrão para todos |

---

## 📊 TIMELINE

- Tarefa 1: 30 minutos
- Tarefa 2: 60 minutos
- Tarefa 3: 45 minutos
- Tarefa 4: 30 minutos

**TOTAL: 2 horas 45 minutos**

---

## 🚀 PRÓXIMA AÇÃO

Pronto para começar? Vou:

1. **Primeiro** - Estender `QrCodeGenerationService` com método genérico
2. **Depois** - Integrar em cada service (unidade, prop, inq, imob)
3. **Então** - Criar widgets para exibição
4. **Finalmente** - Testar tudo

**Quer que eu comece?** 🎯
