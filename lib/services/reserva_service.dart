import '../models/reserva.dart';
import 'supabase_service.dart';

class ReservaService {
  /// Buscar todas as reservas de um condomínio
  static Future<List<Reserva>> getReservasPorCondominio(String condominioId) async {
    try {
      final response = await SupabaseService.client
          .from('reservas')
          .select()
          .eq('condominio_id', condominioId)
          .order('data_reserva', ascending: true)
          .order('hora_inicio', ascending: true);
      return response.map((json) => Reserva.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Erro ao buscar reservas por condomínio: $e');
    }
  }
  /// Buscar todas as reservas do representante atual
  static Future<List<Reserva>> getReservasRepresentante(String representanteId) async {
    try {
      final response = await SupabaseService.client
          .from('reservas')
          .select()
          .eq('representante_id', representanteId)
          .order('data_reserva', ascending: true)
          .order('hora_inicio', ascending: true);
      
      return response.map((json) => Reserva.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Erro ao buscar reservas: $e');
    }
  }

  /// Buscar reservas por data específica e representante
  static Future<List<Reserva>> getReservasPorDataRepresentante(
    String representanteId,
    DateTime data,
  ) async {
    try {
      final dataFormatada = data.toIso8601String().split('T')[0];
      
      final response = await SupabaseService.client
          .from('reservas')
          .select()
          .eq('representante_id', representanteId)
          .eq('data_reserva', dataFormatada)
          .order('hora_inicio', ascending: true);
      
      return response.map((json) => Reserva.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Erro ao buscar reservas por data: $e');
    }
  }

  /// Buscar uma reserva específica por ID
  static Future<Reserva?> getReserva(String reservaId) async {
    try {
      final response = await SupabaseService.client
          .from('reservas')
          .select()
          .eq('id', reservaId)
          .single();
      
      return Reserva.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  /// Criar uma nova reserva
  static Future<Reserva> criarReserva({
    required String representanteId,
    required String ambienteId,
    required DateTime dataReserva,
    required String horaInicio,
    required String horaFim,
    required double valorLocacao,
    required String para,
    required String local,
    String? listaPresentes,
  }) async {
    try {
      print('🔵 [ReservaService] Iniciando criarReserva...');
      print('🔵 [ReservaService] representanteId: $representanteId');
      print('🔵 [ReservaService] ambienteId: $ambienteId');
      
      // Validar se o horário é válido
      if (!_isValidTimeRange(horaInicio, horaFim)) {
        throw Exception('Horário inválido: hora de fim deve ser posterior à hora de início');
      }

      // Preparar dados para insert
      final dados = {
        'ambiente_id': ambienteId,
        'representante_id': representanteId,
        'data_reserva': dataReserva.toIso8601String().split('T')[0],
        'hora_inicio': horaInicio,
        'hora_fim': horaFim,
        'valor_locacao': valorLocacao,
        'para': para,
        'local': local,
      };
      
      print('🔵 [ReservaService] Dados preparados: $dados');
      
      // Adicionar lista_presentes se fornecido
      if (listaPresentes != null && listaPresentes.isNotEmpty) {
        dados['lista_presentes'] = listaPresentes;
      }

      // Inserir com rpc call para evitar problemas com índices
      try {
        print('🔵 [ReservaService] Tentando inserir na tabela...');
        await SupabaseService.client
            .from('reservas')
            .insert(dados);
        print('✅ [ReservaService] Insert realizado com sucesso!');
      } catch (e) {
        print('❌ [ReservaService] Erro no insert: $e');
        // Se o insert direto falhar, tenta sem o campo lista_presentes
        dados.remove('lista_presentes');
        print('🔵 [ReservaService] Tentando novamente sem lista_presentes...');
        await SupabaseService.client
            .from('reservas')
            .insert(dados);
        print('✅ [ReservaService] Insert retry realizado com sucesso!');
      }
      
      // Buscar a reserva criada - versão simplificada
      print('🔵 [ReservaService] Buscando reserva criada...');
      final List<dynamic> response = await SupabaseService.client
          .from('reservas')
          .select()
          .eq('representante_id', representanteId)
          .eq('data_reserva', dataReserva.toIso8601String().split('T')[0])
          .eq('hora_inicio', horaInicio)
          .order('created_at', ascending: false)
          .limit(1);
      
      print('🔵 [ReservaService] Response: $response');
      
      if (response.isEmpty) {
        print('⚠️  [ReservaService] Resposta vazia, criando objeto localmente');
        // Se não conseguir recuperar, cria um objeto com os dados enviados
        return Reserva(
          ambienteId: ambienteId,
          representanteId: representanteId,
          dataReserva: dataReserva,
          horaInicio: horaInicio,
          horaFim: horaFim,
          para: para,
          local: local,
          valorLocacao: valorLocacao,
          listaPresentes: listaPresentes,
        );
      }
      
      print('✅ [ReservaService] Retornando reserva encontrada');
      return Reserva.fromJson(response.first);
    } catch (e, stackTrace) {
      print('❌ [ReservaService] ERRO FATAL: $e');
      print('❌ [ReservaService] Stack trace: $stackTrace');
      throw Exception('Erro ao criar reserva: $e');
    }
  }

  /// Atualizar uma reserva existente
  static Future<Reserva> atualizarReserva(
    String reservaId, {
    String? ambienteId,
    DateTime? dataReserva,
    String? horaInicio,
    String? horaFim,
    String? listaPresentes,
    double? valorLocacao,
    String? para,
    String? local,
  }) async {
    try {
      final dados = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };
      
      if (ambienteId != null) dados['ambiente_id'] = ambienteId;
      if (dataReserva != null) dados['data_reserva'] = dataReserva.toIso8601String().split('T')[0];
      if (horaInicio != null) dados['hora_inicio'] = horaInicio;
      if (horaFim != null) dados['hora_fim'] = horaFim;
      if (listaPresentes != null) dados['lista_presentes'] = listaPresentes;
      if (valorLocacao != null) {
        dados['valor_locacao'] = valorLocacao;
      }
      if (para != null) dados['para'] = para;
      if (local != null) dados['local'] = local;

      // Validar horário se foi alterado
      if (horaInicio != null && horaFim != null) {
        if (!_isValidTimeRange(horaInicio, horaFim)) {
          throw Exception('Horário inválido: hora de fim deve ser posterior à hora de início');
        }
      }

      final response = await SupabaseService.client
          .from('reservas')
          .update(dados)
          .eq('id', reservaId)
          .select()
          .single();
      
      return Reserva.fromJson(response);
    } catch (e) {
      throw Exception('Erro ao atualizar reserva: $e');
    }
  }

  /// Deletar uma reserva
  static Future<void> deletarReserva(String reservaId) async {
    try {
      await SupabaseService.client
          .from('reservas')
          .delete()
          .eq('id', reservaId);
    } catch (e) {
      throw Exception('Erro ao deletar reserva: $e');
    }
  }

  /// Verificar disponibilidade de um ambiente em uma data/horário
  static Future<bool> verificarDisponibilidade({
    required String ambienteId,
    required DateTime data,
    required String horaInicio,
    required String horaFim,
    String? reservaIdExcluir, // Para excluir da verificação (útil em edições)
  }) async {
    try {
      final conflito = await _verificarConflitoHorario(
        ambienteId, 
        data, 
        horaInicio, 
        horaFim,
        reservaIdExcluir: reservaIdExcluir,
      );
      
      return !conflito;
    } catch (e) {
      throw Exception('Erro ao verificar disponibilidade: $e');
    }
  }

  /// Buscar reservas futuras do usuário
  static Future<List<Reserva>> getReservasFuturas() async {
    try {
      final userId = SupabaseService.client.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('Usuário não autenticado');
      }

      final hoje = DateTime.now().toIso8601String().split('T')[0];
      
      final response = await SupabaseService.client
          .from('reservas')
          .select()
          .eq('usuario_id', userId)
          .gte('data_reserva', hoje)
          .order('data_reserva', ascending: true)
          .order('hora_inicio', ascending: true);
      
      return response.map((json) => Reserva.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Erro ao buscar reservas futuras: $e');
    }
  }

  /// Buscar reservas por período
  static Future<List<Reserva>> getReservasPorPeriodo({
    required DateTime dataInicio,
    required DateTime dataFim,
  }) async {
    try {
      final userId = SupabaseService.client.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('Usuário não autenticado');
      }

      final dataInicioFormatada = dataInicio.toIso8601String().split('T')[0];
      final dataFimFormatada = dataFim.toIso8601String().split('T')[0];
      
      final response = await SupabaseService.client
          .from('reservas')
          .select()
          .eq('usuario_id', userId)
          .gte('data_reserva', dataInicioFormatada)
          .lte('data_reserva', dataFimFormatada)
          .order('data_reserva', ascending: true)
          .order('hora_inicio', ascending: true);
      
      return response.map((json) => Reserva.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Erro ao buscar reservas por período: $e');
    }
  }

  // Métodos privados auxiliares

  /// Verificar se existe conflito de horário
  static Future<bool> _verificarConflitoHorario(
    String ambienteId,
    DateTime data,
    String horaInicio,
    String horaFim, {
    String? reservaIdExcluir,
  }) async {
    try {
      final dataFormatada = data.toIso8601String().split('T')[0];
      
      var query = SupabaseService.client
          .from('reservas')
          .select('id')
          .eq('ambiente_id', ambienteId)
          .eq('data_reserva', dataFormatada);

      // Excluir reserva específica da verificação (útil para edições)
      if (reservaIdExcluir != null) {
        query = query.neq('id', reservaIdExcluir);
      }

      final response = await query;
      
      // Verificar sobreposição de horários
      for (final reserva in response) {
        final reservaHoraInicio = reserva['hora_inicio'] as String;
        final reservaHoraFim = reserva['hora_fim'] as String;
        
        if (_horariosSesobrepoe(horaInicio, horaFim, reservaHoraInicio, reservaHoraFim)) {
          return true;
        }
      }
      
      return false;
    } catch (e) {
      throw Exception('Erro ao verificar conflito de horário: $e');
    }
  }

  /// Verificar se dois intervalos de horário se sobrepõem
  static bool _horariosSesobrepoe(
    String inicio1, String fim1,
    String inicio2, String fim2,
  ) {
    final time1Start = _parseTime(inicio1);
    final time1End = _parseTime(fim1);
    final time2Start = _parseTime(inicio2);
    final time2End = _parseTime(fim2);
    
    return time1Start < time2End && time2Start < time1End;
  }

  /// Converter string de horário para minutos desde meia-noite
  static int _parseTime(String timeString) {
    final parts = timeString.split(':');
    final hours = int.parse(parts[0]);
    final minutes = int.parse(parts[1]);
    return hours * 60 + minutes;
  }

  /// Validar se o intervalo de horário é válido
  static bool _isValidTimeRange(String horaInicio, String horaFim) {
    try {
      final inicioMinutos = _parseTime(horaInicio);
      final fimMinutos = _parseTime(horaFim);
      return fimMinutos > inicioMinutos;
    } catch (e) {
      return false;
    }
  }
}