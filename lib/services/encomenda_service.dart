// =====================================================
// SERVIÇO: EncomendaService
// DESCRIÇÃO: Serviço para gerenciar encomendas no Supabase
// FUNCIONALIDADES: CRUD completo, upload de fotos, filtros
// AUTOR: Sistema
// DATA: 2024-01-15
// =====================================================

import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/encomenda.dart';

class EncomendaService {
  /// Cliente Supabase para interação com o banco de dados
  final SupabaseClient _supabase = Supabase.instance.client;
  
  /// Nome do bucket no Supabase Storage para fotos de encomendas
  /// Usando o bucket 'documentos' que já tem RLS configurado
  static const String _bucketFotos = 'documentos';

  // =====================================================
  // MÉTODOS DE CRIAÇÃO (CREATE)
  // =====================================================

  /// Cria uma nova encomenda no banco de dados
  /// 
  /// [encomenda] - Objeto Encomenda com os dados a serem inseridos
  /// 
  /// Retorna o ID da encomenda criada
  Future<String> criarEncomenda(Encomenda encomenda) async {
    try {
      print('🔄 Iniciando criação de encomenda...');
      
      // Converte a encomenda para JSON, removendo campos que serão gerados pelo banco
      final dadosEncomenda = encomenda.toJson();
      dadosEncomenda.remove('id'); // ID será gerado pelo banco
      dadosEncomenda.remove('created_at'); // Será gerado automaticamente
      dadosEncomenda.remove('updated_at'); // Será gerado automaticamente
      
      print('📋 Dados da encomenda a serem inseridos:');
      print(dadosEncomenda);
      
      // Verifica se a conexão com Supabase está ativa
      print('🔗 Verificando conexão com Supabase...');
      
      // Insere no banco e retorna o registro criado
      print('💾 Executando inserção no banco...');
      final response = await _supabase
          .from('encomendas')
          .insert(dadosEncomenda)
          .select('id')
          .single();

      print('📤 Resposta do Supabase:');
      print(response);

      final String novoId = response['id'];
      
      print('✅ Encomenda criada com sucesso. ID: $novoId');
      
      // Verifica se o registro foi realmente inserido
      print('🔍 Verificando se o registro foi inserido...');
      final verificacao = await _supabase
          .from('encomendas')
          .select('id, condominio_id, representante_id')
          .eq('id', novoId)
          .maybeSingle();
      
      if (verificacao != null) {
        print('✅ Verificação confirmada - registro existe no banco:');
        print(verificacao);
      } else {
        print('⚠️ ATENÇÃO: Registro não encontrado na verificação!');
      }
      
      return novoId;
      
    } catch (e) {
      print('❌ Erro ao criar encomenda: $e');
      print('📊 Tipo do erro: ${e.runtimeType}');
      if (e is PostgrestException) {
        print('🔍 Detalhes do erro Postgrest:');
        print('   - Código: ${e.code}');
        print('   - Mensagem: ${e.message}');
        print('   - Detalhes: ${e.details}');
        print('   - Hint: ${e.hint}');
      }
      throw Exception('Erro ao criar encomenda: $e');
    }
  }

  /// Cria uma nova encomenda com upload de foto
  /// 
  /// [encomenda] - Objeto Encomenda com os dados
  /// [arquivoFoto] - Arquivo da foto a ser enviada (opcional)
  /// 
  /// Retorna o ID da encomenda criada
  Future<String> criarEncomendaComFoto(
    Encomenda encomenda, 
    [File? arquivoFoto]
  ) async {
    try {
      String? urlFoto;
      
      // Se há arquivo de foto, faz o upload primeiro
      if (arquivoFoto != null) {
        urlFoto = await _uploadFotoEncomenda(arquivoFoto);
        print('📸 Foto enviada com sucesso: $urlFoto');
      }
      
      // Cria a encomenda com a URL da foto
      final encomendaComFoto = encomenda.copyWith(fotoUrl: urlFoto);
      return await criarEncomenda(encomendaComFoto);
      
    } catch (e) {
      print('❌ Erro ao criar encomenda com foto: $e');
      throw Exception('Erro ao criar encomenda com foto: $e');
    }
  }

