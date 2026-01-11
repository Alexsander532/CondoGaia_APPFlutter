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
      // Trazendo também o nome do inquilino ou representante
      final response = await client
          .from('reservas')
          .select('*, inquilinos(nome), representantes(nome_completo)')
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
    String? representanteId,
    String? inquilinoId,
    required String local,
    required DateTime dataInicio,
    required DateTime dataFim,
    required double valorLocacao,
    required bool termoLocacao,
  }) async {
    try {
      final client = Supabase.instance.client;

      final data = {
        'ambiente_id': ambienteId,
        'local': local,
        'data_reserva': dataInicio.toIso8601String().split('T')[0],
        'hora_inicio': '${dataInicio.hour.toString().padLeft(2, '0')}:${dataInicio.minute.toString().padLeft(2, '0')}',
        'hora_fim': '${dataFim.hour.toString().padLeft(2, '0')}:${dataFim.minute.toString().padLeft(2, '0')}',
        'valor_locacao': valorLocacao,
        'termo_locacao': termoLocacao,
        'para': 'Condomínio', // Default
      };

      if (representanteId != null) {
        data['representante_id'] = representanteId;
      }
      if (inquilinoId != null) {
        data['inquilino_id'] = inquilinoId;
      }

      final response = await client
          .from('reservas')
          .insert(data)
          .select('*, inquilinos(nome), representantes(nome_completo)')
          .single();

      return ReservaModel.fromJson(response);
    } catch (e) {
      print('❌ Erro ao criar reserva: $e');
      throw Exception('Erro ao criar reserva: $e');
    }
  }

  @override
  Future<void> cancelarReserva(String reservaId) async {
    // TODO: Chamar Supabase para cancelar
    await Future.delayed(const Duration(seconds: 1));
  }
}
