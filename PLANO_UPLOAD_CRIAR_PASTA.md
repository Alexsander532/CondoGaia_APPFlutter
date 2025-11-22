# 📋 PLANO DE IMPLEMENTAÇÃO - Upload de Fotos/PDFs ao Criar Pasta

**Data:** 22 de Novembro de 2025  
**Status:** Proposta  
**Complexidade:** Média

---

## 🎯 OBJETIVO

Adicionar a funcionalidade de **tirar fotos** e **selecionar PDFs** na tela de **criação de pasta** (`nova_pasta_screen.dart`), igualmente à funcionalidade que existe na tela de **edição de pasta** (`editar_documentos_screen.dart`).

---

## 📊 SITUAÇÃO ATUAL

### ❌ NovaPastaScreen (Criação)
- ✅ Campo para nome da pasta
- ✅ Opção de privacidade (Público/Privado)
- ✅ Campo para adicionar link externo
- ❌ **SEM opção de tirar foto**
- ❌ **SEM opção de selecionar PDF**
- ❌ **SEM armazenamento temporário de arquivos**

### ✅ EditarDocumentosScreen (Edição)
- ✅ Campo para nome da pasta
- ✅ Opção de privacidade (Público/Privado)
- ✅ Campo para adicionar link externo
- ✅ **COM opção de tirar foto** (método `_tirarFoto()`)
- ✅ **COM opção de selecionar PDF** (método `_selecionarPDF()`)
- ✅ **COM armazenamento de arquivos adicionados**
- ✅ Lista de arquivos criados exibida

---

## 🏗️ ARQUITETURA DA SOLUÇÃO

```
NovaPastaScreen (Criação)
├── UI para seleção de arquivo (já existe em EditarDocumentosScreen)
├── Métodos de seleção (_tirarFoto, _selecionarPDF)
├── Armazenamento temporário de arquivos
│   ├── List<File> _imagensSelecionadas
│   └── List<File> _pdfsTemporarios
├── Display dos arquivos selecionados
├── Remoção de arquivos antes de salvar
└── Upload após criação da pasta
    ├── 1. Criar pasta
    ├── 2. For loop para fazer upload de cada arquivo
    ├── 3. Adicionar arquivo ao banco após upload
    └── 4. Retornar sucesso
```

---

## 💡 COMO FUNCIONARIA

### 1️⃣ SELEÇÃO DE ARQUIVOS (Durante a criação)

User abre a tela de criar pasta:

```
┌──────────────────────────────────────┐
│  Adicionar Nova Pasta                │
│                                      │
│  Nome: [________________]            │
│  Privacidade: ○ Público  ○ Privado  │
│                                      │
│  Link Externo:                       │
│  [_______________________________]   │
│                                      │
│  📸 Tirar Foto  📄 Selecionar PDF    │ ← NOVO!
│                                      │
│  ✅ Arquivos Selecionados:           │ ← NOVO!
│  □ Foto_1234567.jpg                 │ ← NOVO!
│  □ documento.pdf                     │ ← NOVO!
│  ✕ ✕                                │ ← NOVO!
│                                      │
│  [CRIAR PASTA]                       │
└──────────────────────────────────────┘
```

### 2️⃣ FLUXO DE OPERAÇÃO

```
User clica "Tirar Foto"
    ↓
Camera abre (ou galeria)
    ↓
User seleciona imagem
    ↓
Imagem é salva em _imagensSelecionadas[]
    ↓
UI atualiza mostrando arquivo
    ↓
User pode remover (❌) antes de criar
    ↓
User clica "Criar Pasta"
    ↓
1. Criar pasta no banco ✓
    ↓
2. For loop: Para cada arquivo em _imagensSelecionadas[] + _pdfsTemporarios[]
    ├─ Upload do arquivo para Supabase Storage
    ├─ Obter URL pública
    ├─ Adicionar arquivo ao banco (referência à pasta)
    ├─ Mostrar progresso
    └─ Próximo arquivo
    ↓
3. Limpar listas temporárias
    ↓
4. Mostrar sucesso e voltar
```

---

## 🔧 IMPLEMENTAÇÃO TÉCNICA

### PASSO 1: Adicionar variáveis de estado

```dart
class _NovaPastaScreenState extends State<NovaPastaScreen> {
  // ... controllers existentes ...
  
  // ✨ NOVO: Armazenamento de arquivos
  List<File> _imagensSelecionadas = [];
  List<File> _pdfsTemporarios = [];
  bool _isUploadingFiles = false;
  final ImagePicker _picker = ImagePicker();
  
  // ... resto do código ...
}
```

### PASSO 2: Copiar métodos de seleção

