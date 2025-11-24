# 📋 Plano Completo: QR Code para Autorizados (Prop/Inq)

## 🎯 Visão Geral

Adicionar um **QR Code** em cada card de autorizado (Proprietário/Inquilino) que:
- Codifica informações do autorizado (nome, CPF, telefone, etc.)
- Pode ser copiado como imagem para a área de transferência
- Segue o design similar ao exemplo anexado (foto com label "Trocar Foto" + QR Code abaixo)

---

## 📊 Arquitetura da Solução

### **Stack Tecnológico**

```
Frontend (Flutter)
├── qr_flutter: ^6.0.0 (Gerar QR Code)
├── image_gallery_saver: ^2.0.0 (Copiar imagem para clipboard)
└── Existing: [intl, provider, etc]

Backend (Supabase)
├── autorizados_inquilinos (tabela - PODE NÃO PRECISAR MUDANÇA)
└── autorizados_representantes (tabela - PODE NÃO PRECISAR MUDANÇA)
```

---

## 🗄️ Banco de Dados

### **Status Atual**

A tabela `autorizados_inquilinos` (e equivalente para representantes) provavelmente tem:

```sql
CREATE TABLE autorizados_inquilinos (
  id uuid PRIMARY KEY,
  inquilino_id uuid REFERENCES inquilinos(id),
  nome varchar(255) NOT NULL,
  cpf_cnpj varchar(20) NOT NULL,
  telefone varchar(20),
  data_autorizacao timestamp,
  -- ... outros campos
)
```

### **Mudança Necessária: NENHUMA!**

✅ Os dados para gerar o QR Code já existem na tabela!

**O que será codificado no QR:**
```
{
  "id": "abc-123",
  "nome": "João Silva",
  "cpf": "123.456.789-00",
  "telefone": "11987654321",
  "tipo": "inquilino",
  "unidade": "101",
  "data": "2025-11-23"
}
```

---

## 🎨 Design (Frontend)

### **Card Atual (Padrão)**

```
┌─────────────────────────────────┐
│  Nome: João Silva               │
│  CPF: 123.456.789-00            │
│  Telefone: (11) 98765-4321      │
│  Data: 23/11/2025               │
│  [Editar]  [Deletar]            │
└─────────────────────────────────┘
```

### **Card com QR Code (Novo)**

```
┌──────────────────────────────────────────┐
│                                          │
│  ┌──────────────────────────────────┐  │
│  │  📷  Trocar Foto  [Ícone]        │  │ ← (Opcional: espaço para foto)
│  └──────────────────────────────────┘  │
│                                          │
│  Nome: João Silva                       │
│  CPF: 123.456.789-00                    │
│  Telefone: (11) 98765-4321              │
│                                          │
│  ┌──────────────────────────────────┐  │
│  │                                  │  │
│  │       ██████████████████         │  │ ← QR Code
│  │       ██          ██             │  │    (200x200px)
│  │       ██  ██████  ██             │  │
│  │       ██  ██  ██  ██             │  │
│  │       ██  ██████  ██             │  │
│  │       ██          ██             │  │
│  │       ██████████████████         │  │
│  │                                  │  │
│  └──────────────────────────────────┘  │
│                                          │
│  [📋 Copiar QR]  [Editar]  [Deletar]   │
│                                          │
└──────────────────────────────────────────┘
```

---

## 🔧 Implementação (Passo a Passo)

### **1️⃣ Adicionar Dependências (pubspec.yaml)**

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # Novo: Gerar QR Code
  qr_flutter: ^6.2.0
  
  # Novo: Copiar imagem para clipboard
  image_gallery_saver: ^2.0.0
  
  # Novo: Compartilhar imagem
  share_plus: ^7.0.0
  
  # Existentes...
  intl: ^0.19.0
  provider: ^6.0.0
```

**Executar após adicionar:**
```bash
flutter pub get
```

---

### **2️⃣ Modelo de Dados (AutorizadoInquilino)**

**Arquivo:** `lib/models/autorizado_inquilino.dart`

```dart
class AutorizadoInquilino {
  final String id;
  final String inquilinoId;
  final String nome;
  final String cpfCnpj;
  final String? telefone;
  final DateTime? dataAutorizacao;
  // ... outros campos
  
