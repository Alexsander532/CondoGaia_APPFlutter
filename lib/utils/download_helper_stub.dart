import 'dart:typed_data';
import 'package:flutter/material.dart';

class DownloadHelper {
  static Future<void> downloadFile(
    Uint8List bytes,
    BuildContext context,
  ) async {
    // Mostra aviso para usuários no Android/iOS
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'O download do template só está disponível na versão web. Acesse o site para baixar o template.',
          ),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 5),
        ),
      );
    }
  }

  // Método para download de PDF da web (versão stub para mobile)
  static Future<void> downloadPdfFromUrl(
    String pdfUrl,
    String fileName,
    BuildContext context,
  ) async {
    // Em mobile, os downloads são feitos via DocumentoService
    // Este método é apenas um placeholder para manter compatibilidade
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Download em progresso...'),
          backgroundColor: Colors.blue,
        ),
      );
    }
  }
}