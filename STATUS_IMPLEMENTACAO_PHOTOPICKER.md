# 🚀 STATUS DE IMPLEMENTAÇÃO - PhotoPicker Migration

**Data:** 28 de Novembro de 2025  
**Tempo Decorrido:** ~30 minutos  
**Progresso:** 2 de 4 telas críticas

---

## ✅ COMPLETO

### **Tela 1: portaria_representante_screen.dart** ✅
- ✅ Import PhotoPickerService adicionado
- ✅ 3 funções atualizadas:
  - `GestureDetector` (linha 2212) - Câmera com fallback galeria
  - `_selecionarFotoVisitanteCamera()` (linha 4845)
  - `_selecionarFotoVisitanteGaleria()` (linha 4870)

### **Tela 2: detalhes_unidade_screen.dart** ✅
- ✅ Import PhotoPickerService adicionado
- ✅ Removido `final ImagePicker _imagePicker`
- ✅ Adicionado `final _photoPickerService = PhotoPickerService()`
- ✅ 3 funções atualizadas:
  - `_pickImageImobiliaria()`
  - `_pickAndUploadProprietarioFoto()`
  - `_pickAndUploadInquilinoFoto()`

---

## 🔄 PRÓXIMAS TELAS CRÍTICAS (Faltam 2)

### **Tela 3: portaria_inquilino_screen.dart** 
**Prioridade:** 🔴 ALTA (2 funções)

**Mudanças:**
```dart
// Linha 1: Adicionar import
import '../services/photo_picker_service.dart';

// Classe: Adicionar serviço
final _photoPickerService = PhotoPickerService();

// Linha 2739: Substituir
// DE: final XFile? image = await picker.pickImage(source: ImageSource.camera);
// PARA: final XFile? image = await _photoPickerService.pickImageFromCamera();

// Linha 2771: Substituir  
// DE: final XFile? image = await picker.pickImage(source: ImageSource.gallery);
// PARA: final XFile? image = await _photoPickerService.pickImage();
```

### **Tela 4: configurar_ambientes_screen.dart**
**Prioridade:** 🔴 ALTA (4 usos de pickImage)

**Mudanças:**
```dart
// Linha 1: Adicionar import
import '../services/photo_picker_service.dart';

// Classe: Adicionar serviço
final _photoPickerService = PhotoPickerService();

// Linhas 681, 696, 1736, 1750: Substituir
// DE: final XFile? imagem = await ImagePicker().pickImage(source: ImageSource.camera);
// PARA: final XFile? imagem = await _photoPickerService.pickImageFromCamera();

// Linhas 1035, 2051: Deixar FilePickerResult como está (não é imagem)
```

---

## 🟡 TELAS MÉDIAS (Prioridade Média - 7 telas)

Todas seguem o **mesmo padrão**:

1. **Adicionar import:**
   ```dart
   import '../services/photo_picker_service.dart';
   ```

2. **Trocar instância:**
   ```dart
   // REMOVER:
   final ImagePicker _picker = ImagePicker();
   
   // ADICIONAR:
   final _photoPickerService = PhotoPickerService();
   ```

3. **Atualizar chamadas:**
   ```dart
   // REMOVER:
   final XFile? image = await _picker.pickImage(source: source);
   
   // ADICIONAR:
   final XFile? image = await _photoPickerService.pickImage();
   // OU se for câmera:
   final XFile? image = await _photoPickerService.pickImageFromCamera();
   ```

---

## 📋 ARQUIVOS RESTANTES (Padrão Simples)

### **Prioridade MÉDIA:**

| # | Arquivo | Função | Mudanças |
|---|---------|--------|----------|
| 5 | inquilino_home_screen.dart | `_pickAndUploadFoto()` | 1 pickImage |
| 6 | upload_foto_perfil_proprietario_screen.dart | `_pickImage()` | 1 pickImage |
| 7 | upload_foto_perfil_screen.dart | `_pickImage()` | 1 pickImage |
| 8 | upload_foto_perfil_inquilino_screen.dart | `_pickImage()` | 1 pickImage |
| 9 | nova_pasta_screen.dart | `_picker.pickImage()` | 1 pickImage (deixar pickFiles) |
| 10 | editar_documentos_screen.dart | `picker.pickImage()` | 1 pickImage (deixar pickFiles) |
| 11 | documentos_screen.dart | Dialog + `picker.pickImage()` | 2 pickImage |

**Total: 7 telas × 1-2 mudanças simples = ~20 minutos**

---

## 🎯 PRÓXIMO PASSO

### Opção A: TERMINAR AGORA (Recomendado)
Vou completar as 2 telas críticas restantes + build

**Tempo:** 20 minutos

### Opção B: VOCÊ FIZER OS MÉDIOS
Você pode copiar o padrão para as 7 telas médias enquanto eu monitoro

**Tempo:** 20 minutos (você) + 5 minutos (eu revisar + build)

---

## ⏱️ TIMELINE TOTAL

- ✅ **Criação PhotoPickerService:** 5 min
- ✅ **pubspec.yaml:** 2 min
- ✅ **Tela 1 (portaria_representante):** 8 min
- ✅ **Tela 2 (detalhes_unidade):** 10 min
- 🔄 **Tela 3 (portaria_inquilino):** ~5 min
- 🔄 **Tela 4 (configurar_ambientes):** ~8 min
- ⏳ **Telas médias (7):** ~20 min
- ⏳ **Build final:** ~15 min
- ⏳ **Upload Play Console:** ~5 min

**TOTAL:** ~1 hora 15 minutos até publicação!

---

## 🚀 O que você quer fazer?

1. **Eu termino tudo** (Telas críticas + build)
2. **Você faz as médias enquanto eu espero**
3. **Dividir trabalho**

Digite o número! 👇
