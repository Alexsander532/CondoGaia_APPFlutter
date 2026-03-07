import '../entities/boleto_prop_entity.dart';

/// Contrato abstrato do repositório de Boletos do Proprietário/Inquilino
abstract class BoletoPropRepository {
  /// Retorna lista de boletos do morador logado
  Future<List<BoletoPropEntity>> obterBoletos({
    required String moradorId,
    String? filtroStatus, // 'Vencido/A Vencer', 'Pago'
  });

  /// Retorna detalhes de um boleto específico
  Future<BoletoPropEntity?> obterBoletoPorId(String boletoId);

  /// Retorna composição detalhada do boleto
  Future<Map<String, double>> obterComposicaoBoleto(String boletoId);

  /// Retorna demonstrativo financeiro do mês/ano
  Future<Map<String, dynamic>> obterDemonstrativoFinanceiro({
    required String moradorId,
    required int mes,
    required int ano,
  });
}