  // =====================================================
  // MÉTODOS DE CONSULTA (READ)
  // =====================================================

  /// Lista todas as encomendas de um condomínio
  /// 
  /// [condominioId] - ID do condomínio
  /// [apenasAtivas] - Se true, retorna apenas encomendas ativas (padrão: true)
  /// [ordenarPorData] - Se true, ordena por data de cadastro decrescente (padrão: true)
  /// 
  /// Retorna lista de encomendas
  Future<List<Encomenda>> listarEncomendas({
    required String condominioId,
    bool apenasAtivas = true,
    bool ordenarPorData = true,
  }) async {
    try {
      // Monta a query base
      dynamic query = _supabase
          .from('encomendas')
          .select('*')
          .eq('condominio_id', condominioId);
      
      // Aplica filtro de ativas se solicitado
      if (apenasAtivas) {
        query = query.eq('ativo', true);
      }
      
      // Aplica ordenação se solicitada
      if (ordenarPorData) {
        query = query.order('data_cadastro', ascending: false);
      }
      
      final response = await query;
      
      // Converte os dados para objetos Encomenda
      final encomendas = (response as List<dynamic>)
          .map((json) => Encomenda.fromJson(json))
          .toList();
      
      print('📦 ${encomendas.length} encomendas encontradas para o condomínio');
      return encomendas;
      
    } catch (e) {
      print('❌ Erro ao listar encomendas: $e');
      throw Exception('Erro ao listar encomendas: $e');
    }
  }

  /// Lista encomendas pendentes de retirada
  /// 
  /// [condominioId] - ID do condomínio
  /// 
  /// Retorna lista de encomendas não retiradas
  Future<List<Encomenda>> listarEncomendasPendentes(String condominioId) async {
    try {
      final response = await _supabase
          .from('encomendas')
          .select('*')
          .eq('condominio_id', condominioId)
          .eq('ativo', true)
          .eq('recebido', false)
          .order('data_cadastro', ascending: false);
      
      final encomendas = (response as List<dynamic>)
          .map((json) => Encomenda.fromJson(json))
          .toList();
      
      print('⏳ ${encomendas.length} encomendas pendentes encontradas');
      return encomendas;
      
    } catch (e) {
      print('❌ Erro ao listar encomendas pendentes: $e');
      throw Exception('Erro ao listar encomendas pendentes: $e');
    }
  }

  /// Lista encomendas já retiradas
  /// 
  /// [condominioId] - ID do condomínio
  /// [limite] - Número máximo de registros (padrão: 50)
  /// 
  /// Retorna lista de encomendas retiradas
  Future<List<Encomenda>> listarEncomendasRetiradas({
    required String condominioId,
    int limite = 50,
  }) async {
    try {
      final response = await _supabase
          .from('encomendas')
          .select('*')
          .eq('condominio_id', condominioId)
          .eq('ativo', true)
          .eq('recebido', true)
          .order('data_recebimento', ascending: false)
          .limit(limite);
      
      final encomendas = (response as List<dynamic>)
          .map((json) => Encomenda.fromJson(json))
          .toList();
      
      print('✅ ${encomendas.length} encomendas retiradas encontradas');
      return encomendas;
      
    } catch (e) {
      print('❌ Erro ao listar encomendas retiradas: $e');
      throw Exception('Erro ao listar encomendas retiradas: $e');
    }
  }

  /// Lista encomendas de uma unidade específica
  /// 
  /// [unidadeId] - ID da unidade
  /// [apenasAtivas] - Se true, retorna apenas encomendas ativas (padrão: true)
  /// 
  /// Retorna lista de encomendas da unidade
  Future<List<Encomenda>> listarEncomendasUnidade({
    required String unidadeId,
    bool apenasAtivas = true,
  }) async {
    try {
      var query = _supabase
          .from('encomendas')
          .select('*')
          .eq('unidade_id', unidadeId);
      
      if (apenasAtivas) {
        query = query.eq('ativo', true);
      }
      
      final response = await query.order('data_cadastro', ascending: false);
      
      final encomendas = (response as List<dynamic>)
          .map((json) => Encomenda.fromJson(json))
          .toList();
      
      print('🏠 ${encomendas.length} encomendas encontradas para a unidade');
      return encomendas;
      
    } catch (e) {
      print('❌ Erro ao listar encomendas da unidade: $e');
      throw Exception('Erro ao listar encomendas da unidade: $e');
    }
  }