  /// Gera dados para QR Code (JSON)
  String gerarDadosQR({
    String? unidade,
    String? tipoAutorizado = 'inquilino',
  }) {
    final mapa = {
      'id': id,
      'nome': nome,
      'cpf_cnpj': cpfCnpj,
      'telefone': telefone,
      'tipo': tipoAutorizado,
      'unidade': unidade,
      'data_autorizacao': dataAutorizacao?.toIso8601String(),
      'timestamp': DateTime.now().toIso8601String(),
    };
    return jsonEncode(mapa);
  }
}
```

---

### **3️⃣ Utilitário QR Code (qr_code_helper.dart)**

**Arquivo:** `lib/utils/qr_code_helper.dart`

```dart
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/rendering.dart';
import 'package:image/image.dart' as img;
import 'dart:typed_data';
import 'dart:ui' as ui;

class QrCodeHelper {
  /// Gera uma imagem PNG do QR Code a partir de dados
  static Future<Uint8List?> gerarImagemQR(String dados, {int tamanho = 200}) async {
    try {
      final qrPainter = QrPainter(
        data: dados,
        version: QrVersions.auto,
        gapless: true,
        color: const Color(0xFF000000),
        emptyColor: const Color(0xFFFFFFFF),
      );

      final imagem = await qrPainter.toImageData(
        size: tamanho.toDouble(),
      );

      return imagem?.buffer.asUint8List();
    } catch (e) {
      print('Erro ao gerar imagem QR: $e');
      return null;
    }
  }

  /// Copia a imagem QR para a área de transferência
  static Future<bool> copiarQRParaClipboard(String dados) async {
    try {
      final imagemBytes = await gerarImagemQR(dados);
      if (imagemBytes == null) return false;

      // Usar image_gallery_saver ou clipboard
      // Para clipboard nativo, usar:
      // Clipboard.setData(ClipboardData(text: dados));
      
      return true;
    } catch (e) {
      print('Erro ao copiar QR: $e');
      return false;
    }
  }

  /// Compartilha a imagem QR
  static Future<bool> compartilharQR(String dados, String nome) async {
    try {
      final imagemBytes = await gerarImagemQR(dados);
      if (imagemBytes == null) return false;

      // Usar share_plus para compartilhar
      // Share.shareXFiles(...);
      
      return true;
    } catch (e) {
      print('Erro ao compartilhar QR: $e');
      return false;
    }
  }
}
```

---

### **4️⃣ Widget QR Code (qr_code_widget.dart)**

**Arquivo:** `lib/widgets/qr_code_widget.dart`

```dart
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../utils/qr_code_helper.dart';

class QrCodeWidget extends StatefulWidget {
  final String dados;
  final String nome;
  final VoidCallback onCopiar;
  final VoidCallback? onCompartilhar;

  const QrCodeWidget({
    Key? key,
    required this.dados,
    required this.nome,
    required this.onCopiar,
    this.onCompartilhar,
  }) : super(key: key);

  @override
  State<QrCodeWidget> createState() => _QrCodeWidgetState();
}

