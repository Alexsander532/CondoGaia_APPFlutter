import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/evento_agenda.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';

class EventoAgendaService {
  static SupabaseClient get _client => Supabase.instance.client;

  /// Cria um novo evento de agenda
  static Future<EventoAgenda?> criarEvento({
    required String representanteId,
    required String condominioId,
    required String titulo,
    String? descricao,
    required DateTime dataEvento,
    required String horaInicio,
    String? horaFim,
    bool eventoRecorrente = false,
    int? numeroMesesRecorrencia,
    bool avisarCondominiosEmail = false,
    bool avisarRepresentanteEmail = false,
  }) async {
    try {
      print('🔵 [EventoAgendaService] criarEvento chamado - eventoRecorrente: $eventoRecorrente, numeroMeses: $numeroMesesRecorrencia');
      final eventoData = {
        'representante_id': representanteId,
        'condominio_id': condominioId,
        'titulo': titulo,
        'descricao': descricao,
        'data_evento': dataEvento.toIso8601String().split('T')[0],
        'hora_inicio': horaInicio,
        'hora_fim': horaFim,
        'evento_recorrente': eventoRecorrente,
        'numero_meses_recorrencia': numeroMesesRecorrencia,
        'avisar_condominios_email': avisarCondominiosEmail,
        'avisar_representante_email': avisarRepresentanteEmail,
        'status': 'ativo',
      };

      final response = await _client
          .from('eventos_agenda_representante')
          .insert(eventoData)
          .select()
          .single();

      // Se é recorrente, gera eventos nos intervalos especificados
      if (eventoRecorrente && numeroMesesRecorrencia != null && numeroMesesRecorrencia > 0) {
        await _gerarEventosRecorrentes(
          representanteId: representanteId,
          condominioId: condominioId,
          titulo: titulo,
          descricao: descricao,
          dataEventoInicial: dataEvento,
          horaInicio: horaInicio,
          horaFim: horaFim,
          numeroMesesRecorrencia: numeroMesesRecorrencia,
          avisarCondominiosEmail: avisarCondominiosEmail,
          avisarRepresentanteEmail: avisarRepresentanteEmail,
        );
      }

      return EventoAgenda.fromJson(response);
    } catch (e) {
      print('Erro ao criar evento de agenda: $e');
      rethrow;
    }
  }

  /// Gera eventos recorrentes a cada X meses durante 4 anos
  static Future<void> _gerarEventosRecorrentes({
    required String representanteId,
    required String condominioId,
    required String titulo,
    String? descricao,
    required DateTime dataEventoInicial,
    required String horaInicio,
    String? horaFim,
    required int numeroMesesRecorrencia,
    required bool avisarCondominiosEmail,
    required bool avisarRepresentanteEmail,
  }) async {
    try {
      print('🟢 [EventoAgendaService._gerarEventosRecorrentes] Iniciando geração de eventos recorrentes - intervalo: $numeroMesesRecorrencia meses');
      final List<Map<String, dynamic>> eventosRecorrentes = [];
      
      // Calcula até 4 anos (1460 dias aprox) depois da data inicial
      final dataLimite = dataEventoInicial.add(Duration(days: 4 * 365 + 1)); // 4 anos

      // Gera eventos em intervalos de numeroMesesRecorrencia
      int intervaloAtual = numeroMesesRecorrencia;
      
      while (true) {
        // Calcula a próxima data: data inicial + N meses
        DateTime dataSeguinte = DateTime(
          dataEventoInicial.year,
          dataEventoInicial.month + intervaloAtual,
          dataEventoInicial.day,
        );
        
        // Normaliza a data se o mês ultrapassar 12
        while (dataSeguinte.month > 12) {
          dataSeguinte = DateTime(
            dataSeguinte.year + 1,
            dataSeguinte.month - 12,
            dataSeguinte.day,
          );
        }

        if (dataSeguinte.isAfter(dataLimite)) {
          break;
        }

        print('Gerando evento recorrente para: ${dataSeguinte.toIso8601String().split('T')[0]}');
        
        eventosRecorrentes.add({
          'representante_id': representanteId,
          'condominio_id': condominioId,
          'titulo': titulo,
          'descricao': descricao,
          'data_evento': dataSeguinte.toIso8601String().split('T')[0],
          'hora_inicio': horaInicio,
          'hora_fim': horaFim,
          'evento_recorrente': false, // Não marcamos como recorrente os filhos
          'numero_meses_recorrencia': null,
          'avisar_condominios_email': avisarCondominiosEmail,
          'avisar_representante_email': avisarRepresentanteEmail,
          'status': 'ativo',
        });

        // Avança para o próximo intervalo
        intervaloAtual += numeroMesesRecorrencia;
      }

      // Insere todos os eventos recorrentes em uma única operação
      if (eventosRecorrentes.isNotEmpty) {
        await _client
            .from('eventos_agenda_representante')
            .insert(eventosRecorrentes);
        
        print('${eventosRecorrentes.length} eventos recorrentes criados com sucesso!');
      }
    } catch (e) {
      print('Erro ao gerar eventos recorrentes: $e');
      // Não retira erro, apenas registra no log
    }
  }