  /// Lista encomendas de uma pessoa específica (proprietário ou inquilino)
  /// 
  /// [unidadeId] - ID da unidade
  /// [proprietarioId] - ID do proprietário (opcional)
  /// [inquilinoId] - ID do inquilino (opcional)
  /// [apenasAtivas] - Se true, retorna apenas encomendas ativas (padrão: true)
  /// 
  /// Retorna lista de encomendas da pessoa específica
  /// 
  /// IMPORTANTE: Deve ser fornecido OU proprietarioId OU inquilinoId (não ambos)
  Future<List<Encomenda>> listarEncomendasPessoa({
    required String unidadeId,
    String? proprietarioId,
    String? inquilinoId,
    bool apenasAtivas = true,
  }) async {
    // Validação: deve ter exatamente um dos IDs
    if ((proprietarioId == null && inquilinoId == null) ||
        (proprietarioId != null && inquilinoId != null)) {
      throw Exception('Deve ser fornecido exatamente um ID: proprietário OU inquilino');
    }

    try {
      var query = _supabase
          .from('encomendas')
          .select('*')
          .eq('unidade_id', unidadeId);
      
      // Filtrar por proprietário ou inquilino
      if (proprietarioId != null) {
        query = query.eq('proprietario_id', proprietarioId);
        print('🔍 Filtrando encomendas do proprietário: $proprietarioId');
      } else if (inquilinoId != null) {
        query = query.eq('inquilino_id', inquilinoId);
        print('🔍 Filtrando encomendas do inquilino: $inquilinoId');
      }
      
      if (apenasAtivas) {
        query = query.eq('ativo', true);
      }
      
      final response = await query.order('data_cadastro', ascending: false);
      
      final encomendas = (response as List<dynamic>)
          .map((json) => Encomenda.fromJson(json))
          .toList();
      
      final tipoPessoa = proprietarioId != null ? 'proprietário' : 'inquilino';
      print('👤 ${encomendas.length} encomendas encontradas para o $tipoPessoa');
      return encomendas;
      
    } catch (e) {
      print('❌ Erro ao listar encomendas da pessoa: $e');
      throw Exception('Erro ao listar encomendas da pessoa: $e');
    }
  }

  /// Busca uma encomenda específica pelo ID
  /// 
  /// [encomendaId] - ID da encomenda
  /// 
  /// Retorna a encomenda encontrada ou null se não existir
  Future<Encomenda?> buscarEncomenda(String encomendaId) async {
    try {
      final response = await _supabase
          .from('encomendas')
          .select('*')
          .eq('id', encomendaId)
          .eq('ativo', true)
          .maybeSingle();
      
      if (response == null) {
        print('⚠️ Encomenda não encontrada: $encomendaId');
        return null;
      }
      
      final encomenda = Encomenda.fromJson(response);
      print('🔍 Encomenda encontrada: ${encomenda.id}');
      return encomenda;
      
    } catch (e) {
      print('❌ Erro ao buscar encomenda: $e');
      throw Exception('Erro ao buscar encomenda: $e');
    }
  }

  // =====================================================
  // MÉTODOS DE ATUALIZAÇÃO (UPDATE)
  // =====================================================

  /// Marca uma encomenda como recebida/retirada
  /// 
  /// [encomendaId] - ID da encomenda
  /// [recebidoPor] - Nome da pessoa que recebeu a encomenda
  /// 
  /// Retorna true se a operação foi bem-sucedida
  Future<bool> marcarComoRecebida(String encomendaId, {String? recebidoPor}) async {
    try {
      final agora = DateTime.now();
      
      final response = await _supabase
          .from('encomendas')
          .update({
            'recebido': true,
            'recebido_por': recebidoPor,
            'data_recebimento': agora.toIso8601String(),
            'updated_at': agora.toIso8601String(),
          })
          .eq('id', encomendaId)
          .eq('ativo', true);
      
      print('✅ Encomenda marcada como recebida: $encomendaId${recebidoPor != null ? ' por $recebidoPor' : ''}');
      return true;
      
    } catch (e) {
      print('❌ Erro ao marcar encomenda como recebida: $e');
      return false;
    }
  }

