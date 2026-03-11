/// DataSource é responsável APENAS por buscar dados
/// Pode ser Supabase, API REST, SQLite, etc
/// Não conhece Repository ou Entities

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/reserva_model.dart';
import '../models/ambiente_model.dart';

abstract class ReservaRemoteDataSource {
  /// Busca reservas do condomínio via JOIN com ambientes.condominio_id
  Future<List<ReservaModel>> obterReservas(String condominioId);

  /// Busca ambientes do condomínio específico
  Future<List<AmbienteModel>> obterAmbientes(String condominioId);

  Future<ReservaModel> criarReserva({
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
  });
  Future<void> cancelarReserva(String reservaId);
  Future<ReservaModel> atualizarReserva({
    required String reservaId,
    required String ambienteId,
    required String local,
    required DateTime dataInicio,
    required DateTime dataFim,
    required double valorLocacao,
    String? listaPresentes,
    String? para,
    String? blocoUnidadeId,
  });
}

/// Implementação concreta que chama Supabase
class ReservaRemoteDataSourceImpl implements ReservaRemoteDataSource {
  @override
  Future<ReservaModel> atualizarReserva({
    required String reservaId,
    required String ambienteId,
    required String local,
    required DateTime dataInicio,
    required DateTime dataFim,
    required double valorLocacao,
    String? listaPresentes,
    String? para,
    String? blocoUnidadeId,
  }) async {
    try {
      final client = Supabase.instance.client;

      final data = <String, dynamic>{
        'ambiente_id': ambienteId,
        'local': local,
        'data_reserva': dataInicio.toIso8601String().split('T')[0],
        'hora_inicio':
            '${dataInicio.hour.toString().padLeft(2, '0')}:${dataInicio.minute.toString().padLeft(2, '0')}',
        'hora_fim':
            '${dataFim.hour.toString().padLeft(2, '0')}:${dataFim.minute.toString().padLeft(2, '0')}',
        'valor_locacao': valorLocacao,
      };

      if (listaPresentes != null) {
        data['lista_presentes'] = listaPresentes;
      }
      if (para != null) {
        data['para'] = para;
      }
      if (blocoUnidadeId != null) {
        data['bloco_unidade_id'] = blocoUnidadeId;
      }

      final response = await client
          .from('reservas')
          .update(data)
          .eq('id', reservaId)
          .select(
            '*, inquilinos(nome), representantes(nome_completo), proprietarios(nome)',
          )
          .single();

      return ReservaModel.fromJson(response);
    } catch (e) {
      throw Exception('Erro ao atualizar reserva: $e');
    }
  }

  @override
  Future<List<AmbienteModel>> obterAmbientes(String condominioId) async {
    try {
      final client = Supabase.instance.client;

      // Filtra ambientes pelo condomínio (coluna criada via migration)
      final response = await client
          .from('ambientes')
          .select()
          .eq('condominio_id', condominioId)
          .order('titulo');

      return (response as List)
          .map((json) => AmbienteModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<ReservaModel>> obterReservas(String condominioId) async {
    try {
      final client = Supabase.instance.client;

      // Busca reservas via JOIN com ambientes para filtrar por condomínio
      // ambientes.condominio_id = condominioId
      final response = await client
          .from('reservas')
          .select(
            '*, inquilinos(nome), representantes(nome_completo), proprietarios(nome), ambientes!inner(condominio_id)',
          )
          .eq('ambientes.condominio_id', condominioId)
          .order('data_reserva', ascending: true);

      final reservas = (response as List)
          .map((json) => ReservaModel.fromJson(json as Map<String, dynamic>))
          .toList();
      return reservas;
    } catch (e) {
      return [];
    }
  }

  @override
  Future<ReservaModel> criarReserva({
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
  }) async {
    try {
      final client = Supabase.instance.client;

      final data = <String, dynamic>{
        'ambiente_id': ambienteId,
        'local': local,
        'data_reserva': dataInicio.toIso8601String().split('T')[0],
        'hora_inicio':
            '${dataInicio.hour.toString().padLeft(2, '0')}:${dataInicio.minute.toString().padLeft(2, '0')}',
        'hora_fim':
            '${dataFim.hour.toString().padLeft(2, '0')}:${dataFim.minute.toString().padLeft(2, '0')}',
        'valor_locacao': valorLocacao,
        'termo_locacao': termoLocacao,
        'para': para ?? 'Condomínio',
      };

      if (listaPresentes != null && listaPresentes.isNotEmpty) {
        data['lista_presentes'] = listaPresentes;
      }
      if (representanteId != null) {
        data['representante_id'] = representanteId;
      }
      if (inquilinoId != null) {
        data['inquilino_id'] = inquilinoId;
      }
      if (proprietarioId != null) {
        data['proprietario_id'] = proprietarioId;
      }
      if (blocoUnidadeId != null) {
        data['bloco_unidade_id'] = blocoUnidadeId;
      }

      final response = await client
          .from('reservas')
          .insert(data)
          .select(
            '*, inquilinos(nome), representantes(nome_completo), proprietarios(nome)',
          )
          .single();

      return ReservaModel.fromJson(response);
    } catch (e) {
      throw Exception('Erro ao criar reserva: $e');
    }
  }

  @override
  Future<void> cancelarReserva(String reservaId) async {
    try {
      final client = Supabase.instance.client;
      await client.from('reservas').delete().eq('id', reservaId);
    } catch (e) {
      throw Exception('Erro ao cancelar reserva: $e');
    }
  }
}
