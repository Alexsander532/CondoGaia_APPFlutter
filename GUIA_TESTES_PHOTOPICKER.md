# 🧪 GUIA COMPLETO DE TESTES - PhotoPicker Migration

**Data:** 28 de Novembro de 2025  
**Status:** Pronto para Testes  
**Telas Modificadas:** 4 (Críticas completadas)

---

## 🎯 OBJETIVO DOS TESTES

Validar que:
1. ✅ PhotoPickerService funciona corretamente
2. ✅ Seleção de fotos funciona em Android 9, 12 e 13+
3. ✅ Fallback automático funciona para Android < 13
4. ✅ Todas as telas conseguem selecionar e fazer upload de fotos
5. ✅ Não há permissões desnecessárias no Android 13+
6. ✅ Google Play Console aceita o novo app bundle

---

## 🏗️ PASSO 1: Preparação do Build

### 1.1 Limpar e Sincronizar
```bash
cd C:\Users\Alexsander\Desktop\Aplicativos\APPflutter\condogaiaapp

# Limpar builds anteriores
flutter clean

# Sincronizar dependências
flutter pub get

# Verificar se há erros
flutter analyze
```

**O que observar:**
- ❌ Nenhum erro deve aparecer
- ✅ `Device_info_plus` deve ser listada nas dependências
- ✅ `PhotoPickerService` deve ser encontrada

### 1.2 Verificar Imports
Procure por erros de import não resolvidos:
```bash
# Procura por erro de import
grep -r "photo_picker_service" lib/
```

**Esperado:**
- ✅ Vários arquivos importando `photo_picker_service.dart`

---

## 🏃 PASSO 2: Testar em Emulador (Recomendado)

### 2.1 Emulador Android 13+ (com PhotoPicker)

**Configuração:**
- Crie um emulador com API 33+ (Android 13+)
- Abra no Android Studio ou use CLI

**Comandos:**
```bash
# Listar emuladores disponíveis
flutter emulators

# Lançar emulador específico
flutter emulators --launch <emulator_id>

# Rodar app em debug
flutter run -d <emulator_id>
```

**Testes a Fazer:**

#### **Teste 1: Logs de Debug**
1. Abra `lib/services/photo_picker_service.dart`
2. Procure pelos logs `debugPrint`
3. No app em execução, abra Logcat:
   ```
   Ctrl + Alt + 6 (Android Studio)
   ```
4. Procure por:
   ```
   ✅ SDK Version: 33  (ou maior)
   ✅ Usando PhotoPicker API (Android 13+)
   ✅ Foto selecionada via PhotoPicker
   ```

**Resultado Esperado:**
```
📱 SDK Version: 33
✅ Usando PhotoPicker API (Android 13+)
📷 Abrindo câmera...
✅ Foto selecionada via PhotoPicker
```

#### **Teste 2: Tela Portaria Representante (CRÍTICA)**
1. Login no app
2. Vá para: **Portaria → Representante**
3. Tente fazer upload de foto de encomenda:
   - Clique no botão de câmera
   - Tire uma foto (ou selecione da galeria)
   - Verifique se a foto aparece
4. Repita com botão de galeria

**Validações:**
- ✅ Dialog abre corretamente
- ✅ Foto é selecionada
- ✅ Preview aparece
- ✅ Sem erro de permissão
- ✅ Logs mostram "PhotoPicker API"

#### **Teste 3: Tela Detalhes Unidade**
1. Vá para: **Unidades → Selecione uma → Fotos**
2. Tente fazer upload de 3 tipos de fotos:
   - Foto Imobiliária
   - Foto Proprietário
   - Foto Inquilino
3. Para cada uma: câmera + galeria

**Validações:**
- ✅ Cada uma funciona
- ✅ Foto é salva
- ✅ Sem erros

#### **Teste 4: Tela Portaria Inquilino**
1. Vá para: **Portaria → Inquilino**
2. Selecione um inquilino
3. Tente fazer upload de foto

