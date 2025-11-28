# 🎬 GUIA PASSO-A-PASSO: Como Testar a Migração PhotoPicker

## 📋 PRÉ-REQUISITOS

- ✅ 4 telas críticas já modificadas
- ✅ PhotoPickerService criado
- ✅ pubspec.yaml atualizado
- ✅ flutter pub get executado

---

## 🚀 PASSO 1: Preparar o Emulador/Dispositivo

### Opção A: Usar Emulador Android 13+ (Recomendado)

**No Android Studio:**
1. Clique em: **Device Manager** (lado direito)
2. Clique em: **Create device**
3. Escolha: **Pixel 6** (ou qualquer modelo)
4. Escolha: **API 33 ou maior** (Android 13+)
5. Clique: **Next** e **Finish**
6. Clique no ícone de play para abrir

### Opção B: Usar Dispositivo Real
1. Conectar telefone com Android 13+ via USB
2. Habilitar Developer Mode e USB Debugging
3. Autorizar conexão no telefone

---

## 🎯 PASSO 2: Rodar a Aplicação

### No Terminal/PowerShell:

```bash
cd C:\Users\Alexsander\Desktop\Aplicativos\APPflutter\condogaiaapp

# Limpar tudo (importante!)
flutter clean

# Sincronizar dependências
flutter pub get

# Rodar a aplicação
flutter run
```

**O que esperar:**
- ✅ Compilação (~2-3 minutos)
- ✅ App abre no emulador/dispositivo
- ✅ Você vê a tela de login

---

## 📱 PASSO 3: Testar Cada Funcionalidade

### TESTE 1: Portaria Representante (CRÍTICO)

**Navegação:**
```
1. Faça login no app
2. Clique em: "Portaria" (ou menu principal)
3. Selecione: "Representante"
4. Procure por: Seção de "Encomenda"
5. Clique no botão: 📷 (Câmera)
```

**O que fazer:**
- Tire uma foto com a câmera do emulador
- OU selecione "Cancelar" para testar galeria depois

**O que procurar nos LOGS:**

Abra **Logcat** (Android Studio):
- Menu: **View → Tool Windows → Logcat**
- OU: Atalho `Ctrl + Alt + 6`

Procure por:
```
✅ "🎯 Iniciando seleção de foto..."
✅ "📱 SDK Version: 33"
✅ "✅ Usando PhotoPicker API (Android 13+)"
✅ "✅ Foto selecionada via PhotoPicker"
```

**Resultado Esperado:**
- ✅ Foto é selecionada
- ✅ Preview aparece na tela
- ✅ Nenhum erro ou crash

---

### TESTE 2: Portaria Representante - Galeria (Fallback)

**Na mesma tela:**
1. Clique no botão: 🖼️ (Galeria)
2. Selecione uma foto existente

**O que procurar nos LOGS:**
```
✅ "🎯 Iniciando seleção de foto..."
✅ "✅ Usando PhotoPicker API (Android 13+)"
✅ "✅ Foto selecionada via PhotoPicker"
```

**Resultado Esperado:**
- ✅ Galeria abre
- ✅ Você consegue selecionar foto
- ✅ Photo aparece

---

### TESTE 3: Detalhes Unidade - Múltiplas Fotos

**Navegação:**
```
1. Vá para: Menu → Unidades
2. Selecione uma unidade existente
3. Procure pela seção: "Fotos" ou "Imagens"
```

**Teste 3A: Foto Imobiliária**
- Clique em: Adicionar/Editar Foto Imobiliária
- Escolha câmera
- Tire uma foto
- ✅ Foto deve aparecer

**Teste 3B: Foto Proprietário**
- Clique em: Adicionar/Editar Foto Proprietário
- Escolha galeria
- Selecione uma foto
- ✅ Foto deve aparecer

**Teste 3C: Foto Inquilino**
- Clique em: Adicionar/Editar Foto Inquilino
- Escolha câmera
- Tire uma foto
- ✅ Foto deve aparecer

**O que procurar nos LOGS:**
```
✅ Cada vez que tira foto, deve aparecer:
   "🎯 Iniciando seleção de foto..."
   "✅ Usando PhotoPicker API (Android 13+)"
```

---

### TESTE 4: Configurar Ambientes - Múltiplas Fotos

**Navegação:**
```
1. Menu → Configurações
2. Selecione: "Ambientes"
3. Clique em: Editar ou Adicionar Ambiente
```

**O que fazer:**
1. Tente adicionar múltiplas fotos
2. Use câmera e galeria
3. Verifique que tudo funciona

**O que procurar nos LOGS:**
- ✅ Múltiplas linhas de "Foto selecionada"

---

### TESTE 5: Portaria Inquilino

**Navegação:**
```
1. Menu → Portaria
2. Selecione: "Inquilino"
3. Procure por: Upload de Foto
```

