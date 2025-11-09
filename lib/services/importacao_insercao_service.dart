import 'package:supabase_flutter/supabase_flutter.dart';

/// Resultado de uma operação de inserção
class ResultadoInsercao {
  final bool sucesso;
  final String? id;
  final String? erro;
  final int? linhaNumero;

  ResultadoInsercao({
    required this.sucesso,
    this.id,
    this.erro,
    this.linhaNumero,
  });

  @override
  String toString() => sucesso
      ? 'Sucesso: $id'
      : 'Erro (linha $linhaNumero): $erro';
}

/// Service de inserção de dados para importação
/// Responsável por inserir unidades, proprietários, inquilinos e imobiliárias
/// respeitando a ordem e lidando com erros por linha
class ImportacaoInsercaoService {
  static SupabaseClient get _client => Supabase.instance.client;

  /// Busca unidade existente ou cria uma nova
  /// Retorna o ID da unidade (novo ou existente)
  static Future<ResultadoInsercao> buscarOuCriarUnidade(
    Map<String, dynamic> dadosUnidade,
  ) async {
    try {
      final numero = dadosUnidade['numero'] as String;
      final condominioId = dadosUnidade['condominio_id'] as String;
      final linhaNumero = dadosUnidade['_linhaNumero'] as int?;

      // 1. Tentar buscar unidade existente
      try {
        final existente = await _client
            .from('unidades')
            .select('id')
            .eq('numero', numero)
            .eq('condominio_id', condominioId)
            .single();

        print('✅ Unidade existente encontrada: ${existente['id']}');
        return ResultadoInsercao(
          sucesso: true,
          id: existente['id'] as String,
          linhaNumero: linhaNumero,
        );
      } on PostgrestException catch (e) {
        if (e.code == 'PGRST116') {
          // Não encontrado, vamos criar
          print('📝 Unidade não encontrada, criando nova...');
        } else {
          throw e;
        }
      }

      // 2. Criar nova unidade
      final dadosLimpos = Map<String, dynamic>.from(dadosUnidade);
      dadosLimpos.remove('_linhaNumero'); // Remover campo temporário

      final response = await _client
          .from('unidades')
          .insert(dadosLimpos)
          .select('id')
          .single();

      final unidadeId = response['id'] as String;
      print('✅ Unidade criada com sucesso: $unidadeId');

      return ResultadoInsercao(
        sucesso: true,
        id: unidadeId,
        linhaNumero: linhaNumero,
      );
    } catch (e) {
      print('❌ Erro ao buscar/criar unidade: $e');
      return ResultadoInsercao(
        sucesso: false,
        erro: 'Erro ao criar unidade: ${e.toString()}',
        linhaNumero: dadosUnidade['_linhaNumero'] as int?,
      );
    }
  }

  /// Insere um proprietário
  /// Requer unidade_id da unidade criada na etapa anterior
  static Future<ResultadoInsercao> inserirProprietario(
    Map<String, dynamic> dadosProprietario,
    String unidadeId,
  ) async {
    try {
      final linhaNumero = dadosProprietario['_linhaNumero'] as int?;

      // Preparar dados
      final dados = Map<String, dynamic>.from(dadosProprietario);
      dados.remove('_linhaNumero'); // Remover campo temporário
      dados['unidade_id'] = unidadeId;

      // Inserir
      final response = await _client
          .from('proprietarios')
          .insert(dados)
          .select('id')
          .single();

      final proprietarioId = response['id'] as String;
      print('✅ Proprietário inserido com sucesso: $proprietarioId');

      return ResultadoInsercao(
        sucesso: true,
        id: proprietarioId,
        linhaNumero: linhaNumero,
      );
    } catch (e) {
      print('❌ Erro ao inserir proprietário: $e');
      return ResultadoInsercao(
        sucesso: false,
        erro: 'Erro ao inserir proprietário: ${e.toString()}',
        linhaNumero: dadosProprietario['_linhaNumero'] as int?,
      );
    }
  }

  /// Insere um inquilino (opcional)
  /// Requer unidade_id da unidade criada na etapa anterior
  static Future<ResultadoInsercao?> inserirInquilino(
    Map<String, dynamic>? dadosInquilino,
    String unidadeId,
  ) async {
    // Se não há dados de inquilino, retorna null
    if (dadosInquilino == null) return null;

    try {
      final linhaNumero = dadosInquilino['_linhaNumero'] as int?;

      // Preparar dados
      final dados = Map<String, dynamic>.from(dadosInquilino);
      dados.remove('_linhaNumero'); // Remover campo temporário
      dados['unidade_id'] = unidadeId;

      // Inserir
      final response = await _client
          .from('inquilinos')
          .insert(dados)
          .select('id')
          .single();

      final inquilinoId = response['id'] as String;
      print('✅ Inquilino inserido com sucesso: $inquilinoId');

      return ResultadoInsercao(
        sucesso: true,
        id: inquilinoId,
        linhaNumero: linhaNumero,
      );
    } catch (e) {
      print('❌ Erro ao inserir inquilino: $e');
      return ResultadoInsercao(
        sucesso: false,
        erro: 'Erro ao inserir inquilino: ${e.toString()}',
        linhaNumero: dadosInquilino['_linhaNumero'] as int?,
      );
    }
  }

