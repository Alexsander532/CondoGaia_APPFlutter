# 🧪 TESTES RÁPIDOS - Checklist Visual

## ⚡ ANTES DE COMEÇAR

```bash
# 1. Limpar
flutter clean

# 2. Sincronizar
flutter pub get

# 3. Verificar
flutter analyze
```

**Esperado:** ✅ Nenhum erro

---

## 🎯 5 TESTES PRINCIPAIS (10 minutos)

### ✅ TESTE 1: Portaria Representante
```
1. Abra app em Android 13+ emulador
2. Portaria → Representante
3. Clique em CÂMERA (botão foto encomenda)
4. Abra Logcat (Ctrl+Alt+6)
5. PROCURE POR:
   ✅ "SDK Version: 33"
   ✅ "Usando PhotoPicker API"
   ✅ "Foto selecionada"
```

### ✅ TESTE 2: Galeria (Fallback)
```
1. Mesma tela
2. Se câmera falhar, deve abrir GALERIA
3. Selecione uma foto
4. PROCURE NOS LOGS:
   ✅ "pickImage()" foi chamado
   ✅ Foto foi selecionada
```

### ✅ TESTE 3: Detalhes Unidade
```
1. Vá para UNIDADES → Selecione uma
2. Clique em FOTOS
3. Tente:
   - Foto Imobiliária (câmera)
   - Foto Proprietário (galeria)
   - Foto Inquilino (câmera)
4. Verifique:
   ✅ Todas funcionam
   ✅ Nenhum erro
   ✅ Fotos salvam
```

### ✅ TESTE 4: Configurar Ambientes
```
1. Vá para CONFIGURAÇÕES → Ambientes
2. Adicione/edite ambiente
3. Tente adicionar múltiplas fotos
4. Verifique:
   ✅ Múltiplas fotos funcionam
   ✅ Upload funciona
```

### ✅ TESTE 5: Android 12 (Fallback)
```
1. Mude para emulador Android 12
2. Repita testes 1-4
3. PROCURE NOS LOGS:
   ✅ "SDK Version: 31"
   ✅ "Usando ImagePicker"
   ✅ Pedirá permissão READ_EXTERNAL_STORAGE
4. Verifique:
   ✅ Tudo funciona igual
```

---

## 🔍 LOGS ESPERADOS

### Android 13+ (PhotoPicker)
```
📱 SDK Version: 33
🎯 Iniciando seleção de foto...
✅ Usando PhotoPicker API (Android 13+)
✅ Foto selecionada via PhotoPicker
```

### Android 12 (ImagePicker)
```
📱 SDK Version: 31
🎯 Iniciando seleção de foto...
✅ Usando ImagePicker (Android 9-12 ou Câmera)
```

---

## 🚨 ERROS COMUNS

### ❌ "Unresolved reference: PhotoPickerService"
```
SOLUÇÃO:
1. flutter clean
2. flutter pub get
3. Verificar import em cada arquivo
```

### ❌ "device_info_plus not found"
```
SOLUÇÃO:
1. Verificar pubspec.yaml tem: device_info_plus: ^9.0.0
2. flutter pub get
```

### ❌ "Crash ao abrir câmera"
```
SOLUÇÃO:
1. Verifique AndroidManifest.xml tem:
   <uses-permission android:name="android.permission.CAMERA" />
2. Flutter clean e rodar novamente
```

---

## ✅ DEPOIS DOS TESTES

Se tudo passou:

```bash
# Build final
flutter build appbundle --release

# Arquivo gerado em:
# build/app/outputs/bundle/release/app-release.aab
```

**Upload no Google Play Console:**
1. Vá para Release → Production
2. Upload: app-release.aab
3. Adicione justificativa de permissão (JUSTIFICATIVA_NOVA_HONESTA.md)
4. Clique "Next" e "Review release"
5. Clique "Start rollout to Production"

---

## 📊 RESUMO

| Teste | Android | Esperado | Status |
|-------|---------|----------|--------|
| 1 | 13+ | PhotoPicker | ✅ |
| 2 | 13+ | Galeria fallback | ✅ |
| 3 | 13+ | Múltiplas fotos | ✅ |
| 4 | 13+ | Upload funciona | ✅ |
| 5 | 12 | ImagePicker | ✅ |

---

**Tempo total de testes:** ~30 minutos  
**Próximo passo:** Build e upload no Play Console 🚀
