import 'package:condogaiaapp/services/laravel_api_service.dart';

class BoletoEmailService {
  final LaravelApiService _apiService = LaravelApiService();

  /// Enviar boleto por email
  Future<void> enviarBoleto({
    required String email,
    required String nome,
    required double valor,
    required String dataVencimento,
  }) async {
    try {
      final payload = {
        'email': email,
        'nome': nome,
        'valor': valor,
        'dataVencimento': dataVencimento,
      };

      await _apiService.post('/resend/boleto/enviar', payload);
    } catch (e) {
      print('⚠️ [BoletoEmailService] Erro ao enviar boleto por e-mail: $e');
      throw Exception(
        'Falha ao enviar boleto por e-mail. Verifique sua conexão e tente novamente.',
      );
    }
  }

  /// Enviar lembrete de vencimento
  Future<void> enviarLembrete({
    required String email,
    required String nome,
    required double valor,
    required String dataVencimento,
    required int diasRestantes,
  }) async {
    try {
      final payload = {
        'email': email,
        'nome': nome,
        'valor': valor,
        'dataVencimento': dataVencimento,
        'diasRestantes': diasRestantes,
      };

      await _apiService.post('/resend/boleto/lembrete', payload);
    } catch (e) {
      print('⚠️ [BoletoEmailService] Erro ao enviar lembrete por e-mail: $e');
      throw Exception(
        'Falha ao enviar lembrete por e-mail. Verifique sua conexão e tente novamente.',
      );
    }
  }

  /// Enviar boletos em lote
  Future<void> enviarLote(List<Map<String, dynamic>> boletos) async {
    try {
      final payload = {'boletos': boletos};

      await _apiService.post('/resend/boleto/enviar-lote', payload);
    } catch (e) {
      print(
        '⚠️ [BoletoEmailService] Erro ao enviar boletos em lote por e-mail: $e',
      );
      throw Exception(
        'Falha ao enviar boletos em lote por e-mail. Verifique sua conexão e tente novamente.',
      );
    }
  }
}
