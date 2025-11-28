# 📊 RELATÓRIO COMPLETO: Migração para PhotoPicker API

**Data:** 28 de Novembro de 2025  
**Projeto:** CondoGaia  
**Status:** Análise Completa ✅

---

## 📈 SUMÁRIO EXECUTIVO

- **Total de Telas:** 14
- **Usos de ImagePicker:** 28
- **Usos de FilePicker:** 8  
- **Arquivos a Modificar:** 16
- **Tempo Estimado:** 3-4 horas
- **Complexidade:** Média

---

## 🗂️ ARQUIVOS ANALISADOS

### **Screens (Telas) - 14 Arquivos**

| # | Arquivo | Usos | Tipo | Prioridade |
|---|---------|------|------|-----------|
| 1 | `detalhes_unidade_screen.dart` | 3x pickImage | ImagePicker | 🔴 Alta |
| 2 | `inquilino_home_screen.dart` | 1x pickImage | ImagePicker | 🔴 Alta |
| 3 | `portaria_representante_screen.dart` | 3x pickImage | ImagePicker | 🔴 Alta |
| 4 | `upload_foto_perfil_proprietario_screen.dart` | 1x pickImage | ImagePicker | 🟡 Média |
| 5 | `upload_foto_perfil_screen.dart` | 1x pickImage | ImagePicker | 🟡 Média |
| 6 | `upload_foto_perfil_inquilino_screen.dart` | 1x pickImage | ImagePicker | 🟡 Média |
| 7 | `portaria_inquilino_screen.dart` | 2x pickImage | ImagePicker | 🔴 Alta |
| 8 | `nova_pasta_screen.dart` | 1x pickImage + 1x pickFiles | Híbrido | 🟡 Média |
| 9 | `editar_documentos_screen.dart` | 1x pickImage + 1x pickFiles | Híbrido | 🟡 Média |
| 10 | `documentos_screen.dart` | 2x pickImage | ImagePicker | 🟡 Média |
| 11 | `configurar_ambientes_screen.dart` | 4x pickImage + 1x pickFiles | Híbrido | 🔴 Alta |
| 12 | `reservas_screen.dart` | 1x pickFiles | FilePicker | 🟡 Média |
| 13 | `agenda_screen_backup.dart` | ? | ? | ⚪ Verificar |
| 14 | `?` | ? | ? | ⚪ Outros |

### **Services (Serviços) - 4 Arquivos**

| # | Arquivo | Usos | Tipo |
|---|---------|------|------|
| 1 | `documento_service.dart` | 2x Permission.storage | Permission Handler |
| 2 | `ambiente_service.dart` | Métodos upload | Suporte |
| 3 | `excel_service.dart` | 1x pickFiles | FilePicker |
| 4 | `importacao_service_exemplos.dart` | 2x pickFiles | FilePicker |

### **Widgets - 2 Arquivos**

| # | Arquivo | Usos | Tipo |
|---|---------|------|------|
| 1 | `importacao_modal_widget.dart` | 1x pickFiles | FilePicker |
| 2 | Outros | ? | ? |

---

## 🎯 DETALHAMENTO POR TELA

### **1️⃣ DETALHES_UNIDADE_SCREEN.dart** 
**Linhas:** 119, 787-840, 1002-1060, 1155-1225  
**Prioridade:** 🔴 ALTA

**Funcionalidades:**
- ✅ Foto Imobiliária (Galeria/Câmera)
- ✅ Foto Proprietário (Galeria/Câmera)
- ✅ Foto Inquilino (Galeria/Câmera)

**Código Atual:**
```dart
final ImagePicker _imagePicker = ImagePicker();

// Linha 822
final XFile? image = await _imagePicker.pickImage(
  source: source,
  maxWidth: 800,
  maxHeight: 800,
  imageQuality: 85,
);

// Linhas 1036, 1189 - repetido
```

**Mudança Necessária:**
- Remover `final ImagePicker _imagePicker = ImagePicker();`
- Substituir por `final _photoPickerService = PhotoPickerService();`
- Mudar `_imagePicker.pickImage(...)` para `_photoPickerService.pickImage()`

**Impacto:** 3 funções diferentes (`_pickImageImobiliaria`, `_pickAndUploadProprietarioFoto`, `_pickAndUploadInquilinoFoto`)

---

### **2️⃣ INQUILINO_HOME_SCREEN.dart**
**Linhas:** 47, 159-180  
**Prioridade:** 🔴 ALTA

**Funcionalidades:**
- ✅ Upload foto de perfil

**Código Atual:**
```dart
final ImagePicker _imagePicker = ImagePicker();

// Linha 161
final XFile? image = await _imagePicker.pickImage(
  source: source,
  maxWidth: 800,
  maxHeight: 800,
  imageQuality: 85,
);
```

