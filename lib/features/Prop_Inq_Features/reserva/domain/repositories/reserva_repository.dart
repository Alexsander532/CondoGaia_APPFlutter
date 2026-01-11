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
    String? representanteId,
    String? inquilinoId,
    required String local,
    required DateTime dataInicio,
    required DateTime dataFim,
    required double valorLocacao,
    required bool termoLocacao,
  });
  Future<void> cancelarReserva(String reservaId);
}
