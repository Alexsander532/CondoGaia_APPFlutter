import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/password_generator.dart';

class SupabaseService {
  static const String supabaseUrl = 'https://tukpgefrddfchmvtiujp.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InR1a3BnZWZyZGRmY2htdnRpdWpwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTI1MTg1NTEsImV4cCI6MjA2ODA5NDU1MX0.dZ1Pna1_dwelIJTlhrSN0iiH5nhuzL0y4p6llYJsLp8';

  static SupabaseClient get client => Supabase.instance.client;
  
  static get nomeCondominio => null;

  /// Inicializa o Supabase
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }

  /// Insere um novo condomínio na tabela condominios
  static Future<Map<String, dynamic>?> insertCondominio(Map<String, dynamic> condominioData) async {
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
  static Future<Map<String, dynamic>?> updateCondominio(String id, Map<String, dynamic> condominioData) async {
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
      await client
          .from('condominios')
          .delete()
          .eq('id', id);
    } catch (e) {
      print('Erro ao deletar condomínio: $e');
      rethrow;
    }
  }

  /// Insere um novo representante na tabela representantes
  static Future<Map<String, dynamic>?> saveRepresentante(Map<String, dynamic> representanteData) async {
    try {
      // Gerar senha automática baseada no nome do representante
      final nomeCompleto = representanteData['nome_completo'] as String? ?? '';
      print('DEBUG: Nome completo para geração de senha: "$nomeCompleto"');
      
      final senhaGerada = PasswordGenerator.generatePasswordFromName(nomeCompleto);
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
  static Future<Map<String, dynamic>?> authenticateRepresentante(String cpf, String senha) async {
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
  static Future<Map<String, dynamic>?> updateRepresentanteSenha(String id, String novaSenha) async {
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
      
      // Extrai cidades únicas e remove duplicatas
      final cidades = response
          .map((item) => item['cidade'] as String)
          .where((cidade) => cidade.isNotEmpty)
          .toSet()
          .toList();
      
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
      
      // Extrai cidades únicas e remove duplicatas
      final cidades = response
          .map((item) => item['cidade'] as String)
          .where((cidade) => cidade.isNotEmpty)
          .toSet()
          .toList();
      
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
      var query = client
          .from('representantes')
          .select('*');
      
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
          'cpf.ilike.%$textoPesquisa%'
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
  static Future<List<Map<String, dynamic>>> pesquisarRepresentantesComCondominios({
    String? uf,
    String? cidade,
    String? textoPesquisa,
  }) async {
    try {
      // Busca representantes com seus condomínios usando JOIN
      var query = client
          .from('representantes')
          .select('''
            *,
            condominios!condominios_representante_id_fkey(
              *
            )
          ''');
      
      if (uf != null && uf.isNotEmpty) {
        query = query.eq('uf', uf);
      }
      
      if (cidade != null && cidade.isNotEmpty) {
        query = query.eq('cidade', cidade);
      }
      
      if (textoPesquisa != null && textoPesquisa.isNotEmpty) {
        query = query.or(
          'nome_completo.ilike.%$textoPesquisa%,'
          'cpf.ilike.%$textoPesquisa%'
        );
      }
      
      final response = await query.order('created_at', ascending: false);
      
      // Processa os resultados para criar uma linha por condomínio
      final resultados = <Map<String, dynamic>>[];
      
      for (final representante in response) {
        final condominios = representante['condominios'] as List<dynamic>? ?? [];
        
        if (condominios.isEmpty) {
          // Representante sem condomínios
          final resultado = Map<String, dynamic>.from(representante);
          resultado.remove('condominios'); // Remove a chave condominios
          resultado['nome_condominio'] = 'Sem condomínio';
          resultado['cnpj'] = 'N/A';
          resultado['condominio_cidade'] = 'N/A';
          resultado['condominio_estado'] = 'N/A';
          
          // Aplica filtro de texto se necessário
          if (textoPesquisa == null || textoPesquisa.isEmpty || 
              _contemTexto(resultado, textoPesquisa)) {
            resultados.add(resultado);
          }
        } else {
          // Para cada condomínio associado
          for (final condominio in condominios) {
            final resultado = Map<String, dynamic>.from(representante);
            resultado.remove('condominios'); // Remove a chave condominios
            
            // Adiciona todos os campos do condomínio ao resultado
            resultado['condominio_id'] = condominio['id'];
            resultado['nome_condominio'] = condominio['nome_condominio'];
            resultado['cnpj'] = condominio['cnpj'];
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
            resultado['instituicao_financeiro_condominio'] = condominio['instituicao_financeiro_condominio'];
            resultado['token_financeiro_condominio'] = condominio['token_financeiro_condominio'];
            resultado['instituicao_financeiro_unidade'] = condominio['instituicao_financeiro_unidade'];
            resultado['token_financeiro_unidade'] = condominio['token_financeiro_unidade'];
            
            // Aplica filtro de texto se necessário
            if (textoPesquisa == null || textoPesquisa.isEmpty || 
                _contemTexto(resultado, textoPesquisa)) {
              resultados.add(resultado);
            }
          }
        }
      }
      
      return resultados;
    } catch (e) {
      print('Erro ao pesquisar representantes com condomínios: $e');
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
  static Future<List<Map<String, dynamic>>> getRepresentantesByCondominio(String condominioId) async {
    try {
      // Busca o condomínio e seu representante associado
      final condominioResponse = await client
          .from('condominios')
          .select('''
            *,
            representantes!condominios_representante_id_fkey(*)
          ''')
          .eq('id', condominioId)
          .single();
      
      final representante = condominioResponse['representantes'];
      if (representante != null) {
        return [representante];
      } else {
        return [];
      }
    } catch (e) {
      print('Erro ao buscar representantes do condomínio: $e');
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
  static Future<Map<String, dynamic>?> associarRepresentanteCondominio(String condominioId, String representanteId) async {
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
  static Future<Map<String, dynamic>?> desassociarRepresentanteCondominio(String condominioId) async {
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
  static Future<List<Map<String, dynamic>>> getCondominiosByRepresentante(String representanteId) async {
    try {
      final response = await client
          .from('condominios')
          .select('*')
          .eq('representante_id', representanteId)
          .order('nome_condominio');
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Erro ao buscar condomínios do representante: $e');
      rethrow;
    }
  }

  /// Busca condomínios disponíveis para associação a um representante específico
  /// Retorna condomínios sem representante + condomínios já associados ao representante atual
  static Future<List<Map<String, dynamic>>> getCondominiosDisponiveisParaRepresentante(String representanteId) async {
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
  static Future<List<Map<String, dynamic>>> transferirCondominios(String representanteOrigemId, String representanteDestinoId) async {
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
  static Future<String?> uploadImage(File imageFile, String bucket, String fileName) async {
    try {
      final bytes = await imageFile.readAsBytes();
      
      final response = await client.storage
          .from(bucket)
          .uploadBinary(fileName, bytes);
      
      if (response.isNotEmpty) {
        // Retorna a URL pública da imagem
        final publicUrl = client.storage
            .from(bucket)
            .getPublicUrl(fileName);
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
  static Future<Map<String, dynamic>?> updateRepresentanteFotoPerfil(String representanteId, String fotoBase64) async {
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
  static Future<Map<String, dynamic>?> removeRepresentanteFotoPerfil(String representanteId) async {
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

  static bool _contemTexto(Map<String, dynamic> item, String texto) {
    final textoLower = texto.toLowerCase();
    return (item['nome_completo']?.toString().toLowerCase().contains(textoLower) ?? false) ||
           (item['nome_condominio']?.toString().toLowerCase().contains(textoLower) ?? false) ||
           (item['cnpj']?.toString().toLowerCase().contains(textoLower) ?? false) ||
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
  static Future<List<Map<String, dynamic>>> getPastasDocumentos(String condominioId) async {
    try {
      final response = await client
          .from('documentos')
          .select()
          .eq('condominio_id', condominioId)
          .eq('tipo', 'pasta')
          .order('created_at', ascending: false);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Erro ao buscar pastas de documentos: $e');
      rethrow;
    }
  }

  /// Buscar arquivos de uma pasta específica
  static Future<List<Map<String, dynamic>>> getArquivosPasta(String pastaId) async {
    try {
      final response = await client
          .from('documentos')
          .select()
          .eq('pasta_id', pastaId)
          .eq('tipo', 'arquivo')
          .order('created_at', ascending: false);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Erro ao buscar arquivos da pasta: $e');
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
    File arquivo,
    String nomeArquivo,
    String condominioId,
  ) async {
    try {
      final bytes = await arquivo.readAsBytes();
      final sanitizedName = _sanitizeFileName(nomeArquivo);
      final fileName = '${condominioId}/${DateTime.now().millisecondsSinceEpoch}_$sanitizedName';
      
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
        .replaceAll(' ', '_')  // Substitui espaços por underscore
        .replaceAll(RegExp(r'[^\w\-_\.]'), '')  // Remove caracteres especiais, mantém apenas letras, números, hífen, underscore e ponto
        .replaceAll(RegExp(r'_{2,}'), '_');  // Substitui múltiplos underscores por um único
    
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
      final fileName = '${condominioId}/${DateTime.now().millisecondsSinceEpoch}_$sanitizedName';
      
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
  static Future<List<Map<String, dynamic>>> getBalancetes(String condominioId) async {
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
      await client
          .from('balancetes')
          .delete()
          .eq('id', balanceteId);
    } catch (e) {
      print('Erro ao deletar balancete: $e');
      rethrow;
    }
  }

  /// Upload de balancete para o storage
  static Future<String?> uploadBalancete(
    File arquivo,
    String nomeArquivo,
    String condominioId,
    String mes,
    String ano,
  ) async {
    try {
      final bytes = await arquivo.readAsBytes();
      final sanitizedName = _sanitizeFileName(nomeArquivo);
      final fileName = '${condominioId}/balancetes/${ano}_${mes}_${DateTime.now().millisecondsSinceEpoch}_$sanitizedName';
      
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
      print('Erro ao fazer upload do balancete: $e');
      rethrow;
    }
  }

  /// Download de arquivo do storage
  static Future<Uint8List?> downloadArquivo(String url) async {
    try {
      // Extrair o caminho do arquivo da URL
      final uri = Uri.parse(url);
      final pathSegments = uri.pathSegments;
      
      // Encontrar o índice do bucket 'documentos'
      final bucketIndex = pathSegments.indexOf('documentos');
      if (bucketIndex == -1 || bucketIndex >= pathSegments.length - 1) {
        throw Exception('URL inválida para download');
      }
      
      // Construir o caminho do arquivo no storage
      final filePath = pathSegments.sublist(bucketIndex + 1).join('/');
      
      // Fazer download do arquivo
      final response = await client.storage
          .from('documentos')
          .download(filePath);
      
      return response;
    } catch (e) {
      print('Erro ao fazer download do arquivo: $e');
      rethrow;
    }
  }

  /// Busca todos os representantes com dados dos condomínios associados para exibição na tela do administrador
  static Future<List<Map<String, dynamic>>> getRepresentantesComCondominiosParaAdmin() async {
    try {
      // Busca representantes com seus condomínios usando JOIN
      final response = await client
          .from('representantes')
          .select('''
            id,
            nome_completo,
            email,
            senha_acesso,
            cpf,
            telefone,
            celular,
            cidade,
            uf,
            created_at,
            condominios!condominios_representante_id_fkey(
              id,
              nome_condominio,
              cnpj,
              cidade,
              estado
            )
          ''')
          .order('created_at', ascending: false);
      
      // Processa os resultados para criar uma estrutura mais amigável
      final resultados = <Map<String, dynamic>>[];
      
      for (final representante in response) {
        final condominios = representante['condominios'] as List<dynamic>? ?? [];
        
        // Cria um mapa com os dados do representante e seus condomínios
        final representanteData = {
          'id': representante['id'],
          'nome_completo': representante['nome_completo'],
          'email': representante['email'],
          'senha_acesso': representante['senha_acesso'],
          'cpf': representante['cpf'],
          'telefone': representante['telefone'],
          'celular': representante['celular'],
          'cidade': representante['cidade'],
          'uf': representante['uf'],
          'created_at': representante['created_at'],
          'condominios': condominios,
          'total_condominios': condominios.length,
        };
        
        resultados.add(representanteData);
      }
      
      return resultados;
    } catch (e) {
      print('Erro ao buscar representantes com condomínios para admin: $e');
      rethrow;
    }
  }

  /// Atualiza um representante completo
  static Future<Map<String, dynamic>?> updateRepresentante(String id, Map<String, dynamic> data) async {
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

  /// Exclui um condomínio e atualiza os representantes relacionados
  static Future<void> deleteCondominioComAtualizacaoRepresentantes(String condominioId) async {
    try {
      // Primeiro, busca todos os representantes que têm este condomínio associado
      final representantesResponse = await client
          .from('representantes')
          .select('id, condominios_selecionados')
          .not('condominios_selecionados', 'is', null);

      // Atualiza a lista de condomínios selecionados de cada representante
      for (final representante in representantesResponse) {
        final condominiosSelecionados = representante['condominios_selecionados'] as List<dynamic>? ?? [];
        final condominiosAtualizados = condominiosSelecionados
            .where((id) => id.toString() != condominioId)
            .toList();

        // Atualiza o representante com a nova lista
        await client
            .from('representantes')
            .update({'condominios_selecionados': condominiosAtualizados})
            .eq('id', representante['id']);
      }

      // Depois exclui o condomínio
      await client
          .from('condominios')
          .delete()
          .eq('id', condominioId);
    } catch (e) {
      print('Erro ao excluir condomínio e atualizar representantes: $e');
      rethrow;
    }
  }

  /// Exclui um representante e libera os condomínios associados
  static Future<void> deleteRepresentanteComLiberacaoCondominios(String representanteId) async {
    try {
      // Primeiro, libera todos os condomínios associados ao representante
      await client
          .from('condominios')
          .update({'representante_id': null})
          .eq('representante_id', representanteId);

      // Depois exclui o representante
      await client
          .from('representantes')
          .delete()
          .eq('id', representanteId);
    } catch (e) {
      print('Erro ao excluir representante e liberar condomínios: $e');
      rethrow;
    }
  }
}