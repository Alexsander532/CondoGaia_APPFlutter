import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class DownloadHelper {
  static Future<void> downloadFile(
    Uint8List bytes,
    BuildContext context,
  ) async {
    // Mantendo legado se necessário
  }

  static Future<void> downloadPdfFromUrl(
    String pdfUrl,
    String fileName,
    BuildContext context,
  ) async {
    // Mantendo legado se necessário
  }

  static Future<void> downloadBytes(
    Uint8List bytes,
    String fileName,
    BuildContext context,
  ) async {
    try {
      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/$fileName';
      final file = File(filePath);
      await file.writeAsBytes(bytes);

      await Share.shareXFiles([
        XFile(filePath),
      ], subject: 'Download do Layout - $fileName');
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao baixar arquivo no mobile: $e')),
        );
      }
    }
  }
}