  /// Insere uma imobiliária (opcional)
  /// Não depende de outras entidades
  static Future<ResultadoInsercao?> inserirImobiliaria(
    Map<String, dynamic>? dadosImobiliaria,
  ) async {
    // Se não há dados de imobiliária, retorna null
    if (dadosImobiliaria == null) return null;

    try {
      final linhaNumero = dadosImobiliaria['_linhaNumero'] as int?;

      // Preparar dados
      final dados = Map<String, dynamic>.from(dadosImobiliaria);
      dados.remove('_linhaNumero'); // Remover campo temporário

      // Verificar se já existe
      try {
        final cnpj = dados['cnpj'] as String;
        final condominioId = dados['condominio_id'] as String;

        final existente = await _client
            .from('imobiliarias')
            .select('id')
            .eq('cnpj', cnpj)
            .eq('condominio_id', condominioId)
            .single();

        print('✅ Imobiliária já existente: ${existente['id']}');
        return ResultadoInsercao(
          sucesso: true,
          id: existente['id'] as String,
          linhaNumero: linhaNumero,
        );
      } on PostgrestException catch (e) {
        if (e.code == 'PGRST116') {
          // Não encontrada, vamos criar
          print('📝 Imobiliária não encontrada, criando nova...');
        } else {
          throw e;
        }
      }

      // Inserir nova imobiliária
      final response = await _client
          .from('imobiliarias')
          .insert(dados)
          .select('id')
          .single();

      final imobiliarioId = response['id'] as String;
      print('✅ Imobiliária inserida com sucesso: $imobiliarioId');

      return ResultadoInsercao(
        sucesso: true,
        id: imobiliarioId,
        linhaNumero: linhaNumero,
      );
    } catch (e) {
      print('❌ Erro ao inserir imobiliária: $e');
      return ResultadoInsercao(
        sucesso: false,
        erro: 'Erro ao inserir imobiliária: ${e.toString()}',
        linhaNumero: dadosImobiliaria['_linhaNumero'] as int?,
      );
    }
  }

  /// Processa uma linha completa: mapeia, valida e insere na ordem correta
  /// Retorna resultado com sucesso/erro e senhas geradas
  static Future<Map<String, dynamic>> processarLinhaCompleta(
    Map<String, dynamic> dadosLinhaFormatada,
  ) async {
    final linhaNumero = dadosLinhaFormatada['linhaNumero'] as int;
    final unidadeDados = dadosLinhaFormatada['unidade'] as Map<String, dynamic>;
    final proprietarioDados =
        dadosLinhaFormatada['proprietario'] as Map<String, dynamic>;
    final inquilinoDados =
        dadosLinhaFormatada['inquilino'] as Map<String, dynamic>?;
    final imobiliariaDados =
        dadosLinhaFormatada['imobiliaria'] as Map<String, dynamic>?;
    final senhasGeradas = dadosLinhaFormatada['senhas'] as Map<String, dynamic>;

    try {
      print('\n═══════════════════════════════════════════════════');
      print('📊 PROCESSANDO LINHA $linhaNumero');
      print('═══════════════════════════════════════════════════');

      // 1. Buscar ou criar unidade
      print('\n1️⃣  Processando UNIDADE...');
      unidadeDados['_linhaNumero'] = linhaNumero;
      final resultUnidade = await buscarOuCriarUnidade(unidadeDados);

      if (!resultUnidade.sucesso) {
        print('❌ Falha ao processar unidade');
        return {
          'linhaNumero': linhaNumero,
          'sucesso': false,
          'erro': resultUnidade.erro,
          'senhas': null,
        };
      }

      final unidadeId = resultUnidade.id;

      // 2. Inserir proprietário
      print('\n2️⃣  Processando PROPRIETÁRIO...');
      proprietarioDados['_linhaNumero'] = linhaNumero;
      final resultProprietario = await inserirProprietario(
        proprietarioDados,
        unidadeId!,
      );

      if (!resultProprietario.sucesso) {
        print('❌ Falha ao processar proprietário');
        return {
          'linhaNumero': linhaNumero,
          'sucesso': false,
          'erro': resultProprietario.erro,
          'senhas': null,
        };
      }

      // 3. Inserir inquilino (se houver)
      print('\n3️⃣  Processando INQUILINO...');
      if (inquilinoDados != null) {
        inquilinoDados['_linhaNumero'] = linhaNumero;
      }
      final resultInquilino = await inserirInquilino(
        inquilinoDados,
        unidadeId,
      );

      // 4. Inserir imobiliária (se houver)
      print('\n4️⃣  Processando IMOBILIÁRIA...');
      if (imobiliariaDados != null) {
        imobiliariaDados['_linhaNumero'] = linhaNumero;
      }
      final resultImobiliaria = await inserirImobiliaria(imobiliariaDados);

      print('\n✅ LINHA $linhaNumero PROCESSADA COM SUCESSO!\n');

      return {
        'linhaNumero': linhaNumero,
        'sucesso': true,
        'erro': null,
        'ids': {
          'unidade': unidadeId,
          'proprietario': resultProprietario.id,
          'inquilino': resultInquilino?.id,
          'imobiliaria': resultImobiliaria?.id,
        },
        'senhas': senhasGeradas,
      };
    } catch (e) {
      print('\n❌ ERRO AO PROCESSAR LINHA $linhaNumero: $e\n');
      return {
        'linhaNumero': linhaNumero,
        'sucesso': false,
        'erro': 'Erro inesperado: ${e.toString()}',
        'senhas': null,
      };
    }
  }
}
