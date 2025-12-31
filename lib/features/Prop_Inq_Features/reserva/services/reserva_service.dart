import '../models/reserva_model.dart';
import '../models/ambiente_model.dart';

class ReservaService {
  /// Obtém todas as reservas de um condomínio
  Future<List<ReservaModel>> obterReservas(String condominioId) async {
    // TODO: Integrar com Supabase
    // Dados mockados para exemplo
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      ReservaModel(
        id: '1',
        condominioId: condominioId,
        ambienteId: '1',
        usuarioId: '1',
        descricao: 'Reunião de síndicos',
        dataInicio: DateTime.now().add(const Duration(days: 1)),
        dataFim: DateTime.now().add(const Duration(days: 1, hours: 2)),
        dataCriacao: DateTime.now(),
      ),
      ReservaModel(
        id: '2',
        condominioId: condominioId,
        ambienteId: '2',
        usuarioId: '2',
        descricao: 'Aula de pilates',
        dataInicio: DateTime.now().add(const Duration(days: 2)),
        dataFim: DateTime.now().add(const Duration(days: 2, hours: 1)),
        dataCriacao: DateTime.now(),
      ),
    ];
  }

  /// Obtém todos os ambientes de um condomínio
  Future<List<AmbienteModel>> obterAmbientes(String condominioId) async {
    // TODO: Integrar com Supabase
    // Dados mockados para exemplo
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      AmbienteModel(
        id: '1',
        condominioId: condominioId,
        nome: 'Salão de festas',
        descricao: 'Salão com capacidade para 100 pessoas',
        tipo: 'salao',
        capacidadeMaxima: 100,
        dataCriacao: DateTime.now(),
      ),
      AmbienteModel(
        id: '2',
        condominioId: condominioId,
        nome: 'Quadra de esportes',
        descricao: 'Quadra coberta para vários esportes',
        tipo: 'quadra',
        capacidadeMaxima: 50,
        dataCriacao: DateTime.now(),
      ),
      AmbienteModel(
        id: '3',
        condominioId: condominioId,
        nome: 'Piscina',
        descricao: 'Piscina aquecida',
        tipo: 'piscina',
        capacidadeMaxima: 150,
        dataCriacao: DateTime.now(),
      ),
    ];
  }

  /// Cria uma nova reserva
  Future<ReservaModel> criarReserva({
    required String condominioId,
    required String ambienteId,
    required String usuarioId,
    required String descricao,
    required DateTime dataInicio,
    required DateTime dataFim,
  }) async {
    // TODO: Integrar com Supabase
    await Future.delayed(const Duration(seconds: 1));

    return ReservaModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      condominioId: condominioId,
      ambienteId: ambienteId,
      usuarioId: usuarioId,
      descricao: descricao,
      dataInicio: dataInicio,
      dataFim: dataFim,
      status: 'pending',
      dataCriacao: DateTime.now(),
    );
  }

  /// Cancela uma reserva
  Future<void> cancelarReserva(String reservaId) async {
    // TODO: Integrar com Supabase
    await Future.delayed(const Duration(seconds: 1));
    // Simular cancelamento
  }

  /// Valida se há conflito de datas
  bool validarDisponibilidade({
    required String ambienteId,
    required DateTime dataInicio,
    required DateTime dataFim,
    required List<ReservaModel> reservasExistentes,
  }) {
    for (final reserva in reservasExistentes) {
      if (reserva.ambienteId == ambienteId &&
          reserva.status != 'cancelled') {
        // Verificar sobreposição de datas
        if ((dataInicio.isBefore(reserva.dataFim) &&
            dataFim.isAfter(reserva.dataInicio))) {
          return false;
        }
      }
    }
    return true;
  }
}
