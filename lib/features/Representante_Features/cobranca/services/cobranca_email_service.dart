import 'package:condogaiaapp/services/laravel_api_service.dart';

class CobrancaEmailService {
  final LaravelApiService _apiService = LaravelApiService();

  /// Enviar confirmação de pagamento
  Future<void> enviarConfirmacao({
    required String email,
    required String nome,
    required double valor,
    required String dataPagamento,
  }) async {
    try {
      final payload = {
        'email': email,
        'nome': nome,
        'valor': valor,
        'dataPagamento': dataPagamento,
      };

      await _apiService.post('/resend/cobranca/confirmacao', payload);
    } catch (e) {
      print(
        '⚠️ [CobrancaEmailService] Erro ao enviar confirmação de pagamento por e-mail: $e',
      );
      throw Exception(
        'Falha ao enviar confirmação de pagamento. Verifique sua conexão e tente novamente.',
      );
    }
  }

  /// Enviar recibo digital
  Future<void> enviarRecibo({
    required String email,
    required String nome,
    required double valor,
    required String dataPagamento,
  }) async {
    try {
      final payload = {
        'email': email,
        'nome': nome,
        'valor': valor,
        'dataPagamento': dataPagamento,
      };

      await _apiService.post('/resend/cobranca/recibo', payload);
    } catch (e) {
      print('⚠️ [CobrancaEmailService] Erro ao enviar recibo por e-mail: $e');
      throw Exception(
        'Falha ao enviar recibo. Verifique sua conexão e tente novamente.',
      );
    }
  }
}
