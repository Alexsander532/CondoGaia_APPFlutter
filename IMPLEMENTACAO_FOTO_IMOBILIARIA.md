# Implementação: Upload de Foto da Imobiliária com Camera/Galeria

## 📋 Funcionalidade Implementada

Adicionado sistema completo de upload de foto da imobiliária com:
- ✅ Seleção de câmera (mobile) ou galeria (web + mobile)
- ✅ Upload automático para Supabase Storage
- ✅ Visualização de foto em modo ampliado com zoom
- ✅ Salvamento da URL da foto no banco de dados

---

## 🔧 Alterações Técnicas Realizadas

### 1. **Modelo Imobiliaria Atualizado** (`lib/models/imobiliaria.dart`)

Adicionado campo `fotoUrl`:
```dart
final String? fotoUrl;  // Nova propriedade
```

Atualizado `fromJson()`, `toJson()` e `copyWith()` para incluir `foto_url`

### 2. **Imports Adicionados** (`detalhes_unidade_screen.dart`)

```dart
import 'package:flutter/foundation.dart';        // Para kIsWeb
import 'package:image_picker/image_picker.dart'; // Para selecionar imagem
import 'dart:typed_data';                        // Para Uint8List
import '../services/supabase_service.dart';      // Para upload
```

### 3. **Variáveis de Estado Adicionadas**

```dart
final ImagePicker _imagePicker = ImagePicker();
Uint8List? _fotoImobiliariaBytes;
bool _isUploadingFotoImobiliaria = false;
```

### 4. **Funções Implementadas**

#### a) `_showImageSourceDialogImobiliaria()`
- Abre dialog com opções: Galeria e Câmera (mobile only)
- Compatível com web e mobile

#### b) `_pickImageImobiliaria(ImageSource source)`
- Seleciona imagem de câmera ou galeria
- Comprime imagem (maxWidth: 800, maxHeight: 800, quality: 85)
- Automaticamente chama `_uploadFotoImobiliaria()`

#### c) `_uploadFotoImobiliaria()`
- Faz upload para Supabase Storage no bucket 'documentos'
- Retorna URL pública da imagem
- Atualiza `_imobiliaria.fotoUrl` no estado
- Mostra feedback ao usuário

#### d) `_showFotoImobiliariaZoom()`
- Exibe dialog com `InteractiveViewer` para zoom
- Permite pan e zoom da imagem
- Suporta carregamento com spinner

### 5. **Widget de Foto Atualizado** (`_buildImobiliariaContent()`)

**Se já tem foto:**
```dart
GestureDetector(
  onTap: _showFotoImobiliariaZoom,  // Clica para zoom
  child: Container(
    width: 120,
    height: 120,
    image: DecorationImage(
      image: NetworkImage(_imobiliaria!.fotoUrl!),
    ),
    child: Icon(Icons.zoom_in),  // Indicador de zoom
  ),
)
```

**Se não tem foto:**
```dart
GestureDetector(
  onTap: _showImageSourceDialogImobiliaria,  // Clica para selecionar
  child: Container(
    width: 120,
    height: 120,
    child: Column(
      children: [
        Icon(Icons.camera_alt_outlined),
        Text('Anexar foto'),
      ],
    ),
  ),
)
```

### 6. **Salvamento de Dados** (`_salvarImobiliaria()`)

Atualizado para incluir `foto_url`:
```dart
final dadosAtualizacao = <String, dynamic>{
  'nome': _imobiliariaNomeController.text.trim(),
  'cnpj': _imobiliariaCnpjController.text.trim(),
  'telefone': ...,
  'celular': ...,
  'email': ...,
  'foto_url': _imobiliaria?.fotoUrl,  // ← Nova linha
};
```

---

## 📝 Passo a Passo para Completar

### Passo 1: Adicionar Coluna no Banco de Dados

Execute no Supabase SQL Editor:

```sql
-- Adicionar coluna foto_url na tabela imobiliarias
ALTER TABLE imobiliarias
ADD COLUMN foto_url TEXT NULL;

-- Criar comentário para documentação
COMMENT ON COLUMN imobiliarias.foto_url IS 'URL pública da foto da imobiliária armazenada no Supabase Storage';
```

### Passo 2: Verificar Bucket do Supabase

✅ **Você já criou o bucket**: `Imobiliaria_Unidade_Morador`

**Configurações necessárias no bucket:**
1. Acesse: Supabase → Storage → Imobiliaria_Unidade_Morador
2. Clique em **Policies**
3. Crie policy para `SELECT` (leitura pública)
4. Crie policy para `INSERT` (upload)

