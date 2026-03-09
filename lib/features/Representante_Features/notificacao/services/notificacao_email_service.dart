import 'package:condogaiaapp/services/laravel_api_service.dart';

class NotificacaoEmailService {
  final LaravelApiService _apiService = LaravelApiService();

  /// Notificar morador sobre atraso
  Future<void> notificarAtraso({
    required String email,
    required String nome,
    required double valor,
    required String dataVencimento,
    required int diasAtraso,
  }) async {
    try {
      final payload = {
        'email': email,
        'nome': nome,
        'valor': valor,
        'dataVencimento': dataVencimento,
        'diasAtraso': diasAtraso,
      };

      await _apiService.post('/resend/notificacao/atraso', payload);
    } catch (e) {
      print(
        '⚠️ [NotificacaoEmailService] Erro ao notificar atraso por e-mail: $e',
      );
      throw Exception(
        'Falha ao notificar atraso. Verifique sua conexão e tente novamente.',
      );
    }
  }

  /// Notificar sobre leitura realizada
  Future<void> notificarLeitura({
    required String email,
    required String nome,
    required String tipoLeitura,
    required double leituraAtual,
  }) async {
    try {
      final payload = {
        'email': email,
        'nome': nome,
        'tipoLeitura': tipoLeitura,
        'leituraAtual': leituraAtual,
      };

      await _apiService.post('/resend/notificacao/leitura', payload);
    } catch (e) {
      print(
        '⚠️ [NotificacaoEmailService] Erro ao notificar leitura por e-mail: $e',
      );
      throw Exception(
        'Falha ao notificar leitura. Verifique sua conexão e tente novamente.',
      );
    }
  }

  /// Notificar sobre reserva de ambiente
  Future<void> notificarReserva({
    required String email,
    required String nome,
    required String nomeAmbiente,
    required String dataReserva,
    required String status,
  }) async {
    try {
      final payload = {
        'email': email,
        'nome': nome,
        'nomeAmbiente': nomeAmbiente,
        'dataReserva': dataReserva,
        'status': status,
      };

      await _apiService.post('/resend/notificacao/reserva', payload);
    } catch (e) {
      print(
        '⚠️ [NotificacaoEmailService] Erro ao notificar reserva por e-mail: $e',
      );
      throw Exception(
        'Falha ao notificar reserva. Verifique sua conexão e tente novamente.',
      );
    }
  }
}
