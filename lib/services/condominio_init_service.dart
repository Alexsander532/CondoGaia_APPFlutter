import 'package:condogaiaapp/services/conversas_service.dart';

/// Service para inicializar dados do condomínio
/// Executa operações de setup quando um representante entra no condomínio
class CondominioInitService {
  final ConversasService _conversasService = ConversasService();

  /// Inicializa o condomínio:
  /// 1. Cria conversas automáticas com todos os proprietários e inquilinos
  /// 2. Valida dados necessários
  Future<void> inicializarCondominio(String condominioId) async {
    try {
      // Cria conversas automáticas com TODOS os proprietários e inquilinos
      await _conversasService.criarConversasAutomaticas(
        condominioId: condominioId,
      );
      
      print('✅ Condomínio $condominioId inicializado com sucesso');
    } catch (e) {
      print('❌ Erro ao inicializar condomínio: $e');
      rethrow;
    }
  }

  /// Inicializa apenas as conversas (útil para sincronização)
  Future<int> inicializarConversas(String condominioId) async {
    try {
      final conversas = await _conversasService.criarConversasAutomaticas(
        condominioId: condominioId,
      );
      
      print('✅ ${conversas.length} conversas criadas/verificadas');
      return conversas.length;
    } catch (e) {
      print('❌ Erro ao inicializar conversas: $e');
      rethrow;
    }
  }
}