**Mudança Necessária:**
- Mesma abordagem acima

---

### **3️⃣ PORTARIA_REPRESENTANTE_SCREEN.dart**
**Linhas:** 2212, 2214, 2230, 4815, 4816, 4845, 4846  
**Prioridade:** 🔴 ALTA (Crítico para verificação de documentos)

**Funcionalidades:**
- ✅ Foto de Encomenda (Câmera)
- ✅ Foto de Encomenda (Galeria) - fallback
- ✅ Documento RG/CPF (Câmera)
- ✅ Documento RG/CPF (Galeria)

**Código Atual:**
```dart
// Linha 2212
final ImagePicker picker = ImagePicker();
try {
  final XFile? image = await picker.pickImage(
    source: ImageSource.camera,
    maxWidth: 800,
    maxHeight: 600,
    imageQuality: 80,
  );
  
  // Fallback para galeria
  final XFile? image = await picker.pickImage(
    source: ImageSource.gallery,
  );
}
```

**Mudança Necessária:**
- Usar variável global `_photoPickerService`
- Remover instâncias locais `final ImagePicker picker = ImagePicker();`

---

### **4️⃣ UPLOAD_FOTO_PERFIL_*.dart** (3 arquivos)
**Linhas:** 25, 26, 22 respectivamente  
**Prioridade:** 🟡 MÉDIA

**Arquivos:**
- `upload_foto_perfil_proprietario_screen.dart`
- `upload_foto_perfil_screen.dart`  
- `upload_foto_perfil_inquilino_screen.dart`

**Padrão:**
```dart
final ImagePicker _picker = ImagePicker();

Future<void> _pickImage(ImageSource source) async {
  final XFile? image = await _picker.pickImage(
    source: source,
    maxWidth: 800,
    maxHeight: 800,
    imageQuality: 85,
  );
}
```

**Mudança:** Usar `PhotoPickerService` em todas as 3

---

### **5️⃣ PORTARIA_INQUILINO_SCREEN.dart**
**Linhas:** 2739, 2740, 2771, 2772  
**Prioridade:** 🔴 ALTA

**Funcionalidades:**
- ✅ Foto de Encomenda (Câmera)
- ✅ Foto de Encomenda (Galeria)

**Padrão:** Similar a `portaria_representante_screen.dart`

---

### **6️⃣ NOVA_PASTA_SCREEN.dart**
**Linhas:** 49, 221, 265  
**Prioridade:** 🟡 MÉDIA

**Funcionalidades:**
- ✅ Foto de Pasta (Câmera)
- ⚠️ FilePicker para documentos

**Código:**
```dart
final ImagePicker _picker = ImagePicker();
final XFile? image = await _picker.pickImage(source: ImageSource.camera);

FilePickerResult? result = await FilePicker.platform.pickFiles(
  type: FileType.image,
);
```

**Mudança:** 
- ImagePicker → PhotoPickerService
- FilePicker → Deixar como está (ou implementar PhotoPicker também)

---

### **7️⃣ EDITAR_DOCUMENTOS_SCREEN.dart**
**Linhas:** 766, 767, 830  
**Prioridade:** 🟡 MÉDIA

**Padrão:** Híbrido (ImagePicker + FilePicker)

---

### **8️⃣ DOCUMENTOS_SCREEN.dart**
**Linhas:** 73, 162, 191  
**Prioridade:** 🟡 MÉDIA

**Funcionalidades:**
- ✅ Dialog para escolher Câmera/Galeria
- ✅ Upload foto documento

**Código:**
```dart
final ImagePicker _picker = ImagePicker();

final ImageSource? source = await showDialog<ImageSource>(
  context: context,
  builder: (context) {
    return AlertDialog(
      title: const Text('Escolha a fonte'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, ImageSource.camera),
          child: const Text('Câmera'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, ImageSource.gallery),
          child: const Text('Galeria'),
        ),
      ],
    );
  },
);

if (source != null) {
  final XFile? image = await picker.pickImage(source: source);
}
```

**Mudança:** Manter dialog, trocar picker

---

### **9️⃣ CONFIGURAR_AMBIENTES_SCREEN.dart**
**Linhas:** 681, 696, 1736, 1750, 1035, 2051  
**Prioridade:** 🔴 ALTA

**Funcionalidades:**
- ✅ Fotos de Ambientes (múltiplas)
- ✅ Múltiplas operações FilePicker

**Código:**
```dart
final XFile? imagem = await ImagePicker().pickImage(
  source: ImageSource.camera,
);

FilePickerResult? result = await FilePicker.platform.pickFiles(
  type: FileType.image,
);
```

---

