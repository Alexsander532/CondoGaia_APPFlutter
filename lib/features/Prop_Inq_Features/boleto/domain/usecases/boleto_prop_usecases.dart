import '../entities/boleto_prop_entity.dart';
import '../repositories/boleto_prop_repository.dart';

/// Caso de uso: Obter todos os boletos do proprietário/inquilino
class ObterBoletosPropUseCase {
  final BoletoPropRepository repository;

  ObterBoletosPropUseCase({required this.repository});

  Future<List<BoletoPropEntity>> call({
    required String moradorId,
    String? filtroStatus,
  }) {
    return repository.obterBoletos(
      moradorId: moradorId,
      filtroStatus: filtroStatus,
    );
  }
}

/// Caso de uso: Obter composição do boleto
class ObterComposicaoBoletoUseCase {
  final BoletoPropRepository repository;

  ObterComposicaoBoletoUseCase({required this.repository});

  Future<Map<String, double>> call(String boletoId) {
    return repository.obterComposicaoBoleto(boletoId);
  }
}

/// Caso de uso: Obter demonstrativo financeiro
class ObterDemonstrativoFinanceiroUseCase {
  final BoletoPropRepository repository;

  ObterDemonstrativoFinanceiroUseCase({required this.repository});

  Future<Map<String, dynamic>> call({
    required String moradorId,
    required int mes,
    required int ano,
  }) {
    return repository.obterDemonstrativoFinanceiro(
      moradorId: moradorId,
      mes: mes,
      ano: ano,
    );
  }
}
