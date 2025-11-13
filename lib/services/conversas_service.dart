import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:condogaiaapp/models/conversa.dart';

/// Service para gerenciar conversas entre usuários e representantes
/// Responsável por CRUD e streams de conversas
class ConversasService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // ============================================
  // CRUD - CREATE
  // ============================================

  /// Cria uma nova conversa ou retorna a existente
  /// Valida se usuário e unidade existem
  Future<Conversa> buscarOuCriar({
    required String condominioId,
    required String unidadeId,
    required String usuarioTipo, // 'proprietario' | 'inquilino'
    required String usuarioId,
    required String usuarioNome,
  }) async {
    try {
      // Busca conversa existente
      final response = await _supabase
          .from('conversas')
          .select()
          .eq('condominio_id', condominioId)
          .eq('unidade_id', unidadeId)
          .eq('usuario_id', usuarioId)
          .maybeSingle();

      if (response != null) {
        return Conversa.fromJson(response);
      }

      // Cria nova conversa
      final novaConversa = {
        'condominio_id': condominioId,
        'unidade_id': unidadeId,
        'usuario_tipo': usuarioTipo,
        'usuario_id': usuarioId,
        'usuario_nome': usuarioNome,
        'representante_id': null, // Será preenchido pelo representante
        'status': 'ativa',
        'total_mensagens': 0,
        'mensagens_nao_lidas_usuario': 0,
        'mensagens_nao_lidas_representante': 0,
        'notificacoes_ativas': true,
        'prioridade': 'normal',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      final result = await _supabase
          .from('conversas')
          .insert(novaConversa)
          .select()
          .single();

      return Conversa.fromJson(result);
    } catch (e) {
      throw Exception('Erro ao criar/buscar conversa: $e');
    }
  }

  // ============================================
  // CRUD - READ
  // ============================================

  /// Lista todas as conversas de um usuário
  Future<List<Conversa>> listarConversas({
    required String condominioId,
    required String usuarioId,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final response = await _supabase
          .from('conversas')
          .select()
          .eq('condominio_id', condominioId)
          .eq('usuario_id', usuarioId)
          .order('updated_at', ascending: false)
          .range(offset, offset + limit - 1);

      final conversas = (response as List<dynamic>)
          .map((json) => Conversa.fromJson(json as Map<String, dynamic>))
          .toList();

      return conversas;
    } catch (e) {
      throw Exception('Erro ao listar conversas: $e');
    }
  }

  /// Lista conversas de um representante (todas as suas conversas)
  Future<List<Conversa>> listarConversasRepresentante({
    required String condominioId,
    required String representanteId,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final response = await _supabase
          .from('conversas')
          .select()
          .eq('condominio_id', condominioId)
          .eq('representante_id', representanteId)
          .order('updated_at', ascending: false)
          .range(offset, offset + limit - 1);

      final conversas = (response as List<dynamic>)
          .map((json) => Conversa.fromJson(json as Map<String, dynamic>))
          .toList();

      return conversas;
    } catch (e) {
      throw Exception('Erro ao listar conversas do representante: $e');
    }
  }

  /// Busca uma conversa específica por ID
  Future<Conversa?> buscarPorId(String conversaId) async {
    try {
      final response = await _supabase
          .from('conversas')
          .select()
          .eq('id', conversaId)
          .maybeSingle();

      if (response == null) return null;

      return Conversa.fromJson(response);
    } catch (e) {
      throw Exception('Erro ao buscar conversa: $e');
    }
  }

  // ============================================
  // CRUD - UPDATE
  // ============================================

  /// Marca conversa como lida (limpa não-lidas)
  Future<void> marcarComoLida(String conversaId, bool paraRepresentante) async {
    try {
      debugPrint('[CONVERSAS_SERVICE] Marcando conversa como lida');
      debugPrint('[CONVERSAS_SERVICE] Conversa ID: $conversaId');
      debugPrint('[CONVERSAS_SERVICE] Para Representante: $paraRepresentante');
      
      final updateData = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (paraRepresentante) {
        updateData['mensagens_nao_lidas_representante'] = 0;
        debugPrint('[CONVERSAS_SERVICE] Limpando nao-lidas do representante');
      } else {
        updateData['mensagens_nao_lidas_usuario'] = 0;
        debugPrint('[CONVERSAS_SERVICE] Limpando nao-lidas do usuario');
      }

      debugPrint('[CONVERSAS_SERVICE] Atualizando no Supabase...');
      await _supabase.from('conversas').update(updateData).eq('id', conversaId);
      debugPrint('[CONVERSAS_SERVICE] OK: Conversa marcada como lida');
    } catch (e) {
      debugPrint('[CONVERSAS_SERVICE] ERROR ao marcar como lida: $e');
      throw Exception('Erro ao marcar conversa como lida: $e');
    }
  }

  /// Atualiza status da conversa
  Future<void> atualizarStatus(
    String conversaId,
    String novoStatus, // 'ativa' | 'arquivada' | 'bloqueada'
  ) async {
    try {
      await _supabase
          .from('conversas')
          .update({
            'status': novoStatus,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', conversaId);
    } catch (e) {
      throw Exception('Erro ao atualizar status da conversa: $e');
    }
  }

  /// Atualiza prioridade da conversa
  Future<void> atualizarPrioridade(
    String conversaId,
    String novaPrioridade, // 'baixa' | 'normal' | 'alta' | 'urgente'
  ) async {
    try {
      await _supabase
          .from('conversas')
          .update({
            'prioridade': novaPrioridade,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', conversaId);
    } catch (e) {
      throw Exception('Erro ao atualizar prioridade da conversa: $e');
    }
  }

  /// Atualiza assunto da conversa
  Future<void> atualizarAssunto(String conversaId, String novoAssunto) async {
    try {
      await _supabase
          .from('conversas')
          .update({
            'assunto': novoAssunto,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', conversaId);
    } catch (e) {
      throw Exception('Erro ao atualizar assunto da conversa: $e');
    }
  }

  /// Ativa/desativa notificações para conversa
  Future<void> atualizarNotificacoes(
    String conversaId,
    bool ativado,
  ) async {
    try {
      await _supabase
          .from('conversas')
          .update({
            'notificacoes_ativas': ativado,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', conversaId);
    } catch (e) {
      throw Exception('Erro ao atualizar notificações: $e');
    }
  }

  /// Incrementa contador de não-lidas
  Future<void> incrementarNaoLidas(String conversaId, bool doUsuario) async {
    try {
      final conversa = await buscarPorId(conversaId);
      if (conversa == null) throw Exception('Conversa não encontrada');

      final campo = doUsuario
          ? 'mensagens_nao_lidas_usuario'
          : 'mensagens_nao_lidas_representante';

      final novoValor = doUsuario
          ? conversa.mensagensNaoLidasUsuario + 1
          : conversa.mensagensNaoLidasRepresentante + 1;

      await _supabase.from('conversas').update({
        campo: novoValor,
        'total_mensagens': conversa.totalMensagens + 1,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', conversaId);
    } catch (e) {
      throw Exception('Erro ao incrementar não-lidas: $e');
    }
  }

  /// Atualiza preview e data da última mensagem
  Future<void> atualizarUltimaMensagem(
    String conversaId,
    String preview,
    String por, // 'usuario' | 'representante'
  ) async {
    try {
      debugPrint('[CONVERSAS_SERVICE] Atualizando ultima mensagem');
      debugPrint('[CONVERSAS_SERVICE] Conversa ID: $conversaId');
      debugPrint('[CONVERSAS_SERVICE] Preview: "$preview"');
      debugPrint('[CONVERSAS_SERVICE] Por: $por');
      
      await _supabase
          .from('conversas')
          .update({
            'ultima_mensagem_preview': preview,
            'ultima_mensagem_data': DateTime.now().toIso8601String(),
            'ultima_mensagem_por': por,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', conversaId);
      
      debugPrint('[CONVERSAS_SERVICE] OK: Ultima mensagem atualizada');
    } catch (e) {
      debugPrint('[CONVERSAS_SERVICE] ERROR ao atualizar: $e');
      throw Exception('Erro ao atualizar última mensagem: $e');
    }
  }

  /// Atualiza representante responsável
  Future<void> atribuirRepresentante(
    String conversaId,
    String representanteId,
    String representanteNome,
  ) async {
    try {
      await _supabase
          .from('conversas')
          .update({
            'representante_id': representanteId,
            'representante_nome': representanteNome,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', conversaId);
    } catch (e) {
      throw Exception('Erro ao atribuir representante: $e');
    }
  }

  // ============================================
  // CRUD - DELETE
  // ============================================

  /// Deleta uma conversa (soft delete - apenas marca como deletada)
  Future<void> deletar(String conversaId) async {
    try {
      await _supabase.from('conversas').delete().eq('id', conversaId);
    } catch (e) {
      throw Exception('Erro ao deletar conversa: $e');
    }
  }

  // ============================================
  // STREAMS - Real-time
  // ============================================

  /// Stream de uma conversa específica (atualizações em tempo real)
  Stream<Conversa?> streamConversa(String conversaId) {
    return _supabase
        .from('conversas')
        .stream(primaryKey: ['id'])
        .eq('id', conversaId)
        .map((list) {
          if (list.isEmpty) return null;
          return Conversa.fromJson(list.first);
        });
  }

  /// Stream de conversas de um usuário (atualizações em tempo real)
  Stream<List<Conversa>> streamConversasUsuario({
    required String condominioId,
    required String usuarioId,
  }) {
    return _supabase
        .from('conversas')
        .stream(primaryKey: ['id'])
        .map((list) {
          final filtered = (list as List<dynamic>)
              .where((item) {
                final json = item as Map<String, dynamic>;
                return json['condominio_id'] == condominioId &&
                    json['usuario_id'] == usuarioId;
              })
              .map((json) => Conversa.fromJson(json))
              .toList();

          // Ordena por updated_at decrescente
          filtered.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
          return filtered;
        });
  }

  /// Stream de conversas de um representante
  Stream<List<Conversa>> streamConversasRepresentante({
    required String condominioId,
    required String representanteId,
  }) {
    return _supabase
        .from('conversas')
        .stream(primaryKey: ['id'])
        .map((list) {
          final filtered = (list as List<dynamic>)
              .where((item) {
                final json = item as Map<String, dynamic>;
                return json['condominio_id'] == condominioId &&
                    json['representante_id'] == representanteId;
              })
              .map((json) => Conversa.fromJson(json))
              .toList();

          // Ordena por updated_at decrescente
          filtered.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
          return filtered;
        });
  }

  /// Stream de não-lidas para um usuário
  Stream<int> streamNaoLidasUsuario(String conversaId) {
    return _supabase
        .from('conversas')
        .stream(primaryKey: ['id'])
        .eq('id', conversaId)
        .map((list) {
          if (list.isEmpty) return 0;
          final conversa = Conversa.fromJson(list.first);
          return conversa.mensagensNaoLidasUsuario;
        });
  }

  /// Stream de não-lidas para representante
  Stream<int> streamNaoLidasRepresentante(String conversaId) {
    return _supabase
        .from('conversas')
        .stream(primaryKey: ['id'])
        .eq('id', conversaId)
        .map((list) {
          if (list.isEmpty) return 0;
          final conversa = Conversa.fromJson(list.first);
          return conversa.mensagensNaoLidasRepresentante;
        });
  }

  // ============================================
  // UTILITÁRIOS
  // ============================================

  /// Conta conversas com filtro
  Future<int> contarConversas({
    required String condominioId,
    String? usuarioId,
    String? representanteId,
    String? status,
  }) async {
    try {
      var query = _supabase
          .from('conversas')
          .select('id')
          .eq('condominio_id', condominioId);

      if (usuarioId != null) {
        query = query.eq('usuario_id', usuarioId);
      }
      if (representanteId != null) {
        query = query.eq('representante_id', representanteId);
      }
      if (status != null) {
        query = query.eq('status', status);
      }

      final response = await query;
      return (response as List<dynamic>).length;
    } catch (e) {
      throw Exception('Erro ao contar conversas: $e');
    }
  }

  /// Busca conversas com filtros avançados
  Future<List<Conversa>> buscarComFiltros({
    required String condominioId,
    String? usuarioId,
    String? representanteId,
    String? status,
    String? prioridade,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      var query = _supabase
          .from('conversas')
          .select()
          .eq('condominio_id', condominioId);

      if (usuarioId != null) query = query.eq('usuario_id', usuarioId);
      if (representanteId != null) {
        query = query.eq('representante_id', representanteId);
      }
      if (status != null) query = query.eq('status', status);
      if (prioridade != null) query = query.eq('prioridade', prioridade);

      final response = await query
          .order('updated_at', ascending: false)
          .range(offset, offset + limit - 1);

      return (response as List<dynamic>)
          .map((json) => Conversa.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar conversas com filtros: $e');
    }
  }

  /// Busca conversas não-lidas
  Future<List<Conversa>> buscarNaoLidas({
    required String condominioId,
    required String usuarioId,
  }) async {
    try {
      final response = await _supabase
          .from('conversas')
          .select()
          .eq('condominio_id', condominioId)
          .eq('usuario_id', usuarioId)
          .gt('mensagens_nao_lidas_usuario', 0)
          .order('updated_at', ascending: false);

      return (response as List<dynamic>)
          .map((json) => Conversa.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar conversas não-lidas: $e');
    }
  }

  // ============================================
  // MÉTODO ESPECIAL: Conversas Automáticas
  // ============================================

  /// Cria conversas automáticas com TODOS os proprietários e inquilinos do condomínio
  /// Se conversa já existe, não recria
  /// Retorna lista de todas as conversas
  Future<List<Conversa>> criarConversasAutomaticas({
    required String condominioId,
  }) async {
    try {
      final conversasExistentes = await _supabase
          .from('conversas')
          .select()
          .eq('condominio_id', condominioId);

      final idsExistentes = (conversasExistentes as List<dynamic>)
          .map((c) => (c as Map<String, dynamic>)['usuario_id'] as String)
          .toSet();

      // Busca todos os proprietários
      final proprietarios = await _supabase
          .from('proprietarios')
          .select('id, nome, unidade_id')
          .eq('condominio_id', condominioId);

      // Busca todos os inquilinos
      final inquilinos = await _supabase
          .from('inquilinos')
          .select('id, nome, unidade_id')
          .eq('condominio_id', condominioId);

      final novasConversas = <Conversa>[];

      // Processa proprietários
      for (var prop in (proprietarios as List<dynamic>)) {
        final propMap = prop as Map<String, dynamic>;
        final propId = propMap['id'] as String;
        final propNome = propMap['nome'] as String;
        final unidadeId = propMap['unidade_id'] as String;

        // Se conversa não existe, cria
        if (!idsExistentes.contains(propId)) {
          try {
            final conversa = await buscarOuCriar(
              condominioId: condominioId,
              unidadeId: unidadeId,
              usuarioTipo: 'proprietario',
              usuarioId: propId,
              usuarioNome: propNome,
            );
            
            // Busca dados da unidade separadamente
            try {
              final unidadeResponse = await _supabase
                  .from('unidades')
                  .select('numero, bloco')
                  .eq('id', unidadeId)
                  .single();
              
              final numero = unidadeResponse['numero'] as String?;
              final bloco = unidadeResponse['bloco'] as String?;
              
              String? unidadeNumero;
              if (numero != null) {
                unidadeNumero = bloco != null && bloco.isNotEmpty 
                    ? '$bloco/$numero'
                    : numero;
              }
              
              // Atualiza conversa com unidadeNumero
              if (unidadeNumero != null) {
                await _supabase
                    .from('conversas')
                    .update({'unidade_numero': unidadeNumero})
                    .eq('id', conversa.id);
              }
            } catch (e) {
              print('Erro ao buscar unidade para proprietário $propNome: $e');
            }
            
            novasConversas.add(conversa);
          } catch (e) {
            print('Erro ao criar conversa com proprietário $propNome: $e');
          }
        }
      }

      // Processa inquilinos
      for (var inq in (inquilinos as List<dynamic>)) {
        final inqMap = inq as Map<String, dynamic>;
        final inqId = inqMap['id'] as String;
        final inqNome = inqMap['nome'] as String;
        final unidadeId = inqMap['unidade_id'] as String;

        // Se conversa não existe, cria
        if (!idsExistentes.contains(inqId)) {
          try {
            final conversa = await buscarOuCriar(
              condominioId: condominioId,
              unidadeId: unidadeId,
              usuarioTipo: 'inquilino',
              usuarioId: inqId,
              usuarioNome: inqNome,
            );
            
            // Busca dados da unidade separadamente
            try {
              final unidadeResponse = await _supabase
                  .from('unidades')
                  .select('numero, bloco')
                  .eq('id', unidadeId)
                  .single();
              
              final numero = unidadeResponse['numero'] as String?;
              final bloco = unidadeResponse['bloco'] as String?;
              
              String? unidadeNumero;
              if (numero != null) {
                unidadeNumero = bloco != null && bloco.isNotEmpty 
                    ? '$bloco/$numero'
                    : numero;
              }
              
              // Atualiza conversa com unidadeNumero
              if (unidadeNumero != null) {
                await _supabase
                    .from('conversas')
                    .update({'unidade_numero': unidadeNumero})
                    .eq('id', conversa.id);
              }
            } catch (e) {
              print('Erro ao buscar unidade para inquilino $inqNome: $e');
            }
            
            novasConversas.add(conversa);
          } catch (e) {
            print('Erro ao criar conversa com inquilino $inqNome: $e');
          }
        }
      }

      // Retorna TODAS as conversas (existentes + novas)
      return await listarConversasDoCondominio(condominioId);
    } catch (e) {
      throw Exception('Erro ao criar conversas automáticas: $e');
    }
  }

  /// Lista TODAS as conversas do condomínio (para representante ver todos)
  /// Chama criarConversasAutomaticas() se necessário
  Future<List<Conversa>> listarConversasDoCondominio(String condominioId) async {
    try {
      final response = await _supabase
          .from('conversas')
          .select()
          .eq('condominio_id', condominioId)
          .order('updated_at', ascending: false);

      final conversas = (response as List<dynamic>)
          .map((json) => Conversa.fromJson(json as Map<String, dynamic>))
          .toList();

      return conversas;
    } catch (e) {
      throw Exception('Erro ao listar conversas do condomínio: $e');
    }
  }

  /// Stream TODOS conversas do condomínio (com criação automática na primeira vez)
  Stream<List<Conversa>> streamTodasConversasCondominio(String condominioId) {
    // Primeiro, cria conversas automáticas se não existirem (fire and forget)
    criarConversasAutomaticas(condominioId: condominioId).ignore();

    // Depois, retorna stream de todas as conversas
    return _supabase
        .from('conversas')
        .stream(primaryKey: ['id'])
        .map((list) {
          final filtered = (list as List<dynamic>)
              .where((item) {
                final json = item as Map<String, dynamic>;
                return json['condominio_id'] == condominioId;
              })
              .map((json) => Conversa.fromJson(json))
              .toList();

          // Ordena por updated_at decrescente
          filtered.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
          return filtered;
        });
  }
}
