# 🎨 Referência Visual: QR Code nos Cards de Autorizados

## Visão Geral da Interface

```
┌─────────────────────────────────────────────────────────────────┐
│  PORTARIA - Inquilinos                            [← Voltar]   │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│  Selecione a Unidade: [Dropdown: 101 ▼]                          │
│                                                                   │
│  ═══════════════════════════════════════════════════════════════ │
│  AUTORIZADOS                                                     │
│  ═══════════════════════════════════════════════════════════════ │
│                                                                   │
│  Card de Autorizado (Fechado):                                   │
│  ┌─────────────────────────────────────────────────────────────┐ │
│  │ João Silva                        123.456.789-00            │ │
│  │ (11) 98765-4321                                        [▼]  │ │
│  └─────────────────────────────────────────────────────────────┘ │
│                                                                   │
│                                                                   │
│  Card de Autorizado (Aberto - Expandido):                        │
│  ┌─────────────────────────────────────────────────────────────┐ │
│  │ Maria Silva                       987.654.321-00            │ │
│  │ (11) 91234-5678                                        [▲]  │ │
│  ├─────────────────────────────────────────────────────────────┤ │
│  │                                                             │ │
│  │  Telefone: (11) 91234-5678                                  │ │
│  │  Data de Autorização: 15/11/2025                            │ │
│  │  Tipo: Inquilino                                            │ │
│  │                                                             │ │
│  │  ┌───────────────────────────────────────────────────────┐ │ │
│  │  │                                                       │ │ │
│  │  │        ██████████████████████████████                │ │ │
│  │  │        ██                      ██                    │ │ │
│  │  │        ██  ██████████████████  ██                    │ │ │
│  │  │        ██  ██            ██  ██                    │ │ │
│  │  │        ██  ██  ██████████  ██                    │ │ │
│  │  │        ██  ██            ██  ██                    │ │ │
│  │  │        ██  ██████████████████  ██                    │ │ │
│  │  │        ██                      ██                    │ │ │
│  │  │        ██████████████████████████████                │ │ │
│  │  │                                                       │ │ │
│  │  │              QR Code de: Maria Silva                  │ │ │
│  │  │                                                       │ │ │
│  │  └───────────────────────────────────────────────────────┘ │ │
│  │                                                             │ │
│  │  ┌──────────────────┬──────────────────┐                    │ │
│  │  │ 📋 Copiar QR     │ 📤 Compartilhar   │                    │ │
│  │  └──────────────────┴──────────────────┘                    │ │
│  │                                                             │ │
│  │  ┌──────────────────┬──────────────────┐                    │ │
│  │  │ ✏️  Editar       │ 🗑️  Deletar      │                    │ │
│  │  └──────────────────┴──────────────────┘                    │ │
│  │                                                             │ │
│  └─────────────────────────────────────────────────────────────┘ │
│                                                                   │
└─────────────────────────────────────────────────────────────────┘
```

---

## Estados da Interface

### **Estado 1: Card Fechado**

```
┌──────────────────────────────────────┐
│ João Silva           123.456.789-00  │
│ (11) 98765-4321                 [▼] │
└──────────────────────────────────────┘
```

- Mostra resumo: Nome, CPF e Telefone
- Botão expandir no lado direito

---

### **Estado 2: Card Expandido (Mostrando QR)**

```
┌──────────────────────────────────────────────────────┐
│ João Silva           123.456.789-00                  │
│ (11) 98765-4321                                [▲]  │
├──────────────────────────────────────────────────────┤
│                                                      │
│ Telefone: (11) 98765-4321                           │
│ Data: 15/11/2025                                    │
│                                                      │
│ ┌─────────────────────────────────────────────────┐ │
│ │                                                 │ │
│ │         [QR CODE 200x200 - Imagem]             │ │
│ │         ██████████████████████                 │ │
│ │         ██                  ██                 │ │
│ │         ██  ██████████████  ██                 │ │
│ │         ██  ██          ██  ██                 │ │
│ │         ██  ██████████████  ██                 │ │
│ │         ██                  ██                 │ │
│ │         ██████████████████████                 │ │
│ │                                                 │ │
│ │    QR Code de: João Silva                      │ │
│ │                                                 │ │
│ └─────────────────────────────────────────────────┘ │
│                                                      │
│  [ 📋 Copiar QR ]  [ 📤 Compartilhar ]             │
│                                                      │
│  [ ✏️ Editar ]  [ 🗑️ Deletar ]                      │
│                                                      │
└──────────────────────────────────────────────────────┘
```

---

## Fluxo de Interação

### **Cenário 1: Copiar QR Code**

```
User vê card fechado de Autorizado
        ↓
User clica no card (ou no ícone ▼)
        ↓
Card expande
        ↓
QR Code é gerado dinamicamente
        ↓
User vê QR Code + Botão "Copiar QR"
        ↓
User clica "Copiar QR"
        ↓
Sistema gera imagem PNG do QR Code
        ↓
Imagem é copiada para Clipboard
        ↓
SnackBar aparece: "QR Code copiado! ✓"
        ↓
User abre WhatsApp / Email
        ↓
User cola (Ctrl+V) a imagem
        ↓
QR fica visível no chat/email
```

