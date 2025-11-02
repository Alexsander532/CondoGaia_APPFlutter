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
}