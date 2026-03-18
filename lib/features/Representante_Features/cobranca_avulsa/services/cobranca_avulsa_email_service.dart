import 'package:condogaiaapp/services/laravel_api_service.dart';

/// Serviço responsável por disparar e-mails relacionados a cobranças avulsas.
class CobrancaAvulsaEmailService {
  final LaravelApiService _apiService = LaravelApiService();

  /// Notifica o morador que uma nova cobrança avulsa foi gerada.
  Future<void> enviarCobrancaAvulsa({
    required String email,
    required String nome,
    required String descricao,
    required double valor,
    required String dataVencimento,
    String? comprovanteUrl,
  }) async {
    try {
      final payload = {
        'email': email,
        'nome': nome,
        'descricao': descricao,
        'valor': valor,
        'dataVencimento': dataVencimento,
        if (comprovanteUrl != null) 'comprovanteUrl': comprovanteUrl,
      };

      await _apiService.post('/resend/cobranca-avulsa/enviar', payload);
    } catch (e) {
      // Não bloquear o fluxo principal por falha de e-mail
      print('⚠️ [CobrancaAvulsaEmailService] Erro ao enviar e-mail: $e');
    }
  }
}