Copiar `_tirarFoto()` e `_selecionarPDF()` da `EditarDocumentosScreen` para `NovaPastaScreen`:

```dart
// Método para tirar foto
Future<void> _tirarFoto() async {
  try {
    setState(() => _isUploadingFiles = true);

    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,  // ← Câmera
      imageQuality: 85,
    );

    if (image != null) {
      final File imageFile = File(image.path);
      setState(() {
        _imagensSelecionadas.add(imageFile);  // ← Armazena
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Foto adicionada!')),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Erro: $e')),
    );
  } finally {
    if (mounted) {
      setState(() => _isUploadingFiles = false);
    }
  }
}

// Método para selecionar PDF
Future<void> _selecionarPDF() async {
  try {
    setState(() => _isUploadingFiles = true);

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      allowMultiple: false,
    );

    if (result != null && result.files.single.path != null) {
      try {
        final File originalFile = File(result.files.single.path!);
        
        // Verificar existência
        if (!await originalFile.exists()) {
          throw Exception('Arquivo não encontrado');
        }

        // Copiar para diretório temporário
        final appDocDir = await getApplicationDocumentsDirectory();
        final tempDir = Directory('${appDocDir.path}/pdf_temporarios');
        if (!await tempDir.exists()) {
          await tempDir.create(recursive: true);
        }

        final fileName = result.files.single.name;
        final copiedFile = File('${tempDir.path}/$fileName');
        final bytes = await originalFile.readAsBytes();
        await copiedFile.writeAsBytes(bytes);

        setState(() {
          _pdfsTemporarios.add(copiedFile);  // ← Armazena
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('PDF "$fileName" adicionado!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao copiar: $e')),
        );
      }
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Erro: $e')),
    );
  } finally {
    if (mounted) {
      setState(() => _isUploadingFiles = false);
    }
  }
}

// Método para remover arquivo
void _removerArquivo(File arquivo) {
  setState(() {
    _imagensSelecionadas.remove(arquivo);
    _pdfsTemporarios.remove(arquivo);
  });
}
```

### PASSO 3: Modificar método `_criarPasta()`

Alterar para fazer upload dos arquivos após criar a pasta:

```dart
Future<void> _criarPasta() async {
  // Validações existentes...
  if (_nomePastaController.text.trim().isEmpty) {
    setState(() {
      _errorMessage = 'Nome da pasta é obrigatório';
    });
    return;
  }

  if (_linkController.text.isNotEmpty && !_linkValido) {
    setState(() {
      _errorMessage = 'Link inválido';
    });
    return;
  }

  setState(() {
    _isLoading = true;
    _errorMessage = null;
  });

  try {
    // 1️⃣ CRIAR PASTA
    final pasta = await DocumentoService.criarPasta(
      nome: _nomePastaController.text.trim(),
      privado: _privacidade == 'Privado',
      condominioId: widget.condominioId,
      representanteId: widget.representanteId,
    );
    
    // 2️⃣ ADICIONAR LINK (se fornecido)
    if (_linkController.text.isNotEmpty && _linkValido) {
      await DocumentoService.adicionarArquivoComLink(
        nome: 'Link - ${_linkController.text.trim()}',
        linkExterno: _linkController.text.trim(),
        privado: _privacidade == 'Privado',
        pastaId: pasta.id,
        condominioId: widget.condominioId,
        representanteId: widget.representanteId,
      );
    }

    // 3️⃣ FAZER UPLOAD DE FOTOS
    print('[NovaPastaScreen] Uploading ${_imagensSelecionadas.length} imagens');
    for (File imagem in _imagensSelecionadas) {
      try {
        await DocumentoService.adicionarArquivoComUpload(
          nome: 'Foto_${DateTime.now().millisecondsSinceEpoch}.jpg',
          arquivo: imagem,
          descricao: 'Foto adicionada ao criar pasta',
          privado: _privacidade == 'Privado',
          pastaId: pasta.id,
          condominioId: widget.condominioId,
          representanteId: widget.representanteId,
        );
        print('[NovaPastaScreen] Imagem enviada com sucesso');
      } catch (e) {
        print('[NovaPastaScreen] ERRO ao enviar imagem: $e');
        throw Exception('Erro ao enviar imagem: $e');
      }
    }

    // 4️⃣ FAZER UPLOAD DE PDFs
    print('[NovaPastaScreen] Uploading ${_pdfsTemporarios.length} PDFs');
    for (File pdf in _pdfsTemporarios) {
      try {
        final nomeArquivo = pdf.path.split('/').last;
        await DocumentoService.adicionarArquivoComUpload(
          nome: nomeArquivo,
          arquivo: pdf,
          descricao: 'PDF adicionado ao criar pasta',
          privado: _privacidade == 'Privado',
          pastaId: pasta.id,
          condominioId: widget.condominioId,
          representanteId: widget.representanteId,
        );
        print('[NovaPastaScreen] PDF enviado com sucesso');
      } catch (e) {
        print('[NovaPastaScreen] ERRO ao enviar PDF: $e');
        throw Exception('Erro ao enviar PDF: $e');
      }
    }

    if (mounted) {
      // 5️⃣ LIMPAR E VOLTAR
      _nomePastaController.clear();
      _linkController.clear();
      setState(() {
        _imagensSelecionadas.clear();
        _pdfsTemporarios.clear();
      });

      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Pasta criada com sucesso! ' +
            (_imagensSelecionadas.isNotEmpty || _pdfsTemporarios.isNotEmpty 
              ? 'Arquivos enviados.' 
              : '')
          ),
        ),
      );
    }
  } catch (e) {
    setState(() {
      _errorMessage = 'Erro: $e';
      _isLoading = false;
    });
  }
}
```

