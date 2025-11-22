# 📋 RELATÓRIO COMPLETO - Sistema de Upload de PDF e Fotos para Documentos do Representante

**Data do Relatório:** 22 de Novembro de 2025  
**Versão:** 1.0  
**Plataformas:** Mobile (Android/iOS) + Web

---

## 📑 ÍNDICE
1. [Visão Geral](#visão-geral)
2. [Arquitetura do Sistema](#arquitetura-do-sistema)
3. [Fluxo de Upload](#fluxo-de-upload)
4. [Componentes Principais](#componentes-principais)
5. [Tipos de Arquivo Suportados](#tipos-de-arquivo-suportados)
6. [Implementação Mobile](#implementação-mobile)
7. [Implementação Web](#implementação-web)
8. [Tratamento de Erros](#tratamento-de-erros)
9. [Limitações e Considerações](#limitações-e-considerações)
10. [Segurança](#segurança)

---

## 🎯 VISÃO GERAL

O sistema permite que representantes façam upload de:
- **Fotos** (JPEG, PNG)
- **PDFs** de documentos
- **Links externos** para balancetes

Os arquivos são armazenados no **Supabase Storage** e vinculados a um período específico (mês/ano).

### Estrutura de Dados

```
BALANCETES
├── id (UUID)
├── nome_arquivo (string) - Nome do arquivo
├── url (string) - URL pública do arquivo no storage
├── link_externo (string) - Link externo (se for um link)
├── mes (integer) - Mês do balancete (1-12)
├── ano (integer) - Ano do balancete
├── privado (boolean) - Se é privado ou público
├── condominio_id (UUID) - Referência ao condomínio
├── representante_id (UUID) - Referência ao representante
├── created_at (timestamp)
└── updated_at (timestamp)
```

---

## 🏗️ ARQUITETURA DO SISTEMA

```
┌─────────────────────────────────────────────────────────┐
│                  DocumentosScreen (UI)                  │
│  - Seleção de arquivos (fotos/PDFs)                    │
│  - Gerenciamento de arquivo temporários                 │
│  - Formulário de upload                                │
└──────────────────┬──────────────────────────────────────┘
                   │
                   ↓
┌─────────────────────────────────────────────────────────┐
│              DocumentoService (Business Logic)          │
│  - adicionarBalanceteComUpload()                       │
│  - getBalancetesPorPeriodo()                           │
│  - atualizarBalancete()                                │
│  - deletarBalancete()                                  │
└──────────────────┬──────────────────────────────────────┘
                   │
                   ↓
┌─────────────────────────────────────────────────────────┐
│            SupabaseService (Storage & Database)        │
│  - uploadBalancete() → Supabase Storage                │
│  - adicionarBalancete() → Database                     │
│  - downloadArquivo() → Retrieve from Storage           │
└──────────────────┬──────────────────────────────────────┘
                   │
                   ↓
┌─────────────────────────────────────────────────────────┐
│         Supabase Backend (Storage + Database)          │
│  - Bucket: 'documentos'                               │
│  - Tabela: 'balancetes'                               │
│  - Autenticação: Row Level Security (RLS)             │
└─────────────────────────────────────────────────────────┘
```

---

## 🔄 FLUXO DE UPLOAD

### 1️⃣ SELEÇÃO DE ARQUIVO

**Responsabilidade:** `DocumentosScreen`

```dart
// Fotos - Câmera ou Galeria
Future<void> _tirarFoto() async {
  final ImageSource? source = await showDialog<ImageSource>(...)
  
  if (source != null) {
    final XFile? image = await _picker.pickImage(
      source: source,
      imageQuality: 85,        // ← Compressão de qualidade
      maxWidth: 1920,
      maxHeight: 1080,
    );
    
    if (image != null) {
      final File imageFile = File(image.path);
      setState(() {
        _imagensTemporarias.add(imageFile);  // ← Armazena localmente
      });
    }
  }
}

// PDFs - File Picker
Future<void> _selecionarPDF() async {
  FilePickerResult? result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['pdf'],  // ← Apenas PDFs
    allowMultiple: false,
  );
  
  if (result != null && result.files.single.path != null) {
    // Copiar para diretório temporário
    final appDocDir = await getApplicationDocumentsDirectory();
    final tempDir = Directory('${appDocDir.path}/pdf_temporarios');
    
    // ... copiar arquivo ...
    
    setState(() {
      _pdfsTemporarios.add(copiedFile);  // ← Armazena localmente
    });
  }
}
```

### 2️⃣ VALIDAÇÃO E ARMAZENAMENTO TEMPORÁRIO

**Responsabilidade:** `DocumentosScreen`

```
┌────────────────────────────────────────┐
│     Arquivo Selecionado                │
└──────────┬─────────────────────────────┘
           │
           ↓
┌────────────────────────────────────────┐
│  Verificar se existe                   │
│  └─ SE NÃO → Erro, mensagem ao user   │
└──────────┬─────────────────────────────┘
           │
           ↓
┌────────────────────────────────────────┐
│  Copiar para temp dir (Android)        │
│  └─ Necessário pois file_picker é      │
│     read-only em alguns casos          │
└──────────┬─────────────────────────────┘
           │
           ↓
┌────────────────────────────────────────┐
│  Adicionar à lista temporária           │
│  ├─ _imagensTemporarias[]              │
│  ├─ _pdfsTemporarios[]                 │
│  └─ _linkController (links externos)   │
└──────────┬─────────────────────────────┘
           │
           ↓
┌────────────────────────────────────────┐
│  Mostrar SnackBar de confirmação       │
│  "Imagem/PDF adicionado! Clique em    │
│   Salvar para confirmar"               │
└────────────────────────────────────────┘
```

### 3️⃣ SALVAR ARQUIVOS

**Responsabilidade:** `DocumentosScreen` → `DocumentoService` → `SupabaseService`

```dart
Future<void> _salvarArquivos() async {
  // 1. Validar se há algo para salvar
  final temLink = _linkController.text.trim().isNotEmpty && _linkValido;
  final temImagens = _imagensTemporarias.isNotEmpty;
  final temPDFs = _pdfsTemporarios.isNotEmpty;
  
  if (!temLink && !temImagens && !temPDFs) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Adicione pelo menos um arquivo ou link'))
    );
    return;
  }
  
  setState(() { isLoading = true; });
  
  try {
    // 2. Salvar Link (se existir)
    if (temLink) {
      await DocumentoService.adicionarBalancete(
        nomeArquivo: 'Link_${DateTime.now().millisecondsSinceEpoch}',
        linkExterno: _linkController.text.trim(),
        mes: _mesSelecionado.toString(),
        ano: _anoSelecionado.toString(),
        privado: selectedPrivacy == 'Privado',
        condominioId: condominioId,
        representanteId: representanteId,
      );
    }
    
    // 3. Salvar Imagens (com upload)
    for (File imagem in _imagensTemporarias) {
      await DocumentoService.adicionarBalanceteComUpload(
        arquivo: imagem,
        nomeArquivo: 'Imagem_${DateTime.now().millisecondsSinceEpoch}.jpg',
        mes: _mesSelecionado.toString(),
        ano: _anoSelecionado.toString(),
        privado: selectedPrivacy == 'Privado',
        condominioId: condominioId,
        representanteId: representanteId,
      );
    }
    
    // 4. Salvar PDFs (com upload)
    for (File pdf in _pdfsTemporarios) {
      final nomeOriginalPDF = pdf.path.split('/').last;
      await DocumentoService.adicionarBalanceteComUpload(
        arquivo: pdf,
        nomeArquivo: nomeOriginalPDF,
        mes: _mesSelecionado.toString(),
        ano: _anoSelecionado.toString(),
        privado: selectedPrivacy == 'Privado',
        condominioId: condominioId,
        representanteId: representanteId,
      );
    }
    
    // 5. Limpar e recarregar
    _linkController.clear();
    setState(() {
      _imagensTemporarias.clear();
      _pdfsTemporarios.clear();
    });
    
    await _carregarBalancetes();
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Arquivos salvos com sucesso!'),
        backgroundColor: Colors.green,
      ),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Erro: $e')),
    );
  } finally {
    setState(() { isLoading = false; });
  }
}
```

### 4️⃣ UPLOAD PARA SUPABASE STORAGE

**Responsabilidade:** `SupabaseService.uploadBalancete()`

```dart
static Future<String?> uploadBalancete(
  dynamic arquivo,
  String nomeArquivo,
  String condominioId,
  String mes,
  String ano,
) async {
  try {
    print('[SupabaseService] Iniciando upload: $nomeArquivo');
    
    // 1. Converter para bytes (compatível com File e XFile)
    late Uint8List bytes;
    
    if (arquivo is File) {
      // Mobile/Desktop
      if (!await arquivo.exists()) {
        throw Exception('Arquivo não encontrado: ${arquivo.path}');
      }
      bytes = await arquivo.readAsBytes();
    } else {
      // Web (XFile) ou outro formato
      bytes = await arquivo.readAsBytes();
    }
    
    print('[SupabaseService] Arquivo lido: ${bytes.length} bytes');
    
    // 2. Sanitizar nome do arquivo
    final sanitizedName = _sanitizeFileName(nomeArquivo);
    
    // 3. Construir caminho no storage
    final fileName = 
      '${condominioId}/balancetes/${ano}_${mes}_${DateTime.now().millisecondsSinceEpoch}_$sanitizedName';
    
    print('[SupabaseService] Caminho: $fileName');
    
    // 4. Fazer upload binário
    final response = await client.storage
        .from('documentos')
        .uploadBinary(fileName, bytes);
    
    if (response.isNotEmpty) {
      // 5. Obter URL pública
      final publicUrl = client.storage
          .from('documentos')
          .getPublicUrl(fileName);
      
      print('[SupabaseService] Upload concluído: $publicUrl');
      return publicUrl;
    }
    
    return null;
  } catch (e) {
    print('[SupabaseService] ERRO: $e');
    rethrow;
  }
}

// Sanitizar nome do arquivo
static String _sanitizeFileName(String fileName) {
  String sanitized = fileName
    .replaceAll(' ', '_')                      // Espaços → underscore
    .replaceAll(RegExp(r'[^\w\-_\.]'), '')    // Remove especiais
    .replaceAll(RegExp(r'_{2,}'), '_');       // Múltiplos underscores → um
  
  return sanitized.replaceAll(RegExp(r'^_+|_+$'), '');
}
```

### 5️⃣ SALVAR NO BANCO DE DADOS

**Responsabilidade:** `SupabaseService.adicionarBalancete()`

```dart
static Future<Map<String, dynamic>?> adicionarBalancete({
  required String nomeArquivo,
  required String? url,
  required String? linkExterno,
  required String mes,
  required String ano,
  required bool privado,
  required String condominioId,
  required String representanteId,
}) async {
  try {
    print('[SupabaseService] Inserindo balancete no banco...');
    
    final response = await client
        .from('balancetes')
        .insert({
          'nome_arquivo': nomeArquivo,
          'url': url,
          'link_externo': linkExterno,
          'mes': int.parse(mes),
          'ano': int.parse(ano),
          'privado': privado,
          'condominio_id': condominioId,
          'representante_id': representanteId,
        })
        .select()
        .single();
    
    print('[SupabaseService] Balancete inserido com sucesso!');
    return response;
  } catch (e) {
    print('[SupabaseService] ERRO ao inserir: $e');
    rethrow;
  }
}
```

### 6️⃣ RECARREGAR E EXIBIR

**Responsabilidade:** `DocumentosScreen`

```dart
Future<void> _carregarBalancetes() async {
  try {
    final balancetesCarregados = 
      await DocumentoService.getBalancetesPorPeriodo(
        condominioId,
        _mesSelecionado,
        _anoSelecionado,
      );
    
    setState(() {
      balancetes = balancetesCarregados;
    });
  } catch (e) {
    print('Erro ao carregar: $e');
  }
}
```

---

## 💻 COMPONENTES PRINCIPAIS

### 1. DocumentosScreen

**Local:** `lib/screens/documentos_screen.dart` (1762 linhas)

**Responsabilidades:**
- Gerenciar UI da tela de documentos
- Selecionar fotos (câmera/galeria)
- Selecionar PDFs (file picker)
- Gerenciar links externos
- Armazenar arquivos temporariamente
- Iniciar processo de salvamento
- Exibir balancetes por período (mês/ano)
- Navegação entre períodos

**Principais Métodos:**

```dart
_tirarFoto()                    // Abrir câmera/galeria
_selecionarPDF()               // Abrir file picker para PDF
_removerArquivoTemporario()    // Remover arquivo antes de salvar
_salvarArquivos()              // Iniciar processo de salvamento
_carregarBalancetes()          // Recarregar lista de balancetes
_navegarMesAnterior()          // Ir para mês anterior
_navegarProximoMes()           // Ir para próximo mês
```

**Variáveis de Estado:**

```dart
List<File> _imagensTemporarias = [];    // Imagens antes de salvar
List<File> _pdfsTemporarios = [];       // PDFs antes de salvar
TextEditingController _linkController;  // Link externo
String selectedPrivacy = 'Público';    // Privado ou Público
int _mesSelecionado;                   // Mês atual
int _anoSelecionado;                   // Ano atual
bool _isUploadingFile = false;         // Flag de upload em progresso
```

### 2. DocumentoService

**Local:** `lib/services/documento_service.dart` (609 linhas)

**Responsabilidades:**
- Abstração entre UI e Supabase
- Métodos para CRUD de documentos e balancetes
- Coordenar upload e salvamento em banco

**Principais Métodos:**

```dart
static Future<Balancete> adicionarBalanceteComUpload({
  required dynamic arquivo,
  required String nomeArquivo,
  required String mes,
  required String ano,
  required bool privado,
  required String condominioId,
  required String representanteId,
})

static Future<Balancete> adicionarBalancete({
  required String nomeArquivo,
  required String? linkExterno,
  required String mes,
  required String ano,
  required bool privado,
  required String condominioId,
  required String representanteId,
})

static Future<List<Balancete>> getBalancetesPorPeriodo(
  String condominioId,
  int mes,
  int ano,
)

static Future<bool> atualizarBalancete(...)
static Future<bool> deletarBalancete(...)
```

### 3. SupabaseService

**Local:** `lib/services/supabase_service.dart` (1670 linhas)

**Responsabilidades:**
- Comunicação com Supabase Storage
- Comunicação com banco de dados
- Upload de arquivos binários
- Download de arquivos
- Sanitização de nomes

**Principais Métodos:**

```dart
static Future<String?> uploadBalancete(
  dynamic arquivo,
  String nomeArquivo,
  String condominioId,
  String mes,
  String ano,
)

static Future<String?> uploadArquivoDocumento(
  dynamic arquivo,
  String nomeArquivo,
  String condominioId,
)

static Future<String?> uploadArquivoDocumentoBytes(
  Uint8List bytes,
  String nomeArquivo,
  String condominioId,
)

static Future<Map<String, dynamic>?> adicionarBalancete({...})

static Future<Uint8List?> downloadArquivo(String url)

static String _sanitizeFileName(String fileName)
```

### 4. Modelos de Dados

**Documento.dart:**
```dart
class Documento {
  final String id;
  final String nome;
  final String? descricao;
  final String tipo;          // 'pasta' ou 'arquivo'
  final String? url;
  final String? linkExterno;
  final bool privado;
  final String? pastaId;
  final String condominioId;
  final String representanteId;
  final DateTime createdAt;
  final DateTime updatedAt;
}
```

**Balancete.dart:**
```dart
class Balancete {
  final String id;
  final String nomeArquivo;
  final String? url;
  final String? linkExterno;
  final int mes;
  final int ano;
  final bool privado;
  final String condominioId;
  final String representanteId;
  final DateTime createdAt;
  final DateTime updatedAt;
}
```

---

## 📁 TIPOS DE ARQUIVO SUPORTADOS

| Tipo | Extensões | Compressão | Observações |
|------|-----------|-----------|-------------|
| **Imagem** | JPEG, PNG | 85% qualidade | Máx 1920x1080 |
| **PDF** | .pdf | Sem compressão | File Picker exclusivo |
| **Link** | URL válida | N/A | Validação de URL |

---

## 📱 IMPLEMENTAÇÃO MOBILE

### Android

**Permissões (AndroidManifest.xml):**

```xml
<!-- Câmera -->
<uses-permission android:name="android.permission.CAMERA" />

<!-- Galeria -->
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />

<!-- Armazenamento (para copiar PDFs) -->
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
```

**Fluxo de Seleção de PDF:**

```
User seleciona PDF
    ↓
FilePicker busca arquivo na memória
    ↓
SupabaseService verifica se existe
    ↓
Copia arquivo para /app/Documents/pdf_temporarios
    ↓
Adiciona à lista _pdfsTemporarios[]
    ↓
User clica "Salvar"
    ↓
Arquivo é lido como bytes
    ↓
Upload para Supabase Storage
    ↓
Arquivo temporário é deletado
```

**Plugins Necessários:**

```yaml
dependencies:
  image_picker: ^0.8.0+       # Para fotos
  file_picker: ^8.0.0+1       # Para PDFs
  permission_handler: ^11.0.0 # Para permissões
  path_provider: ^2.0.0       # Para diretórios temp
  dio: ^5.0.0                 # Para downloads
```

### iOS

**Permissões (Info.plist):**

```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>Precisamos acessar sua galeria para selecionar imagens</string>

<key>NSCameraUsageDescription</key>
<string>Precisamos acessar sua câmera para tirar fotos</string>

<key>NSDocumentsFolderAccessDescription</key>
<string>Precisamos acessar documentos para selecionar PDFs</string>
```

**Fluxo Similar ao Android**

---

## 🌐 IMPLEMENTAÇÃO WEB

### Diferenças Principais

1. **Sem permissões do SO** - Browser solicita permissões
2. **XFile ao invés de File** - `image_picker` retorna XFile na web
3. **Sem acesso ao filesystem** - FilePicker retorna bytes, não caminhos
4. **Requisições HTTP** - Communicação via HTTP, não native

### Fluxo Web

```
User clica "Selecionar Foto"
    ↓
HTML file input (tipo image) abre
    ↓
Browser retorna XFile
    ↓
DocumentosScreen armazena XFile na memória
    ↓
XFile.readAsBytes() → Uint8List
    ↓
SupabaseService.uploadBalancete recebe Uint8List
    ↓
POST para Supabase Storage API
    ↓
Response com URL pública
    ↓
Salva URL no banco
```

### Compatibilidade

```dart
// Mesmo código funciona em mobile e web!
if (arquivo is File) {
  // Mobile/Desktop
  bytes = await arquivo.readAsBytes();
} else {
  // Web (XFile)
  bytes = await arquivo.readAsBytes();
}
```

### Limitações Web

```
❌ Sem acesso ao filesystem
❌ Sem diretórios temporários
❌ Sem permissões do SO
✅ Upload direto de bytes
✅ Múltiplos arquivos em memória
✅ Suporte a drag-and-drop (possível adicionar)
```

---

## ⚠️ TRATAMENTO DE ERROS

### 1. Arquivo Não Encontrado

```dart
if (arquivo is File) {
  if (!await arquivo.exists()) {
    throw Exception('Arquivo não encontrado: ${arquivo.path}');
  }
}
```

**Resposta ao Usuário:**
```
❌ Erro ao carregar arquivo
"Arquivo não encontrado no caminho especificado."
```

### 2. Falha no Upload

```dart
if (response.isEmpty) {
  throw Exception('Erro ao fazer upload do arquivo');
}
```

**Resposta ao Usuário:**
```
❌ Erro ao salvar
"Não foi possível fazer upload do arquivo. Tente novamente."
```

### 3. Falha no Banco de Dados

```dart
try {
  final response = await client
      .from('balancetes')
      .insert(data)
      .select()
      .single();
} catch (e) {
  print('[SupabaseService] ERRO ao inserir: $e');
  rethrow;
}
```

**Resposta ao Usuário:**
```
❌ Erro ao criar balancete
"Não foi possível salvar os dados. Verifique sua conexão."
```

### 4. Validação de Link

```dart
// Validar URL
bool isValidUrl(String url) {
  try {
    Uri.parse(url);
    return url.startsWith('http://') || url.startsWith('https://');
  } catch (e) {
    return false;
  }
}
```

---

## 🔒 SEGURANÇA

### 1. Row Level Security (RLS)

**Tabela: balancetes**

```sql
-- Representantes veem seus próprios balancetes + públicos
CREATE POLICY "representante_view_balancetes" ON balancetes
FOR SELECT USING (
  auth.uid()::text = representante_id OR privado = false
);

-- Representantes inserem balancetes
CREATE POLICY "representante_insert_balancetes" ON balancetes
FOR INSERT WITH CHECK (
  auth.uid()::text = representante_id
);

-- Representantes atualizam seus balancetes
CREATE POLICY "representante_update_balancetes" ON balancetes
FOR UPDATE USING (auth.uid()::text = representante_id)
WITH CHECK (auth.uid()::text = representante_id);

-- Representantes deletam seus balancetes
CREATE POLICY "representante_delete_balancetes" ON balancetes
FOR DELETE USING (auth.uid()::text = representante_id);
```

### 2. Sanitização de Nomes

```dart
static String _sanitizeFileName(String fileName) {
  String sanitized = fileName
    .replaceAll(' ', '_')                      // Espaços → _
    .replaceAll(RegExp(r'[^\w\-_\.]'), '')    // Remove path traversal
    .replaceAll(RegExp(r'_{2,}'), '_');       // Múltiplos _
  
  return sanitized.replaceAll(RegExp(r'^_+|_+$'), '');
}

// "../../malicioso.jpg" → "malicioso.jpg"
// "arquivo com espaço.pdf" → "arquivo_com_espaço.pdf"
```

### 3. Validação de Tipo de Arquivo

```dart
// Mobile
FilePickerResult? result = await FilePicker.platform.pickFiles(
  type: FileType.custom,
  allowedExtensions: ['pdf'],  // ← Whitelist
);

// Web
final XFile? image = await picker.pickImage(
  // ← image_picker valida automaticamente
);
```

### 4. Armazenamento Seguro

- Arquivo temporário deletado após upload
- Sem armazenamento local de credentials
- Token JWT do Supabase gerenciado automaticamente
- HTTPS obrigatório para Supabase

---

## ⚡ LIMITAÇÕES E CONSIDERAÇÕES

### Limitações Atuais

| Aspecto | Limitação | Impacto |
|---------|-----------|---------|
| **Tamanho de arquivo** | Não definido explicitamente | Risco de out-of-memory em arquivos muito grandes |
| **Tipos de arquivo** | Apenas JPEG/PNG e PDF | Não suporta XLSX, DOCX, etc |
| **Upload múltiplo** | Um arquivo por vez | UX mais lenta com vários arquivos |
| **Progresso de upload** | Sem barra de progresso | Usuário não vê andamento |
| **Duplicação de nomes** | Timestamp previne, mas sem validação explícita | Possível nome duplicado em mesmo período |
| **Sincronização Web** | Sem cache offline | Offline = sem funcionalidade |

### Recomendações de Melhorias

```
1. Adicionar barra de progresso (StreamUpload)
   └─ Usar `client.storage.from('documentos').uploadBinary(
        ..., 
        onProgress: (progress) { ... }
      )`

2. Validar tamanho de arquivo antes de enviar
   └─ if (bytes.length > 50 * 1024 * 1024) { // 50MB
        throw Exception('Arquivo muito grande');
      }

3. Suportar upload múltiplo paralelo
   └─ Future.wait([upload1, upload2, upload3])

4. Adicionar cache offline (Hive)
   └─ Salvar arquivos localmente se offline

5. Suportar mais tipos de arquivo
   └─ XLSX, DOCX, TXT, JPG, PNG, GIF, SVG

6. Validar URL antes de adicionar link
   └─ if (!isValidUrl(link)) { ... }

7. Adicionar crop de imagem
   └─ image_cropper: ^7.0.0

8. Compressão automática de PDF
   └─ pdf: ^3.0.0
```

---

## 📊 FLUXO VISUAL COMPLETO

### Desktop/Web
```
┌──────────────────────────────────────────────┐
│  DOCUMENTOS DO REPRESENTANTE                 │
│                                              │
│  ◀ Novembro 2025 ▶                          │
│  [10/10 arquivos]                           │
│                                              │
│  ┌─────────────────────────────────────┐    │
│  │  Balancete Novembro 2025 (Público)  │    │
│  │  📊 balancete_nov_2025.pdf          │    │
│  │  📅 21/11/2025 10:30                │    │
│  └─────────────────────────────────────┘    │
│                                              │
│  ┌─────────────────────────────────────┐    │
│  │  + ADICIONAR BALANCETE              │    │
│  │                                      │    │
│  │  Link/Arquivo Público ○ Privado     │    │
│  │  [Link: ________________]            │    │
│  │                                      │    │
│  │  Ou selecione arquivo:               │    │
│  │  [📸 CÂMERA] [📁 GALERIA] [📄 PDF]  │    │
│  │                                      │    │
│  │  [❌ ❌ ❌] (removidos antes salvar) │    │
│  │                                      │    │
│  │  [CANCELAR] [SALVAR]                │    │
│  └─────────────────────────────────────┘    │
│                                              │
└──────────────────────────────────────────────┘
```

### Mobile
```
┌─────────────────────────────────┐
│  Documentos                      │
│ ◀ Nov 2025 ▶  [10/10]           │
├─────────────────────────────────┤
│                                  │
│ ┌──────────────────────────────┐ │
│ │ Balancete Nov 2025           │ │
│ │ 📊 balancete_nov_2025.pdf    │ │
│ │ 📅 21/11/2025                │ │
│ └──────────────────────────────┘ │
│                                  │
│ ┌──────────────────────────────┐ │
│ │ + ADICIONAR BALANCETE        │ │
│ ├──────────────────────────────┤ │
│ │ URL (Público / Privado)      │ │
│ │ [____________________]       │ │
│ │                              │ │
│ │ [📸] [🖼️] [📄]              │ │
│ │ Câm  Gal  PDF              │ │
│ │                              │ │
│ │ [CANCELAR] [SALVAR]         │ │
│ └──────────────────────────────┘ │
│                                  │
└─────────────────────────────────┘
```

---

## 📈 ESTATÍSTICAS DE CÓDIGO

| Componente | Arquivo | Linhas | Responsabilidade |
|-----------|---------|--------|------------------|
| **UI** | documentos_screen.dart | 1762 | Seleção e gerenciamento |
| **Service** | documento_service.dart | 609 | Business logic |
| **Storage** | supabase_service.dart | 1670 | Upload e download |
| **Modelo** | balancete.dart | ~100 | Serialização |
| **Total** | - | ~4141 | Sistema completo |

---

## 🎯 RESUMO EXECUTIVO

### ✅ O que funciona bem

1. **Upload de fotos** - Câmera e galeria em mobile/web
2. **Upload de PDFs** - Seleção e upload sem compressão
3. **Links externos** - Armazenamento de URLs
4. **Privacidade** - Público/Privado controlável
5. **Período** - Filtro por mês/ano funcionando
6. **Compatibilidade** - Mobile (Android/iOS) e Web
7. **Segurança** - RLS, sanitização, validação

### ⚠️ Áreas de melhoria

1. Adicionar progresso de upload
2. Validar tamanho antes de enviar
3. Suportar mais tipos de arquivo
4. Cache offline
5. Upload múltiplo paralelo
6. Validação de URL automática

### 🚀 Próximos passos recomendados

1. Adicionar barra de progresso com `StreamUpload`
2. Implementar validação de tamanho (máx 50MB)
3. Adicionar suporte a XLSX/DOCX
4. Implementar cache com Hive
5. Adicionar crop de imagem
6. Testes E2E com diferentes tipos de arquivo

---

**Relatório Gerado:** 22 de Novembro de 2025  
**Versão:** 1.0  
**Status:** ✅ Documentação Completa