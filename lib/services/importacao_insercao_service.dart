import 'package:supabase_flutter/supabase_flutter.dart';
import 'qr_code_generation_service.dart';

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

  /// Busca bloco existente ou cria um novo
  static Future<void> buscarOuCriarBloco(String nomeBloco, String condominioId) async {
    try {
      // 1. Tentar buscar bloco existente
      final existente = await _client
          .from('blocos')
          .select('id')
          .eq('nome', nomeBloco)
          .eq('condominio_id', condominioId)
          .limit(1)
          .maybeSingle();

      if (existente != null) {
        print('✅ Bloco "$nomeBloco" já existe: ${existente['id']}');
        return;
      }

      // 2. Criar novo bloco
      print('📝 Bloco "$nomeBloco" não encontrado, criando novo...');
      
      // Obter próxima ordem (simplificado, pode ser otimizado)
      // Aqui apenas inserimos, assumindo que ordem pode ser nula ou default,
      // ou se necessário, buscamos max ordem.
      // Para simplificar, vou deixar ordem como 0 ou sequencial simples se o banco permitir.
      // Se 'ordem' for obrigatório, preciso calcular.
      
      // Consultar maior ordem atual
      final maxOrdemResult = await _client
          .from('blocos')
          .select('ordem')
          .eq('condominio_id', condominioId)
          .order('ordem', ascending: false)
          .limit(1)
          .maybeSingle();
          
      final proximaOrdem = (maxOrdemResult != null && maxOrdemResult['ordem'] != null)
          ? (maxOrdemResult['ordem'] as int) + 1
          : 1;

      final novoBloco = {
        'nome': nomeBloco,
        'codigo': nomeBloco, // ✅ Adicionado campo obrigatório
        'condominio_id': condominioId,
        'ordem': proximaOrdem,
        'ativo': true,
      };

      final response = await _client
          .from('blocos')
          .insert(novoBloco)
          .select('id')
          .single();

      print('✅ Bloco "$nomeBloco" criado com sucesso: ${response['id']}');

    } catch (e) {
      print('❌ Erro ao buscar/criar bloco "$nomeBloco": $e');
      // Não lançar erro para não parar a importação da unidade, 
      // mas logar. Se o bloco for obrigatório, a query da unidade pode falhar depois 
      // dependendo de como o backend funciona, mas aqui apenas tentamos garantir.
      throw e; // Lançar para parar se for crítico
    }
  }

  /// Busca unidade existente ou cria uma nova
  /// Retorna o ID da unidade (novo ou existente)
  static Future<ResultadoInsercao> buscarOuCriarUnidade(
    Map<String, dynamic> dadosUnidade,
  ) async {
    try {
      final numero = dadosUnidade['numero'] as String;
      final condominioId = dadosUnidade['condominio_id'] as String;
      final bloco = dadosUnidade['bloco'] as String? ?? ''; // ✅ NOVO: Considerar bloco
      final linhaNumero = dadosUnidade['_linhaNumero'] as int?;

      print('🔍 Buscando unidade: numero="$numero", bloco="$bloco", condominio="$condominioId"');

      // 1. Tentar buscar unidade existente (agora considerando bloco!)
      try {
        final existente = await _client
            .from('unidades')
            .select('id, qr_code_url') // Buscar qr_code_url também
            .eq('numero', numero)
            .eq('condominio_id', condominioId)
            .eq('bloco', bloco) // ✅ CORREÇÃO: Filtrar também por bloco
            .single();

        print('✅ Unidade existente encontrada: ${existente['id']} (bloco=$bloco)');

        // ✅ Verificar e gerar QR Code se faltar
        final existingUrl = existente['qr_code_url'] as String?;
        _gerarQRCodeSeNecessarioBackground(
          id: existente['id'] as String,
          tipo: 'unidade',
          tabelaNome: 'unidades',
          nome: numero,
          dados: {
            'id': existente['id'],
            'numero': numero,
            'bloco': bloco,
            'condominio_id': condominioId,
          },
          urlExistente: existingUrl,
        );

        return ResultadoInsercao(
          sucesso: true,
          id: existente['id'] as String,
          linhaNumero: linhaNumero,
        );
      } on PostgrestException catch (e) {
        if (e.code == 'PGRST116') {
          // Não encontrado, vamos criar
          print('📝 Unidade "$numero" (bloco="$bloco") não encontrada, criando nova...');
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

      // ✅ Gerar QR Code em background para Unidade (se necessário)
      _gerarQRCodeSeNecessarioBackground(
        id: unidadeId,
        tipo: 'unidade',
        tabelaNome: 'unidades',
        nome: numero, // Numero da unidade
        dados: {
          'id': unidadeId,
          'numero': numero,
          'bloco': bloco,
          'condominio_id': condominioId,
        },
        urlExistente: null, // Nova unidade não tem QR Code
      );

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

  /// Insere ou atualiza um proprietário
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

      String proprietarioId;
      final cpfCnpj = dados['cpf_cnpj'] as String?;

      // 1. Verificar se JÁ EXISTE proprietário com este CPF nesta Unidade
      Map<String, dynamic>? proprietarioExistenteNestaUnidade;
      
      if (cpfCnpj != null && cpfCnpj.isNotEmpty) {
        proprietarioExistenteNestaUnidade = await _client
            .from('proprietarios')
            .select('id, qr_code_url')
            .eq('unidade_id', unidadeId)
            .eq('cpf_cnpj', cpfCnpj)
            .limit(1)
            .maybeSingle();
      }

      if (proprietarioExistenteNestaUnidade != null) {
        // ✨ UPSERT: Atualizar registro existente
        proprietarioId = proprietarioExistenteNestaUnidade['id'] as String;
        print('♻️ Proprietário já existe na unidade (ID: $proprietarioId). Atualizando dados...');
        
        await _client
            .from('proprietarios')
            .update(dados)
            .eq('id', proprietarioId);
            
      } else {
        // 🆕 INSERÇÃO NOVA
        
        // ✅ MULTI-UNIT: Verificar se já existe proprietário com este CPF em OUTRA unidade para herdar credenciais
        if (cpfCnpj != null && cpfCnpj.isNotEmpty) {
          final existenteOutraUnidade = await _client
              .from('proprietarios')
              .select('email, senha_acesso, foto_perfil')
              .eq('cpf_cnpj', cpfCnpj)
              .limit(1)
              .maybeSingle();

          if (existenteOutraUnidade != null) {
            // ♻️ HERDAR credenciais existentes para manter login unificado
            dados['email'] = existenteOutraUnidade['email'] ?? dados['email'];
            dados['senha_acesso'] = existenteOutraUnidade['senha_acesso'] ?? dados['senha_acesso'];
            dados['foto_perfil'] = existenteOutraUnidade['foto_perfil'];
            print('♻️ CPF existente em outra unidade! Herdando credenciais de: ${existenteOutraUnidade['email']}');
          }
        }

        // Inserir novo
        final response = await _client
            .from('proprietarios')
            .insert(dados)
            .select('id')
            .single();

        proprietarioId = response['id'] as String;
        print('✅ Novo proprietário inserido com sucesso: $proprietarioId');
      }

      // ✅ Gerar QR Code em background (sempre, para garantir atualização)
      // ✅ Gerar QR Code em background (sempre verifica se precisa)
      // O método helper interno já verifica se a URL existe para evitar redundância
      _gerarQRCodeSeNecessarioBackground(
        id: proprietarioId,
        tipo: 'proprietario',
        tabelaNome: 'proprietarios',
        nome: dados['nome'] as String? ?? 'Proprietario',
        dados: {
          'id': proprietarioId,
          'nome': dados['nome'],
          'cpf': cpfCnpj != null && cpfCnpj.length >= 4 
              ? cpfCnpj.substring(cpfCnpj.length - 4) 
              : cpfCnpj,
          'email': dados['email'] ?? '',
          'telefone': dados['celular'] ?? dados['telefone'] ?? '',
          'condominio_id': dados['condominio_id'] ?? '',
        },
        urlExistente: proprietarioExistenteNestaUnidade?['qr_code_url'] as String?,
      );

      return ResultadoInsercao(
        sucesso: true,
        id: proprietarioId,
        linhaNumero: linhaNumero,
      );
    } catch (e) {
      print('❌ Erro ao inserir/atualizar proprietário: $e');
      return ResultadoInsercao(
        sucesso: false,
        erro: 'Erro ao processar proprietário: ${e.toString()}',
        linhaNumero: dadosProprietario['_linhaNumero'] as int?,
      );
    }
  }



  /// Insere ou atualiza um inquilino (opcional)
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
      
      String inquilinoId;
      final cpfCnpj = dados['cpf_cnpj'] as String?;

      // 1. Verificar se JÁ EXISTE inquilino com este CPF nesta Unidade
      Map<String, dynamic>? inquilinoExistenteNestaUnidade;
      
      if (cpfCnpj != null && cpfCnpj.isNotEmpty) {
        inquilinoExistenteNestaUnidade = await _client
            .from('inquilinos')
            .select('id, qr_code_url')
            .eq('unidade_id', unidadeId)
            .eq('cpf_cnpj', cpfCnpj)
            .limit(1)
            .maybeSingle();
      }

      if (inquilinoExistenteNestaUnidade != null) {
        // ✨ UPSERT: Atualizar registro existente
        inquilinoId = inquilinoExistenteNestaUnidade['id'] as String;
        print('♻️ Inquilino já existe na unidade (ID: $inquilinoId). Atualizando dados...');
        
        await _client
            .from('inquilinos')
            .update(dados)
            .eq('id', inquilinoId);
            
      } else {
        // 🆕 INSERÇÃO NOVA
        final response = await _client
            .from('inquilinos')
            .insert(dados)
            .select('id')
            .single();

        inquilinoId = response['id'] as String;
        print('✅ Novo inquilino inserido com sucesso: $inquilinoId');
      }

      // ✅ Gerar QR Code em background
      // ✅ Gerar QR Code em background (se necessário)
      _gerarQRCodeSeNecessarioBackground(
        id: inquilinoId,
        tipo: 'inquilino',
        tabelaNome: 'inquilinos',
        nome: dados['nome'] as String? ?? 'Inquilino',
        dados: {
          'id': inquilinoId,
          'nome': dados['nome'],
          'cpf': cpfCnpj != null && cpfCnpj.length >= 4 
              ? cpfCnpj.substring(cpfCnpj.length - 4) 
              : cpfCnpj,
          'email': dados['email'] ?? '',
          'telefone': dados['celular'] ?? dados['telefone'] ?? '',
          'condominio_id': dados['condominio_id'] ?? '',
        },
        urlExistente: inquilinoExistenteNestaUnidade?['qr_code_url'] as String?,
      );

      return ResultadoInsercao(
        sucesso: true,
        id: inquilinoId,
        linhaNumero: linhaNumero,
      );
    } catch (e) {
      print('❌ Erro ao inserir/atualizar inquilino: $e');
      return ResultadoInsercao(
        sucesso: false,
        erro: 'Erro ao processar inquilino: ${e.toString()}',
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
            .select('id, qr_code_url')
            .eq('cnpj', cnpj)
            .eq('condominio_id', condominioId)
            .single();

        print('✅ Imobiliária já existente: ${existente['id']}');
        
        // ✅ Gerar QR Code se faltar
        final existingUrl = existente['qr_code_url'] as String?;
        _gerarQRCodeSeNecessarioBackground(
          id: existente['id'] as String,
          tipo: 'imobiliaria',
          tabelaNome: 'imobiliarias',
          nome: dados['nome_imobiliaria'] ?? 'Imobiliária',
          dados: {
            'id': existente['id'],
            'nome': dados['nome_imobiliaria'],
            'cnpj': cnpj,
            'condominio_id': condominioId,
          },
          urlExistente: existingUrl,
        );

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

      // ✅ Gerar QR Code em background
      _gerarQRCodeSeNecessarioBackground(
        id: imobiliarioId,
        tipo: 'imobiliaria',
        tabelaNome: 'imobiliarias',
        nome: dados['nome_imobiliaria'] ?? 'Imobiliária',
        dados: {
          'id': imobiliarioId,
          'nome': dados['nome_imobiliaria'],
          'cnpj': dados['cnpj'] ?? '',
          'condominio_id': dados['condominio_id'] ?? '',
        },
        urlExistente: null,
      );

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

      // 0. Garantir que o bloco existe (se informado)
      final nomeBloco = unidadeDados['bloco'] as String?;
      final condominioId = unidadeDados['condominio_id'] as String;
      
      if (nomeBloco != null && nomeBloco.isNotEmpty) {
        print('\n0️⃣  Verificando BLOCO "$nomeBloco"...');
        await buscarOuCriarBloco(nomeBloco, condominioId);
      }

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

  /// Helper para gerar QR Code em background apenas SE NECESSÁRIO
  static void _gerarQRCodeSeNecessarioBackground({
    required String id,
    required String tipo,
    required String tabelaNome,
    required String nome,
    required Map<String, dynamic> dados,
    required String? urlExistente,
  }) {
    if (urlExistente != null && urlExistente.isNotEmpty) {
      // 🛑 Já tem QR Code, não precisa gerar
      // print('⏭️ [$tipo] QR Code já existe, pulando geração.');
      return;
    }

    Future.delayed(const Duration(milliseconds: 300), () async {
      try {
        print('🔄 [Import] Iniciando geração de QR para $tipo: $nome');
        await QrCodeGenerationService.gerarESalvarQRCodeGenerico(
          tipo: tipo,
          id: id,
          nome: nome,
          tabelaNome: tabelaNome,
          dados: {
            ...dados,
            'data_criacao': DateTime.now().toIso8601String(),
          },
        );
      } catch (e) {
        print('❌ [Import] Erro ao gerar QR Code para $tipo ($nome): $e');
      }
    });
  }
}
