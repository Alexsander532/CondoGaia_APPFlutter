/// Repository é a implementação concreta do contrato
/// Fica entre DataSource e Domain, fazendo tratamento de erros e conversões
import '../datasources/reserva_remote_datasource.dart';
import '../../domain/repositories/reserva_repository.dart';
import '../../domain/entities/reserva_entity.dart';
import '../../domain/entities/ambiente_entity.dart';

class ReservaRepositoryImpl implements ReservaRepository {
  final ReservaRemoteDataSource remoteDataSource;

  ReservaRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<ReservaEntity>> obterReservas(String condominioId) async {
    try {
      // Chama DataSource e converte para Entity
      final models = await remoteDataSource.obterReservas(condominioId);
      return models.map((model) => model as ReservaEntity).toList();
    } catch (e) {
      throw Exception('Erro ao obter reservas: $e');
    }
  }

  @override
  Future<List<AmbienteEntity>> obterAmbientes() async {
    try {
      // Chama DataSource e converte para Entity
      final models = await remoteDataSource.obterAmbientes();
      return models.map((model) => model as AmbienteEntity).toList();
    } catch (e) {
      throw Exception('Erro ao obter ambientes: $e');
    }
  }

  @override
  Future<ReservaEntity> criarReserva({
    required String condominioId,
    required String ambienteId,
    required String usuarioId,
    required String descricao,
    required DateTime dataInicio,
    required DateTime dataFim,
  }) async {
    try {
      final model = await remoteDataSource.criarReserva(
        condominioId: condominioId,
        ambienteId: ambienteId,
        usuarioId: usuarioId,
        descricao: descricao,
        dataInicio: dataInicio,
        dataFim: dataFim,
      );
      return model as ReservaEntity;
    } catch (e) {
      throw Exception('Erro ao criar reserva: $e');
    }
  }

  @override
  Future<void> cancelarReserva(String reservaId) async {
    try {
      await remoteDataSource.cancelarReserva(reservaId);
    } catch (e) {
      throw Exception('Erro ao cancelar reserva: $e');
    }
  }
}
