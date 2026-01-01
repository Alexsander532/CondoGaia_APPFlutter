/// Use Cases são casos de uso específicos do domínio
/// Cada UseCase é reutilizável e testável
/// É a camada de LÓGICA DE NEGÓCIO

import '../../domain/repositories/reserva_repository.dart';
import '../../domain/entities/reserva_entity.dart';

// Caso de uso: Obter Reservas
class ObterReservasUseCase {
  final ReservaRepository repository;

  ObterReservasUseCase({required this.repository});

  Future<List<ReservaEntity>> call(String condominioId) {
    return repository.obterReservas(condominioId);
  }
}

// Caso de uso: Criar Reserva
class CriarReservaUseCase {
  final ReservaRepository repository;

  CriarReservaUseCase({required this.repository});

  Future<ReservaEntity> call({
    required String condominioId,
    required String ambienteId,
    required String usuarioId,
    required String descricao,
    required DateTime dataInicio,
    required DateTime dataFim,
  }) {
    return repository.criarReserva(
      condominioId: condominioId,
      ambienteId: ambienteId,
      usuarioId: usuarioId,
      descricao: descricao,
      dataInicio: dataInicio,
      dataFim: dataFim,
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
    
    for (final reserva in reservas) {
      if (reserva.ambienteId == ambienteId &&
          reserva.status != 'cancelled') {
        // Verificar sobreposição
        if ((dataInicio.isBefore(reserva.dataFim) &&
            dataFim.isAfter(reserva.dataInicio))) {
          return false;
        }
      }
    }
    return true;
  }
}
