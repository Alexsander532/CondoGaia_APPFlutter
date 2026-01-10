/// Repository é um contrato (interface) que define operações
/// Não importa se é Supabase, Firebase, API REST, SQLite
import '../../domain/entities/reserva_entity.dart';
import '../../domain/entities/ambiente_entity.dart';

abstract class ReservaRepository {
  Future<List<ReservaEntity>> obterReservas(String condominioId);
  Future<List<AmbienteEntity>> obterAmbientes();
  Future<ReservaEntity> criarReserva({
    required String condominioId,
    required String ambienteId,
    required String usuarioId,
    required String descricao,
    required DateTime dataInicio,
    required DateTime dataFim,
  });
  Future<void> cancelarReserva(String reservaId);
}
