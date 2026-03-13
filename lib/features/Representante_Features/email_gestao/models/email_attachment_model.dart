import 'dart:convert';
import 'dart:typed_data';

/// Representa um arquivo anexado ao email de forma cross-platform.
///
/// Utiliza [Uint8List] em vez de [dart:io File] para funcionar
/// tanto em mobile (Android/iOS) quanto na web (Flutter Web).
class EmailAttachmentModel {
  /// Bytes do arquivo (conteúdo binário)
  final Uint8List bytes;

  /// Nome do arquivo com extensão (ex: 'foto_comunicado.jpg')
  final String filename;

  /// MIME type do arquivo (ex: 'image/jpeg', 'image/png')
  final String mimeType;

  /// Tamanho em bytes para exibição ao usuário
  final int sizeBytes;

  const EmailAttachmentModel({
    required this.bytes,
    required this.filename,
    required this.mimeType,
    required this.sizeBytes,
  });

  /// Limite máximo permitido: 5MB em bytes
  static const int maxSizeBytes = 5 * 1024 * 1024;

  /// Converte os bytes para base64 string para envio via JSON ao Laravel.
  String toBase64() => base64Encode(bytes);

  /// Formato legível do tamanho do arquivo
  String get sizeFormatted {
    if (sizeBytes < 1024) return '$sizeBytes B';
    if (sizeBytes < 1024 * 1024) {
      return '${(sizeBytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  /// Verifica se o arquivo está dentro do limite de tamanho
  bool get isValidSize => sizeBytes <= maxSizeBytes;

  /// Converte para o formato JSON esperado pelo backend Laravel/Resend
  Map<String, dynamic> toJsonPayload() {
    return {
      'filename': filename,
      'content': toBase64(),
    };
  }
}
