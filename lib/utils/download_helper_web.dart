import 'dart:html' as html;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

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

  // Método para download de PDF da web
  static Future<void> downloadPdfFromUrl(
    String pdfUrl,
    String fileName,
    BuildContext context,
  ) async {
    try {
      // Mostra indicador de carregamento
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.white)),
                ),
                SizedBox(width: 16),
                Text('Baixando PDF...'),
              ],
            ),
            duration: Duration(seconds: 30),
          ),
        );
      }

      // Faz download dos bytes do PDF usando Dio
      final Dio dio = Dio();
      final response = await dio.get<List<int>>(
        pdfUrl,
        options: Options(
          responseType: ResponseType.bytes,
        ),
      );

      final Uint8List bytes = Uint8List.fromList(response.data ?? []);

      if (bytes.isEmpty) {
        throw Exception('PDF vazio ou não conseguiu fazer download');
      }

      // Cria o blob com o tipo MIME correto para PDF
      final blob = html.Blob([bytes], 'application/pdf');
      final url = html.Url.createObjectUrlFromBlob(blob);

      // Gera nome com timestamp para evitar problemas de cache
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String finalFileName = fileName.contains('.pdf')
          ? fileName.replaceAll('.pdf', '_$timestamp.pdf')
          : '$fileName\_$timestamp.pdf';

      // Cria e clica no elemento de download
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', finalFileName)
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
          SnackBar(
            content: Text('✓ PDF "$fileName" baixado com sucesso!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }

      print('PDF baixado com sucesso: $finalFileName');
    } catch (e) {
      print('Erro ao baixar PDF: $e');

      // Mostra mensagem de erro
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao baixar PDF: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }
}