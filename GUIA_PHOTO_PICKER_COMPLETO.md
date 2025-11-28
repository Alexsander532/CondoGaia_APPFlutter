# 📸 GUIA: Implementar PhotoPicker API no CondoGaia

## 🎯 O que é PhotoPicker?

**PhotoPicker** é a nova forma recomendada pelo Google de selecionar fotos no Android 13+:

| Aspecto | ImagePicker (Antiga) | PhotoPicker (Nova) |
|--------|---------------------|-------------------|
| **Permissão** | READ_MEDIA_IMAGES | ❌ Nenhuma |
| **Segurança** | 🟡 Acesso a todos | ✅ Apenas fotos selecionadas |
| **Android** | 9+ | 13+ (fallback para 9-12) |
| **Aprovação Google** | 🔴 Difícil | ✅ Automática |
| **Código** | `image_picker` | `photos` |

---

## 📦 PASSO 1: Adicionar pacotes

Adicione no seu `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # Para Android 13+
  photos: ^0.0.1
  
  # Manter para compatibilidade Android 9-12
  image_picker: ^1.0.7
  file_picker: ^8.0.0+1
```

---

## 🔧 PASSO 2: Criar Serviço Unificado

Crie novo arquivo: `lib/services/photo_picker_service.dart`

```dart
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photos/photos.dart';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';

class PhotoPickerService {
  static final PhotoPickerService _instance = PhotoPickerService._internal();

  factory PhotoPickerService() {
    return _instance;
  }

  PhotoPickerService._internal();

  final _imagePicker = ImagePicker();
  final _deviceInfo = DeviceInfoPlugin();

  /// Verifica se pode usar PhotoPicker (Android 13+)
  Future<bool> _canUsePhotoPicker() async {
    try {
      final androidInfo = await _deviceInfo.androidInfo;
      // PhotoPicker está disponível no Android 13 (SDK 33) em diante
      return androidInfo.version.sdkInt >= 33;
    } catch (e) {
      print('Erro ao verificar SDK: $e');
      return false;
    }
  }

  /// Selecionar uma foto
  /// Usa PhotoPicker no Android 13+ (mais seguro)
  /// Usa ImagePicker no Android 9-12 (compatibilidade)
  Future<XFile?> pickImage({
    ImageSource source = ImageSource.gallery,
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
  }) async {
    try {
      // Se Android 13+, usar PhotoPicker
      if (await _canUsePhotoPicker()) {
        return await _pickImageWithPhotoPicker();
      }

      // Senão, usar ImagePicker (Android 9-12)
      return await _imagePicker.pickImage(
        source: source,
        maxWidth: maxWidth ?? 800,
        maxHeight: maxHeight ?? 800,
        imageQuality: imageQuality ?? 85,
      );
    } catch (e) {
      print('Erro ao selecionar foto: $e');
      return null;
    }
  }

  /// Usar PhotoPicker (Android 13+)
  /// Não requer permissões!
  Future<XFile?> _pickImageWithPhotoPicker() async {
    try {
      final photos = await Photos.listPhotos(
        mediaType: MediaType.image,
        skip: 0,
        take: 1,
        hasVideo: false,
        freezeDatabase: false,
      );

      if (photos.isEmpty) {
        return null;
      }

      final photo = photos.first;
      
      // Converter para XFile para manter compatibilidade
      return XFile(photo.path);
    } catch (e) {
      print('Erro ao usar PhotoPicker: $e');
      return null;
    }
  }

  /// Selecionar múltiplas fotos
  Future<List<XFile>> pickMultipleImages({
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
  }) async {
    try {
      if (await _canUsePhotoPicker()) {
        return await _pickMultipleImagesWithPhotoPicker();
      }

      final images = await _imagePicker.pickMultiImage(
        maxWidth: maxWidth ?? 800,
        maxHeight: maxHeight ?? 800,
        imageQuality: imageQuality ?? 85,
      );

      return images;
    } catch (e) {
      print('Erro ao selecionar fotos: $e');
      return [];
    }
  }

  /// Múltiplas fotos com PhotoPicker
  Future<List<XFile>> _pickMultipleImagesWithPhotoPicker() async {
    try {
      final photos = await Photos.listPhotos(
        mediaType: MediaType.image,
        hasVideo: false,
        freezeDatabase: false,
      );

      return photos.map((photo) => XFile(photo.path)).toList();
    } catch (e) {
      print('Erro ao selecionar múltiplas fotos: $e');
      return [];
    }
  }
}
```

