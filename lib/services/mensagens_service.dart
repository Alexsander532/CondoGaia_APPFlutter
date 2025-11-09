import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:condogaiaapp/models/mensagem.dart';

/// Service para gerenciar mensagens entre usuários e representantes
/// Responsável por CRUD, streams e lógica de entrega/leitura
class MensagensService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // ============================================
  // CRUD - CREATE
  // ============================================

  /// Envia uma nova mensagem
  Future<Mensagem> enviar({
    required String conversaId,
    required String condominioId,
    required String remetenteTipo, // 'usuario' | 'representante'
    required String remententeId,
    required String remetenteName,
    required String conteudo,
    String tipoConteudo = 'texto', // 'texto' | 'imagem' | 'arquivo' | 'audio'
    String? anexoUrl,
    String? anexoTipo,
    String? anexoNome,
    int? anexoTamanho,
    String? respostaAMensagemId,
    String prioridade = 'normal', // 'baixa' | 'normal' | 'alta' | 'urgente'
    String? categoria,
  }) async {
    debugPrint('[MENSAGENS_SERVICE] ENVIAR MENSAGEM');
    debugPrint('[MENSAGENS_SERVICE] Conversa ID: $conversaId');
    debugPrint('[MENSAGENS_SERVICE] Condominio ID: $condominioId');
    debugPrint('[MENSAGENS_SERVICE] Remetente Tipo: $remetenteTipo');
    debugPrint('[MENSAGENS_SERVICE] Remetente ID: $remententeId');
    debugPrint('[MENSAGENS_SERVICE] Remetente Nome: $remetenteName');
    debugPrint('[MENSAGENS_SERVICE] Conteudo: "$conteudo"');
    debugPrint('[MENSAGENS_SERVICE] Tipo Conteudo: $tipoConteudo');
    
    try {
      final agora = DateTime.now();
      final novaMsg = {
        'conversa_id': conversaId,
        'condominio_id': condominioId,
        'remetente_tipo': remetenteTipo,
        'remetente_id': remententeId,
        'remetente_nome': remetenteName,
        'conteudo': conteudo,
        'tipo_conteudo': tipoConteudo,
        'anexo_url': anexoUrl,
        'anexo_tipo': anexoTipo,
        'anexo_nome': anexoNome,
        'anexo_tamanho': anexoTamanho,
        'status': 'entregue', // Comeca como entregue localmente
        'lida': false,
        'data_leitura': null,
        'resposta_a_mensagem_id': respostaAMensagemId,
        'editada': false,
        'data_edicao': null,
        'conteudo_original': null,
        'prioridade': prioridade,
        'categoria': categoria,
        'created_at': agora.toIso8601String(),
        'updated_at': agora.toIso8601String(),
      };

      debugPrint('[MENSAGENS_SERVICE] Inserindo mensagem no Supabase...');
      debugPrint('[MENSAGENS_SERVICE] Dados: $novaMsg');
      
      final result = await _supabase
          .from('mensagens')
          .insert(novaMsg)
          .select()
          .single();

      debugPrint('[MENSAGENS_SERVICE] OK: Mensagem inserida com sucesso!');
      debugPrint('[MENSAGENS_SERVICE] Resultado: $result');

      return Mensagem.fromJson(result);
    } catch (e, stackTrace) {
      debugPrint('[MENSAGENS_SERVICE] ERROR ao enviar mensagem!');
      debugPrint('[MENSAGENS_SERVICE] Erro: $e');
      debugPrint('[MENSAGENS_SERVICE] Stack: $stackTrace');
      throw Exception('Erro ao enviar mensagem: $e');
    }
  }

  // ============================================
  // CRUD - READ
  // ============================================

  /// Lista mensagens de uma conversa (paginada)
  Future<List<Mensagem>> listar({
    required String conversaId,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await _supabase
          .from('mensagens')
          .select()
          .eq('conversa_id', conversaId)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      final mensagens = (response as List<dynamic>)
          .map((json) => Mensagem.fromJson(json as Map<String, dynamic>))
          .toList();

      // Inverte para ordem cronológica (mais antiga primeiro)
      return mensagens.reversed.toList();
    } catch (e) {
      throw Exception('Erro ao listar mensagens: $e');
    }
  }

  /// Busca uma mensagem específica por ID
  Future<Mensagem?> buscarPorId(String mensagemId) async {
    try {
      final response = await _supabase
          .from('mensagens')
          .select()
          .eq('id', mensagemId)
          .maybeSingle();

      if (response == null) return null;

      return Mensagem.fromJson(response);
    } catch (e) {
      throw Exception('Erro ao buscar mensagem: $e');
    }
  }

  /// Busca mensagens não-lidas de uma conversa
  Future<List<Mensagem>> buscarNaoLidas({
    required String conversaId,
    String? remetenteTipo, // Para filtrar por tipo
  }) async {
    try {
      var query = _supabase
          .from('mensagens')
          .select()
          .eq('conversa_id', conversaId)
          .eq('lida', false)
          .order('created_at', ascending: true);

      final response = await query;

      return (response as List<dynamic>)
          .map((json) => Mensagem.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar mensagens não-lidas: $e');
    }
  }

  // ============================================
  // CRUD - UPDATE
  // ============================================

  /// Marca mensagem como lida
  Future<void> marcarLida(String mensagemId) async {
    try {
      await _supabase
          .from('mensagens')
          .update({
            'lida': true,
            'data_leitura': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', mensagemId);
    } catch (e) {
      throw Exception('Erro ao marcar mensagem como lida: $e');
    }
  }

  /// Marca múltiplas mensagens como lidas
  Future<void> marcarVariasLidas(List<String> mensagemIds) async {
    try {
      final agora = DateTime.now().toIso8601String();
      for (final id in mensagemIds) {
        await _supabase
            .from('mensagens')
            .update({
              'lida': true,
              'data_leitura': agora,
              'updated_at': agora,
            })
            .eq('id', id);
      }
    } catch (e) {
      throw Exception('Erro ao marcar mensagens como lidas: $e');
    }
  }

  /// Edita conteúdo de uma mensagem
  Future<void> editar(
    String mensagemId,
    String novoConteudo,
  ) async {
    try {
      final agora = DateTime.now().toIso8601String();

      // Busca mensagem original para guardar histórico
      final original = await buscarPorId(mensagemId);
      if (original == null) throw Exception('Mensagem não encontrada');

      await _supabase
          .from('mensagens')
          .update({
            'conteudo': novoConteudo,
            'editada': true,
            'data_edicao': agora,
            'conteudo_original': original.conteudo,
            'updated_at': agora,
          })
          .eq('id', mensagemId);
    } catch (e) {
      throw Exception('Erro ao editar mensagem: $e');
    }
  }

  /// Atualiza status da entrega
  Future<void> atualizarStatus(
    String mensagemId,
    String novoStatus, // 'enviada' | 'entregue' | 'lida' | 'erro'
  ) async {
    try {
      await _supabase
          .from('mensagens')
          .update({
            'status': novoStatus,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', mensagemId);
    } catch (e) {
      throw Exception('Erro ao atualizar status: $e');
    }
  }

  // ============================================
  // CRUD - DELETE
  // ============================================

  /// Deleta uma mensagem
  Future<void> deletar(String mensagemId) async {
    try {
      await _supabase.from('mensagens').delete().eq('id', mensagemId);
    } catch (e) {
      throw Exception('Erro ao deletar mensagem: $e');
    }
  }

  // ============================================
  // STREAMS - Real-time
  // ============================================

  /// Stream de mensagens de uma conversa (atualizações em tempo real)
  Stream<List<Mensagem>> streamMensagens(String conversaId) {
    return _supabase
        .from('mensagens')
        .stream(primaryKey: ['id'])
        .eq('conversa_id', conversaId)
        .order('created_at', ascending: true)
        .map((list) {
          return (list as List<dynamic>)
              .map((json) => Mensagem.fromJson(json as Map<String, dynamic>))
              .toList();
        });
  }

  /// Stream de uma mensagem específica
  Stream<Mensagem?> streamMensagem(String mensagemId) {
    return _supabase
        .from('mensagens')
        .stream(primaryKey: ['id'])
        .eq('id', mensagemId)
        .map((list) {
          if (list.isEmpty) return null;
          return Mensagem.fromJson(list.first);
        });
  }

  /// Stream de status de leitura de uma mensagem
  Stream<bool> streamStatusLeitura(String mensagemId) {
    return _supabase
        .from('mensagens')
        .stream(primaryKey: ['id'])
        .eq('id', mensagemId)
        .map((list) {
          if (list.isEmpty) return false;
          return list.first['lida'] as bool;
        });
  }

  // ============================================
  // UTILITÁRIOS
  // ============================================

  /// Conta mensagens de uma conversa
  Future<int> contar(String conversaId) async {
    try {
      final response = await _supabase
          .from('mensagens')
          .select('id')
          .eq('conversa_id', conversaId);

      return (response as List<dynamic>).length;
    } catch (e) {
      throw Exception('Erro ao contar mensagens: $e');
    }
  }

  /// Conta mensagens não-lidas
  Future<int> contarNaoLidas({
    required String conversaId,
    String? remetenteTipo,
  }) async {
    try {
      var query = _supabase
          .from('mensagens')
          .select('id')
          .eq('conversa_id', conversaId)
          .eq('lida', false);

      if (remetenteTipo != null) {
        query = query.eq('remetente_tipo', remetenteTipo);
      }

      final response = await query;
      return (response as List<dynamic>).length;
    } catch (e) {
      throw Exception('Erro ao contar não-lidas: $e');
    }
  }

  /// Busca mensagens com filtro avançado
  Future<List<Mensagem>> buscarComFiltros({
    required String conversaId,
    String? remetenteTipo,
    String? status,
    String? tipoConteudo,
    bool? lida,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      var query = _supabase
          .from('mensagens')
          .select()
          .eq('conversa_id', conversaId);

      if (remetenteTipo != null) query = query.eq('remetente_tipo', remetenteTipo);
      if (status != null) query = query.eq('status', status);
      if (tipoConteudo != null) query = query.eq('tipo_conteudo', tipoConteudo);
      if (lida != null) query = query.eq('lida', lida);

      final response = await query
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return (response as List<dynamic>)
          .map((json) => Mensagem.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar mensagens com filtros: $e');
    }
  }

  /// Busca contexto de uma resposta (mensagem original + contexto)
  Future<Map<String, dynamic>> buscarContextoResposta(
      String mensagemId) async {
    try {
      final msg = await buscarPorId(mensagemId);
      if (msg == null) throw Exception('Mensagem não encontrada');

      final contexto = <String, dynamic>{
        'mensagem_atual': msg,
        'mensagem_original': null as Mensagem?,
      };

      if (msg.respostaAMensagemId != null) {
        contexto['mensagem_original'] =
            await buscarPorId(msg.respostaAMensagemId!);
      }

      return contexto;
    } catch (e) {
      throw Exception('Erro ao buscar contexto de resposta: $e');
    }
  }

  /// Carrega mais mensagens antigas (para carregar mais ao scroll)
  Future<List<Mensagem>> carregarMais({
    required String conversaId,
    required DateTime dataReferencia,
    int limit = 20,
  }) async {
    try {
      final response = await _supabase
          .from('mensagens')
          .select()
          .eq('conversa_id', conversaId)
          .lt('created_at', dataReferencia.toIso8601String())
          .order('created_at', ascending: false)
          .limit(limit);

      return (response as List<dynamic>)
          .map((json) => Mensagem.fromJson(json as Map<String, dynamic>))
          .toList()
          .reversed
          .toList();
    } catch (e) {
      throw Exception('Erro ao carregar mais mensagens: $e');
    }
  }

  /// Busca últimas mensagens de uma conversa
  Future<List<Mensagem>> buscarUltimas({
    required String conversaId,
    int quantidade = 10,
  }) async {
    try {
      final response = await _supabase
          .from('mensagens')
          .select()
          .eq('conversa_id', conversaId)
          .order('created_at', ascending: false)
          .limit(quantidade);

      return (response as List<dynamic>)
          .map((json) => Mensagem.fromJson(json as Map<String, dynamic>))
          .toList()
          .reversed
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar últimas mensagens: $e');
    }
  }

  /// Busca primeira mensagem (para contexto de conversa)
  Future<Mensagem?> buscarPrimeira(String conversaId) async {
    try {
      final response = await _supabase
          .from('mensagens')
          .select()
          .eq('conversa_id', conversaId)
          .order('created_at', ascending: true)
          .limit(1)
          .maybeSingle();

      if (response == null) return null;

      return Mensagem.fromJson(response);
    } catch (e) {
      throw Exception('Erro ao buscar primeira mensagem: $e');
    }
  }

  /// Verifica se há mensagens não-lidas
  Future<bool> temNaoLidas({
    required String conversaId,
    String? remetenteTipo,
  }) async {
    try {
      final count = await contarNaoLidas(
        conversaId: conversaId,
        remetenteTipo: remetenteTipo,
      );
      return count > 0;
    } catch (e) {
      throw Exception('Erro ao verificar não-lidas: $e');
    }
  }
}