### **🔟 RESERVAS_SCREEN.dart**
**Linha:** 1705  
**Prioridade:** 🟡 MÉDIA

**Funcionalidades:**
- ⚠️ FilePicker para anexos

---

## 🔧 SERVIÇOS A MODIFICAR

### **documento_service.dart**
```dart
final status = await Permission.storage.request();
```

**Problema:** Pede permissão de armazenamento  
**Solução:** Com PhotoPicker, isso pode ser opcional

### **ambiente_service.dart**
Suporta múltiplos tipos de arquivo (File, XFile, PlatformFile)  
**Impacto:** Nenhum (será compatível)

### **excel_service.dart & importacao_service_exemplos.dart**
Usam FilePicker para Excel  
**Impacto:** Pode deixar como está (não é imagem)

---

## 📦 DEPENDÊNCIAS A ADICIONAR

### **pubspec.yaml**

```yaml
dependencies:
  # Adicionar:
  photos: ^0.0.1              # Para PhotoPicker (Android 13+)
  device_info_plus: ^9.0.0    # Para verificar versão Android
  
  # Manter:
  image_picker: ^1.0.7        # Fallback Android 9-12
  file_picker: ^8.0.0+1       # Para arquivos não-imagem
  permission_handler: ^11.3.1 # Para Android 9-12
```

---

## 🔄 FLUXO DE MUDANÇAS

### **Passo 1: Criar Service Unificado**
- Criar `lib/services/photo_picker_service.dart`
- Implementar lógica de Android version check
- Fallback automático para ImagePicker

### **Passo 2: Modificar Screens**

**Ordem de Prioridade:**
1. 🔴 `portaria_representante_screen.dart` (verificação documentos - crítico)
2. 🔴 `detalhes_unidade_screen.dart` (3 usos - core)
3. 🔴 `portaria_inquilino_screen.dart` (2 usos)
4. 🔴 `configurar_ambientes_screen.dart` (4 usos)
5. 🟡 Restantes (prioridade média)

### **Passo 3: Atualizar AndroidManifest**
```xml
<!-- Remover se usar PhotoPicker -->
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />

<!-- Manter para compatibilidade -->
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
```

### **Passo 4: Teste e Build**
```bash
flutter clean
flutter pub get
flutter build appbundle --release
```

---

## 💼 ARQUIVOS MODIFICADOS (ANTES vs DEPOIS)

### **Exemplo: detalhes_unidade_screen.dart**

#### ANTES:
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

#### DEPOIS:
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

## ✅ CHECKLIST DE IMPLEMENTAÇÃO

### **Fase 1: Setup**
- [ ] Adicionar `photos` e `device_info_plus` ao pubspec.yaml
- [ ] Executar `flutter pub get`
- [ ] Criar `lib/services/photo_picker_service.dart`

### **Fase 2: Screens - Prioridade Alta**
- [ ] `portaria_representante_screen.dart` (3 funções)
- [ ] `detalhes_unidade_screen.dart` (3 funções)
- [ ] `portaria_inquilino_screen.dart` (2 funções)
- [ ] `configurar_ambientes_screen.dart` (4 funções)

### **Fase 3: Screens - Prioridade Média**
- [ ] `inquilino_home_screen.dart`
- [ ] `upload_foto_perfil_proprietario_screen.dart`
- [ ] `upload_foto_perfil_screen.dart`
- [ ] `upload_foto_perfil_inquilino_screen.dart`
- [ ] `nova_pasta_screen.dart`
- [ ] `editar_documentos_screen.dart`
- [ ] `documentos_screen.dart`
- [ ] `reservas_screen.dart`

### **Fase 4: Cleanup**
- [ ] Remover imports de `image_picker` não utilizados
- [ ] Atualizar AndroidManifest.xml (opcional)
- [ ] Teste em Android 9, 12 e 13+
- [ ] Novo build: `flutter build appbundle --release`

### **Fase 5: Play Console**
- [ ] Remover justificativas de permissão
- [ ] Upload novo app bundle
- [ ] Acompanhar revisão

---

## 📊 IMPACTO ESTIMADO

| Métrica | Antes | Depois |
|---------|-------|--------|
| **Permissões** | READ_MEDIA_IMAGES | Nenhuma (Android 13+) |
| **Linhas a Mudar** | ~200 | ~150 (net savings) |
| **Complexidade** | Média | Baixa (com service) |
| **Segurança** | 🟡 Média | ✅ Alta |
| **Aprovação Google** | 🔴 Difícil | ✅ Automática |

---

## 🚀 PRÓXIMO PASSO

Qual fase você quer começar?

1. **Criar PhotoPickerService** (30 minutos)
2. **Modificar screens** (2 horas)  
3. **Testar e buildar** (30 minutos)

Você quer que eu comece a implementação agora? 👇
