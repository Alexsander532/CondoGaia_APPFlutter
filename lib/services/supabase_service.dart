import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/password_generator.dart';

class SupabaseService {
  static const String supabaseUrl = 'https://tukpgefrddfchmvtiujp.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InR1a3BnZWZyZGRmY2htdnRpdWpwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTI1MTg1NTEsImV4cCI6MjA2ODA5NDU1MX0.dZ1Pna1_dwelIJTlhrSN0iiH5nhuzL0y4p6llYJsLp8';

  static SupabaseClient get client => Supabase.instance.client;

  static get nomeCondominio => null;

  /// Inicializa o Supabase
  static Future<void> initialize() async {
    await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  }

  /// Insere um novo condomínio na tabela condominios
  static Future<Map<String, dynamic>?> insertCondominio(
    Map<String, dynamic> condominioData,
  ) async {
    try {
      final response = await client
          .from('condominios')
          .insert(condominioData)
          .select()
          .single();

      return response;
    } catch (e) {
      print('Erro ao inserir condomínio: $e');
      rethrow;
    }
  }

  /// Busca todos os condomínios
  static Future<List<Map<String, dynamic>>> getCondominios() async {
    try {
      final response = await client
          .from('condominios')
          .select()
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Erro ao buscar condomínios: $e');
      rethrow;
    }
  }

  /// Busca um condomínio por ID
  static Future<Map<String, dynamic>?> getCondominioById(String id) async {
    try {
      final response = await client
          .from('condominios')
          .select()
          .eq('id', id)
          .single();

      return response;
    } catch (e) {
      print('Erro ao buscar condomínio por ID: $e');
      rethrow;
    }
  }

  /// Atualiza um condomínio
  static Future<Map<String, dynamic>?> updateCondominio(
    String id,
    Map<String, dynamic> condominioData,
  ) async {
    try {
      final response = await client
          .from('condominios')
          .update(condominioData)
          .eq('id', id)
          .select()
          .single();

      return response;
    } catch (e) {
      print('Erro ao atualizar condomínio: $e');
      rethrow;
    }
  }

  /// Deleta um condomínio
  static Future<void> deleteCondominio(String id) async {
    try {
      await client.from('condominios').delete().eq('id', id);
    } catch (e) {
      print('Erro ao deletar condomínio: $e');
      rethrow;
    }
  }

  /// Insere um novo representante na tabela representantes
  static Future<Map<String, dynamic>?> saveRepresentante(
    Map<String, dynamic> representanteData,
  ) async {
    try {
      // Gerar senha automática baseada no nome do representante
      final nomeCompleto = representanteData['nome_completo'] as String? ?? '';
      print('DEBUG: Nome completo para geração de senha: "$nomeCompleto"');

      final senhaGerada = PasswordGenerator.generatePasswordFromName(
        nomeCompleto,
      );
      print('DEBUG: Senha gerada: "$senhaGerada"');

      // Adicionar a senha gerada aos dados do representante
      final dadosComSenha = Map<String, dynamic>.from(representanteData);
      dadosComSenha['senha_acesso'] = senhaGerada;

      print('DEBUG: Dados que serão inseridos no banco:');
      print('  - Email: ${dadosComSenha['email']}');
      print('  - Nome: ${dadosComSenha['nome_completo']}');
      print('  - Senha: ${dadosComSenha['senha_acesso']}');

      final response = await client
          .from('representantes')
          .insert(dadosComSenha)
          .select()
          .single();

      print('DEBUG: Representante criado com sucesso. Resposta do banco:');
      print('  - ID: ${response['id']}');
      print('  - Email: ${response['email']}');
      print('  - Senha salva: ${response['senha_acesso']}');

      return response;
    } catch (e) {
      print('Erro ao salvar representante: $e');
      rethrow;
    }
  }

  /// Busca todos os representantes
  static Future<List<Map<String, dynamic>>> getRepresentantes() async {
    try {
      final response = await client
          .from('representantes')
          .select()
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Erro ao buscar representantes: $e');
      rethrow;
    }
  }

  /// Busca um representante por ID
  static Future<Map<String, dynamic>?> getRepresentanteById(String id) async {
    try {
      final response = await client
          .from('representantes')
          .select()
          .eq('id', id)
          .single();

      return response;
    } catch (e) {
      print('Erro ao buscar representante por ID: $e');
      rethrow;
    }
  }

  /// Busca um representante por CPF
  static Future<Map<String, dynamic>?> getRepresentanteByCpf(String cpf) async {
    try {
      final response = await client
          .from('representantes')
          .select()
          .eq('cpf', cpf)
          .single();

      return response;
    } catch (e) {
      print('Erro ao buscar representante por CPF: $e');
      rethrow;
    }
  }

  /// Autentica um representante usando CPF e senha
  static Future<Map<String, dynamic>?> authenticateRepresentante(
    String cpf,
    String senha,
  ) async {
    try {
      final response = await client
          .from('representantes')
          .select()
          .eq('cpf', cpf)
          .eq('senha_acesso', senha)
          .single();

      return response;
    } catch (e) {
      print('Erro ao autenticar representante: $e');
      return null; // Retorna null se não encontrar ou houver erro
    }
  }

  /// Atualiza a senha de um representante
  static Future<Map<String, dynamic>?> updateRepresentanteSenha(
    String id,
    String novaSenha,
  ) async {
    try {
      final response = await client
          .from('representantes')
          .update({'senha_acesso': novaSenha})
          .eq('id', id)
          .select()
          .single();

      return response;
    } catch (e) {
      print('Erro ao atualizar senha do representante: $e');
      rethrow;
    }
  }

  /// Busca UFs únicas dos representantes cadastrados
  static Future<List<String>> getUfsFromRepresentantes() async {
    try {
      final response = await client
          .from('representantes')
          .select('uf')
          .not('uf', 'is', null);

      // Extrai UFs únicas e remove duplicatas
      final ufs = response
          .map((item) => item['uf'] as String)
          .where((uf) => uf.isNotEmpty)
          .toSet()
          .toList();

      ufs.sort(); // Ordena alfabeticamente
      return ufs;
    } catch (e) {
      print('Erro ao buscar UFs dos representantes: $e');
      rethrow;
    }
  }

  /// Busca UFs únicas dos condomínios cadastrados
  static Future<List<String>> getUfsFromCondominios() async {
    try {
      final response = await client
          .from('condominios')
          .select('estado')
          .not('estado', 'is', null);

      // Extrai UFs únicas e remove duplicatas
      final ufs = response
          .map((item) => item['estado'] as String)
          .where((uf) => uf.isNotEmpty)
          .toSet()
          .toList();

      ufs.sort(); // Ordena alfabeticamente
      return ufs;
    } catch (e) {
      print('Erro ao buscar UFs dos condomínios: $e');
      rethrow;
    }
  }

