import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/historico_acesso.dart';

/// Serviço para gerenciar histórico de acessos (entradas e saídas)
class HistoricoAcessoService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Registra uma entrada de visitante/autorizado
  Future<HistoricoAcesso?> registrarEntrada({
    required String visitanteId,
    required String condominioId,
    String? observacoes,
    String? placaVeiculo,
    String registradoPor = 'Sistema',
    String tipoVisitante = 'visitante_portaria',
  }) async {
    try {
      // Verifica se já existe uma entrada sem saída para este visitante
      final entradaExistente = await _verificarEntradaSemSaida(visitanteId);
      if (entradaExistente != null) {
        throw Exception('Visitante já possui entrada registrada sem saída');
      }

      final historicoData = {
        'visitante_id': visitanteId,
        'condominio_id': condominioId,
        'tipo_registro': 'entrada',
        'tipo_visitante': tipoVisitante,
        'data_hora': DateTime.now().toLocal().toIso8601String(),
        'observacoes': observacoes,
        'registrado_por': registradoPor,
        'ativo': true,
      };

      final response = await _supabase
          .from('historico_acessos')
          .insert(historicoData)
          .select()
          .single();

      // Não atualizamos status pois a tabela autorizados_inquilinos não possui essa coluna

      return HistoricoAcesso.fromJson(response);
    } catch (e) {
      print('Erro ao registrar entrada: $e');
      rethrow;
    }
  }

  /// Registra uma saída de visitante/autorizado
  Future<HistoricoAcesso?> registrarSaida({
    required String visitanteId,
    required String condominioId,
    String? observacoes,
    String registradoPor = 'Sistema',
  }) async {
    try {
      // Verifica se existe uma entrada sem saída para este visitante
      final entradaSemSaida = await _verificarEntradaSemSaida(visitanteId);
      if (entradaSemSaida == null) {
        throw Exception(
          'Não foi encontrada entrada registrada para este visitante',
        );
      }

      // Usar o mesmo tipo_visitante da entrada original
      final tipoVisitanteOriginal = entradaSemSaida.tipoVisitante;

      final historicoData = {
        'visitante_id': visitanteId,
        'condominio_id': condominioId,
        'tipo_registro': 'saida',
        'tipo_visitante':
            tipoVisitanteOriginal, // Usar o tipo da entrada original
        'data_hora': DateTime.now().toLocal().toIso8601String(),
        'observacoes': observacoes,
        'registrado_por': registradoPor,
        'ativo': true,
      };

      final response = await _supabase
          .from('historico_acessos')
          .insert(historicoData)
          .select()
          .single();

      // Não atualizamos status pois a tabela autorizados_inquilinos não possui essa coluna

      return HistoricoAcesso.fromJson(response);
    } catch (e) {
      print('Erro ao registrar saída: $e');
      rethrow;
    }
  }

  /// Verifica se existe entrada sem saída para um visitante
  Future<HistoricoAcesso?> _verificarEntradaSemSaida(String visitanteId) async {
    try {
      // Busca a última entrada do visitante
      final ultimaEntrada = await _supabase
          .from('historico_acessos')
          .select()
          .eq('visitante_id', visitanteId)
          .eq('tipo_registro', 'entrada')
          .eq('ativo', true)
          .order('data_hora', ascending: false)
          .limit(1)
          .maybeSingle();

      if (ultimaEntrada == null) return null;

      final entrada = HistoricoAcesso.fromJson(ultimaEntrada);

      // Verifica se existe saída após esta entrada
      final saidaAposEntrada = await _supabase
          .from('historico_acessos')
          .select()
          .eq('visitante_id', visitanteId)
          .eq('tipo_registro', 'saida')
          .eq('ativo', true)
          .gte('data_hora', entrada.dataHora.toIso8601String())
          .limit(1)
          .maybeSingle();

      return saidaAposEntrada == null ? entrada : null;
    } catch (e) {
      print('Erro ao verificar entrada sem saída: $e');
      return null;
    }
  }

  /// Busca visitantes/autorizados atualmente no condomínio (com entrada sem saída)
  Future<List<Map<String, dynamic>>> getVisitantesNoCondominio(
    String condominioId,
  ) async {
    try {
      List<Map<String, dynamic>> visitantesNoCondominio = [];

      // 1. Buscar todas as entradas ativas no histórico
      final entradas = await _supabase
          .from('historico_acessos')
          .select('*')
          .eq('tipo_registro', 'entrada')
          .eq('ativo', true)
          .order('data_hora', ascending: false);

      print('Total de entradas encontradas: ${entradas.length}');

      // 2. Para cada entrada, buscar os dados do visitante e verificar se ainda está no condomínio
      for (var entrada in entradas) {
        final visitanteId = entrada['visitante_id'];
        final tipoVisitante = entrada['tipo_visitante'] ?? 'inquilino';

        print(
          'Processando entrada: visitante_id=$visitanteId, tipo=$tipoVisitante',
        );

        Map<String, dynamic>? visitanteInfo;
        Map<String, dynamic>? unidadeInfo;

        // Buscar dados do visitante baseado no tipo
        if (tipoVisitante == 'inquilino') {
          // Buscar inquilino autorizado
          final inquilinos = await _supabase
              .from('autorizados_inquilinos')
              .select('*, unidades(*)')
              .eq('id', visitanteId);

          if (inquilinos.isNotEmpty) {
            visitanteInfo = inquilinos.first;
            unidadeInfo = visitanteInfo['unidades'];
          }
        } else if (tipoVisitante == 'visitante_portaria') {
          // Buscar visitante da portaria
          final visitantes = await _supabase
              .from('autorizados_visitantes_portaria_representante')
              .select('*, unidades(*)')
              .eq('id', visitanteId);

          if (visitantes.isNotEmpty) {
            visitanteInfo = visitantes.first;
            unidadeInfo = visitanteInfo['unidades'];
          }
        }

        // Verificar se o visitante pertence ao condomínio solicitado
        // Verifica na unidade OU diretamente no visitante (para casos sem unidade)
        bool pertenceAoCondominio = false;

        if (visitanteInfo != null) {
          if (unidadeInfo != null &&
              unidadeInfo['condominio_id'] == condominioId) {
            pertenceAoCondominio = true;
          } else if (visitanteInfo['condominio_id'] == condominioId) {
            pertenceAoCondominio = true;
          }
        }

        if (pertenceAoCondominio && visitanteInfo != null) {
          // Verificar se existe saída para este visitante após esta entrada
          final saidas = await _supabase
              .from('historico_acessos')
              .select('*')
              .eq('visitante_id', visitanteId)
              .eq('tipo_registro', 'saida')
              .eq('ativo', true)
              .gte('data_hora', entrada['data_hora'])
              .order('data_hora', ascending: false)
              .limit(1);

          // Se não há saída após esta entrada, o visitante ainda está no condomínio
          if (saidas.isEmpty) {
            visitantesNoCondominio.add({
              ...entrada,
              'nome': visitanteInfo['nome'],
              'cpf': visitanteInfo['cpf'],
              'celular': visitanteInfo['celular'] ?? '',
              'foto_url': visitanteInfo['foto_url'], // Adicionar foto_url
              'tipo_pessoa': tipoVisitante == 'inquilino'
                  ? 'Inquilino'
                  : 'Visitante',
              'unidades': unidadeInfo != null
                  ? {
                      'numero': unidadeInfo['numero'],
                      'bloco': unidadeInfo['bloco'],
                    }
                  : null,
              'hora_entrada_real': entrada['data_hora'],
              'observacoes_entrada': entrada['observacoes'],
            });

            print('Visitante adicionado: ${visitanteInfo['nome']}');
          } else {
            print('Visitante já saiu: ${visitanteInfo['nome']}');
          }
        } else {
          print(
            'Visitante não encontrado ou não pertence ao condomínio: visitante_id=$visitanteId',
          );
        }
      }

      print(
        'Total de visitantes no condomínio: ${visitantesNoCondominio.length}',
      );

      // Ordenar por data de entrada (mais recente primeiro)
      visitantesNoCondominio.sort(
        (a, b) => DateTime.parse(
          b['data_hora'],
        ).compareTo(DateTime.parse(a['data_hora'])),
      );

      return visitantesNoCondominio;
    } catch (e) {
      print('Erro ao buscar visitantes no condomínio: $e');
      return [];
    }
  }

  /// Busca histórico completo de acessos com filtros
  Future<List<Map<String, dynamic>>> getHistoricoAcessos({
    required String condominioId,
    DateTime? dataInicio,
    DateTime? dataFim,
    String? tipoRegistro,
    String? visitanteId,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      var query = _supabase
          .from('historico_acessos')
          .select('''
            *,
            autorizados_inquilinos!inner(
              nome,
              cpf,
              celular,
              tipo_autorizacao,
              unidade_id,
              unidades(numero, bloco)
            )
          ''')
          .eq('condominio_id', condominioId)
          .eq('ativo', true);

      if (dataInicio != null) {
        query = query.gte('data_hora', dataInicio.toIso8601String());
      }

      if (dataFim != null) {
        query = query.lte('data_hora', dataFim.toIso8601String());
      }

      if (tipoRegistro != null && tipoRegistro.isNotEmpty) {
        query = query.eq('tipo_registro', tipoRegistro);
      }

      if (visitanteId != null && visitanteId.isNotEmpty) {
        query = query.eq('visitante_id', visitanteId);
      }

      final response = await query
          .order('data_hora', ascending: false)
          .range(offset, offset + limit - 1);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Erro ao buscar histórico de acessos: $e');
      return [];
    }
  }

  /// Busca estatísticas de acessos
  Future<Map<String, dynamic>> getEstatisticasAcessos({
    required String condominioId,
    DateTime? dataInicio,
    DateTime? dataFim,
  }) async {
    try {
      final dataInicioStr =
          dataInicio?.toIso8601String() ??
          DateTime.now().subtract(const Duration(days: 30)).toIso8601String();
      final dataFimStr =
          dataFim?.toIso8601String() ?? DateTime.now().toIso8601String();

      // Total de entradas
      final totalEntradas = await _supabase
          .from('historico_acessos')
          .select('id')
          .eq('condominio_id', condominioId)
          .eq('tipo_registro', 'entrada')
          .eq('ativo', true)
          .gte('data_hora', dataInicioStr)
          .lte('data_hora', dataFimStr)
          .count();

      // Total de saídas
      final totalSaidas = await _supabase
          .from('historico_acessos')
          .select('id')
          .eq('condominio_id', condominioId)
          .eq('tipo_registro', 'saida')
          .eq('ativo', true)
          .gte('data_hora', dataInicioStr)
          .lte('data_hora', dataFimStr)
          .count();

      // Visitantes únicos
      final visitantesUnicos = await _supabase
          .from('historico_acessos')
          .select('visitante_id')
          .eq('condominio_id', condominioId)
          .eq('ativo', true)
          .gte('data_hora', dataInicioStr)
          .lte('data_hora', dataFimStr)
          .count();

      return {
        'total_entradas': totalEntradas.count,
        'total_saidas': totalSaidas.count,
        'visitantes_unicos': visitantesUnicos.count,
        'visitantes_no_condominio': totalEntradas.count - totalSaidas.count,
      };
    } catch (e) {
      print('Erro ao buscar estatísticas de acessos: $e');
      return {
        'total_entradas': 0,
        'total_saidas': 0,
        'visitantes_unicos': 0,
        'visitantes_no_condominio': 0,
      };
    }
  }

  /// Cancela um registro de acesso
  Future<bool> cancelarRegistro(String registroId) async {
    try {
      await _supabase
          .from('historico_acessos')
          .update({'ativo': false})
          .eq('id', registroId);

      return true;
    } catch (e) {
      print('Erro ao cancelar registro: $e');
      return false;
    }
  }

  /// Verifica se um visitante pode registrar saída
  Future<bool> podeRegistrarSaida(String visitanteId) async {
    final entradaSemSaida = await _verificarEntradaSemSaida(visitanteId);
    return entradaSemSaida != null;
  }

  /// Verifica se um visitante pode registrar entrada
  Future<bool> podeRegistrarEntrada(String visitanteId) async {
    final entradaSemSaida = await _verificarEntradaSemSaida(visitanteId);
    return entradaSemSaida == null;
  }

  /// Busca visitantes cadastrados na tabela de visitantes da portaria
  Future<List<Map<String, dynamic>>> getVisitantesCadastrados(
    String condominioId, {
    String? filtroNome,
    String? filtroCpf,
  }) async {
    try {
      var query = _supabase
          .from('autorizados_visitantes_portaria_representante')
          .select('''
            *,
            unidades(
              numero,
              bloco
            )
          ''')
          .eq('condominio_id', condominioId)
          .eq('ativo', true)
          .order('nome', ascending: true);

      // Aplicar filtros se fornecidos
      /*if (filtroNome != null && filtroNome.isNotEmpty) {
        query = query.ilike('nome', '%$filtroNome%');
      }
      
      if (filtroCpf != null && filtroCpf.isNotEmpty) {
        query = query.ilike('cpf', '%$filtroCpf%');
      }*/

      final response = await query;

      return response.map<Map<String, dynamic>>((visitante) {
        return {
          'id': visitante['id'],
          'nome': visitante['nome'],
          'cpf': visitante['cpf'],
          'celular': visitante['celular'] ?? '',
          'tipo_autorizacao': visitante['tipo_autorizacao'] ?? 'unidade',
          'unidade_id': visitante['unidade_id'],
          'unidade_numero': visitante['unidades']?['numero'] ?? '',
          'unidade_bloco': visitante['unidades']?['bloco'] ?? '',
          'quem_autorizou': visitante['quem_autorizou'] ?? '',
          'observacoes': visitante['observacoes'] ?? '',
          'veiculo_tipo': visitante['veiculo_tipo'] ?? '',
          'veiculo_marca': visitante['veiculo_marca'] ?? '',
          'veiculo_modelo': visitante['veiculo_modelo'] ?? '',
          'veiculo_cor': visitante['veiculo_cor'] ?? '',
          'veiculo_placa': visitante['veiculo_placa'] ?? '',
          'data_visita': visitante['data_visita'],
          'status_visita': visitante['status_visita'] ?? 'agendado',
          'foto_url': visitante['foto_url'], // Adicionando foto do visitante
          'qr_code_url':
              visitante['qr_code_url'], // ✅ Adicionando URL do QR Code
        };
      }).toList();
    } catch (e) {
      print('Erro ao buscar visitantes cadastrados: $e');
      return [];
    }
  }
}