### **Cenário 2: Compartilhar QR Code**

```
User clica "Compartilhar"
        ↓
Abre dialog de compartilhamento nativo
        ↓
User escolhe aplicativo (WhatsApp, Email, etc)
        ↓
QR é enviado como imagem
```

---

## Dados Codificados no QR Code

### **Estrutura JSON**

```json
{
  "id": "a1b2c3d4-e5f6-7g8h-i9j0-k1l2m3n4o5p6",
  "nome": "João Silva Santos",
  "cpf_cnpj": "123.456.789-00",
  "telefone": "(11) 98765-4321",
  "tipo": "inquilino",
  "unidade": "101",
  "data_autorizacao": "2025-11-23T10:30:00Z",
  "timestamp": "2025-11-23T18:45:30.123456Z"
}
```

### **O que significa**

| Campo | Valor | Propósito |
|-------|-------|-----------|
| `id` | UUID | Identificador único do autorizado |
| `nome` | String | Nome completo |
| `cpf_cnpj` | String | Documento de identificação |
| `telefone` | String | Contato do autorizado |
| `tipo` | "inquilino" / "proprietario" | Tipo de relacionamento |
| `unidade` | "101" | Unidade associada |
| `data_autorizacao` | ISO 8601 | Quando foi autorizado |
| `timestamp` | ISO 8601 | Quando o QR foi gerado |

---

## Tamanhos e Dimensões

### **QR Code**
- Tamanho: 200x200 pixels (na exibição)
- Versão: Auto (qr_flutter detecta automaticamente)
- Erro Correction: Level H (30% recuperação)
- Cores: Preto (dados) e Branco (fundo)

### **Card**
- Largura: Full width - 16px padding
- Altura QR: Aproximadamente 250-300px (com espaçamento)
- Botões: 48px de altura (Material Design)

---

## Cores e Styling

### **Paleta**

```
Background do Card QR:    #F5F5F5 (cinza claro)
Borda do Card QR:        #E0E0E0 (cinza médio)
Botão Copiar:            #2196F3 (azul)
Botão Compartilhar:      #4CAF50 (verde)
Botão Editar:            #FF9800 (laranja)
Botão Deletar:           #F44336 (vermelho)
Texto Normal:            #424242 (cinza escuro)
Texto Secundário:        #9E9E9E (cinza)
Sucesso (Snackbar):      #4CAF50 (verde)
Erro (Snackbar):         #F44336 (vermelho)
```

---

## Responsividade

```
Celular (Small):
  └─ QR: 150x150px
  └─ Botões: Empilhados (100% width)
  └─ Fonte: 12px

Tablet (Medium):
  └─ QR: 200x200px
  └─ Botões: Lado a lado
  └─ Fonte: 14px

Desktop (Large):
  └─ QR: 250x250px
  └─ Botões: Lado a lado com espaço
  └─ Fonte: 16px
```

---

## Estados de Carregamento

### **Gerando QR**

```
┌──────────────────────────┐
│  ⏳ Gerando QR Code...   │
│                          │
│  [Spinner animado]       │
│                          │
│  Aguarde...              │
└──────────────────────────┘
```

### **Copiando para Clipboard**

```
Botão muda para:
[ ⏳ Copiando... ]  (desabilitado)

Após sucesso (2s):
[ 📋 Copiar QR ]   (habilitado)

SnackBar mostra:
✓ QR Code copiado para a área de transferência!
```

### **Erro**

```
SnackBar mostra:
❌ Erro ao copiar QR Code. Tente novamente.
```

---

## Acessibilidade

- ✅ Botões com rótulos descritivos
- ✅ Ícones + Texto (não apenas ícones)
- ✅ Tamanho mínimo de toque: 48x48px
- ✅ Feedback visual (Snackbar) para ações
- ✅ Contraste adequado de cores
- ✅ Suporte a temas escuro/claro (opcional)

---

## Integração com Portaria

### **Workflow Completo**

```
Porteiro acessa tela de Inquilinos
    ↓
Seleciona Unidade
    ↓
Vê lista de Autorizados dessa unidade
    ↓
Expande card de um Autorizado
    ↓
Vê QR Code e dados
    ↓
Pode:
  A) Copiar QR para enviar por WhatsApp/Email
  B) Compartilhar direto com WhatsApp
  C) Editar dados do autorizado
  D) Deletar autorizado
```

---

## ✅ Checklist de Implementação

- [ ] Adicionar dependências (qr_flutter, image_gallery_saver)
- [ ] Criar QrCodeHelper com métodos de geração
- [ ] Criar QrCodeWidget reutilizável
- [ ] Adicionar método gerarDadosQR() no modelo
- [ ] Integrar no portaria_inquilino_screen
- [ ] Integrar no portaria_representante_screen
- [ ] Testar geração do QR Code
- [ ] Testar cópia para clipboard
- [ ] Testar compartilhamento
- [ ] Testar escanamento de QR gerado
- [ ] Validar responsividade
- [ ] Validar acessibilidade