### PASSO 4: Adicionar UI para botões de seleção

Na seção "Adicionar Nova Pasta", após os campos de link:

```dart
// Seção de Upload de Arquivo
const SizedBox(height: 24),
const Text(
  'Adicionar Arquivos (Opcional)',
  style: TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Color(0xFF1E3A8A),
  ),
),
const SizedBox(height: 16),

// Botões de seleção
Row(
  children: [
    Expanded(
      child: ElevatedButton.icon(
        onPressed: _isUploadingFiles ? null : _tirarFoto,
        icon: const Icon(Icons.camera_alt),
        label: const Text('📸 Tirar Foto'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue[100],
          foregroundColor: Colors.blue[900],
        ),
      ),
    ),
    const SizedBox(width: 8),
    Expanded(
      child: ElevatedButton.icon(
        onPressed: _isUploadingFiles ? null : _selecionarPDF,
        icon: const Icon(Icons.picture_as_pdf),
        label: const Text('📄 PDF'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red[100],
          foregroundColor: Colors.red[900],
        ),
      ),
    ),
  ],
),
const SizedBox(height: 16),

// Lista de arquivos selecionados
if (_imagensSelecionadas.isNotEmpty || _pdfsTemporarios.isNotEmpty)
  Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Arquivos Selecionados:',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      const SizedBox(height: 8),
      
      // Imagens
      ..._imagensSelecionadas.map((imagem) {
        final nomearquivo = imagem.path.split('/').last;
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.blue[300]!),
            borderRadius: BorderRadius.circular(8),
            backgroundColor: Colors.blue[50],
          ),
          child: Row(
            children: [
              Icon(Icons.image, color: Colors.blue[600]),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  nomearquivo,
                  style: const TextStyle(fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => _removerArquivo(imagem),
                constraints: const BoxConstraints(maxWidth: 32, maxHeight: 32),
                padding: EdgeInsets.zero,
                iconSize: 18,
              ),
            ],
          ),
        );
      }).toList(),

      // PDFs
      ..._pdfsTemporarios.map((pdf) {
        final nomeArquivo = pdf.path.split('/').last;
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.red[300]!),
            borderRadius: BorderRadius.circular(8),
            backgroundColor: Colors.red[50],
          ),
          child: Row(
            children: [
              Icon(Icons.picture_as_pdf, color: Colors.red[600]),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  nomeArquivo,
                  style: const TextStyle(fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => _removerArquivo(pdf),
                constraints: const BoxConstraints(maxWidth: 32, maxHeight: 32),
                padding: EdgeInsets.zero,
                iconSize: 18,
              ),
            ],
          ),
        );
      }).toList(),
      
      const SizedBox(height: 16),
    ],
  ),
```

### PASSO 5: Adicionar imports necessários

```dart
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
```

---

## 📈 COMPARAÇÃO ANTES E DEPOIS

### ANTES (Atual)
```
NovaPastaScreen
├── Campo nome ✅
├── Opção privacidade ✅
├── Campo link ✅
├── Botão criar ✅
└── ❌ SEM fotos/PDFs
```

### DEPOIS (Proposto)
```
NovaPastaScreen
├── Campo nome ✅
├── Opção privacidade ✅
├── Campo link ✅
├── Botão tirar foto ✨
├── Botão selecionar PDF ✨
├── Lista de arquivos ✨
├── Remover arquivo ✨
└── Upload automático após criar ✨
```

---

## 🔄 FLUXO DE DADOS