  /// Desfaz a marcação de recebida (volta para pendente)
  /// 
  /// [encomendaId] - ID da encomenda
  /// 
  /// Retorna true se a operação foi bem-sucedida
  Future<bool> marcarComoPendente(String encomendaId) async {
    try {
      final agora = DateTime.now();
      
      final response = await _supabase
          .from('encomendas')
          .update({
            'recebido': false,
            'recebido_por': null,
            'data_recebimento': null,
            'updated_at': agora.toIso8601String(),
          })
          .eq('id', encomendaId)
          .eq('ativo', true);
      
      print('⏳ Encomenda marcada como pendente: $encomendaId');
      return true;
      
    } catch (e) {
      print('❌ Erro ao marcar encomenda como pendente: $e');
      return false;
    }
  }

  /// Atualiza a foto de uma encomenda
  /// 
  /// [encomendaId] - ID da encomenda
  /// [novoArquivoFoto] - Novo arquivo de foto
  /// 
  /// Retorna true se a operação foi bem-sucedida
  Future<bool> atualizarFoto(String encomendaId, File novoArquivoFoto) async {
    try {
      // Busca a encomenda atual para obter a URL da foto antiga
      final encomendaAtual = await buscarEncomenda(encomendaId);
      if (encomendaAtual == null) {
        throw Exception('Encomenda não encontrada');
      }
      
      // Remove a foto antiga se existir
      if (encomendaAtual.temFoto) {
        await _removerFotoEncomenda(encomendaAtual.fotoUrl!);
      }
      
      // Faz upload da nova foto
      final novaUrlFoto = await _uploadFotoEncomenda(novoArquivoFoto);
      
      // Atualiza no banco
      final agora = DateTime.now();
      await _supabase
          .from('encomendas')
          .update({
            'foto_url': novaUrlFoto,
            'updated_at': agora.toIso8601String(),
          })
          .eq('id', encomendaId)
          .eq('ativo', true);
      
      print('📸 Foto da encomenda atualizada: $encomendaId');
      return true;
      
    } catch (e) {
      print('❌ Erro ao atualizar foto da encomenda: $e');
      return false;
    }
  }

  // =====================================================
  // MÉTODOS DE EXCLUSÃO (DELETE)
  // =====================================================

  /// Remove uma encomenda (soft delete)
  /// 
  /// [encomendaId] - ID da encomenda
  /// 
  /// Retorna true se a operação foi bem-sucedida
  Future<bool> removerEncomenda(String encomendaId) async {
    try {
      final agora = DateTime.now();
      
      final response = await _supabase
          .from('encomendas')
          .update({
            'ativo': false,
            'updated_at': agora.toIso8601String(),
          })
          .eq('id', encomendaId);
      
      print('🗑️ Encomenda removida (soft delete): $encomendaId');
      return true;
      
    } catch (e) {
      print('❌ Erro ao remover encomenda: $e');
      return false;
    }
  }

  /// Exclui permanentemente uma encomenda e sua foto
  /// ⚠️ ATENÇÃO: Esta operação é irreversível!
  /// 
  /// [encomendaId] - ID da encomenda
  /// 
  /// Retorna true se a operação foi bem-sucedida
  Future<bool> excluirEncomendaPermanentemente(String encomendaId) async {
    try {
      // Busca a encomenda para obter a URL da foto
      final encomenda = await buscarEncomenda(encomendaId);
      if (encomenda == null) {
        print('⚠️ Encomenda não encontrada para exclusão: $encomendaId');
        return false;
      }
      
      // Remove a foto se existir
      if (encomenda.temFoto) {
        await _removerFotoEncomenda(encomenda.fotoUrl!);
      }
      
      // Exclui o registro do banco
      await _supabase
          .from('encomendas')
          .delete()
          .eq('id', encomendaId);
      
      print('💀 Encomenda excluída permanentemente: $encomendaId');
      return true;
      
    } catch (e) {
      print('❌ Erro ao excluir encomenda permanentemente: $e');
      return false;
    }
  }

