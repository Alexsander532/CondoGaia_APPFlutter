# 📱 Guia Prático: Testar Cópia de Imagem QR

## ✅ Pré-requisitos

- [ ] Bucket `qr_codes` criado no Supabase (deve ser PUBLIC)
- [ ] App compilado e rodando no celular/emulador
- [ ] Conexão de internet ativa

## 🧪 Passo a Passo do Teste

### 1️⃣ Abra o app e vá até a tela de Portaria

```
Home → Portaria Inquilino/Representante
```

### 2️⃣ Procure um autorizado e veja o QR Code

Você deve ver:
```
┌─────────────────────┐
│   [QR Code]         │
│                     │
│ QR Code de: João    │
└─────────────────────┘

   [📋 Copiar Imagem] [📤 Compartilhar]
```

### 3️⃣ Verifique os logs enquanto gera

Abra o Android Studio ou use:
```bash
flutter logs
```

Você deve ver:
```
I/flutter: [QR Widget] Iniciando geração...
I/flutter: [QR] Gerando e salvando QR no Supabase...
I/flutter: [QR] Imagem gerada: 5491 bytes
I/flutter: [QR] Arquivo salvo com sucesso
I/flutter: [QR] URL pública gerada: https://...
```

### 4️⃣ Clique em "📋 Copiar Imagem"

Você deve ver:
```
I/flutter: [QR Widget] _copiarURL chamado
I/flutter: [QR] Baixando imagem QR da URL: https://...
I/flutter: [QR] Imagem baixada com sucesso: 5491 bytes
I/flutter: [QR] Imagem copiada para clipboard (native)
```

### 5️⃣ Veja a mensagem de sucesso

```
✅ Imagem do QR copiada com sucesso!
   (Cole em WhatsApp, Email, etc)
```

### 6️⃣ Teste a colagem

**Opção A - WhatsApp:**
- Abra uma conversa no WhatsApp
- Clique no campo de mensagem
- Cole (Ctrl+V ou long press → Colar)
- A imagem QR deve aparecer

**Opção B - Email:**
- Abra um email (Gmail, Outlook, etc)
- Cole a imagem no corpo do email
- A imagem deve aparecer

**Opção C - Galeria:**
- Abre arquivo
- Cole (Ctrl+V)
- A imagem deve aparecer

## 🔧 Troubleshooting

### ❌ Erro: "Erro ao gerar QR Code"

**Causa:** Problema ao salvar no Supabase  
**Solução:**
```bash
# Verifique o bucket
# Supabase Dashboard → Storage → qr_codes

# Se não existir, crie:
# Name: qr_codes
# Public: ✅ SIM
```

### ❌ Erro: "URL do QR Code não disponível"

**Causa:** QR não foi gerado  
**Solução:**
- Aguarde o loading terminar (deve mostrar "Gerando QR Code...")
- Se demorar muito, tente recarregar a tela

### ❌ Erro: "Erro ao copiar imagem"

**Causa:** Problema ao baixar do Supabase  
**Solução:**
- Verifique conexão de internet
- Verifique se a URL do bucket está correta
- Veja os logs para mais detalhes

### ⚠️ Fallback acionado (Share Dialog aberto)

**Por quê:** Platform channel não disponível ou falhou  
**O que fazer:**
- Selecione um app para compartilhar (Gmail, WhatsApp, etc)
- Ou copie manualmente se o app tiver opção

## 📊 Checklist de Teste

- [ ] QR Code aparece logo que abre a tela
- [ ] Botão "Copiar Imagem" fica habilitado
- [ ] Clicando mostra loading
- [ ] Após sucesso, mostra mensagem verde
- [ ] Ao colar em WhatsApp, a imagem aparece
- [ ] Ao colar em Email, a imagem aparece
- [ ] Ao colar em Galeria, a imagem aparece
- [ ] Botão "Compartilhar" funciona
- [ ] Botão "Compartilhar" abre menu nativo

## 🐛 Debug Avançado

Se algo não funcionar, adicione prints no seu widget:

```dart
Future<void> _copiarURL() async {
  print('[DEBUG] _copiarURL iniciado');
  print('[DEBUG] _urlQr = $_urlQr');
  
  // Resto do código...
}
```

Depois execute:
```bash
flutter logs -f
```

E veja todos os prints em tempo real.

## ✨ Resultado Esperado

### Teste Local
```
1. App abre → QR Code gerado em ~1-2 segundos
2. Clica "Copiar" → Mostra loading por ~0.5s
3. Sucesso → Mensagem verde aparece por 3s
4. Cola no WhatsApp → Imagem QR aparece

Tempo total: ~3-4 segundos
```

## 🎉 Se tudo funcionar

Parabéns! 🎊

O sistema está:
- ✅ Gerando QR Codes
- ✅ Salvando no Supabase
- ✅ Copiando imagens para clipboard
- ✅ Compartilhando via apps nativos

Agora é só testar em produção! 🚀