**O que fazer:**
1. Tente tirar foto com câmera
2. Tente selecionar da galeria

**O que procurar:**
- ✅ Funciona sem erros

---

## 🔄 PASSO 4: Testar Fallback (Android 12)

### Trocar para Emulador Android 12

**No Android Studio:**
1. **Device Manager**
2. **Create device**
3. Escolha: **API 31 ou 32** (Android 11-12)
4. Crie e abra

**No Terminal:**
```bash
flutter devices  # para ver id do emulador

flutter run -d <android_12_device_id>
```

**Testes:**
1. Repita TESTES 1-4 acima
2. Procure nos LOGS:
```
✅ "📱 SDK Version: 31"
✅ "✅ Usando ImagePicker (Android 9-12 ou Câmera)"
```

**Diferença:**
- Pode aparecer pedido de permissão nativa do Android
- Depois disso, funciona normalmente

---

## 📊 PASSO 5: Verificar Logs Completos

### Abra Logcat e procure por:

**Sucesso - Android 13+ PhotoPicker:**
```
I  📱 Android Info:
I  Versão SDK: 33
I  Release: 13.0
I  🎯 Iniciando seleção de foto...
I  ✅ Usando PhotoPicker API (Android 13+)
I  ✅ Foto selecionada via PhotoPicker
```

**Sucesso - Android 12 ImagePicker:**
```
I  📱 Android Info:
I  Versão SDK: 31
I  Release: 12.0
I  🎯 Iniciando seleção de foto...
I  ✅ Usando ImagePicker (Android 9-12 ou Câmera)
```

**Erro - Não deveria aparecer:**
```
❌ "MissingPluginException"
❌ "Unresolved reference"
❌ "NoSuchMethodError"
```

---

## ✅ PASSO 6: Verificar Permissões

### No Dispositivo/Emulador:

```
Settings → Apps → CondoGaia → Permissions
```

**Esperado em Android 13+:**
- ✅ Camera (pedida pelo app)
- ❌ Nenhuma permissão de "Files" ou "All Files"

**Esperado em Android 12:**
- ✅ Camera
- ✅ Storage (por fallback)

---

## 📝 CHECKLIST DE VALIDAÇÃO

Coloque um ✅ conforme valida cada item:

```
TESTE 1: Portaria Representante
- [ ] Câmera funciona
- [ ] Galeria funciona
- [ ] Logs mostram PhotoPicker (Android 13+)
- [ ] Logs mostram ImagePicker (Android 12)
- [ ] Sem crash ou erro

TESTE 2: Detalhes Unidade
- [ ] Foto Imobiliária (câmera) funciona
- [ ] Foto Imobiliária (galeria) funciona
- [ ] Foto Proprietário funciona
- [ ] Foto Inquilino funciona
- [ ] Nenhum erro

TESTE 3: Configurar Ambientes
- [ ] Múltiplas fotos funcionam
- [ ] Câmera funciona
- [ ] Galeria funciona
- [ ] Upload funciona

TESTE 4: Portaria Inquilino
- [ ] Upload de foto funciona
- [ ] Câmera funciona
- [ ] Galeria funciona

TESTE 5: Android 12 Fallback
- [ ] Tudo funciona
- [ ] Pede permissão de storage (normal)
- [ ] Logs mostram ImagePicker

PERMISSÕES
- [ ] Sem permissões excessivas em Android 13+
- [ ] Permissões normais em Android 12

GERAL
- [ ] Nenhum crash
- [ ] Nenhum erro no Logcat
- [ ] App funciona completamente
```

---

## 🚨 SE ALGO NÃO FUNCIONAR

### Erro: "PhotoPickerService não encontrado"
```bash
# Solução:
flutter clean
flutter pub get
flutter run
```

### Erro: "device_info_plus not available"
```bash
# Solução:
# 1. Abra pubspec.yaml
# 2. Verifique se tem: device_info_plus: ^9.0.0
# 3. flutter pub get
# 4. flutter run
```

### Crash ao abrir câmera
```
# Verifique em AndroidManifest.xml:
<uses-permission android:name="android.permission.CAMERA" />

# Se não tiver, adicione!
```

### Logs não aparecem
```
# No Android Studio:
# View → Tool Windows → Logcat
# OU: Ctrl + Alt + 6

# Procure por filtro "photo_picker" ou "PhotoPicker"
```

---

## ✨ APÓS VALIDAR TUDO

Se todos os testes passaram:

```bash
# Build final
flutter build appbundle --release

# Resultado:
# ✅ build/app/outputs/bundle/release/app-release.aab
```

**Próximo: Upload no Google Play Console!** 🚀

---

**Tempo estimado:** 30-45 minutos  
**Dúvidas?** Consulte `GUIA_TESTES_PHOTOPICKER.md` para mais detalhes