  /// Busca cidades únicas dos representantes, opcionalmente filtradas por UF
  static Future<List<String>> getCidadesFromRepresentantes({String? uf}) async {
    try {
      var query = client
          .from('representantes')
          .select('cidade')
          .not('cidade', 'is', null);

      // Filtra por UF se fornecida
      if (uf != null && uf.isNotEmpty) {
        query = query.eq('uf', uf);
      }

      final response = await query;

      // Extrai cidades únicas e remove duplicatas (com normalização case-insensitive)
      // Usa um Set com lowercase para comparação, mas preserva o valor original
      final cidadesMap = <String, String>{};
      for (final item in response) {
        final cidade = (item['cidade'] as String).trim();
        if (cidade.isNotEmpty) {
          // Usa lowercase como chave para deduplicação, mas preserva original
          final chave = cidade.toLowerCase();
          if (!cidadesMap.containsKey(chave)) {
            cidadesMap[chave] = cidade;
          }
        }
      }

      final cidades = cidadesMap.values.toList();
      cidades.sort(); // Ordena alfabeticamente
      return cidades;
    } catch (e) {
      print('Erro ao buscar cidades dos representantes: $e');
      rethrow;
    }
  }

  /// Busca cidades únicas dos condomínios, opcionalmente filtradas por UF
  static Future<List<String>> getCidadesFromCondominios({String? uf}) async {
    try {
      var query = client
          .from('condominios')
          .select('cidade')
          .not('cidade', 'is', null);

      // Filtra por UF se fornecida
      if (uf != null && uf.isNotEmpty) {
        query = query.eq('estado', uf);
      }

      final response = await query;

      // Extrai cidades únicas e remove duplicatas (com normalização case-insensitive)
      // Usa um Set com lowercase para comparação, mas preserva o valor original
      final cidadesMap = <String, String>{};
      for (final item in response) {
        final cidade = (item['cidade'] as String).trim();
        if (cidade.isNotEmpty) {
          // Usa lowercase como chave para deduplicação, mas preserva original
          final chave = cidade.toLowerCase();
          if (!cidadesMap.containsKey(chave)) {
            cidadesMap[chave] = cidade;
          }
        }
      }

      final cidades = cidadesMap.values.toList();
      cidades.sort(); // Ordena alfabeticamente
      return cidades;
    } catch (e) {
      print('Erro ao buscar cidades dos condomínios: $e');
      rethrow;
    }
  }

  /// Pesquisa representantes com filtros opcionais
  static Future<List<Map<String, dynamic>>> pesquisarRepresentantes({
    String? uf,
    String? cidade,
    String? textoPesquisa,
  }) async {
    try {
      var query = client.from('representantes').select('*');

      // Aplica filtro de UF se fornecido
      if (uf != null && uf.isNotEmpty) {
        query = query.eq('uf', uf);
      }

      // Aplica filtro de cidade se fornecido
      if (cidade != null && cidade.isNotEmpty) {
        query = query.eq('cidade', cidade);
      }

      // Aplica filtro de texto se fornecido (busca em nome_completo, cnpj, cpf)
      if (textoPesquisa != null && textoPesquisa.isNotEmpty) {
        query = query.or(
          'nome_completo.ilike.%$textoPesquisa%,'
          'cnpj.ilike.%$textoPesquisa%,'
          'cpf.ilike.%$textoPesquisa%',
        );
      }

      final response = await query.order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Erro ao pesquisar representantes: $e');
      rethrow;
    }
  }

  /// Pesquisa representantes com dados dos condomínios associados
  /// Usa o array condominios_selecionados da tabela representantes
  static Future<List<Map<String, dynamic>>>
  pesquisarRepresentantesComCondominios({
    String? uf,
    String? cidade,
    String? textoPesquisa,
  }) async {
    try {
      print('🔍 PESQUISA REPRESENTANTES: uf=$uf, cidade=$cidade, texto=$textoPesquisa');
      
      // Busca representantes com filtros básicos
      var query = client.from('representantes').select('*');

      if (uf != null && uf.isNotEmpty) {
        query = query.eq('uf', uf);
      }

      if (cidade != null && cidade.isNotEmpty) {
        query = query.eq('cidade', cidade);
      }

      /* REMOVED SQL FILTER TO ALLOW SEARCHING BY CONDO NAME IN MEMORY
      if (textoPesquisa != null && textoPesquisa.isNotEmpty) {
        query = query.or(
          'nome_completo.ilike.%$textoPesquisa%,'
          'cpf.ilike.%$textoPesquisa%',
        );
      }
      */

      final representantes = await query.order('created_at', ascending: false);
      print('✅ Encontrados ${representantes.length} representantes');

      // Agora busca todos os condomínios para fazer o matching
      final condominiosResponse = await client
          .from('condominios')
          .select('*')
          .order('nome_condominio');
      
      final condominiosMap = <String, Map<String, dynamic>>{};
      for (final cond in condominiosResponse) {
        condominiosMap[cond['id'] as String] = cond;
        print('🏢 Condomínio carregado: ${cond['nome_condominio']} - representante_id: ${cond['representante_id']}');
      }
      print('✅ Carregados ${condominiosMap.length} condomínios para matching');

      // Criar mapa de representantes por ID para rápida lookup
      final representantesMap = <String, Map<String, dynamic>>{};
      for (final rep in representantes) {
        representantesMap[rep['id'] as String] = rep;
      }
      print('✅ Carregados ${representantesMap.length} representantes para matching');

      // Processa os resultados para criar uma linha por condomínio
      // CORRIÇÃO: Usar representante_id da tabela de condominios como fonte de verdade
      final resultados = <Map<String, dynamic>>[];

      // Agrupar condomínios por representante_id
      for (final representante in representantes) {
        // Buscar condomínios que têm este representante_id
        final condominiosDoRepresentante = condominiosMap.values
            .where((cond) => cond['representante_id'] == representante['id'])
            .toList();

        print('👤 Representante ${representante['nome_completo']} (${representante['id']}): ${condominiosDoRepresentante.length} condomínios');

        // Se não tiver condomínios, adicionar entrada apenas com dados do representante
        if (condominiosDoRepresentante.isEmpty) {
          print('  ⚠️ ${representante['nome_completo']} não tem condomínios associados. Adicionando à lista.');
          
          final resultado = Map<String, dynamic>.from(representante);
          resultado.remove('condominios_selecionados');
          
          // Define campos de condomínio como nulos ou texto indicativo
          resultado['condominio_id'] = null;
          resultado['nome_condominio'] = 'Sem condomínio associado';
          resultado['cnpj'] = '-';
          resultado['condominio_cidade'] = representante['cidade']; // Mostra a cidade do representante
          resultado['condominio_estado'] = representante['uf'];     // Mostra o UF do representante
          
          // O representante associado é o próprio
          resultado['representante_associado'] = representante['nome_completo'];
          resultado['representante_id_associado'] = representante['id'];
          
          // Aplica filtro de texto se necessário
          if (textoPesquisa == null ||
              textoPesquisa.isEmpty ||
              _contemTexto(resultado, textoPesquisa)) {
            resultados.add(resultado);
          }
          continue;
        }
        
        // Para cada condomínio associado a este representante
        for (final condominio in condominiosDoRepresentante) {
          final resultado = Map<String, dynamic>.from(representante);
          resultado.remove('condominios_selecionados');

          // Adiciona todos os campos do condomínio ao resultado
          resultado['condominio_id'] = condominio['id'];
          resultado['nome_condominio'] = condominio['nome_condominio'] ?? 'Sem nome';
          resultado['cnpj'] = condominio['cnpj'] ?? 'N/A';
          resultado['cep'] = condominio['cep'];
          resultado['endereco'] = condominio['endereco'];
          resultado['numero'] = condominio['numero'];
          resultado['bairro'] = condominio['bairro'];
          resultado['condominio_cidade'] = condominio['cidade'];
          resultado['condominio_estado'] = condominio['estado'];
          resultado['plano_assinatura'] = condominio['plano_assinatura'];
          resultado['pagamento'] = condominio['pagamento'];
          resultado['vencimento'] = condominio['vencimento'];
          resultado['valor'] = condominio['valor'];
          resultado['instituicao_financeiro_condominio'] =
              condominio['instituicao_financeiro_condominio'];
          resultado['token_financeiro_condominio'] =
              condominio['token_financeiro_condominio'];
          resultado['instituicao_financeiro_unidade'] =
              condominio['instituicao_financeiro_unidade'];
          resultado['token_financeiro_unidade'] =
              condominio['token_financeiro_unidade'];

          // O representante associado é o próprio representante
          resultado['representante_associado'] = representante['nome_completo'];
          resultado['representante_id_associado'] = representante['id'];
          print('🔗 ${condominio['nome_condominio']}: Associado a ${representante['nome_completo']}');

          // Aplica filtro de texto se necessário
          if (textoPesquisa == null ||
              textoPesquisa.isEmpty ||
              _contemTexto(resultado, textoPesquisa)) {
            resultados.add(resultado);
          }
        }
      }

      print('✅ Retornando ${resultados.length} resultados da pesquisa');
      return resultados;
    } catch (e) {
      print('❌ Erro ao pesquisar representantes com condomínios: $e');
      throw Exception('Erro ao pesquisar representantes: $e');
    }
  }