**Validações:**
- ✅ Funciona
- ✅ Foto enviada

#### **Teste 5: Tela Configurar Ambientes**
1. Vá para: **Configurações → Ambientes**
2. Tente adicionar/editar ambiente com foto

**Validações:**
- ✅ Funciona
- ✅ Foto enviada

---

### 2.2 Emulador Android 12 (Fallback ImagePicker)

**Configuração:**
- Crie um emulador com API 31 (Android 12)

**Comandos:**
```bash
flutter run -d <android_12_emulator>
```

**Testes:**
1. Repita todos os testes acima
2. Procure nos logs por:
   ```
   📱 SDK Version: 31
   ✅ Usando ImagePicker (Android 9-12 ou Câmera)
   ```

**Diferença Esperada:**
- Aparecerá dialog nativo do Android de permissão (READ_EXTERNAL_STORAGE)
- Depois disso, galeria abre normalmente

---

### 2.3 Emulador Android 9 (Fallback Máximo)

**Configuração:**
- Crie um emulador com API 28 (Android 9)

**Testes:**
1. Repita tudo
2. Logs devem mostrar:
   ```
   📱 SDK Version: 28
   ✅ Usando ImagePicker (Android 9-12 ou Câmera)
   ```

---

## 📱 PASSO 3: Testar em Dispositivo Real (Importante!)

### 3.1 Dispositivo Real Android 13+

**Preparação:**
```bash
# Habilitar developer mode e USB debugging
# Conectar telefone

# Listar dispositivos
flutter devices

# Rodar no dispositivo
flutter run -d <device_id>
```

**Testes:**
1. Repita todos os testes da seção 2.1
2. **Testar seleção de múltiplas fotos:**
   - Abra configurar ambientes
   - Tente adicionar múltiplas fotos
   - Logs devem mostrar PhotoPicker

3. **Testar sem permissões excessivas:**
   - Vá para: Settings → Apps → CondoGaia → Permissions
   - ⚠️ NÃO deve ter "Files" ou "All Files"
   - ✅ Apenas: Camera, Internet (esperado)

---

## 🔍 PASSO 4: Verificar AndroidManifest.xml

### 4.1 Verificar Permissões Declaradas

Abra: `android/app/src/main/AndroidManifest.xml`

```xml
<!-- Deve ter isso: -->
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.INTERNET" />

<!-- Compatibilidade Android 9-12: -->
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />

<!-- Deve TER SIDO REMOVIDO: -->
❌ READ_MEDIA_VIDEO (você já removeu isso!)
❌ READ_MEDIA_AUDIO
```

**Validação:**
- ✅ READ_MEDIA_IMAGES PODE estar aí (fallback)
- ✅ READ_MEDIA_VIDEO NÃO deve estar
- ✅ MANAGE_EXTERNAL_STORAGE é OK

---

## 🏗️ PASSO 5: Build para Release

### 5.1 Limpar e Buildar

```bash
flutter clean
flutter pub get

# Build APK (para teste rápido)
flutter build apk --release

# Build App Bundle (para Play Store)
flutter build appbundle --release
```

**Esperado:**
- ✅ Exit Code: 0
- ✅ Arquivo gerado: `build/app/outputs/bundle/release/app-release.aab`
- ❌ Nenhum erro ou warning crítico

### 5.2 Verificar Tamanho do App

```
Tempo de build normal: ~10-15 minutos
Tamanho AAB: ~40-50 MB
Sem permissões excessivas
```

---

## 📋 CHECKLIST FINAL DE TESTES

### Tela: Portaria Representante ✅
- [ ] Foto câmera: funciona
- [ ] Foto galeria (fallback): funciona
- [ ] Logs mostram PhotoPicker (Android 13+)
- [ ] Logs mostram ImagePicker (Android 9-12)
- [ ] Sem erro de permissão

