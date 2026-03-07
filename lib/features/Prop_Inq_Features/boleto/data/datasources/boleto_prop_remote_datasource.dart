import '../models/boleto_prop_model.dart';

/// Contrato abstrato do DataSource remoto
abstract class BoletoPropRemoteDataSource {
  Future<List<BoletoPropModel>> obterBoletos({
    required String moradorId,
    String? filtroStatus,
  });

  Future<BoletoPropModel?> obterBoletoPorId(String boletoId);

  Future<Map<String, double>> obterComposicaoBoleto(String boletoId);

  Future<Map<String, dynamic>> obterDemonstrativoFinanceiro({
    required String moradorId,
    required int mes,
    required int ano,
  });
}

/// Implementação stub do DataSource remoto (Supabase)
/// TODO: Implementar chamadas reais ao Supabase
class BoletoPropRemoteDataSourceImpl implements BoletoPropRemoteDataSource {
  @override
  Future<List<BoletoPropModel>> obterBoletos({
    required String moradorId,
    String? filtroStatus,
  }) async {
    // TODO: Implementar query Supabase
    return [];
  }

  @override
  Future<BoletoPropModel?> obterBoletoPorId(String boletoId) async {
    // TODO: Implementar query Supabase
    return null;
  }

  @override
  Future<Map<String, double>> obterComposicaoBoleto(String boletoId) async {
    // TODO: Implementar query Supabase
    return {};
  }

  @override
  Future<Map<String, dynamic>> obterDemonstrativoFinanceiro({
    required String moradorId,
    required int mes,
    required int ano,
  }) async {
    // TODO: Implementar query Supabase
    return {};
  }
}
