# 💻 Comandos e Snippets: QR Code Implementation

## 🚀 Fase 1: Adicionar Dependências

### Comando para terminal

```bash
flutter pub add qr_flutter image_gallery_saver share_plus
```

Ou manualmente em `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # Novo
  qr_flutter: ^6.2.0
  image_gallery_saver: ^2.0.0
  share_plus: ^7.0.0
  
  # Existentes...
  intl: ^0.19.0
  provider: ^6.0.0
  http: ^1.1.0
  supabase_flutter: ^2.0.0
```

Depois execute:
```bash
flutter pub get
```

---

## 📁 Fase 2: Criar lib/utils/qr_code_helper.dart

```dart
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;

class QrCodeHelper {
  /// Gera uma imagem PNG do QR Code a partir de dados
  static Future<Uint8List?> gerarImagemQR(
    String dados, {
    int tamanho = 200,
  }) async {
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

      // Nota: Flutter não tem suporte nativo para copiar imagens
      // Use image_gallery_saver para salvar primeiro, depois compartilhar
      // Ou implemente nativo (iOS/Android)
      
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

      // Use share_plus para compartilhar
      // final result = await Share.shareXFiles(
      //   [XFile.fromData(imagemBytes, name: '${nome}_qr.png')],
      //   text: 'QR Code de: $nome',
      // );
      
      return true;
    } catch (e) {
      print('Erro ao compartilhar QR: $e');
      return false;
    }
  }

  /// Valida se os dados não estão vazios
  static bool validarDados(String dados) {
    return dados.trim().isNotEmpty && dados.length < 2953;
  }
}
```

---

## 📁 Fase 3: Criar lib/widgets/qr_code_widget.dart

```dart
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../utils/qr_code_helper.dart';

class QrCodeWidget extends StatefulWidget {
  final String dados;
  final String nome;
  final VoidCallback? onCopiar;
  final VoidCallback? onCompartilhar;

  const QrCodeWidget({
    Key? key,
    required this.dados,
    required this.nome,
    this.onCopiar,
    this.onCompartilhar,
  }) : super(key: key);

  @override
  State<QrCodeWidget> createState() => _QrCodeWidgetState();
}

class _QrCodeWidgetState extends State<QrCodeWidget> {
  bool _copiando = false;
  bool _compartilhando = false;

  @override
  Widget build(BuildContext context) {
    if (!QrCodeHelper.validarDados(widget.dados)) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.red[300]!),
          borderRadius: BorderRadius.circular(12),
          color: Colors.red[50],
        ),
        child: Text(
          'Dados inválidos para gerar QR Code',
          style: TextStyle(color: Colors.red[700]),
        ),
      );
    }

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
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ElevatedButton.icon(
                onPressed: _copiando ? null : _copiarQR,
                icon: _copiando
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Icon(Icons.content_copy),
                label: Text(_copiando ? 'Copiando...' : 'Copiar QR'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey,
                ),
              ),
              if (widget.onCompartilhar != null)
                ElevatedButton.icon(
                  onPressed: _compartilhando ? null : _compartilharQR,
                  icon: _compartilhando
                      ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Icon(Icons.share),
                  label: Text(
                    _compartilhando ? 'Compartilhando...' : 'Compartilhar',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey,
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

    try {
      final sucesso = await QrCodeHelper.copiarQRParaClipboard(
        widget.dados,
      );

      setState(() => _copiando = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            sucesso
                ? 'QR Code copiado para a área de transferência!'
                : 'Erro ao copiar QR Code',
          ),
          backgroundColor: sucesso ? Colors.green : Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );

      if (sucesso && widget.onCopiar != null) {
        widget.onCopiar!();
      }
    } catch (e) {
      setState(() => _copiando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao copiar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _compartilharQR() async {
    setState(() => _compartilhando = true);

    try {
      // Implementar compartilhamento aqui
      if (widget.onCompartilhar != null) {
        widget.onCompartilhar!();
      }

      setState(() => _compartilhando = false);
    } catch (e) {
      setState(() => _compartilhando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao compartilhar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
```

---

## 📝 Fase 4: Atualizar Modelo AutorizadoInquilino

**Arquivo:** `lib/models/autorizado_inquilino.dart`

```dart
import 'dart:convert';

// Adicionar método à classe AutorizadoInquilino:

class AutorizadoInquilino {
  // ... campos existentes ...
  
  /// Gera dados JSON para codificar no QR Code
  String gerarDadosQR({
    String? unidade,
    String tipoAutorizado = 'inquilino',
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

## 🎨 Fase 5: Integrar no portaria_inquilino_screen.dart

```dart
// Adicionar import no topo
import '../widgets/qr_code_widget.dart';

// Atualizar o widget _buildAutorizadoCardFromModel:

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
              // Informações básicas
              if (autorizado.telefone != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    'Telefone: ${autorizado.telefone}',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              if (autorizado.dataAutorizacao != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    'Data: ${autorizado.dataAutorizacao}',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),

              // QR Code Widget
              QrCodeWidget(
                dados: autorizado.gerarDadosQR(
                  unidade: widget.unidade ?? 'N/A',
                  tipoAutorizado: 'inquilino',
                ),
                nome: autorizado.nome,
                onCopiar: () {
                  // Feedback adicional se necessário
                },
              ),
              const SizedBox(height: 16),

              // Botões de ação
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      // Editar autorizado
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Editar'),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      // Deletar autorizado
                    },
                    icon: const Icon(Icons.delete),
                    label: const Text('Deletar'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                  ),
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

## 🎨 Fase 6: Integrar no portaria_representante_screen.dart

```dart
// Mesmo padrão do inquilino, mas adaptar para AutorizadoRepresentante
// Adicionar import:

import '../widgets/qr_code_widget.dart';

// E integrar QrCodeWidget no card de autorizado
```

---

## ✅ Verificação Final

```bash
# Verificar se compila sem erros
flutter analyze

# Testar se as dependências foram instaladas
flutter pub get

# Executar testes (se houver)
flutter test

# Rodar na primeira tela que integrou QR
flutter run
```

---

## 🐛 Debug

Se encontrar erros, adicione logging:

```dart
// No QrCodeHelper
print('[QR] Gerando QR Code...');
print('[QR] Tamanho dos dados: ${dados.length} caracteres');
print('[QR] Dados: $dados');

// No QrCodeWidget
print('[QR Widget] Copiando...');
print('[QR Widget] Compartilhando...');
```

---

## 📱 Teste em Device

```bash
# Compilar APK para Android
flutter build apk

# Compilar IPA para iOS
flutter build ios

# Rodar em device físico
flutter run
```

---

## 💡 Dicas

1. **Para testar cópia:** Use um emulador que suporte clipboard
2. **Para testar compartilhamento:** Instale WhatsApp/Email no emulador
3. **Para testar escaneamento:** Use app de QR Scanner (Google Lens, etc)
4. **Para debug:** Use `flutter run -v` para logs detalhados