  /// Busca eventos de agenda por representante
  static Future<List<EventoAgenda>> buscarEventosPorRepresentante(String representanteId) async {
    try {
      final response = await _client
          .from('eventos_agenda_representante')
          .select()
          .eq('representante_id', representanteId)
          .eq('status', 'ativo')
          .order('data_evento', ascending: true)
          .order('hora_inicio', ascending: true);

      return response.map<EventoAgenda>((json) => EventoAgenda.fromJson(json)).toList();
    } catch (e) {
      print('Erro ao buscar eventos por representante: $e');
      rethrow;
    }
  }

  /// Busca eventos de agenda por condomínio
  static Future<List<EventoAgenda>> buscarEventosPorCondominio(String condominioId) async {
    try {
      final response = await _client
          .from('eventos_agenda_representante')
          .select()
          .eq('condominio_id', condominioId)
          .eq('status', 'ativo')
          .order('data_evento', ascending: true)
          .order('hora_inicio', ascending: true);

      return response.map<EventoAgenda>((json) => EventoAgenda.fromJson(json)).toList();
    } catch (e) {
      print('Erro ao buscar eventos por condomínio: $e');
      rethrow;
    }
  }

  /// Busca eventos de agenda por data específica
  static Future<List<EventoAgenda>> buscarEventosPorData({
    required String representanteId,
    required DateTime data,
  }) async {
    try {
      final dataFormatada = data.toIso8601String().split('T')[0];
      
      final response = await _client
          .from('eventos_agenda_representante')
          .select()
          .eq('representante_id', representanteId)
          .eq('data_evento', dataFormatada)
          .eq('status', 'ativo')
          .order('hora_inicio', ascending: true);

      return response.map<EventoAgenda>((json) => EventoAgenda.fromJson(json)).toList();
    } catch (e) {
      print('Erro ao buscar eventos por data: $e');
      rethrow;
    }
  }

  /// Busca eventos de agenda em um período
  static Future<List<EventoAgenda>> buscarEventosPorPeriodo({
    required String representanteId,
    required DateTime dataInicio,
    required DateTime dataFim,
  }) async {
    try {
      final dataInicioFormatada = dataInicio.toIso8601String().split('T')[0];
      final dataFimFormatada = dataFim.toIso8601String().split('T')[0];
      
      final response = await _client
          .from('eventos_agenda_representante')
          .select()
          .eq('representante_id', representanteId)
          .gte('data_evento', dataInicioFormatada)
          .lte('data_evento', dataFimFormatada)
          .eq('status', 'ativo')
          .order('data_evento', ascending: true)
          .order('hora_inicio', ascending: true);

      return response.map<EventoAgenda>((json) => EventoAgenda.fromJson(json)).toList();
    } catch (e) {
      print('Erro ao buscar eventos por período: $e');
      rethrow;
    }
  }

  /// Atualiza um evento de agenda
  static Future<EventoAgenda?> atualizarEvento({
    required String eventoId,
    String? titulo,
    String? descricao,
    DateTime? dataEvento,
    String? horaInicio,
    String? horaFim,
    bool? eventoRecorrente,
    int? numeroMesesRecorrencia,
    bool? avisarCondominiosEmail,
    bool? avisarRepresentanteEmail,
    String? status,
  }) async {
    try {
      final updateData = <String, dynamic>{};
      
      if (titulo != null) updateData['titulo'] = titulo;
      if (descricao != null) updateData['descricao'] = descricao;
      if (dataEvento != null) updateData['data_evento'] = dataEvento.toIso8601String().split('T')[0];
      if (horaInicio != null) updateData['hora_inicio'] = horaInicio;
      if (horaFim != null) updateData['hora_fim'] = horaFim;
      if (eventoRecorrente != null) updateData['evento_recorrente'] = eventoRecorrente;
      if (numeroMesesRecorrencia != null) updateData['numero_meses_recorrencia'] = numeroMesesRecorrencia;
      if (avisarCondominiosEmail != null) updateData['avisar_condominios_email'] = avisarCondominiosEmail;
      if (avisarRepresentanteEmail != null) updateData['avisar_representante_email'] = avisarRepresentanteEmail;
      if (status != null) updateData['status'] = status;

      if (updateData.isEmpty) {
        throw Exception('Nenhum campo para atualizar foi fornecido');
      }

      final response = await _client
          .from('eventos_agenda_representante')
          .update(updateData)
          .eq('id', eventoId)
          .select()
          .single();

      return EventoAgenda.fromJson(response);
    } catch (e) {
      print('Erro ao atualizar evento: $e');
      rethrow;
    }
  }