**Policy para SELECT (Público):**
```sql
CREATE POLICY "Allow public read"
ON storage.objects FOR SELECT
USING (bucket_id = 'Imobiliaria_Unidade_Morador');
```

**Policy para INSERT:**
```sql
CREATE POLICY "Allow authenticated users to upload"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'Imobiliaria_Unidade_Morador');
```

### Passo 3: Testar a Funcionalidade

1. **Abra a tela de Detalhes da Unidade**
2. **Expanda a seção "Imobiliária"**
3. **Clique em "Anexar foto"** (ícone de câmera)
4. **Escolha:** Galeria ou Câmera (em mobile)
5. **Aguarde o upload** (mensagem "Enviando...")
6. **Foto aparecerá** com ícone de zoom
7. **Clique em "SALVAR IMOBILIÁRIA"** para confirmar
8. ✅ Foto será salva no banco de dados

---

## 🎯 Fluxo de Funcionamento

```
[Botão Anexar Foto]
        ↓
[Dialog: Câmera/Galeria]
        ↓
[Seleciona Imagem]
        ↓
[Upload para Supabase Storage]
        ↓
[Obtém URL Pública]
        ↓
[Exibe Foto no Widget]
        ↓
[Clica em "SALVAR IMOBILIÁRIA"]
        ↓
[URL é salva no campo foto_url da tabela]
```

---

## 🖼️ Recursos Visuais

### Antes de anexar foto:
```
┌──────────────────┐
│ 📷 Anexar foto   │
└──────────────────┘
```

### Depois de anexar foto:
```
┌──────────────────┐
│  [Foto da Imo]   │
│  🔍 Zoom        │
└──────────────────┘
```

### Ao clicar em zoom:
```
Dialog com InteractiveViewer
Permite: Pan e Zoom
Tecla Esc: Fecha
```

---

## ✅ Checklist de Implementação

- [x] Atualizar modelo Imobiliaria com campo fotoUrl
- [x] Adicionar imports necessários (ImagePicker, Foundation, etc)
- [x] Implementar _showImageSourceDialogImobiliaria()
- [x] Implementar _pickImageImobiliaria()
- [x] Implementar _uploadFotoImobiliaria()
- [x] Implementar _showFotoImobiliariaZoom()
- [x] Atualizar widget _buildImobiliariaContent()
- [x] Atualizar _salvarImobiliaria() para incluir foto_url
- [ ] Adicionar coluna foto_url no Supabase
- [ ] Configurar policies do bucket
- [ ] Testar em web (galeria)
- [ ] Testar em mobile (câmera + galeria)

---

## 🧪 Testes Recomendados

### Teste 1: Upload via Galeria (Web/Mobile)
1. Clique em "Anexar foto"
2. Selecione "Galeria"
3. Escolha uma imagem
4. Verifique se foto aparece
5. Clique em zoom para confirmar

### Teste 2: Upload via Câmera (Mobile Only)
1. Clique em "Anexar foto"
2. Selecione "Câmera"
3. Tire uma foto
4. Verifique se foto aparece
5. Clique em zoom

### Teste 3: Salvamento no Banco
1. Faça upload de uma foto
2. Clique em "SALVAR IMOBILIÁRIA"
3. Verifique no Supabase se `foto_url` foi preenchido

### Teste 4: Persistência
1. Recarregue a página
2. Abra a mesma unidade novamente
3. Verifique se a foto carregou (deve vir de `imobiliaria.fotoUrl`)

---

## 📦 Dependências Utilizadas

- `image_picker: ^1.0.0+` - Já está no pubspec.yaml
- `flutter/foundation.dart` - Para detecção de web (kIsWeb)
- `Supabase Storage` - Bucket 'documentos' reutilizado

---

## 🔐 Segurança

- ✅ Upload apenas para usuários autenticados
- ✅ Imagens comprimidas (max 800x800, quality 85)
- ✅ Nomes de arquivo com timestamp único
- ✅ URLs públicas de leitura (melhor que base64)

---

## 🚀 Próximos Passos (Opcional)

- [ ] Adicionar suporte a múltiplas fotos
- [ ] Implementar crop/edição de imagem antes de upload
- [ ] Adicionar indicador de progresso (%) de upload
- [ ] Permitir deletar/trocar foto

---

**Data de Conclusão**: 23/11/2025  
**Status**: ✅ Implementação Completa (Aguardando: Adicionar coluna no Supabase)
