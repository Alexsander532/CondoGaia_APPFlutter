/// DataSource é responsável APENAS por buscar dados
/// Pode ser Supabase, API REST, SQLite, etc
/// Não conhece Repository ou Entities

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/reserva_model.dart';
import '../models/ambiente_model.dart';

abstract class ReservaRemoteDataSource {
  Future<List<ReservaModel>> obterReservas(String condominioId);
  Future<List<AmbienteModel>> obterAmbientes();
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
  Future<List<AmbienteModel>> obterAmbientes() async {
    try {
      final client = Supabase.instance.client;
      
      final response = await client
          .from('ambientes')
          .select()
          .order('titulo');

      return (response as List)
          .map((json) => AmbienteModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('❌ Erro ao buscar ambientes: $e');
      return [];
    }
  }

  @override
  Future<List<ReservaModel>> obterReservas(String condominioId) async {
    try {
      final client = Supabase.instance.client;
      
      // Buscar reservas ordenadas por data mais próxima
      final response = await client
          .from('reservas')
          .select()
          .order('data_reserva', ascending: true);

      final reservas = (response as List)
          .map((json) => ReservaModel.fromJson(json as Map<String, dynamic>))
          .toList();
      return reservas;
    } catch (e) {
      print('❌ Erro ao buscar reservas: $e');
      return [];
    }
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
    // Por enquanto, retorna um modelo mockado
    await Future.delayed(const Duration(seconds: 1));
    return ReservaModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      ambienteId: ambienteId,
      representanteId: usuarioId,
      dataReserva: dataInicio,
      horaInicio: '${dataInicio.hour.toString().padLeft(2, '0')}:${dataInicio.minute.toString().padLeft(2, '0')}',
      horaFim: '${dataFim.hour.toString().padLeft(2, '0')}:${dataFim.minute.toString().padLeft(2, '0')}',
      local: descricao,
      valorLocacao: 0.0,
      termoLocacao: false,
      para: 'Condomínio',
      dataCriacao: DateTime.now(),
      dataAtualizacao: DateTime.now(),
    );
  }

  @override
  Future<void> cancelarReserva(String reservaId) async {
    // TODO: Chamar Supabase para cancelar
    await Future.delayed(const Duration(seconds: 1));
  }
}
