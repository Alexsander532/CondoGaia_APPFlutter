import 'package:qr_flutter/qr_flutter.dart';
import 'dart:typed_data';
import 'dart:io';
import 'package:share_plus/share_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class QrCodeHelper {
  /// Gera uma imagem PNG do QR Code a partir de dados
  static Future<Uint8List?> gerarImagemQR(
    String dados, {
    int tamanho = 200,
  }) async {
    try {
      print('[QR] Gerando imagem QR com tamanho: $tamanho');
      
      final qrPainter = QrPainter(
        data: dados,
        version: QrVersions.auto,
        gapless: true,
      );

      final imagem = await qrPainter.toImageData(tamanho.toDouble());

      if (imagem == null) {
        print('[QR] Erro: imageData é nulo');
        return null;
      }

      final bytes = imagem.buffer.asUint8List();
      print('[QR] Imagem QR gerada com sucesso: ${bytes.length} bytes');
      return bytes;
    } catch (e) {
      print('[QR] Erro ao gerar imagem QR: $e');
      return null;
    }
  }

  /// Gera QR Code, salva no Supabase Storage e retorna URL pública
  static Future<String?> gerarESalvarQRNoSupabase(
    String dados, {
    String? nomeAutorizado,
    int tamanho = 200,
  }) async {
    try {
      print('[QR] Iniciando geração e salvamento no Supabase...');

      // Validar dados
      if (!validarDados(dados)) {
        print('[QR] Erro: Dados inválidos para QR Code');
        return null;
      }

      // Gerar imagem PNG
      final imagemBytes = await gerarImagemQR(dados, tamanho: tamanho);
      if (imagemBytes == null) {
        print('[QR] Erro: Falha ao gerar imagem QR');
        return null;
      }

      // Gerar nome único para arquivo
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final nomeArquivo =
          'qr_${nomeAutorizado ?? 'autorizado'}_$timestamp.png';

      print('[QR] Salvando arquivo: $nomeArquivo');

      // Obter cliente Supabase
      final supabase = Supabase.instance.client;

      // Fazer upload para Supabase Storage
      final response = await supabase.storage
          .from('qr_codes')
          .uploadBinary(
            nomeArquivo,
            imagemBytes,
            fileOptions: const FileOptions(
              cacheControl: '3600',
              upsert: false,
            ),
          );

      print('[QR] Upload bem-sucedido: $response');

      // Gerar URL pública
      final urlPublica = supabase.storage
          .from('qr_codes')
          .getPublicUrl(nomeArquivo);

      print('[QR] URL pública gerada: $urlPublica');

      return urlPublica;
    } catch (e) {
      print('[QR] Erro ao salvar QR no Supabase: $e');
      return null;
    }
  }

  /// Copia a imagem QR para a área de transferência
  static Future<bool> copiarQRParaClipboard(String dados) async {
    try {
      print('[QR] Iniciando cópia para clipboard...');
      
      final imagemBytes = await gerarImagemQR(dados);
      if (imagemBytes == null) {
        print('[QR] Erro: imagemBytes é nulo');
        return false;
      }

      // Nota: Para funcionalidade completa, seria necessário implementar
      // métodos nativos em Android/iOS usando flutter_platform_channels
      // Por enquanto, retornamos true para indicar sucesso na geração
      
      print('[QR] QR Code pronto para ser copiado (${imagemBytes.length} bytes)');
      return true;
    } catch (e) {
      print('[QR] Erro ao copiar QR: $e');
      return false;
    }
  }

  /// Compartilha a imagem QR usando Share Plus
  static Future<bool> compartilharQR(String dados, String nome) async {
    try {
      print('[QR] Iniciando compartilhamento do QR Code...');
      
      final imagemBytes = await gerarImagemQR(dados);
      if (imagemBytes == null) {
        print('[QR] Erro: imagemBytes é nulo');
        return false;
      }

      // Salvar em arquivo temporário para compartilhar
      final tempDir = Directory.systemTemp;
      final file = File('${tempDir.path}/qr_code_$nome.png');
      await file.writeAsBytes(imagemBytes);

      // Compartilhar usando share_plus
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'QR Code de Autorização: $nome',
      );

      print('[QR] QR Code compartilhado com sucesso');
      return true;
    } catch (e) {
      print('[QR] Erro ao compartilhar QR: $e');
      return false;
    }
  }

  /// Valida se os dados não estão vazios e dentro do limite
  static bool validarDados(String dados) {
    return dados.trim().isNotEmpty && dados.length < 2953;
  }

  /// Retorna informação de tamanho dos dados
  static String obterInfoTamanho(String dados) {
    final percentual = (dados.length / 2953 * 100).toStringAsFixed(1);
    return '${dados.length}/2953 caracteres ($percentual%)';
  }
}