  /// Pesquisa condomínios com filtros opcionais
  static Future<List<Map<String, dynamic>>> pesquisarCondominios({
    String? uf,
    String? cidade,
    bool? ativo,
  }) async {
    try {
      var query = client.from('condominios').select('*');

      // Aplica filtros se fornecidos
      if (uf != null && uf.isNotEmpty) {
        query = query.eq('estado', uf);
      }

      if (cidade != null && cidade.isNotEmpty) {
        query = query.eq('cidade', cidade);
      }

      if (ativo != null) {
        query = query.eq('ativo', ativo);
      }

      final response = await query.order('nome_condominio');
      return response;
    } catch (e) {
      print('Erro ao pesquisar condomínios: $e');
      rethrow;
    }
  }

  /// Busca representantes associados a um condomínio específico
  /// CORRIGIDO: Busca usando representante_id na tabela de condomínios (fonte de verdade)
  static Future<List<Map<String, dynamic>>> getRepresentantesByCondominio(
    String condominioId,
  ) async {
    try {
      print('🔍 BUSCAR REPRESENTANTES DO CONDOMÍNIO: $condominioId');
      
      // CORRIGIDO: Busca o condomínio e pega seu representante_id
      // Antes: iterava o array condominios_selecionados de todos os representantes
      // Agora: busca direto o representante_id do condomínio
      final condominio = await client
          .from('condominios')
          .select('representante_id')
          .eq('id', condominioId)
          .maybeSingle();

      if (condominio == null || condominio['representante_id'] == null) {
        print('❌ Condomínio não encontrado ou sem representante');
        return [];
      }

      // Busca o representante associado
      final representante = await client
          .from('representantes')
          .select('*')
          .eq('id', condominio['representante_id'])
          .maybeSingle();

      if (representante == null) {
        return [];
      }

      print('✅ Encontrado representante para o condomínio');
      return [representante];
    } catch (e) {
      print('❌ Erro ao buscar representantes do condomínio: $e');
      rethrow;
    }
  }

  /// Busca condomínios que ainda não possuem representante associado
  static Future<List<Map<String, dynamic>>> getCondominiosDisponiveis() async {
    try {
      // Busca condomínios que não possuem representante_id definido
      final response = await client
          .from('condominios')
          .select('*')
          .filter('representante_id', 'is', null)
          .order('nome_condominio');

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Erro ao buscar condomínios disponíveis: $e');
      rethrow;
    }
  }

  /// Associa um representante a um condomínio
  static Future<Map<String, dynamic>?> associarRepresentanteCondominio(
    String condominioId,
    String representanteId,
  ) async {
    try {
      final response = await client
          .from('condominios')
          .update({'representante_id': representanteId})
          .eq('id', condominioId)
          .select()
          .single();

      return response;
    } catch (e) {
      print('Erro ao associar representante ao condomínio: $e');
      rethrow;
    }
  }

  /// Desassocia um representante de um condomínio
  static Future<Map<String, dynamic>?> desassociarRepresentanteCondominio(
    String condominioId,
  ) async {
    try {
      final response = await client
          .from('condominios')
          .update({'representante_id': null})
          .eq('id', condominioId)
          .select()
          .single();

      return response;
    } catch (e) {
      print('Erro ao desassociar representante do condomínio: $e');
      rethrow;
    }
  }

  /// Busca condomínios associados a um representante específico
  /// Usa o array condominios_selecionados da tabela representantes
  static Future<List<Map<String, dynamic>>> getCondominiosByRepresentante(
    String representanteId,
  ) async {
    try {
      print('🔍 BUSCAR CONDOMÍNIOS: representante=$representanteId');
      
      // CORRIGIDO: Busca condomínios usando representante_id (fonte de verdade)
      // Antes: usava array condominios_selecionados
      // Agora: busca por representante_id na tabela de condomínios
      final condominios = await client
          .from('condominios')
          .select('*')
          .eq('representante_id', representanteId)
          .order('nome_condominio');

      print('✅ Representante tem ${condominios.length} condomínios associados');
      return condominios;
    } catch (e) {
      print('❌ Erro ao buscar condomínios do representante: $e');
      rethrow;
    }
  }