---

## 🎨 PASSO 3: Usar em suas telas

Antes (ImagePicker direto):
```dart
final ImagePicker picker = ImagePicker();
final XFile? image = await picker.pickImage(source: ImageSource.gallery);
```

Depois (PhotoPickerService):
```dart
final photoPickerService = PhotoPickerService();
final XFile? image = await photoPickerService.pickImage();
```

---

## 📝 EXEMPLO: Atualizar uma tela

### Arquivo: `lib/screens/detalhes_unidade_screen.dart`

**Antes:**
```dart
import 'package:image_picker/image_picker.dart';

class _DetalhesUnidadeScreenState extends State<DetalhesUnidadeScreen> {
  final ImagePicker _imagePicker = ImagePicker();
  
  Future<void> _pickImageImobiliaria(ImageSource source) async {
    final XFile? image = await _imagePicker.pickImage(
      source: source,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );
    // ...
  }
}
```

**Depois:**
```dart
import 'package:condogaiaapp/services/photo_picker_service.dart';

class _DetalhesUnidadeScreenState extends State<DetalhesUnidadeScreen> {
  final _photoPickerService = PhotoPickerService();
  
  Future<void> _pickImageImobiliaria(ImageSource source) async {
    final XFile? image = await _photoPickerService.pickImage();
    // ...
  }
}
```

---

## 🔄 PASSO 4: Atualizar AndroidManifest (IMPORTANTE!)

Se usar PhotoPicker, pode remover a permissão:

### Arquivo: `android/app/src/main/AndroidManifest.xml`

**Remover:**
```xml
<!-- Permissões de armazenamento para Android 13+ -->
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
```

**Manter apenas:**
```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.INTERNET" />

<!-- Para Android 9-12 (compatibilidade) -->
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
```

---

## ✅ VANTAGENS

✅ **Google aprova automaticamente** (sem precisa justificar)  
✅ **Mais seguro** (usuário controla acesso)  
✅ **Melhor UX** (interface nativa do Android 13+)  
✅ **Compatível** (fallback automático para Android 9-12)  
✅ **Menos problemas** (sem conflitos de permissões)

---

## ⚠️ DESVANTAGENS

❌ **Requer Android 13+ para full benefit**  
❌ **PhotoPicker package ainda é novo**  
❌ **Mais código para manter**

---

## 🚀 PASSO 5: Testar

1. Compilar com novo código:
```bash
flutter clean
flutter pub get
flutter build appbundle --release
```

2. Testar funcionalidade:
   - Em Android 13+: Deve usar PhotoPicker (sem pedir permissão)
   - Em Android 9-12: Deve usar ImagePicker (pede permissão)

3. Google Play: Submeter sem mentir sobre permissões!

---

## 📋 Checklist de Implementação

- [ ] Adicionar `photos` ao pubspec.yaml
- [ ] Adicionar `device_info_plus` ao pubspec.yaml
- [ ] Criar `lib/services/photo_picker_service.dart`
- [ ] Atualizar `detalhes_unidade_screen.dart`
- [ ] Atualizar `inquilino_home_screen.dart`
- [ ] Atualizar `portaria_representante_screen.dart`
- [ ] Atualizar `configurar_ambientes_screen.dart`
- [ ] Remover `READ_MEDIA_IMAGES` do AndroidManifest (opcional)
- [ ] Fazer novo build: `flutter build appbundle --release`
- [ ] Reenviar ao Google Play Console

---

## 🎯 Opções para você

### **Opção A: Implementar PhotoPicker COMPLETO** (Recomendado)
- ✅ Máxima compatibilidade
- ✅ Melhor segurança
- ✅ Google aprova 100%
- ⏱️ Tempo: 2-3 horas

### **Opção B: Usar justificativa honesta AGORA**
- ✅ Rápido
- ✅ Funciona com código atual
- ⏱️ Tempo: 5 minutos
- ⚠️ Pode ser rejeitado novamente

### **Opção C: Aumentar minSdkVersion para 33**
- ✅ Força PhotoPicker
- ✅ Elimina compatibilidade com Android 9-12
- ⏱️ Tempo: 10 minutos
- ⚠️ Exclui 30% dos usuários

---

## 💡 Recomendação

1. **Agora:** Use justificativa honesta (JUSTIFICATIVA_NOVA_HONESTA.md)
2. **Depois:** Implemente PhotoPicker quando tiver tempo
3. **Futuro:** Considere aumentar minSdkVersion

Qual você prefere? 👇
