import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';

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
      final response = await client
          .from('representantes')
          .insert(representanteData)
          .select()
          .single();
      
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
              id,
              nome_condominio,
              cnpj,
              cidade,
              estado
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
            
            resultado['nome_condominio'] = condominio['nome_condominio'];
            resultado['cnpj'] = condominio['cnpj'];
            resultado['condominio_cidade'] = condominio['cidade'];
            resultado['condominio_estado'] = condominio['estado'];
            
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
}