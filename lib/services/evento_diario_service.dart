import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/evento_diario.dart';
import 'dart:io';
import 'dart:typed_data';

class EventoDiarioService {
  static SupabaseClient get _client => Supabase.instance.client;

  /// Cria um novo evento de diário
  static Future<EventoDiario?> criarEvento({
    required String representanteId,
    required String condominioId,
    required String titulo,
    String? descricao,
    required DateTime dataEvento,
  }) async {
    try {
      final eventoData = {
        'representante_id': representanteId,
        'condominio_id': condominioId,
        'titulo': titulo,
        'descricao': descricao,
        'data_evento': dataEvento.toIso8601String().split('T')[0],
        'status': 'ativo',
      };

      final response = await _client
          .from('eventos_diario_representante')
          .insert(eventoData)
          .select()
          .single();

      return EventoDiario.fromJson(response);
    } catch (e) {
      print('Erro ao criar evento de diário: $e');
      rethrow;
    }
  }

  /// Busca eventos de diário por representante
  static Future<List<EventoDiario>> buscarEventosPorRepresentante(String representanteId) async {
    try {
      final response = await _client
          .from('eventos_diario_representante')
          .select()
          .eq('representante_id', representanteId)
          .eq('status', 'ativo')
          .order('data_evento', ascending: false)
          .order('criado_em', ascending: false);

      return response.map<EventoDiario>((json) => EventoDiario.fromJson(json)).toList();
    } catch (e) {
      print('Erro ao buscar eventos por representante: $e');
      rethrow;
    }
  }

  /// Busca eventos de diário por condomínio
  static Future<List<EventoDiario>> buscarEventosPorCondominio(String condominioId) async {
    try {
      print('🔵 EventoDiarioService.buscarEventosPorCondominio - Buscando eventos para condominio: $condominioId');
      final response = await _client
          .from('eventos_diario_representante')
          .select()
          .eq('condominio_id', condominioId)
          .eq('status', 'ativo')
          .order('data_evento', ascending: false)
          .order('criado_em', ascending: false);

      print('🔵 EventoDiarioService - Response: $response');
      print('✅ EventoDiarioService - Eventos encontrados: ${response.length}');
      return response.map<EventoDiario>((json) => EventoDiario.fromJson(json)).toList();
    } catch (e) {
      print('❌ Erro ao buscar eventos por condomínio: $e');
      rethrow;
    }
  }

  /// Busca eventos de diário por data específica
  static Future<List<EventoDiario>> buscarEventosPorData({
    required String representanteId,
    required DateTime data,
  }) async {
    try {
      final dataFormatada = data.toIso8601String().split('T')[0];
      
      final response = await _client
          .from('eventos_diario_representante')
          .select()
          .eq('representante_id', representanteId)
          .eq('data_evento', dataFormatada)
          .eq('status', 'ativo')
          .order('criado_em', ascending: false);

      return response.map<EventoDiario>((json) => EventoDiario.fromJson(json)).toList();
    } catch (e) {
      print('Erro ao buscar eventos por data: $e');
      rethrow;
    }
  }

  /// Busca eventos de diário em um período
  static Future<List<EventoDiario>> buscarEventosPorPeriodo({
    required String representanteId,
    required DateTime dataInicio,
    required DateTime dataFim,
  }) async {
    try {
      final dataInicioFormatada = dataInicio.toIso8601String().split('T')[0];
      final dataFimFormatada = dataFim.toIso8601String().split('T')[0];
      
      final response = await _client
          .from('eventos_diario_representante')
          .select()
          .eq('representante_id', representanteId)
          .gte('data_evento', dataInicioFormatada)
          .lte('data_evento', dataFimFormatada)
          .eq('status', 'ativo')
          .order('data_evento', ascending: false)
          .order('criado_em', ascending: false);

      return response.map<EventoDiario>((json) => EventoDiario.fromJson(json)).toList();
    } catch (e) {
      print('Erro ao buscar eventos por período: $e');
      rethrow;
    }
  }

  /// Atualiza um evento de diário
  static Future<EventoDiario?> atualizarEvento({
    required String eventoId,
    String? titulo,
    String? descricao,
    DateTime? dataEvento,
    String? status,
    String? fotoUrl,
  }) async {
    try {
      final updateData = <String, dynamic>{};
      
      if (titulo != null) updateData['titulo'] = titulo;
      if (descricao != null) updateData['descricao'] = descricao;
      if (dataEvento != null) updateData['data_evento'] = dataEvento.toIso8601String().split('T')[0];
      if (status != null) updateData['status'] = status;
      if (fotoUrl != null) updateData['foto_url'] = fotoUrl;

      if (updateData.isEmpty) {
        throw Exception('Nenhum campo para atualizar foi fornecido');
      }

      final response = await _client
          .from('eventos_diario_representante')
          .update(updateData)
          .eq('id', eventoId)
          .select()
          .single();

      return EventoDiario.fromJson(response);
    } catch (e) {
      print('Erro ao atualizar evento: $e');
      rethrow;
    }
  }

