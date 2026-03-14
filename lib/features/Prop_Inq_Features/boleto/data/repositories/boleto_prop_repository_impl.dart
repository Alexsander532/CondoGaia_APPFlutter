import '../../domain/entities/boleto_prop_entity.dart';
import '../../domain/repositories/boleto_prop_repository.dart';
import '../datasources/boleto_prop_remote_datasource.dart';

/// Implementação concreta do repositório
/// Conecta o Domain Layer ao Data Layer
class BoletoPropRepositoryImpl implements BoletoPropRepository {
  final BoletoPropRemoteDataSource remoteDataSource;

  BoletoPropRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<BoletoPropEntity>> obterBoletos({
    required String moradorId,
    String? filtroStatus,
  }) async {
    try {
      final models = await remoteDataSource.obterBoletos(
        moradorId: moradorId,
        filtroStatus: filtroStatus,
      );
      return models;
    } catch (e) {
      print('⚠️ [BoletoPropRepository] Erro ao obter boletos: $e');
      return [];
    }
  }

  @override
  Future<BoletoPropEntity?> obterBoletoPorId(String boletoId) async {
    try {
      return await remoteDataSource.obterBoletoPorId(boletoId);
    } catch (e) {
      print('⚠️ [BoletoPropRepository] Erro ao obter boleto: $e');
      return null;
    }
  }

  @override
  Future<Map<String, double>> obterComposicaoBoleto(String boletoId) async {
    try {
      return await remoteDataSource.obterComposicaoBoleto(boletoId);
    } catch (e) {
      print('⚠️ [BoletoPropRepository] Erro ao obter composição: $e');
      return {};
    }
  }

  @override
  Future<Map<String, dynamic>> obterDemonstrativoFinanceiro({
    required String moradorId,
    required int mes,
    required int ano,
  }) async {
    try {
      return await remoteDataSource.obterDemonstrativoFinanceiro(
        moradorId: moradorId,
        mes: mes,
        ano: ano,
      );
    } catch (e) {
      print('⚠️ [BoletoPropRepository] Erro ao obter demonstrativo: $e');
      return {};
    }
  }

  @override
  Future<List<Map<String, dynamic>>> obterLeituras({
    required String unidadeId,
    required int mes,
    required int ano,
  }) async {
    try {
      return await remoteDataSource.obterLeituras(
        unidadeId: unidadeId,
        mes: mes,
        ano: ano,
      );
    } catch (e) {
      print('⚠️ [BoletoPropRepository] Erro ao obter leituras: $e');
      return [];
    }
  }

  @override
  Future<Map<String, dynamic>> obterBalanceteOnline({
    required String condominioId,
    required int mes,
    required int ano,
  }) async {
    try {
      return await remoteDataSource.obterBalanceteOnline(
        condominioId: condominioId,
        mes: mes,
        ano: ano,
      );
    } catch (e) {
      print('⚠️ [BoletoPropRepository] Erro ao obter balancete: $e');
      return {};
    }
  }
}
