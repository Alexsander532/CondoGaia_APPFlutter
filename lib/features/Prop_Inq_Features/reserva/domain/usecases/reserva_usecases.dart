/// Use Cases são casos de uso específicos do domínio
/// Cada UseCase é reutilizável e testável
/// É a camada de LÓGICA DE NEGÓCIO

import '../../domain/repositories/reserva_repository.dart';
import '../../domain/entities/reserva_entity.dart';
import '../../domain/entities/ambiente_entity.dart';

// Caso de uso: Obter Reservas
class ObterReservasUseCase {
  final ReservaRepository repository;

  ObterReservasUseCase({required this.repository});

  Future<List<ReservaEntity>> call(String condominioId) {
    return repository.obterReservas(condominioId);
  }
}

// Caso de uso: Obter Ambientes
class ObterAmbientesUseCase {
  final ReservaRepository repository;

  ObterAmbientesUseCase({required this.repository});

  Future<List<AmbienteEntity>> call() {
    return repository.obterAmbientes();
  }
}

// Caso de uso: Criar Reserva
class CriarReservaUseCase {
  final ReservaRepository repository;

  CriarReservaUseCase({required this.repository});

  Future<ReservaEntity> call({
    required String condominioId,
    required String ambienteId,
    String? representanteId,
    String? inquilinoId,
    String? proprietarioId,
    required String local,
    required DateTime dataInicio,
    required DateTime dataFim,
    required double valorLocacao,
    required bool termoLocacao,
    String? listaPresentes,
  }) {
    return repository.criarReserva(
      condominioId: condominioId,
      ambienteId: ambienteId,
      representanteId: representanteId,
      inquilinoId: inquilinoId,
      proprietarioId: proprietarioId,
      local: local,
      dataInicio: dataInicio,
      dataFim: dataFim,
      valorLocacao: valorLocacao,
      termoLocacao: termoLocacao,
      listaPresentes: listaPresentes,
    );
  }
}

// Caso de uso: Atualizar Reserva
class AtualizarReservaUseCase {
  final ReservaRepository repository;

  AtualizarReservaUseCase({required this.repository});

  Future<ReservaEntity> call({
    required String reservaId,
    required String ambienteId,
    required String local,
    required DateTime dataInicio,
    required DateTime dataFim,
    required double valorLocacao,
    String? listaPresentes,
  }) {
    return repository.atualizarReserva(
      reservaId: reservaId,
      ambienteId: ambienteId,
      local: local,
      dataInicio: dataInicio,
      dataFim: dataFim,
      valorLocacao: valorLocacao,
      listaPresentes: listaPresentes,
    );
  }
}

// Caso de uso: Cancelar Reserva
class CancelarReservaUseCase {
  final ReservaRepository repository;

  CancelarReservaUseCase({required this.repository});

  Future<void> call(String reservaId) {
    return repository.cancelarReserva(reservaId);
  }
}

// Caso de uso: Validar Disponibilidade
class ValidarDisponibilidadeUseCase {
  final ReservaRepository repository;

  ValidarDisponibilidadeUseCase({required this.repository});

  Future<bool> call({
    required String condominioId,
    required String ambienteId,
    required DateTime dataInicio,
    required DateTime dataFim,
  }) async {
    final reservas = await repository.obterReservas(condominioId);

    // Converter DateTime em data para comparação com dataReserva
    final dataInicioDate = DateTime(
      dataInicio.year,
      dataInicio.month,
      dataInicio.day,
    );
    final dataFimDate = DateTime(dataFim.year, dataFim.month, dataFim.day);

    for (final reserva in reservas) {
      if (reserva.ambienteId == ambienteId) {
        // Verificar se há sobreposição de datas
        if (reserva.dataReserva.isBefore(dataFimDate) &&
                reserva.dataReserva.isAfter(dataInicioDate) ||
            reserva.dataReserva.isAtSameMomentAs(dataInicioDate) ||
            reserva.dataReserva.isAtSameMomentAs(dataFimDate)) {
          return false;
        }
      }
    }
    return true;
  }
}
