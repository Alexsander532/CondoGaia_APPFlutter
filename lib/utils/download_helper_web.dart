import 'dart:html' as html;
import 'dart:typed_data';
import 'package:flutter/material.dart';

class DownloadHelper {
  static Future<void> downloadFile(
    Uint8List bytes,
    BuildContext context,
  ) async {
    try {
      // Verifica se o arquivo não está vazio ou corrompido
      if (bytes.isEmpty) {
        throw Exception('Arquivo template está vazio');
      }

      // Verifica se é um arquivo ODS válido (deve começar com PK)
      if (bytes.length < 4 || bytes[0] != 0x50 || bytes[1] != 0x4B) {
        throw Exception('Arquivo template não é um ODS válido');
      }

      // Cria o blob com o tipo MIME correto para ODS
      final blob = html.Blob([
        bytes,
      ], 'application/vnd.oasis.opendocument.spreadsheet');
      final url = html.Url.createObjectUrlFromBlob(blob);

      // Gera nome único para evitar problemas de cache
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String fileName =
          'Template_Unidade_Morador_Condogaia_V1_$timestamp.ods';

      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', fileName)
        ..style.display = 'none';

      // Adiciona ao DOM, clica e remove
      html.document.body?.append(anchor);
      anchor.click();
      anchor.remove();

      // Limpa a URL do blob
      html.Url.revokeObjectUrl(url);

      // Mostra mensagem de sucesso
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Template baixado com sucesso!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      // Mostra mensagem de erro
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao baixar template: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }
}