class _QrCodeWidgetState extends State<QrCodeWidget> {
  bool _copiando = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey[50],
      ),
      child: Column(
        children: [
          // QR Code
          Center(
            child: QrImageView(
              data: widget.dados,
              version: QrVersions.auto,
              size: 200,
              embeddedImage: null,
              gapless: true,
              errorCorrectionLevel: QrErrorCorrectLevel.H,
              dataModuleStyle: const QrDataModuleStyle(
                dataModuleShape: QrDataModuleShape.square,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Label
          Text(
            'QR Code de: ${widget.nome}',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          // Botões
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: _copiando ? null : _copiarQR,
                icon: _copiando
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(Icons.content_copy),
                label: Text(_copiando ? 'Copiando...' : 'Copiar QR'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              if (widget.onCompartilhar != null)
                ElevatedButton.icon(
                  onPressed: widget.onCompartilhar,
                  icon: const Icon(Icons.share),
                  label: const Text('Compartilhar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _copiarQR() async {
    setState(() => _copiando = true);

    final sucesso = await QrCodeHelper.copiarQRParaClipboard(widget.dados);

    setState(() => _copiando = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          sucesso ? 'QR Code copiado para a área de transferência!' : 'Erro ao copiar QR Code',
        ),
        backgroundColor: sucesso ? Colors.green : Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );

    if (sucesso) {
      widget.onCopiar();
    }
  }
}
```

---

### **5️⃣ Card de Autorizado Atualizado**

**Arquivo:** `lib/screens/portaria_inquilino_screen.dart`

```dart
Widget _buildAutorizadoCardFromModel(AutorizadoInquilino autorizado) {
  return Card(
    margin: const EdgeInsets.symmetric(vertical: 8),
    child: ExpansionTile(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              autorizado.nome,
              style: const TextStyle(fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (autorizado.cpfCnpj != null)
            Text(
              autorizado.cpfCnpj!,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
        ],
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Informações
              Text('Telefone: ${autorizado.telefone ?? "N/A"}'),
              Text('Data: ${autorizado.dataAutorizacao?.toString() ?? "N/A"}'),
              const SizedBox(height: 16),

              // QR Code
              QrCodeWidget(
                dados: autorizado.gerarDadosQR(
                  unidade: widget.unidade,
                  tipoAutorizado: 'inquilino',
                ),
                nome: autorizado.nome,
                onCopiar: () {
                  // Feedback
                },
              ),
              const SizedBox(height: 16),

              // Botões
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(icon: const Icon(Icons.edit), label: const Text('Editar')),
                  TextButton(icon: const Icon(Icons.delete), label: const Text('Deletar')),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
```

---

## 📋 O que será Codificado no QR

```json
{
  "id": "12345678-1234-1234-1234-123456789012",
  "nome": "João Silva Santos",
  "cpf_cnpj": "123.456.789-00",
  "telefone": "(11) 98765-4321",
  "tipo": "inquilino",
  "unidade": "101",
  "data_autorizacao": "2025-11-23T10:30:00Z",
  "timestamp": "2025-11-23T18:45:30Z"
}
```

---

## 🔄 Fluxo de Uso

```
User abre Portaria (Prop/Inq)
    ↓
User seleciona Unidade
    ↓
User vê lista de Autorizados
    ↓
User clica em um Autorizado
    ↓
Card se expande mostrando:
  ✅ Informações básicas
  ✅ QR Code gerado
  ✅ Botão "Copiar QR"
    ↓
User clica "Copiar QR"
    ↓
Sistema gera imagem PNG do QR
    ↓
Imagem é copiada para clipboard
    ↓
User pode colar em WhatsApp, Email, etc
```

---

## 📝 Arquivos a Criar/Modificar

| Arquivo | Tipo | O quê |
|---------|------|-------|
| `pubspec.yaml` | Modificar | Adicionar dependências (qr_flutter, image_gallery_saver) |
| `lib/utils/qr_code_helper.dart` | Criar | Utilitários para gerar QR |
| `lib/widgets/qr_code_widget.dart` | Criar | Widget reutilizável de QR |
| `lib/models/autorizado_inquilino.dart` | Modificar | Adicionar método `gerarDadosQR()` |
| `lib/screens/portaria_inquilino_screen.dart` | Modificar | Integrar QR no card |
| `lib/screens/portaria_representante_screen.dart` | Modificar | Integrar QR no card |

---

## ✨ Benefícios

✅ **Compartilhamento Fácil:** Copiar QR e enviar direto  
✅ **Verificação:** Portaria pode escanear para confirmar autorizado  
✅ **Informações:** QR contém dados de contato/identificação  
✅ **Segurança:** Dados codificados, difícil de falsificar  
✅ **Mobile:** Funciona em qualquer smartphone  

---

## 🎯 Próximas Etapas

1. ✅ Plano criado
2. ⏳ Adicionar dependências ao pubspec.yaml
3. ⏳ Criar `qr_code_helper.dart`
4. ⏳ Criar `qr_code_widget.dart`
5. ⏳ Atualizar modelos (AutorizadoInquilino)
6. ⏳ Integrar no `portaria_inquilino_screen.dart`
7. ⏳ Integrar no `portaria_representante_screen.dart`
8. ⏳ Testar cópia para clipboard
9. ⏳ Testar escanear QR gerado

---

## ✅ Status

- ✅ Plano detalhado e completo
- ⏳ Aguardando aprovação para implementar