### Tela: Detalhes Unidade ✅
- [ ] Foto Imobiliária câmera: funciona
- [ ] Foto Imobiliária galeria: funciona
- [ ] Foto Proprietário: funciona
- [ ] Foto Inquilino: funciona
- [ ] Todas salvam corretamente

### Tela: Portaria Inquilino ✅
- [ ] Foto upload: funciona
- [ ] Galeria: funciona

### Tela: Configurar Ambientes ✅
- [ ] Múltiplas fotos: funciona
- [ ] Upload ambiente: funciona

### Geral ✅
- [ ] Build APK bem-sucedido
- [ ] Build AAB bem-sucedido
- [ ] Sem erros de import
- [ ] Sem erros de permissão
- [ ] Logs aparecem corretamente
- [ ] App não crasha ao selecionar foto
- [ ] Fotos são enviadas corretamente

---

## 🐛 TROUBLESHOOTING

### Problema: "PhotoPickerService não encontrado"
```
❌ Erro: Unresolved reference: 'PhotoPickerService'
```

**Solução:**
1. Verifique se arquivo existe: `lib/services/photo_picker_service.dart`
2. Verify import está correto em todos os screens
3. Execute: `flutter clean && flutter pub get`

---

### Problema: "device_info_plus não está instalada"
```
❌ Erro: MissingPluginException
```

**Solução:**
1. Verifique `pubspec.yaml` tem `device_info_plus: ^9.0.0`
2. Execute: `flutter pub get`
3. Reconstruir app

---

### Problema: "Permissão de camera não aparece"
```
❌ App crasha ao tentar abrir câmera
```

**Solução:**
1. Verifique `AndroidManifest.xml` tem:
   ```xml
   <uses-permission android:name="android.permission.CAMERA" />
   ```
2. App pede permissão em runtime (normal)

---

### Problema: "Android 13+ não usa PhotoPicker"
```
❌ Logs mostram ImagePicker mesmo em Android 13+
```

**Solução:**
1. Verifique `device_info_plus` instalado
2. Verifique método `_canUsePhotoPicker()` em `photo_picker_service.dart`
3. Adicione debug print para verificar SDK:
   ```dart
   await photoPickerService.printAndroidInfo();
   ```

---

## ✅ APÓS VALIDAR TUDO

1. **Se tudo passou:**
   ```
   ✅ Pronto para upload no Google Play Console!
   ```

2. **Upload no Play Console:**
   - Arquivo: `build/app/outputs/bundle/release/app-release.aab`
   - Versão: 1.1.2+12
   - Adicione justificativa de permissão (já temos em `JUSTIFICATIVA_NOVA_HONESTA.md`)

3. **Aguarde revisão:** 24-48 horas

---

## 📱 COMANDOS RÁPIDOS DE REFERÊNCIA

```bash
# Limpar tudo
flutter clean

# Sincronizar dependências
flutter pub get

# Analisar código
flutter analyze

# Rodar em debug no dispositivo padrão
flutter run

# Rodar em debug em dispositivo específico
flutter run -d <device_id>

# Build APK release
flutter build apk --release

# Build App Bundle release
flutter build appbundle --release

# Ver logs
flutter logs

# Ver permissões do app instalado
adb shell pm list permissions -g | grep condogaia
```

---

## 🎯 RESULTADO ESPERADO

Se todos os testes passarem:

```
✅ PhotoPickerService funciona
✅ Todos os screens conseguem selecionar fotos
✅ Android 13+ usa PhotoPicker (sem permissões excessivas)
✅ Android 9-12 usa ImagePicker (com fallback correto)
✅ Google Play Console aceita o novo app bundle
✅ App publicado com sucesso!
```

---

**Tempo estimado de testes:** 30-45 minutos  
**Próximo passo:** Upload no Play Console

Comece pelos testes básicos no Logcat! 🚀