  /// Cancela um evento (soft delete)
  static Future<bool> cancelarEvento(String eventoId) async {
    try {
      await _client
          .from('eventos_diario_representante')
          .update({'status': 'cancelado'})
          .eq('id', eventoId);

      return true;
    } catch (e) {
      print('Erro ao cancelar evento: $e');
      return false;
    }
  }

  /// Marca um evento como concluído
  static Future<bool> concluirEvento(String eventoId) async {
    try {
      await _client
          .from('eventos_diario_representante')
          .update({'status': 'concluido'})
          .eq('id', eventoId);

      return true;
    } catch (e) {
      print('Erro ao concluir evento: $e');
      return false;
    }
  }

  /// Deleta permanentemente um evento
  static Future<bool> deletarEvento(String eventoId) async {
    try {
      await _client
          .from('eventos_diario_representante')
          .delete()
          .eq('id', eventoId);

      return true;
    } catch (e) {
      print('Erro ao deletar evento: $e');
      return false;
    }
  }

  /// Busca um evento específico por ID
  static Future<EventoDiario?> buscarEventoPorId(String eventoId) async {
    try {
      final response = await _client
          .from('eventos_diario_representante')
          .select()
          .eq('id', eventoId)
          .single();

      return EventoDiario.fromJson(response);
    } catch (e) {
      print('Erro ao buscar evento por ID: $e');
      return null;
    }
  }

  /// Busca eventos recentes do diário (últimos 30 dias)
  static Future<List<EventoDiario>> buscarEventosRecentes({
    required String representanteId,
    int diasAtras = 30,
  }) async {
    try {
      final dataLimite = DateTime.now().subtract(Duration(days: diasAtras));
      final dataLimiteFormatada = dataLimite.toIso8601String().split('T')[0];
      
      final response = await _client
          .from('eventos_diario_representante')
          .select()
          .eq('representante_id', representanteId)
          .gte('data_evento', dataLimiteFormatada)
          .eq('status', 'ativo')
          .order('data_evento', ascending: false)
          .order('criado_em', ascending: false);

      return response.map<EventoDiario>((json) => EventoDiario.fromJson(json)).toList();
    } catch (e) {
      print('Erro ao buscar eventos recentes: $e');
      rethrow;
    }
  }

  /// Conta total de eventos por representante
  static Future<int> contarEventosPorRepresentante(String representanteId) async {
    try {
      final response = await _client
          .from('eventos_diario_representante')
          .select('*')
          .eq('representante_id', representanteId)
          .eq('status', 'ativo');

      return response.length;
    } catch (e) {
      print('Erro ao contar eventos: $e');
      return 0;
    }
  }

  /// Busca eventos por termo de pesquisa (título ou descrição)
  static Future<List<EventoDiario>> buscarEventosPorTermo({
    required String representanteId,
    required String termo,
  }) async {
    try {
      final response = await _client
          .from('eventos_diario_representante')
          .select()
          .eq('representante_id', representanteId)
          .eq('status', 'ativo')
          .or('titulo.ilike.%$termo%,descricao.ilike.%$termo%')
          .order('data_evento', ascending: false)
          .order('criado_em', ascending: false);

      return response.map<EventoDiario>((json) => EventoDiario.fromJson(json)).toList();
    } catch (e) {
      print('Erro ao buscar eventos por termo: $e');
      rethrow;
    }
  }

  /// Faz upload da foto do evento diário para Supabase Storage
  /// Bucket: imagens_diario_representante
  /// Path: /condominio_id/evento_id/nomeArquivo
  static Future<String?> uploadFotoEventoDiario({
    required String condominioId,
    required String eventoId,
    required File arquivo,
    required String nomeArquivo,
  }) async {
    try {
      print('🔵 [EventoDiarioService] Iniciando upload da foto do evento diário...');
      
      final path = '$condominioId/$eventoId/$nomeArquivo';
      
      // Converter para Uint8List para fazer upload
      final bytes = Uint8List.fromList(await arquivo.readAsBytes());
      
      await _client.storage.from('imagens_diario_representante').uploadBinary(
            path,
            bytes,
          );

      // Obter URL pública
      final publicUrl = _client.storage
          .from('imagens_diario_representante')
          .getPublicUrl(path);

      print('✅ [EventoDiarioService] Upload realizado com sucesso: $publicUrl');
      return publicUrl;
    } catch (e) {
      print('❌ [EventoDiarioService] Erro ao fazer upload da foto: $e');
      return null;
    }
  }
}