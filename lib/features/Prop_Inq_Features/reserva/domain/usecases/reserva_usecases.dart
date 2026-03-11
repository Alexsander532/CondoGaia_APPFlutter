/// Use Cases são casos de uso específicos do domínio
/// Cada UseCase é reutilizável e testável
/// É a camada de LÓGICA DE NEGÓCIO

import '../../domain/repositories/reserva_repository.dart';
import '../../domain/entities/reserva_entity.dart';
import '../../domain/entities/ambiente_entity.dart';

// Caso de uso: Obter Reservas do condomínio (via JOIN com ambientes)
class ObterReservasUseCase {
  final ReservaRepository repository;

  ObterReservasUseCase({required this.repository});

  Future<List<ReservaEntity>> call(String condominioId) {
    return repository.obterReservas(condominioId);
  }
}

// Caso de uso: Obter Ambientes do condomínio
class ObterAmbientesUseCase {
  final ReservaRepository repository;

  ObterAmbientesUseCase({required this.repository});

  Future<List<AmbienteEntity>> call(String condominioId) {
    return repository.obterAmbientes(condominioId);
  }
}

// Caso de uso: Criar Reserva
class CriarReservaUseCase {
  final ReservaRepository repository;

  CriarReservaUseCase({required this.repository});

  Future<ReservaEntity> call({
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
    String? para,
    String? blocoUnidadeId,
  }) {
    return repository.criarReserva(
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
      para: para,
      blocoUnidadeId: blocoUnidadeId,
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
    String? para,
    String? blocoUnidadeId,
  }) {
    return repository.atualizarReserva(
      reservaId: reservaId,
      ambienteId: ambienteId,
      local: local,
      dataInicio: dataInicio,
      dataFim: dataFim,
      valorLocacao: valorLocacao,
      listaPresentes: listaPresentes,
      para: para,
      blocoUnidadeId: blocoUnidadeId,
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
// Verifica se o ambiente já possui reserva na data via query direta no servidor
class ValidarDisponibilidadeUseCase {
  final ReservaRepository repository;

  ValidarDisponibilidadeUseCase({required this.repository});

  Future<bool> call({
    required String condominioId,
    required String ambienteId,
    required DateTime dataInicio,
    required DateTime dataFim,
    String?
    reservaIdExcluir, // Para edição: excluir a própria reserva da validação
  }) async {
    return await repository.verificarDisponibilidade(
      ambienteId: ambienteId,
      data: dataInicio,
      reservaIdExcluir: reservaIdExcluir,
    );
  }
}
