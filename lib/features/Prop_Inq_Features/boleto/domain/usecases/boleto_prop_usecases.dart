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

/// Caso de uso: Obter leituras da unidade
class ObterLeiturasUseCase {
  final BoletoPropRepository repository;

  ObterLeiturasUseCase({required this.repository});

  Future<List<Map<String, dynamic>>> call({
    required String unidadeId,
    required int mes,
    required int ano,
  }) {
    return repository.obterLeituras(
      unidadeId: unidadeId,
      mes: mes,
      ano: ano,
    );
  }
}

/// Caso de uso: Obter balancete online
class ObterBalanceteOnlineUseCase {
  final BoletoPropRepository repository;

  ObterBalanceteOnlineUseCase({required this.repository});

  Future<Map<String, dynamic>> call({
    required String condominioId,
    required int mes,
    required int ano,
  }) {
    return repository.obterBalanceteOnline(
      condominioId: condominioId,
      mes: mes,
      ano: ano,
    );
  }
}

/// Caso de uso: Sincronizar boleto com gateway
class SincronizarBoletoUseCase {
  final BoletoPropRepository repository;

  SincronizarBoletoUseCase({required this.repository});

  Future<String> call(String boletoId) {
    return repository.sincronizarBoleto(boletoId);
  }
}
