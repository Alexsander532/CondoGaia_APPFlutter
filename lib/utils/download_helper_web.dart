import 'dart:html' as html;
import 'dart:typed_data';
import 'package:flutter/material.dart';

class DownloadHelper {
  // Mantendo compatibilidade com métodos antigos
  static Future<void> downloadFile(
    Uint8List bytes,
    BuildContext context,
  ) async {}
  static Future<void> downloadPdfFromUrl(
    String pdfUrl,
    String fileName,
    BuildContext context,
  ) async {}

  static Future<void> downloadBytes(
    Uint8List bytes,
    String fileName,
    BuildContext context,
  ) async {
    try {
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute("download", fileName)
        ..style.display = 'none';

      html.document.body?.append(anchor);
      anchor.click();
      anchor.remove();
      html.Url.revokeObjectUrl(url);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Download de $fileName iniciado.')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro no download web: $e')));
      }
    }
  }
}
