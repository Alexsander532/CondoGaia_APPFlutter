import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/bloco.dart';
import '../models/unidade.dart';
import '../models/bloco_com_unidades.dart';
import 'qr_code_generation_service.dart';

class UnidadeService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // =====================================================
  // CONFIGURAÇÃO INICIAL DO CONDOMÍNIO
  // =====================================================

  /// Configura um condomínio completo com blocos e unidades
  /// Usa a função setup_condominio_completo do banco
  Future<Map<String, dynamic>> configurarCondominioCompleto({
    required String condominioId,
    int totalBlocos = 4,
    int unidadesPorBloco = 6,
    bool usarLetras = true,
  }) async {
    try {
      final response = await _supabase.rpc('setup_condominio_completo', params: {
        'p_condominio_id': condominioId,
        'p_total_blocos': totalBlocos,
        'p_unidades_por_bloco': unidadesPorBloco,
        'p_usar_letras': usarLetras,
      });

      if (response == null) {
        throw Exception('Resposta nula do servidor');
      }

      return Map<String, dynamic>.from(response);
    } catch (e) {
      throw Exception('Erro ao configurar condomínio: $e');
    }
  }

  // =====================================================
  // LISTAGEM E CONSULTAS
  // =====================================================

  /// Lista todas as unidades de um condomínio organizadas por bloco
  /// Usa a função listar_unidades_condominio do banco
  Future<List<BlocoComUnidades>> listarUnidadesCondominio(String condominioId) async {
    try {
      final response = await _supabase.rpc('listar_unidades_condominio', params: {
        'p_condominio_id': condominioId,
      });

      if (response == null) {
        return [];
      }

      final List<dynamic> data = response as List<dynamic>;
      return data.map((item) => BlocoComUnidades.fromJson(item)).toList();
    } catch (e) {
      throw Exception('Erro ao listar unidades: $e');
    }
  }

  /// Busca dados completos de uma unidade específica
  /// Usa a função buscar_dados_completos_unidade do banco
  Future<Map<String, dynamic>> buscarDadosCompletosUnidade(String unidadeId) async {
    try {
      final response = await _supabase.rpc('buscar_dados_completos_unidade', params: {
        'p_unidade_id': unidadeId,
      });

      if (response == null) {
        throw Exception('Unidade não encontrada');
      }

      return Map<String, dynamic>.from(response);
    } catch (e) {
      throw Exception('Erro ao buscar dados da unidade: $e');
    }
  }

  /// Obtém estatísticas do condomínio
  /// Usa a função estatisticas_condominio do banco
  Future<Map<String, dynamic>?> obterEstatisticasCondominio(String condominioId) async {
    try {
      final response = await _supabase.rpc('estatisticas_condominio', params: {
        'p_condominio_id': condominioId,
      });

      if (response == null) {
        return null;
      }

      return Map<String, dynamic>.from(response);
    } catch (e) {
      throw Exception('Erro ao obter estatísticas: $e');
    }
  }

  // =====================================================
  // OPERAÇÕES CRUD INDIVIDUAIS
  // =====================================================

  /// Cria um novo bloco
  Future<Bloco> criarBloco(Bloco bloco) async {
    try {
      final response = await _supabase
          .from('blocos')
          .insert(bloco.toJson())
          .select()
          .single();

      return Bloco.fromJson(response);
    } catch (e) {
      throw Exception('Erro ao criar bloco: $e');
    }
  }

  /// Cria uma nova unidade
  Future<Unidade> criarUnidade(Unidade unidade) async {
    try {
      final response = await _supabase
          .from('unidades')
          .insert(unidade.toJson())
          .select()
          .single();

      final unidadeCriada = Unidade.fromJson(response);
      
      // ✅ Aguardar geração do QR code antes de retornar
      await _gerarQRCodeUnidadeAsync(unidadeCriada);
      
      return unidadeCriada;
    } catch (e) {
      throw Exception('Erro ao criar unidade: $e');
    }
  }

  /// Gera QR code para a unidade
  /// Aguarda a conclusão da geração antes de retornar
  Future<void> _gerarQRCodeUnidadeAsync(Unidade unidade) async {
    // Aguardar um pouco para garantir que os dados foram salvos no banco
    await Future.delayed(const Duration(milliseconds: 300));
    
    try {
      print('🔄 [Unidade] Iniciando geração de QR Code para unidade: ${unidade.numero}');

      final qrCodeUrl = await QrCodeGenerationService.gerarESalvarQRCodeGenerico(
        tipo: 'unidade',
        id: unidade.id,
        nome: unidade.numero,
        tabelaNome: 'unidades',
        dados: {
          'id': unidade.id,
          'numero': unidade.numero,
          'bloco': unidade.bloco ?? '',
          'condominio_id': unidade.condominioId,
          'data_criacao': DateTime.now().toIso8601String(),
        },
      );

      if (qrCodeUrl != null) {
        print('✅ [Unidade] QR Code gerado e salvo: $qrCodeUrl');
      } else {
        print('❌ [Unidade] Falha ao gerar QR Code');
      }
    } catch (e) {
      print('❌ [Unidade] Erro ao gerar QR Code: $e');
    }
  }

  /// Atualiza um bloco existente
  Future<Bloco> atualizarBloco(Bloco bloco) async {
    try {
      final response = await _supabase
          .from('blocos')
          .update(bloco.toJson())
          .eq('id', bloco.id)
          .select()
          .single();

      return Bloco.fromJson(response);
    } catch (e) {
      throw Exception('Erro ao atualizar bloco: $e');
    }
  }

  /// Atualiza uma unidade existente
  Future<Unidade> atualizarUnidade(Unidade unidade) async {
    try {
      final response = await _supabase
          .from('unidades')
          .update(unidade.toJson())
          .eq('id', unidade.id)
          .select()
          .single();

      return Unidade.fromJson(response);
    } catch (e) {
      throw Exception('Erro ao atualizar unidade: $e');
    }
  }

  /// Remove um bloco (soft delete)
  Future<void> removerBloco(String blocoId) async {
    try {
      await _supabase
          .from('blocos')
          .update({'ativo': false, 'updated_at': DateTime.now().toIso8601String()})
          .eq('id', blocoId);
    } catch (e) {
      throw Exception('Erro ao remover bloco: $e');
    }
  }

  /// Remove uma unidade (soft delete)
  Future<void> removerUnidade(String unidadeId) async {
    try {
      await _supabase
          .from('unidades')
          .update({'ativo': false, 'updated_at': DateTime.now().toIso8601String()})
          .eq('id', unidadeId);
    } catch (e) {
      throw Exception('Erro ao remover unidade: $e');
    }
  }

  // =====================================================
  // OPERAÇÕES DE BUSCA E FILTRO
  // =====================================================

  /// Busca unidades por termo (número, bloco, etc.)
  Future<List<BlocoComUnidades>> buscarUnidades({
    required String condominioId,
    required String termo,
  }) async {
    try {
      // Primeiro, obtém todas as unidades
      final todasUnidades = await listarUnidadesCondominio(condominioId);
      
      if (termo.isEmpty) {
        return todasUnidades;
      }

      // Filtra localmente
      final termoLower = termo.toLowerCase();
      final resultados = <BlocoComUnidades>[];

      for (final blocoComUnidades in todasUnidades) {
        // Verifica se o termo corresponde ao nome do bloco
        final blocoCorresponde = blocoComUnidades.bloco.nome.toLowerCase().contains(termoLower) ||
                                blocoComUnidades.bloco.codigo.toLowerCase().contains(termoLower);

        // Filtra unidades que correspondem ao termo
        final unidadesFiltradas = blocoComUnidades.unidades.where((unidade) {
          return unidade.numero.toLowerCase().contains(termoLower);
        }).toList();

        // Se o bloco corresponde, inclui todas as unidades
        if (blocoCorresponde) {
          resultados.add(blocoComUnidades);
        } 
        // Se apenas algumas unidades correspondem, cria um novo BlocoComUnidades com essas unidades
        else if (unidadesFiltradas.isNotEmpty) {
          resultados.add(BlocoComUnidades(
            bloco: blocoComUnidades.bloco,
            unidades: unidadesFiltradas,
          ));
        }
      }

      return resultados;
    } catch (e) {
      throw Exception('Erro ao buscar unidades: $e');
    }
  }

  /// Verifica se um condomínio já foi configurado
  Future<bool> condominioJaConfigurado(String condominioId) async {
    try {
      final response = await _supabase
          .from('configuracao_condominio')
          .select('id')
          .eq('condominio_id', condominioId)
          .maybeSingle();

      return response != null;
    } catch (e) {
      return false;
    }
  }

  /// Edita o nome de um bloco
  Future<bool> editarBloco(String blocoId, String novoNome) async {
    try {
      final response = await _supabase
          .from('blocos')
          .update({'nome': novoNome})
          .eq('id', blocoId);

      return true;
    } catch (e) {
      print('Erro ao editar bloco: $e');
      return false;
    }
  }

  /// Edita o nome de uma unidade
  Future<bool> editarUnidade(String unidadeId, String novoNome) async {
    try {
      final response = await _supabase
          .from('unidades')
          .update({'nome': novoNome})
          .eq('id', unidadeId);

      return true;
    } catch (e) {
      print('Erro ao editar unidade: $e');
      return false;
    }
  }

  /// Exclui um bloco e todas as suas unidades
  Future<bool> deletarBloco(String blocoId) async {
    try {
      // Primeiro, exclui todas as unidades do bloco
      await _supabase
          .from('unidades')
          .delete()
          .eq('bloco_id', blocoId);

      // Depois, exclui o bloco
      await _supabase
          .from('blocos')
          .delete()
          .eq('id', blocoId);

      return true;
    } catch (e) {
      print('Erro ao deletar bloco: $e');
      return false;
    }
  }

  /// Exclui uma unidade específica
  Future<bool> deletarUnidade(String unidadeId) async {
    try {
      await _supabase
          .from('unidades')
          .delete()
          .eq('id', unidadeId);

      return true;
    } catch (e) {
      print('Erro ao deletar unidade: $e');
      return false;
    }
  }

  /// Cria uma unidade rápida com bloco automático ou selecionado
  /// Se o bloco não existe, cria um novo bloco "A"
  /// Usado no fluxo de modal de criação
  Future<Unidade> criarUnidadeRapida({
    required String condominioId,
    required String numero,
    required Bloco bloco,
  }) async {
    try {
      // Verificar se o bloco já existe no banco
      late final Bloco blocoCriado;

      if (bloco.id.isEmpty) {
        // Bloco é novo, precisa criar
        blocoCriado = await criarBloco(bloco);
      } else {
        // Bloco já existe
        blocoCriado = bloco;
      }

      // Criar a unidade com o bloco
      final unidade = Unidade.nova(
        condominioId: condominioId,
        numero: numero,
        bloco: blocoCriado.nome,
        tipoUnidade: 'A', // Padrão
      );

      // Converter para JSON e remover ID vazio (deixar banco gerar)
      final json = unidade.toJson();
      json.remove('id'); // Remove ID nulo para que o banco gere
      
      // ✅ IMPORTANTE: Adicionar bloco_id para a constraint da tabela
      json['bloco_id'] = blocoCriado.id;

      final response = await _supabase
          .from('unidades')
          .insert(json)
          .select()
          .single();

      final unidadeCriada = Unidade.fromJson(response);
      
      // ✅ NOVO: Gerar QR code em background
      _gerarQRCodeUnidadeAsync(unidadeCriada);
      
      return unidadeCriada;
    } catch (e) {
      throw Exception('Erro ao criar unidade rápida: $e');
    }
  }

  /// Verifica se ainda existem unidades no condomínio
  Future<bool> verificarSeExistemUnidades(String condominioId) async {
    try {
      final response = await _supabase
          .from('unidades')
          .select('id')
          .eq('condominio_id', condominioId)
          .limit(1);

      return response.isNotEmpty;
    } catch (e) {
      print('Erro ao verificar unidades: $e');
      return false;
    }
  }

  /// Remove a configuração do condomínio (para reconfiguração)
  Future<bool> removerConfiguracaoCondominio(String condominioId) async {
    try {
      await _supabase
          .from('configuracao_condominio')
          .delete()
          .eq('condominio_id', condominioId);

      return true;
    } catch (e) {
      print('Erro ao remover configuração: $e');
      return false;
    }
  }

  /// Cria um novo bloco com parâmetros nomeados
  Future<Bloco> criarBlocoComParametros({
    required String condominioId,
    required String nome,
    required String codigo,
    required int ordem,
  }) async {
    try {
      final bloco = Bloco.novo(
        condominioId: condominioId,
        nome: nome,
        codigo: codigo,
        ordem: ordem,
      );

      final response = await _supabase
          .from('blocos')
          .insert(bloco.toJson())
          .select()
          .single();

      return Bloco.fromJson(response);
    } catch (e) {
      throw Exception('Erro ao criar bloco: $e');
    }
  }

  /// Cria uma nova unidade com parâmetros nomeados
  Future<Unidade> criarUnidadeComParametros({
    required String condominioId,
    required String numero,
    required String bloco,
    required String tipoUnidade,
  }) async {
    try {
      final unidade = Unidade.nova(
        condominioId: condominioId,
        numero: numero,
        bloco: bloco,
        tipoUnidade: tipoUnidade,
      );

      final response = await _supabase
          .from('unidades')
          .insert(unidade.toJson())
          .select()
          .single();

      return Unidade.fromJson(response);
    } catch (e) {
      throw Exception('Erro ao criar unidade: $e');
    }
  }

  /// Atualiza a configuração do condomínio
  Future<void> atualizarConfiguracaoCondominio(
    String condominioId,
    int totalBlocos,
    int unidadesPorBloco,
    bool usarLetrasBloco,
  ) async {
    try {
      await _supabase
          .from('configuracao_condominio')
          .update({
            'total_blocos': totalBlocos,
            'unidades_por_bloco': unidadesPorBloco,
            'usar_letras_blocos': usarLetrasBloco,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('condominio_id', condominioId);
    } catch (e) {
      throw Exception('Erro ao atualizar configuração: $e');
    }
  }
}