  /// Busca condomínios disponíveis para associação a um representante específico
  /// Retorna condomínios sem representante + condomínios já associados ao representante atual
  static Future<List<Map<String, dynamic>>>
  getCondominiosDisponiveisParaRepresentante(String representanteId) async {
    try {
      final response = await client
          .from('condominios')
          .select('*')
          .or('representante_id.is.null,representante_id.eq.$representanteId')
          .order('nome_condominio');

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Erro ao buscar condomínios disponíveis para representante: $e');
      rethrow;
    }
  }

  /// Transfere todos os condomínios de um representante para outro
  static Future<List<Map<String, dynamic>>> transferirCondominios(
    String representanteOrigemId,
    String representanteDestinoId,
  ) async {
    try {
      final response = await client
          .from('condominios')
          .update({'representante_id': representanteDestinoId})
          .eq('representante_id', representanteOrigemId)
          .select();

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Erro ao transferir condomínios: $e');
      rethrow;
    }
  }

  /// Faz upload de uma imagem para o storage do Supabase
  static Future<String?> uploadImage(
    File imageFile,
    String bucket,
    String fileName,
  ) async {
    try {
      final bytes = await imageFile.readAsBytes();

      final response = await client.storage
          .from(bucket)
          .uploadBinary(fileName, bytes);

      if (response.isNotEmpty) {
        // Retorna a URL pública da imagem
        final publicUrl = client.storage.from(bucket).getPublicUrl(fileName);
        return publicUrl;
      }

      return null;
    } catch (e) {
      print('Erro ao fazer upload da imagem: $e');
      rethrow;
    }
  }