  // =====================================================
  // MÉTODOS DE UPLOAD E GERENCIAMENTO DE FOTOS
  // =====================================================

  /// Faz upload de uma foto para o Supabase Storage
  /// 
  /// [arquivo] - Arquivo da foto a ser enviada
  /// 
  /// Retorna a URL pública da foto ou lança exceção em caso de erro
  Future<String> _uploadFotoEncomenda(File arquivo) async {
    try {
      // Lê os bytes do arquivo
      final bytes = await arquivo.readAsBytes();
      
      // Gera um nome único para o arquivo
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extensao = arquivo.path.split('.').last.toLowerCase();
      final nomeArquivo = 'encomenda_${timestamp}.$extensao';
      final caminhoCompleto = 'encomendas/$nomeArquivo';
      
      // Faz o upload para o bucket usando uploadBinary (mais robusto)
      await _supabase.storage
          .from(_bucketFotos)
          .uploadBinary(caminhoCompleto, bytes);
      
      // Obtém a URL pública
      final urlPublica = _supabase.storage
          .from(_bucketFotos)
          .getPublicUrl(caminhoCompleto);
      
      print('📸 Upload concluído: $caminhoCompleto');
      return urlPublica;
      
    } catch (e) {
      print('❌ Erro no upload da foto: $e');
      throw Exception('Erro no upload da foto: $e');
    }
  }

  /// Remove uma foto do Supabase Storage
  /// 
  /// [urlFoto] - URL da foto a ser removida
  /// 
  /// Retorna true se a operação foi bem-sucedida
  Future<bool> _removerFotoEncomenda(String urlFoto) async {
    try {
      // Extrai o nome do arquivo da URL
      final uri = Uri.parse(urlFoto);
      final nomeArquivo = uri.pathSegments.last;
      
      // Remove do storage
      await _supabase.storage
          .from(_bucketFotos)
          .remove([nomeArquivo]);
      
      print('🗑️ Foto removida: $nomeArquivo');
      return true;
      
    } catch (e) {
      print('❌ Erro ao remover foto: $e');
      return false;
    }
  }

  // =====================================================
  // MÉTODOS DE ESTATÍSTICAS E RELATÓRIOS
  // =====================================================

  /// Obtém estatísticas das encomendas do condomínio
  /// 
  /// [condominioId] - ID do condomínio
  /// 
  /// Retorna mapa com estatísticas
  Future<Map<String, int>> obterEstatisticas(String condominioId) async {
    try {
      // Conta total de encomendas ativas
      final totalResponse = await _supabase
          .from('encomendas')
          .select('id')
          .eq('condominio_id', condominioId)
          .eq('ativo', true)
          .count();
      
      // Conta encomendas pendentes
      final pendentesResponse = await _supabase
          .from('encomendas')
          .select('id')
          .eq('condominio_id', condominioId)
          .eq('ativo', true)
          .eq('recebido', false)
          .count();
      
      // Conta encomendas retiradas
      final retiradasResponse = await _supabase
          .from('encomendas')
          .select('id')
          .eq('condominio_id', condominioId)
          .eq('ativo', true)
          .eq('recebido', true)
          .count();
      
      final estatisticas = {
        'total': totalResponse.count,
        'pendentes': pendentesResponse.count,
        'retiradas': retiradasResponse.count,
      };
      
      print('📊 Estatísticas obtidas: $estatisticas');
      return estatisticas;
      
    } catch (e) {
      print('❌ Erro ao obter estatísticas: $e');
      throw Exception('Erro ao obter estatísticas: $e');
    }
  }

  // =====================================================
  // MÉTODOS DE TESTE E DEBUG
  // =====================================================