```
User abre NovaPastaScreen
    ↓
Preenche nome, privacidade, link (opcional)
    ↓
Clica "Tirar Foto" ou "Selecionar PDF"
    ↓
Arquivo armazenado em _imagensSelecionadas[] ou _pdfsTemporarios[]
    ↓
UI mostra arquivo com opção de remover
    ↓
User clica "Criar Pasta"
    ↓
1. Criar pasta (POST documentos/pastas)
    ↓
2. Adicionar link (POST documentos/arquivos) - se fornecido
    ↓
3. For cada imagem (POST documentos/arquivos + Upload Storage)
    ↓
4. For cada PDF (POST documentos/arquivos + Upload Storage)
    ↓
5. Limpar listas temporárias
    ↓
6. Voltar com sucesso
```

---

## ⚡ IMPACTO NA PERFORMANCE

| Aspecto | Impacto | Observação |
|---------|--------|-----------|
| **Tamanho da tela** | +15% | Novos botões e lista de arquivos |
| **Tempo de criação** | +3-5s por arquivo | Upload é sequencial |
| **Memória** | +50-100MB | Imagens em memória antes de upload |
| **UX** | ✅ Melhorada | User vê what they add |
| **Parallelização** | Possível | Future.wait em lugar do for loop |

---

## 🎯 ETAPAS DE IMPLEMENTAÇÃO

### Fase 1: Preparação (15 minutos)
- [ ] Copiar imports necessários
- [ ] Adicionar variáveis de estado
- [ ] Adicionar ImagePicker initialization

### Fase 2: Métodos de Seleção (20 minutos)
- [ ] Implementar `_tirarFoto()`
- [ ] Implementar `_selecionarPDF()`
- [ ] Implementar `_removerArquivo()`

### Fase 3: UI (15 minutos)
- [ ] Adicionar botões na tela
- [ ] Adicionar lista de arquivos
- [ ] Estilizar componentes

### Fase 4: Lógica de Criação (20 minutos)
- [ ] Modificar `_criarPasta()`
- [ ] Adicionar loop de upload
- [ ] Adicionar tratamento de erros

### Fase 5: Testes (15 minutos)
- [ ] Testar seleção de foto
- [ ] Testar seleção de PDF
- [ ] Testar remoção de arquivo
- [ ] Testar criação com arquivo
- [ ] Testar criação sem arquivo

**Tempo Total Estimado:** ~1.5 horas

---

## ✅ CHECKLIST DE IMPLEMENTAÇÃO

### Código
- [ ] Imports adicionados
- [ ] Variáveis de estado criadas
- [ ] Método `_tirarFoto()` implementado
- [ ] Método `_selecionarPDF()` implementado
- [ ] Método `_removerArquivo()` implementado
- [ ] Método `_criarPasta()` modificado
- [ ] Loop de upload implementado
- [ ] Tratamento de erros adicionado

### UI
- [ ] Botões de seleção adicionados
- [ ] Lista de arquivos exibida
- [ ] Ícones adequados usados
- [ ] Cores consistentes com design
- [ ] Responsivo em mobile

### Testes
- [ ] Foto pode ser selecionada
- [ ] PDF pode ser selecionado
- [ ] Arquivo pode ser removido
- [ ] Pasta criada sem arquivo ✅
- [ ] Pasta criada com 1 arquivo ✅
- [ ] Pasta criada com múltiplos arquivos ✅
- [ ] Link + Arquivo funcionam juntos ✅

---

## 🚀 BENEFÍCIOS

✅ **Consistência UX** - Mesmas funcionalidades em criar e editar  
✅ **User Experience** - Pode adicionar arquivos direto ao criar  
✅ **Eficiência** - Menos cliques para adicionar múltiplos documentos  
✅ **Flexibilidade** - Fotos + PDF + Link na mesma operação  
✅ **Fácil manutenção** - Código reutilizável das duas telas  

---

## ⚠️ CONSIDERAÇÕES

1. **Upload sequencial** é mais seguro que paralelo (menos strain no servidor)
2. **Validação de tamanho** pode ser adicionada antes do upload
3. **Progress feedback** melhora UX durante upload múltiplo
4. **Rollback** - Se upload falhar, pasta fica criada mas sem arquivos (pode ser ok)

---

## 💬 RESUMO

**É possível?** ✅ **100% Possível**

**Como funciona:**
1. User seleciona fotos/PDFs antes de criar pasta
2. Arquivos armazenados temporariamente em memória
3. Ao clicar "Criar Pasta", primeiro a pasta é criada no banco
4. Depois cada arquivo é feito upload para Storage
5. Finalmente cada arquivo é adicionado ao banco referenciando a pasta
6. Se tudo der certo, user vê lista atualizada

**Duração:** ~1.5 horas para implementação completa

**Dificuldade:** Média (maior parte já existe no código)

---

**Próximo Passo:** Confirmação para começar a implementação! 🚀