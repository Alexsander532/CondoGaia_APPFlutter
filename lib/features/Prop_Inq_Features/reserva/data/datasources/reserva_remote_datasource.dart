/// DataSource é responsável APENAS por buscar dados
/// Pode ser Supabase, API REST, SQLite, etc
/// Não conhece Repository ou Entities

import '../models/reserva_model.dart';

abstract class ReservaRemoteDataSource {
  Future<List<ReservaModel>> obterReservas(String condominioId);
  Future<ReservaModel> criarReserva({
    required String condominioId,
    required String ambienteId,
    required String usuarioId,
    required String descricao,
    required DateTime dataInicio,
    required DateTime dataFim,
  });
  Future<void> cancelarReserva(String reservaId);
}

/// Implementação concreta que chama Supabase
class ReservaRemoteDataSourceImpl implements ReservaRemoteDataSource {
  // TODO: Injetar SupabaseService aqui
  // final SupabaseService _supabaseService;

  @override
  Future<List<ReservaModel>> obterReservas(String condominioId) async {
    // TODO: Chamar Supabase
    // final response = await _supabaseService.client
    //     .from('reservas')
    //     .select()
    //     .eq('condominio_id', condominioId);
    
    // Mockado por enquanto
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
        status: 'confirmed',
        dataCriacao: DateTime.now(),
      ),
    ];
  }

  @override
  Future<ReservaModel> criarReserva({
    required String condominioId,
    required String ambienteId,
    required String usuarioId,
    required String descricao,
    required DateTime dataInicio,
    required DateTime dataFim,
  }) async {
    // TODO: Chamar Supabase para criar
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

  @override
  Future<void> cancelarReserva(String reservaId) async {
    // TODO: Chamar Supabase para cancelar
    await Future.delayed(const Duration(seconds: 1));
  }
}