  /// Testa a conectividade básica com a tabela encomendas
  /// 
  /// Retorna true se conseguir acessar a tabela
  Future<bool> testarConectividade() async {
    try {
      print('🧪 Testando conectividade com tabela encomendas...');
      
      // Tenta fazer uma consulta simples na tabela
      final response = await _supabase
          .from('encomendas')
          .select('count')
          .limit(1);
      
      print('✅ Conectividade OK - tabela acessível');
      print('📊 Resposta do teste: $response');
      return true;
      
    } catch (e) {
      print('❌ Erro de conectividade: $e');
      print('📊 Tipo do erro: ${e.runtimeType}');
      
      if (e is PostgrestException) {
        print('🔍 Detalhes do erro Postgrest:');
        print('   - Código: ${e.code}');
        print('   - Mensagem: ${e.message}');
        print('   - Detalhes: ${e.details}');
        print('   - Hint: ${e.hint}');
      }
      
      return false;
    }
  }

  /// Verifica se a tabela encomendas existe e tem a estrutura esperada
  /// 
  /// Retorna informações sobre a tabela
  Future<Map<String, dynamic>> verificarEstruturatabela() async {
    try {
      print('🔍 Verificando estrutura da tabela encomendas...');
      
      // Tenta acessar a tabela e verificar se existe
      final response = await _supabase
          .from('encomendas')
          .select('*')
          .limit(0); // Não retorna dados, apenas verifica estrutura
      
      print('✅ Tabela encomendas existe e é acessível');
      
      // Tenta contar registros existentes
      final count = await _supabase
          .from('encomendas')
          .select('id')
          .count();
      
      final info = {
        'tabela_existe': true,
        'total_registros': count.count,
        'estrutura_ok': true,
      };
      
      print('📊 Informações da tabela: $info');
      return info;
      
    } catch (e) {
      print('❌ Erro ao verificar tabela: $e');
      
      final info = {
        'tabela_existe': false,
        'erro': e.toString(),
        'estrutura_ok': false,
      };
      
      return info;
    }
  }

  /// Lista encomendas com nomes dos destinatários (proprietários/inquilinos)
  /// 
  /// [condominioId] - ID do condomínio
  /// [apenasAtivas] - Se deve filtrar apenas encomendas ativas
  /// [ordenarPorData] - Se deve ordenar por data de cadastro
  /// 
  /// Retorna lista de Maps com dados da encomenda e nome do destinatário
  Future<List<Map<String, dynamic>>> listarEncomendasComNomes({
    required String condominioId,
    bool apenasAtivas = true,
    bool ordenarPorData = true,
  }) async {
    try {
      // Monta a query base com JOIN para buscar nomes
      dynamic query = _supabase
          .from('encomendas')
          .select('''
            *,
            unidades(
              id,
              numero,
              bloco
            ),
            proprietarios(
              id,
              nome
            ),
            inquilinos(
              id,
              nome
            )
          ''')
          .eq('condominio_id', condominioId);
      
      // Aplica filtro de ativas se solicitado
      if (apenasAtivas) {
        query = query.eq('ativo', true);
      }
      
      // Aplica ordenação se solicitada
      if (ordenarPorData) {
        query = query.order('data_cadastro', ascending: false);
      }
      
      final response = await query;
      
      // Processa os dados para incluir o nome do destinatário
      final encomendasComNomes = (response as List<dynamic>).map((item) {
        // Cria uma cópia dos dados da encomenda
        final encomendaData = Map<String, dynamic>.from(item);
        
        // Determina o nome do destinatário
        String nomeDestinatario = 'N/A';
        if (item['proprietarios'] != null && item['proprietarios']['nome'] != null) {
          nomeDestinatario = item['proprietarios']['nome'];
        } else if (item['inquilinos'] != null && item['inquilinos']['nome'] != null) {
          nomeDestinatario = item['inquilinos']['nome'];
        }
        
        // Adiciona o nome do destinatário aos dados
        encomendaData['nome_destinatario'] = nomeDestinatario;
        
        return encomendaData;
      }).toList();
      
      print('📦 ${encomendasComNomes.length} encomendas com nomes encontradas para o condomínio');
      return encomendasComNomes;
      
    } catch (e) {
      print('❌ Erro ao listar encomendas com nomes: $e');
      throw Exception('Erro ao listar encomendas com nomes: $e');
    }
  }

  // =====================================================
  // MÉTODOS PRINCIPAIS
  // =====================================================
}