  /// Cancela um evento (soft delete)
  static Future<bool> cancelarEvento(String eventoId) async {
    try {
      await _client
          .from('eventos_agenda_representante')
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
          .from('eventos_agenda_representante')
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
          .from('eventos_agenda_representante')
          .delete()
          .eq('id', eventoId);

      return true;
    } catch (e) {
      print('Erro ao deletar evento: $e');
      return false;
    }
  }

  /// Busca um evento específico por ID
  static Future<EventoAgenda?> buscarEventoPorId(String eventoId) async {
    try {
      final response = await _client
          .from('eventos_agenda_representante')
          .select()
          .eq('id', eventoId)
          .single();

      return EventoAgenda.fromJson(response);
    } catch (e) {
      print('Erro ao buscar evento por ID: $e');
      return null;
    }
  }

  /// Valida se um horário está disponível para um representante em uma data
  static Future<bool> validarDisponibilidadeHorario({
    required String representanteId,
    required DateTime data,
    required String horaInicio,
    required String horaFim,
    String? eventoIdExcluir, // Para edição de eventos
  }) async {
    try {
      final dataFormatada = data.toIso8601String().split('T')[0];
      
      var query = _client
          .from('eventos_agenda_representante')
          .select('id, hora_inicio, hora_fim')
          .eq('representante_id', representanteId)
          .eq('data_evento', dataFormatada)
          .eq('status', 'ativo');

      // Exclui o evento atual se estiver editando
      if (eventoIdExcluir != null) {
        query = query.neq('id', eventoIdExcluir);
      }

      final response = await query;

      // Verifica conflitos de horário
      for (final evento in response) {
        final eventoInicio = evento['hora_inicio'] as String;
        final eventoFim = evento['hora_fim'] as String?;

        // Se o evento existente não tem hora fim, considera conflito se o horário de início for igual
        if (eventoFim == null) {
          if (horaInicio == eventoInicio) {
            return false;
          }
          continue;
        }

        // Verifica sobreposição de horários
        if (_horariosSeConflitam(horaInicio, horaFim, eventoInicio, eventoFim)) {
          return false;
        }
      }

      return true;
    } catch (e) {
      print('Erro ao validar disponibilidade de horário: $e');
      return false;
    }
  }

  /// Verifica se dois intervalos de horário se conflitam
  static bool _horariosSeConflitam(String inicio1, String fim1, String inicio2, String fim2) {
    final inicio1Minutes = _converterHorarioParaMinutos(inicio1);
    final fim1Minutes = _converterHorarioParaMinutos(fim1);
    final inicio2Minutes = _converterHorarioParaMinutos(inicio2);
    final fim2Minutes = _converterHorarioParaMinutos(fim2);

    // Verifica se há sobreposição
    return (inicio1Minutes < fim2Minutes) && (fim1Minutes > inicio2Minutes);
  }

  /// Converte horário no formato HH:mm para minutos
  static int _converterHorarioParaMinutos(String horario) {
    final partes = horario.split(':');
    final horas = int.parse(partes[0]);
    final minutos = int.parse(partes[1]);
    return horas * 60 + minutos;
  }

  /// Faz upload da foto do evento para Supabase Storage
  /// Bucket: imagens_agenda_representante
  /// Path: /condominio_id/evento_id/nomeArquivo
  static Future<String?> uploadFotoEventoAgenda({
    required String condominioId,
    required String eventoId,
    required dynamic arquivo, // Aceita File (mobile) ou XFile (web)
    required String nomeArquivo,
  }) async {
    try {
      print('🔵 [EventoAgendaService] Iniciando upload da foto do evento...');
      
      // Converter para bytes - compatível com File e XFile
      late Uint8List bytes;
      
      if (arquivo is File) {
        // Mobile
        bytes = await arquivo.readAsBytes();
      } else {
        // Web (XFile) ou outro formato
        try {
          bytes = await arquivo.readAsBytes();
        } catch (e) {
          throw Exception('Não foi possível ler a imagem: $e');
        }
      }
      
      print('📦 [EventoAgendaService] Imagem lida: ${bytes.length} bytes');

      final path = '$condominioId/$eventoId/$nomeArquivo';
      
      print('🔵 [EventoAgendaService] Iniciando upload binário para: $path');
      
      await _client.storage.from('imagens_agenda_representante').uploadBinary(
            path,
            bytes,
          );

      // Obter URL pública
      final publicUrl = _client.storage
          .from('imagens_agenda_representante')
          .getPublicUrl(path);

      print('✅ [EventoAgendaService] Upload realizado com sucesso: $publicUrl');
      return publicUrl;
    } catch (e) {
      print('❌ [EventoAgendaService] Erro ao fazer upload da foto: $e');
      return null;
    }
  }
}