  /// Converte uma imagem para base64
  static Future<String> imageToBase64(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      return base64Encode(bytes);
    } catch (e) {
      print('Erro ao converter imagem para base64: $e');
      rethrow;
    }
  }

  /// Atualiza a foto de perfil de um representante
  static Future<Map<String, dynamic>?> updateRepresentanteFotoPerfil(
    String representanteId,
    String fotoBase64,
  ) async {
    try {
      final response = await client
          .from('representantes')
          .update({'foto_perfil': fotoBase64})
          .eq('id', representanteId)
          .select()
          .single();

      return response;
    } catch (e) {
      print('Erro ao atualizar foto de perfil do representante: $e');
      rethrow;
    }
  }

  /// Remove a foto de perfil de um representante
  static Future<Map<String, dynamic>?> removeRepresentanteFotoPerfil(
    String representanteId,
  ) async {
    try {
      final response = await client
          .from('representantes')
          .update({'foto_perfil': null})
          .eq('id', representanteId)
          .select()
          .single();

      return response;
    } catch (e) {
      print('Erro ao remover foto de perfil do representante: $e');
      rethrow;
    }
  }

  /// Atualiza o representante_id na tabela de condomínios
  /// Esta é a fonte de verdade - a array condominios_selecionados apenas espelha isto
  static Future<void> atualizarRepresentanteCondominios(
    String representanteId,
    List<String> condominiosIds,
    List<String>? condominiosAntigoIds,
  ) async {
    try {
      print('🔄 Atualizando representante_id para representante $representanteId');

      // IDs antigos (condomínios que devem ser desassociados)
      final condominiosRemover = condominiosAntigoIds ?? [];
      
      // Remover representante dos condomínios que foram deseleccionados
      for (final condominioId in condominiosRemover) {
        if (!condominiosIds.contains(condominioId)) {
          print('  ❌ Desassociando condomínio $condominioId');
          await client
              .from('condominios')
              .update({'representante_id': null})
              .eq('id', condominioId);
        }
      }

      // Adicionar representante aos condomínios selecionados
      for (final condominioId in condominiosIds) {
        print('  ✅ Associando condomínio $condominioId ao representante $representanteId');
        await client
            .from('condominios')
            .update({'representante_id': representanteId})
            .eq('id', condominioId);
      }

      print('✅ Representante_id atualizado com sucesso na tabela de condomínios');
    } catch (e) {
      print('❌ Erro ao atualizar representante_id nos condomínios: $e');
      rethrow;
    }
  }

  static bool _contemTexto(Map<String, dynamic> item, String texto) {
    final textoLower = texto.toLowerCase();
    return (item['nome_completo']?.toString().toLowerCase().contains(
              textoLower,
            ) ??
            false) ||
        (item['nome_condominio']?.toString().toLowerCase().contains(
              textoLower,
            ) ??
            false) ||
        (item['cnpj']?.toString().toLowerCase().contains(textoLower) ??
            false) ||
        (item['cpf']?.toString().toLowerCase().contains(textoLower) ?? false);
  }

  // ===========================================
  // MÉTODOS PARA GERENCIAMENTO DE DOCUMENTOS
  // ===========================================

  /// Criar uma nova pasta de documentos
  static Future<Map<String, dynamic>?> criarPastaDocumento({
    required String nome,
    String? descricao,
    required bool privado,
    required String condominioId,
    required String representanteId,
  }) async {
    try {
      final response = await client
          .from('documentos')
          .insert({
            'nome': nome,
            'descricao': descricao,
            'tipo': 'pasta',
            'privado': privado,
            'condominio_id': condominioId,
            'representante_id': representanteId,
          })
          .select()
          .single();

      return response;
    } catch (e) {
      print('Erro ao criar pasta de documento: $e');
      rethrow;
    }
  }

  /// Adicionar um arquivo a uma pasta
  static Future<Map<String, dynamic>?> adicionarArquivoDocumento({
    required String nome,
    String? descricao,
    String? url,
    String? linkExterno,
    required bool privado,
    required String pastaId,
    required String condominioId,
    required String representanteId,
  }) async {
    try {
      final response = await client
          .from('documentos')
          .insert({
            'nome': nome,
            'descricao': descricao,
            'tipo': 'arquivo',
            'url': url,
            'link_externo': linkExterno,
            'privado': privado,
            'pasta_id': pastaId,
            'condominio_id': condominioId,
            'representante_id': representanteId,
          })
          .select()
          .single();

      return response;
    } catch (e) {
      print('Erro ao adicionar arquivo ao documento: $e');
      rethrow;
    }
  }

  /// Buscar pastas de documentos de um condomínio
  static Future<List<Map<String, dynamic>>> getPastasDocumentos(
    String condominioId,
  ) async {
    try {
      print('🔍 Buscando pastas públicas do condominio: $condominioId');
      
      final response = await client
          .from('documentos')
          .select()
          .eq('condominio_id', condominioId)
          .eq('tipo', 'pasta')
          .eq('privado', false)
          .order('created_at', ascending: false);

      print('✅ Pastas públicas encontradas: ${response.length}');
      if (response.isNotEmpty) {
        print('📋 Primeira pasta: ${response[0]}');
      }

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ Erro ao buscar pastas de documentos: $e');
      print('Erro ao buscar pastas de documentos: $e');
      rethrow;
    }
  }

  /// Buscar todas as pastas (públicas E privadas) - para REPRESENTANTE
  static Future<List<Map<String, dynamic>>> getPastasDocumentosRepresentante(
    String condominioId,
  ) async {
    try {
      print('🔍 Buscando todas as pastas (públicas + privadas) do condominio: $condominioId');
      
      final response = await client
          .from('documentos')
          .select()
          .eq('condominio_id', condominioId)
          .eq('tipo', 'pasta')
          .order('created_at', ascending: false);

      print('✅ Todas as pastas encontradas: ${response.length}');
      if (response.isNotEmpty) {
        print('📋 Primeira pasta: ${response[0]}');
      }

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ Erro ao buscar pastas de documentos: $e');
      rethrow;
    }
  }

  /// Buscar arquivos de uma pasta específica
  static Future<List<Map<String, dynamic>>> getArquivosPasta(
    String pastaId,
  ) async {
    try {
      print('🔍 Buscando arquivos da pasta: $pastaId');
      
      final response = await client
          .from('documentos')
          .select()
          .eq('pasta_id', pastaId)
          .eq('tipo', 'arquivo')
          .order('created_at', ascending: false);

      print('✅ Arquivos encontrados: ${response.length}');
      if (response.isNotEmpty) {
        print('📄 Primeiro arquivo: ${response[0]}');
      }

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ Erro ao buscar arquivos da pasta: $e');
      rethrow;
    }
  }

  /// Atualizar uma pasta de documentos
  static Future<Map<String, dynamic>?> atualizarPastaDocumento(
    String pastaId,
    Map<String, dynamic> dados,
  ) async {
    try {
      final response = await client
          .from('documentos')
          .update(dados)
          .eq('id', pastaId)
          .eq('tipo', 'pasta')
          .select()
          .single();

      return response;
    } catch (e) {
      print('Erro ao atualizar pasta de documento: $e');
      rethrow;
    }
  }

  /// Deletar uma pasta e todos os seus arquivos
  static Future<void> deletarPastaDocumento(String pastaId) async {
    try {
      // O CASCADE DELETE irá remover automaticamente os arquivos da pasta
      await client
          .from('documentos')
          .delete()
          .eq('id', pastaId)
          .eq('tipo', 'pasta');
    } catch (e) {
      print('Erro ao deletar pasta de documento: $e');
      rethrow;
    }
  }

  /// Atualizar um arquivo de documento
  static Future<Map<String, dynamic>?> atualizarArquivoDocumento(
    String arquivoId,
    Map<String, dynamic> dados,
  ) async {
    try {
      final response = await client
          .from('documentos')
          .update(dados)
          .eq('id', arquivoId)
          .eq('tipo', 'arquivo')
          .select()
          .single();

      return response;
    } catch (e) {
      print('Erro ao atualizar arquivo de documento: $e');
      rethrow;
    }
  }

  /// Deletar um arquivo específico
  static Future<void> deletarArquivoDocumento(String arquivoId) async {
    try {
      await client
          .from('documentos')
          .delete()
          .eq('id', arquivoId)
          .eq('tipo', 'arquivo');
    } catch (e) {
      print('Erro ao deletar arquivo de documento: $e');
      rethrow;
    }
  }

  /// Upload de arquivo para o storage do Supabase
  static Future<String?> uploadArquivoDocumento(
    dynamic arquivo,
    String nomeArquivo,
    String condominioId,
  ) async {
    try {
      late Uint8List bytes;
      
      // Converter para bytes - compatível com File e XFile
      if (arquivo is File) {
        bytes = await arquivo.readAsBytes();
      } else {
        // Web (XFile) ou outro formato
        bytes = await arquivo.readAsBytes();
      }
      
      final sanitizedName = _sanitizeFileName(nomeArquivo);
      final fileName =
          '${condominioId}/${DateTime.now().millisecondsSinceEpoch}_$sanitizedName';

      final response = await client.storage
          .from('documentos')
          .uploadBinary(fileName, bytes);

      if (response.isNotEmpty) {
        // Retorna a URL pública do arquivo
        final publicUrl = client.storage
            .from('documentos')
            .getPublicUrl(fileName);
        return publicUrl;
      }

      return null;
    } catch (e) {
      print('Erro ao fazer upload do arquivo: $e');
      rethrow;
    }
  }

  /// Sanitiza o nome do arquivo removendo caracteres especiais e espaços
  static String _sanitizeFileName(String fileName) {
    // Remove ou substitui caracteres que podem causar problemas no storage
    String sanitized = fileName
        .replaceAll(' ', '_') // Substitui espaços por underscore
        .replaceAll(
          RegExp(r'[^\w\-_\.]'),
          '',
        ) // Remove caracteres especiais, mantém apenas letras, números, hífen, underscore e ponto
        .replaceAll(
          RegExp(r'_{2,}'),
          '_',
        ); // Substitui múltiplos underscores por um único

    // Garante que não comece ou termine com underscore
    sanitized = sanitized.replaceAll(RegExp(r'^_+|_+$'), '');

    return sanitized;
  }

  /// Upload de arquivo para o storage do Supabase usando bytes diretamente
  static Future<String?> uploadArquivoDocumentoBytes(
    Uint8List bytes,
    String nomeArquivo,
    String condominioId,
  ) async {
    try {
      final sanitizedName = _sanitizeFileName(nomeArquivo);
      final fileName =
          '${condominioId}/${DateTime.now().millisecondsSinceEpoch}_$sanitizedName';

      final response = await client.storage
          .from('documentos')
          .uploadBinary(fileName, bytes);

      if (response.isNotEmpty) {
        // Retorna a URL pública do arquivo
        final publicUrl = client.storage
            .from('documentos')
            .getPublicUrl(fileName);
        return publicUrl;
      }

      return null;
    } catch (e) {
      print('Erro ao fazer upload do arquivo: $e');
      rethrow;
    }
  }

  // ===========================================
  // MÉTODOS PARA GERENCIAMENTO DE BALANCETES
  // ===========================================

  /// Adicionar um balancete
  static Future<Map<String, dynamic>?> adicionarBalancete({
    required String nomeArquivo,
    String? url,
    String? linkExterno,
    required String mes,
    required String ano,
    required bool privado,
    required String condominioId,
    required String representanteId,
  }) async {
    try {
      final response = await client
          .from('balancetes')
          .insert({
            'nome_arquivo': nomeArquivo,
            'url': url,
            'link_externo': linkExterno,
            'mes': mes,
            'ano': ano,
            'privado': privado,
            'condominio_id': condominioId,
            'representante_id': representanteId,
          })
          .select()
          .single();

      return response;
    } catch (e) {
      print('Erro ao adicionar balancete: $e');
      rethrow;
    }
  }

  /// Buscar balancetes de um condomínio
  static Future<List<Map<String, dynamic>>> getBalancetes(
    String condominioId,
  ) async {
    try {
      final response = await client
          .from('balancetes')
          .select()
          .eq('condominio_id', condominioId)
          .order('ano', ascending: false)
          .order('mes', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Erro ao buscar balancetes: $e');
      rethrow;
    }
  }

  /// Buscar balancetes por mês e ano
  static Future<List<Map<String, dynamic>>> getBalancetesPorPeriodo(
    String condominioId,
    String mes,
    String ano,
  ) async {
    try {
      final response = await client
          .from('balancetes')
          .select()
          .eq('condominio_id', condominioId)
          .eq('mes', mes)
          .eq('ano', ano)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Erro ao buscar balancetes por período: $e');
      rethrow;
    }
  }

  /// Atualizar um balancete
  static Future<Map<String, dynamic>?> atualizarBalancete(
    String balanceteId,
    Map<String, dynamic> dados,
  ) async {
    try {
      final response = await client
          .from('balancetes')
          .update(dados)
          .eq('id', balanceteId)
          .select()
          .single();

      return response;
    } catch (e) {
      print('Erro ao atualizar balancete: $e');
      rethrow;
    }
  }

  /// Deletar um balancete
  static Future<void> deletarBalancete(String balanceteId) async {
    try {
      await client.from('balancetes').delete().eq('id', balanceteId);
    } catch (e) {
      print('Erro ao deletar balancete: $e');
      rethrow;
    }
  }

  /// Upload de balancete para o storage
  static Future<String?> uploadBalancete(
    dynamic arquivo,
    String nomeArquivo,
    String condominioId,
    String mes,
    String ano,
  ) async {
    try {
      print('[SupabaseService] Iniciando upload de balancete: $nomeArquivo');
      
      late Uint8List bytes;
      
      // Converter para bytes - compatível com File e XFile
      if (arquivo is File) {
        // Mobile/Desktop
        if (!await arquivo.exists()) {
          print('[SupabaseService] ERRO: Arquivo não existe em ${arquivo.path}');
          throw Exception('Arquivo não encontrado: ${arquivo.path}');
        }
        bytes = await arquivo.readAsBytes();
      } else {
        // Web (XFile) ou outro formato
        try {
          bytes = await arquivo.readAsBytes();
        } catch (e) {
          throw Exception('Não foi possível ler o arquivo: $e');
        }
      }
      
      print('[SupabaseService] Arquivo lido: ${bytes.length} bytes');

      final sanitizedName = _sanitizeFileName(nomeArquivo);
      final fileName =
          '${condominioId}/balancetes/${ano}_${mes}_${DateTime.now().millisecondsSinceEpoch}_$sanitizedName';

      print('[SupabaseService] Caminho no storage: $fileName');
      print('[SupabaseService] Iniciando upload binário...');

      final response = await client.storage
          .from('documentos')
          .uploadBinary(fileName, bytes);

      if (response.isNotEmpty) {
        // Retorna a URL pública do arquivo
        final publicUrl = client.storage
            .from('documentos')
            .getPublicUrl(fileName);
        print('[SupabaseService] Upload concluído com sucesso!');
        print('[SupabaseService] URL pública: $publicUrl');
        return publicUrl;
      }

      print('[SupabaseService] ERRO: Resposta vazia do upload');
      return null;
    } catch (e) {
      print('[SupabaseService] ERRO ao fazer upload do balancete: $e');
      rethrow;
    }
  }

  /// Upload de balancete usando bytes diretamente (compatível com web)
  static Future<String?> uploadBalanceteBytes(
    Uint8List bytes,
    String nomeArquivo,
    String condominioId,
    String mes,
    String ano,
  ) async {
    try {
      print('[SupabaseService] Iniciando upload de balancete (bytes): $nomeArquivo');
      print('[SupabaseService] Tamanho: ${bytes.length} bytes');

      final sanitizedName = _sanitizeFileName(nomeArquivo);
      final fileName =
          '${condominioId}/balancetes/${ano}_${mes}_${DateTime.now().millisecondsSinceEpoch}_$sanitizedName';

      print('[SupabaseService] Caminho no storage: $fileName');
      print('[SupabaseService] Iniciando upload binário...');

      final response = await client.storage
          .from('documentos')
          .uploadBinary(fileName, bytes);

      if (response.isNotEmpty) {
        // Retorna a URL pública do arquivo
        final publicUrl = client.storage
            .from('documentos')
            .getPublicUrl(fileName);
        print('[SupabaseService] Upload concluído com sucesso!');
        print('[SupabaseService] URL pública: $publicUrl');
        return publicUrl;
      }

      print('[SupabaseService] ERRO: Resposta vazia do upload');
      return null;
    } catch (e) {
      print('[SupabaseService] ERRO ao fazer upload do balancete (bytes): $e');
      rethrow;
    }
  }

  /// Download de arquivo do storage
  static Future<Uint8List?> downloadArquivo(String url) async {
    try {
      print('[SupabaseService] Iniciando download da URL: $url');
      
      // Extrair o caminho do arquivo da URL
      final uri = Uri.parse(url);
      final pathSegments = uri.pathSegments;

      print('[SupabaseService] Path segments: $pathSegments');

      // Procurar por qualquer bucket conhecido (fotos_perfil ou documentos)
      String? bucketName;
      int bucketIndex = -1;
      
      final buckets = ['fotos_perfil', 'documentos'];
      for (final bucket in buckets) {
        bucketIndex = pathSegments.indexOf(bucket);
        if (bucketIndex != -1) {
          bucketName = bucket;
          break;
        }
      }

      if (bucketIndex == -1 || bucketIndex >= pathSegments.length - 1) {
        print('[SupabaseService] ERRO: Não encontrou bucket conhecido na URL');
        throw Exception('URL inválida para download - bucket não encontrado');
      }

      print('[SupabaseService] Bucket encontrado: $bucketName');

      // Construir o caminho do arquivo no storage
      final filePath = pathSegments.sublist(bucketIndex + 1).join('/');
      print('[SupabaseService] Caminho do arquivo: $filePath');

      // Fazer download do arquivo
      print('[SupabaseService] Iniciando download do bucket: $bucketName');
      final response = await client.storage
          .from(bucketName!)
          .download(filePath);

      print('[SupabaseService] Download concluído com sucesso! Tamanho: ${response.length} bytes');
      return response;
    } catch (e) {
      print('[SupabaseService] Erro ao fazer download do arquivo: $e');
      rethrow;
    }
  }

  /// Busca todos os representantes com dados dos condomínios associados para exibição na tela do administrador
  static Future<List<Map<String, dynamic>>>
  getRepresentantesComCondominiosParaAdmin() async {
    try {
      print('🔍 BUSCAR REPRESENTANTES PARA ADMIN');
      
      // Busca todos os representantes
      final representantes = await client
          .from('representantes')
          .select('*')
          .order('created_at', ascending: false);

      // Busca todos os condomínios
      final condominios = await client
          .from('condominios')
          .select('*')
          .order('nome_condominio');

      final condominiosMap = <String, Map<String, dynamic>>{};
      for (final cond in condominios) {
        condominiosMap[cond['id'] as String] = cond;
      }

      // Processa os resultados para criar uma estrutura mais amigável
      final resultados = <Map<String, dynamic>>[];

      for (final rep in representantes) {
        final condominiosIds = rep['condominios_selecionados'] as List<dynamic>? ?? [];
        
        // Busca os dados dos condomínios associados
        final condominiosAssociados = <Map<String, dynamic>>[];
        for (final condId in condominiosIds) {
          final cond = condominiosMap[condId.toString()];
          if (cond != null) {
            condominiosAssociados.add(cond);
          }
        }

        // Cria um mapa com os dados do representante e seus condomínios
        final representanteData = {
          'id': rep['id'],
          'nome_completo': rep['nome_completo'],
          'email': rep['email'],
          'senha_acesso': rep['senha_acesso'],
          'cpf': rep['cpf'],
          'telefone': rep['telefone'],
          'celular': rep['celular'],
          'cidade': rep['cidade'],
          'uf': rep['uf'],
          'created_at': rep['created_at'],
          'condominios': condominiosAssociados,
          'total_condominios': condominiosAssociados.length,
        };

        resultados.add(representanteData);
      }

      print('✅ Retornando ${resultados.length} representantes para admin');
      return resultados;
    } catch (e) {
      print('❌ Erro ao buscar representantes com condomínios para admin: $e');
      rethrow;
    }
  }

  /// Atualiza um representante completo
  static Future<Map<String, dynamic>?> updateRepresentante(
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await client
          .from('representantes')
          .update(data)
          .eq('id', id)
          .select()
          .single();

      return response;
    } catch (e) {
      print('Erro ao atualizar representante: $e');
      rethrow;
    }
  }

  /// Atualiza a foto de perfil de um proprietário
  static Future<Map<String, dynamic>?> updateProprietarioFotoPerfil(
    String proprietarioId,
    String fotoBase64,
  ) async {
    try {
      final response = await client
          .from('proprietarios')
          .update({'foto_perfil': fotoBase64})
          .eq('id', proprietarioId)
          .select()
          .single();

      return response;
    } catch (e) {
      print('Erro ao atualizar foto de perfil do proprietário: $e');
      rethrow;
    }
  }

  /// Atualiza a foto de perfil do inquilino
  static Future<Map<String, dynamic>?> updateInquilinoFotoPerfil(
    String inquilinoId,
    String fotoBase64,
  ) async {
    try {
      final response = await client
          .from('inquilinos')
          .update({'foto_perfil': fotoBase64})
          .eq('id', inquilinoId)
          .select()
          .single();

      return response;
    } catch (e) {
      print('Erro ao atualizar foto de perfil do inquilino: $e');
      rethrow;
    }
  }

  /// Deleta um condomínio e atualiza os representantes associados
  static Future<void> deleteCondominioComAtualizacaoRepresentantes(
    String condominioId,
  ) async {
    try {
      print('🗑️ DELETANDO CONDOMÍNIO: $condominioId');
      
      // Primeiro, verificar se existem representantes associados a este condomínio
      final representantesAssociados = await client
          .from('representantes')
          .select('id, condominios_selecionados')
          .not('condominios_selecionados', 'is', null);

      // Atualizar representantes que têm este condomínio associado
      for (final representante in representantesAssociados) {
        final condominiosIds =
            representante['condominios_selecionados'] as List<dynamic>?;
        if (condominiosIds != null && condominiosIds.contains(condominioId)) {
          // Remover o condomínio da lista de condomínios do representante
          final novosCondominiosIds = condominiosIds
              .where((id) => id != condominioId)
              .toList();

          await client
              .from('representantes')
              .update({
                'condominios_selecionados': novosCondominiosIds.isEmpty
                    ? null
                    : novosCondominiosIds,
              })
              .eq('id', representante['id']);
        }
      }

      // Depois, deletar o condomínio
      await client.from('condominios').delete().eq('id', condominioId);

      print(
        '✅ Condomínio $condominioId deletado e representantes atualizados com sucesso',
      );
    } catch (e) {
      print('❌ Erro ao deletar condomínio com atualização de representantes: $e');
      rethrow;
    }
  }

  /// Deleta um representante e libera os condomínios associados
  static Future<void> deleteRepresentanteComLiberacaoCondominios(
    String representanteId,
  ) async {
    try {
      print('🗑️ DELETANDO REPRESENTANTE: $representanteId');
      
      // Primeiro, buscar o representante para ver quais condomínios estão associados
      final representante = await client
          .from('representantes')
          .select('condominios_selecionados')
          .eq('id', representanteId)
          .maybeSingle();

      if (representante != null) {
        final condominiosIds =
            representante['condominios_selecionados'] as List<dynamic>?;

        if (condominiosIds != null && condominiosIds.isNotEmpty) {
          // Verificar se existem outros representantes para estes condomínios
          final outrosRepresentantes = await client
              .from('representantes')
              .select('id, condominios_selecionados')
              .neq('id', representanteId)
              .not('condominios_selecionados', 'is', null);

          // Para cada condomínio do representante que será deletado
          for (final condominioId in condominiosIds) {
            bool temOutroRepresentante = false;

            // Verificar se algum outro representante gerencia este condomínio
            for (final outroRep in outrosRepresentantes) {
              final outrosCondominios =
                  outroRep['condominios_selecionados'] as List<dynamic>?;
              if (outrosCondominios != null &&
                  outrosCondominios.contains(condominioId)) {
                temOutroRepresentante = true;
                break;
              }
            }

            // Se não há outro representante, o condomínio fica sem representante
            // (isso pode ser uma regra de negócio que precisa ser ajustada conforme necessário)
            if (!temOutroRepresentante) {
              print(
                'Aviso: Condomínio $condominioId ficará sem representante após a exclusão',
              );
            }
          }
        }
      }

      // Deletar o representante
      await client.from('representantes').delete().eq('id', representanteId);

      print('Representante $representanteId deletado com sucesso');
    } catch (e) {
      print('Erro ao deletar representante com liberação de condomínios: $e');
      rethrow;
    }
  }

  /// Busca uma unidade por ID
  static Future<Map<String, dynamic>?> getUnidadeById(String id) async {
    try {
      final response = await client
          .from('unidades')
          .select()
          .eq('id', id)
          .single();

      return response;
    } catch (e) {
      print('Erro ao buscar unidade por ID: $e');
      rethrow;
    }
  }

  /// Faz upload da foto de perfil do proprietário para o Storage e atualiza a URL no banco
  static Future<Map<String, dynamic>?> uploadProprietarioFotoPerfil(
    String proprietarioId,
    File imageFile,
  ) async {
    try {
      // Detectar a extensão do arquivo
      final fileName = imageFile.path.split('/').last;
      final fileExtension = fileName.split('.').last.toLowerCase();
      
      // Validar extensão
      final validExtensions = ['jpg', 'jpeg', 'png', 'gif', 'webp'];
      final extension = validExtensions.contains(fileExtension) ? fileExtension : 'jpg';

      // Gerar nome único para o arquivo
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final storagePath = 'proprietarios/$proprietarioId/$timestamp.$extension';

      // Fazer upload para o Storage
      final bytes = await imageFile.readAsBytes();
      await client.storage.from('fotos_perfil').uploadBinary(storagePath, bytes);

      // Obter a URL pública
      final imageUrl =
          client.storage.from('fotos_perfil').getPublicUrl(storagePath);

      // Atualizar a URL no banco de dados
      final response = await client
          .from('proprietarios')
          .update({'foto_perfil': imageUrl})
          .eq('id', proprietarioId)
          .select()
          .single();

      return response;
    } catch (e) {
      print('Erro ao fazer upload da foto de perfil do proprietário: $e');
      rethrow;
    }
  }

  /// Faz upload da foto de perfil do inquilino para o Storage e atualiza a URL no banco
  static Future<Map<String, dynamic>?> uploadInquilinoFotoPerfil(
    String inquilinoId,
    File imageFile,
  ) async {
    try {
      // Detectar a extensão do arquivo
      final fileName = imageFile.path.split('/').last;
      final fileExtension = fileName.split('.').last.toLowerCase();
      
      // Validar extensão
      final validExtensions = ['jpg', 'jpeg', 'png', 'gif', 'webp'];
      final extension = validExtensions.contains(fileExtension) ? fileExtension : 'jpg';

      // Gerar nome único para o arquivo
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final storagePath = 'inquilinos/$inquilinoId/$timestamp.$extension';

      // Fazer upload para o Storage
      final bytes = await imageFile.readAsBytes();
      await client.storage.from('fotos_perfil').uploadBinary(storagePath, bytes);

      // Obter a URL pública
      final imageUrl =
          client.storage.from('fotos_perfil').getPublicUrl(storagePath);

      // Atualizar a URL no banco de dados
      final response = await client
          .from('inquilinos')
          .update({'foto_perfil': imageUrl})
          .eq('id', inquilinoId)
          .select()
          .single();

      return response;
    } catch (e) {
      print('Erro ao fazer upload da foto de perfil do inquilino: $e');
      rethrow;
    }
  }

  /// Gera uma URL assinada (signed URL) temporária para um arquivo no Storage
  /// A URL expira após o tempo especificado (padrão: 1 hora)
  static Future<String?> getSignedUrl({
    required String bucket,
    required String path,
    int expiresIn = 3600, // 1 hora em segundos
  }) async {
    try {
      final signedUrl = await client.storage
          .from(bucket)
          .createSignedUrl(path, expiresIn);
      
      print('✅ Signed URL gerada para: $path (expira em ${expiresIn}s)');
      return signedUrl;
    } catch (e) {
      print('❌ Erro ao gerar signed URL: $e');
      return null;
    }
  }

  /// Gera uma URL assinada para documentos com tempo de expiração
  static Future<String?> getSignedDocumentUrl(
    String documentoUrl, {
    int expiresIn = 3600, // 1 hora
  }) async {
    try {
      print('📋 [SIGNED URL] URL original: $documentoUrl');
      
      // Extrair o caminho do arquivo da URL pública
      // URL formato: https://tukpgefrddfchmvtiujp.supabase.co/storage/v1/object/public/documentos/...
      final uri = Uri.parse(documentoUrl);
      final pathSegments = uri.pathSegments;
      
      print('📋 [SIGNED URL] Path segments: $pathSegments');
      print('📋 [SIGNED URL] Total segments: ${pathSegments.length}');
      
      // Encontrar o índice de 'public' e pegar tudo após ele
      final publicIndex = pathSegments.indexOf('public');
      print('📋 [SIGNED URL] Index de "public": $publicIndex');
      
      if (publicIndex == -1 || publicIndex >= pathSegments.length - 1) {
        print('❌ [SIGNED URL] Não foi possível encontrar "public" ou está no final');
        return null;
      }
      
      // Reconstruir o caminho sem 'public'
      final filePath = pathSegments.skip(publicIndex + 2).join('/');
      final bucketName = pathSegments[publicIndex + 1]; // 'documentos', 'qr_codes', etc
      
      print('📋 [SIGNED URL] Bucket: $bucketName');
      print('📋 [SIGNED URL] File path: $filePath');
      
      // Verificar se o arquivo existe antes de tentar gerar signed URL
      try {
        await client.storage.from(bucketName).list(path: filePath);
        print('✅ [SIGNED URL] Arquivo encontrado no storage');
      } catch (e) {
        print('⚠️ [SIGNED URL] Não foi possível verificar arquivo: $e');
        // Continuar mesmo assim, pois o arquivo pode existir
      }
      
      // Gerar signed URL
      final signedUrl = await client.storage
          .from(bucketName)
          .createSignedUrl(filePath, expiresIn);
      
      print('✅ [SIGNED URL] Signed URL gerada com sucesso!');
      print('📋 [SIGNED URL] Expira em: ${expiresIn}s');
      return signedUrl;
    } catch (e) {
      print('❌ [SIGNED URL] Erro ao processar URL de documento: $e');
      print('❌ [SIGNED URL] Tipo de erro: ${e.runtimeType}');
      return null;
    }
  }
}

