import 'package:dio/dio.dart';
import 'package:condogaiaapp/models/cidade.dart';

class IBGEService {
  // Mapa de UF para código IBGE
  static const Map<String, String> ufCodigoIbgeMap = {
    'AC': '12', // Acre
    'AL': '27', // Alagoas
    'AP': '16', // Amapá
    'AM': '13', // Amazonas
    'BA': '29', // Bahia
    'CE': '23', // Ceará
    'DF': '53', // Distrito Federal
    'ES': '32', // Espírito Santo
    'GO': '52', // Goiás
    'MA': '21', // Maranhão
    'MT': '51', // Mato Grosso
    'MS': '50', // Mato Grosso do Sul
    'MG': '31', // Minas Gerais
    'PA': '15', // Pará
    'PB': '25', // Paraíba
    'PR': '41', // Paraná
    'PE': '26', // Pernambuco
    'PI': '22', // Piauí
    'RJ': '33', // Rio de Janeiro
    'RN': '24', // Rio Grande do Norte
    'RS': '43', // Rio Grande do Sul
    'RO': '11', // Rondônia
    'RR': '14', // Roraima
    'SC': '42', // Santa Catarina
    'SP': '35', // São Paulo
    'SE': '28', // Sergipe
    'TO': '17', // Tocantins
  };

  // Cache de cidades já buscadas
  static final Map<String, List<Cidade>> _cidadesCache = {};

  /// Busca cidades de um estado (UF) na API do IBGE
  /// [uf] - Sigla do estado (ex: 'SP', 'RJ')
  /// Retorna lista de cidades ordenadas por nome
  static Future<List<Cidade>> buscarCidades(String uf) async {
    final ufUpperCase = uf.toUpperCase();
    print('🔵 [IBGEService] Iniciando busca de cidades para UF: $ufUpperCase');

    // Verifica se já está em cache
    if (_cidadesCache.containsKey(ufUpperCase)) {
      print('✅ [IBGEService] Cidades de $ufUpperCase encontradas em CACHE');
      print('📊 [IBGEService] Total de cidades em cache: ${_cidadesCache[ufUpperCase]!.length}');
      return _cidadesCache[ufUpperCase]!;
    }

    print('⏳ [IBGEService] Cache vazio, buscando na API IBGE...');

    try {
      // Obtém o código IBGE para o UF
      final codigoIbge = ufCodigoIbgeMap[ufUpperCase];
      print('🔍 [IBGEService] Procurando código IBGE para: $ufUpperCase');
      
      if (codigoIbge == null) {
        final erro = 'UF inválido: $ufUpperCase';
        print('❌ [IBGEService] $erro');
        throw Exception(erro);
      }
      
      print('✓ [IBGEService] Código IBGE encontrado: $codigoIbge');

      // Faz requisição para a API do IBGE
      final url =
          'https://servicodados.ibge.gov.br/api/v1/localidades/estados/$codigoIbge/municipios';
      print('🌐 [IBGEService] URL da API: $url');
      
      final dio = Dio();
      print('📤 [IBGEService] Enviando requisição HTTP GET...');
      
      final response = await dio.get(url).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          print('⏱️ [IBGEService] TIMEOUT: Requisição levou mais de 10 segundos');
          throw Exception('Timeout ao buscar cidades');
        },
      );

      print('📥 [IBGEService] Resposta recebida com status: ${response.statusCode}');

      if (response.statusCode == 200) {
        // Decodifica resposta JSON
        final List<dynamic> jsonResponse = response.data as List<dynamic>;
        print('📦 [IBGEService] JSON decodificado com sucesso');
        print('📊 [IBGEService] Total de municipios na resposta: ${jsonResponse.length}');

        // Converte para lista de Cidade e ordena por nome
        final cidades = jsonResponse
            .map((json) => Cidade.fromJson(json as Map<String, dynamic>))
            .toList();

        print('✅ [IBGEService] Convertendo ${cidades.length} cidades para objetos Cidade');

        cidades.sort((a, b) => a.nome.compareTo(b.nome));
        print('📋 [IBGEService] Primeiras 5 cidades: ${cidades.take(5).map((c) => c.nome).join(', ')}');

        // Armazena em cache
        _cidadesCache[ufUpperCase] = cidades;
        print('💾 [IBGEService] Cidades armazenadas em CACHE para reutilização');

        print('✨ [IBGEService] Busca concluída com sucesso! Total: ${cidades.length} cidades');
        return cidades;
      } else {
        final erro = 'Erro ao buscar cidades: ${response.statusCode}';
        print('❌ [IBGEService] $erro');
        throw Exception(erro);
      }
    } catch (e) {
      print('🔴 [IBGEService] ERRO GERAL: $e');
      print('📍 [IBGEService] Stack trace: ${StackTrace.current}');
      throw Exception('Erro ao buscar cidades do IBGE: $e');
    }
  }

  /// Filtra cidades por termo de busca
  /// [cidades] - Lista completa de cidades
  /// [termo] - Termo de busca (case-insensitive)
  /// Retorna apenas as cidades que contêm o termo no nome
  static List<Cidade> filtrarCidades(List<Cidade> cidades, String termo) {
    if (termo.isEmpty) {
      return cidades;
    }

    final termoLower = termo.toLowerCase();
    return cidades
        .where((cidade) => cidade.nome.toLowerCase().contains(termoLower))
        .toList();
  }

  /// Limpa o cache de cidades
  static void limparCache() {
    _cidadesCache.clear();
  }

  /// Limpa o cache para um UF específico
  static void limparCacheUF(String uf) {
    _cidadesCache.remove(uf.toUpperCase());
  }
}
