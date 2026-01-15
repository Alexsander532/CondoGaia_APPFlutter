import 'dart:typed_data';
import 'package:condogaiaapp/models/importacao_row.dart';
import 'package:condogaiaapp/models/importacao_resultado.dart';
import 'package:condogaiaapp/models/importacao_entidades.dart';
import 'package:condogaiaapp/models/validador_importacao.dart';
import 'package:condogaiaapp/models/gerador_senha.dart';
import 'package:condogaiaapp/models/parseador_excel.dart';
import 'package:condogaiaapp/services/logger_importacao.dart';
import 'package:condogaiaapp/services/importacao_insercao_service.dart';

/// Service para importação de planilhas
/// Responsável por:
/// - Fazer parsing do arquivo Excel
/// - Validar dados
/// - Detectar duplicatas
/// - Mapear dados para entidades
class ImportacaoService {
  /// Faz o parsing completo de um arquivo Excel com validações
  /// Retorna uma lista de ImportacaoRow com validações já feitas
  static Future<List<ImportacaoRow>> parsarEValidarArquivo(
    Uint8List bytes, {
    Set<String> cpfsExistentesNoBanco = const {},
    Set<String> emailsExistenteNoBanco = const {},
    bool enableLogging = false,
  }) async {
    // 1. Parsing do arquivo
    final rows = await ParseadorExcel.parseExcel(bytes);

    if (enableLogging) {
      LoggerImportacao.logParsing(rows.length);
      for (int i = 0; i < rows.length; i++) {
        final row = rows[i];
        LoggerImportacao.logLinhaParseada(
          i + 2,
          row.bloco ?? '',
          row.unidade ?? '',
          row.proprietarioNomeCompleto ?? '',
          row.proprietarioCpf ?? '',
        );
      }
    }

    // 2. Validação de cada linha
    final cpfsVistos = <String>{};
    final emailsVistos = <String>{};

    if (enableLogging) {
      LoggerImportacao.logValidacaoInicio();
    }

    for (final row in rows) {
      _validarLinha(
        row,
        cpfsVistos,
        emailsVistos,
        cpfsExistentesNoBanco,
        emailsExistenteNoBanco,
      );

      if (enableLogging) {
        if (row.errosValidacao.isEmpty) {
          LoggerImportacao.logLinhaValida(
            row.linhaNumero,
            row.proprietarioNomeCompleto ?? '',
            row.inquilinoNomeCompleto,
          );
        } else {
          LoggerImportacao.logLinhaErro(row.linhaNumero, row.errosValidacao);
        }
      }
    }

    if (enableLogging) {
      final validas = rows.where((r) => r.errosValidacao.isEmpty).length;
      final comErros = rows.length - validas;
      LoggerImportacao.logResumoValidacao(rows.length, validas, comErros);
    }

    return rows;
  }

  /// Valida uma linha individual
  static void _validarLinha(
    ImportacaoRow row,
    Set<String> cpfsVistos,
    Set<String> emailsVistos,
    Set<String> cpfsExistentesNoBanco,
    Set<String> emailsExistenteNoBanco,
  ) {
    // Validar proprietário (obrigatório)
    _validarProprietario(
      row,
      cpfsVistos,
      emailsVistos,
      cpfsExistentesNoBanco,
      emailsExistenteNoBanco,
    );

    // Validar inquilino (opcional)
    if (_temDadosInquilino(row)) {
      _validarInquilino(
        row,
        cpfsVistos,
        emailsVistos,
        cpfsExistentesNoBanco,
        emailsExistenteNoBanco,
      );
    }

    // Validar imobiliária (opcional)
    if (_temDadosImobiliaria(row)) {
      _validarImobiliaria(row);
    }

    // Validar unidade
    _validarUnidade(row);
  }

  /// Helper para sanitizar email (pegar apenas o primeiro se houver múltiplos)
  static String _sanitizarEmail(String? rawEmail) {
    if (rawEmail == null || rawEmail.isEmpty) return '';
    
    // Separadores comuns: ponto e vírgula, vírgula, espaço, quebra de linha
    final separators = [';', ',', '\n', ' '];
    
    String email = rawEmail;
    for (var sep in separators) {
      if (email.contains(sep)) {
        email = email.split(sep).first;
      }
    }
    
    return email.trim();
  }

  /// Valida dados obrigatórios do proprietário
  static void _validarProprietario(
    ImportacaoRow row,
    Set<String> cpfsVistos,
    Set<String> emailsVistos,
    Set<String> cpfsExistentesNoBanco,
    Set<String> emailsExistenteNoBanco,
  ) {
    // 🧹 Sanitizar email DEPOIS de extrair (para modificar a row)
    final rawEmail = row.proprietarioEmail?.trim() ?? '';
    final emailSanitizado = _sanitizarEmail(rawEmail);
    
    // Atualizar a row com email limpo se for diferente
    if (rawEmail != emailSanitizado) {
      row.proprietarioEmail = emailSanitizado;
    }

    final nome = row.proprietarioNomeCompleto?.trim() ?? '';
    final cpf = row.proprietarioCpf?.trim() ?? '';
    final email = emailSanitizado; // Usar o sanitizado
    final telefone = row.proprietarioCel?.trim() ?? '';

    // Campo obrigatório: nome
    if (nome.isEmpty) {
      row.adicionarErro('Nome do proprietário é obrigatório');
      return;
    }

    // Campo obrigatório: CPF ou CNPJ
    if (cpf.isEmpty) {
      row.adicionarErro('CPF/CNPJ do proprietário é obrigatório');
    } else {
      // Validar formato (flexível: aceita 11 ou 14 dígitos)
      if (!ValidadorImportacao.validarCpfOuCnpj(cpf)) {
        row.adicionarErro(
          'CPF/CNPJ "$cpf" inválido - Digite um CPF (11 dígitos) ou CNPJ (14 dígitos)',
        );
      } else {
        final cpfLimpo = ValidadorImportacao.limparCpf(cpf);
        // ✅ MULTI-UNIT: Não verificar duplicação - agora permitimos múltiplas unidades
        // Apenas adicionar ao Set para rastreamento interno (sem bloquear)
        cpfsVistos.add(cpfLimpo);
      }
    }

    // Campo obrigatório: Email
    if (email.isEmpty) {
      row.adicionarErro('Email do proprietário é obrigatório');
    } else {
      // Validar formato do email
      if (!ValidadorImportacao.validarEmail(email)) {
        row.adicionarErro(
          'Email "$email" inválido - Formato correto: usuario@dominio.com',
        );
      } else {
        final emailLimpo = email.toLowerCase();
        // ✅ MULTI-UNIT: Não verificar duplicação - agora permitimos múltiplas unidades
        emailsVistos.add(emailLimpo);
      }
    }

    // Telefone (Opcional)
    if (telefone.isNotEmpty) {
      if (!ValidadorImportacao.validarTelefone(telefone)) {
        row.adicionarErro(
          'Telefone "$telefone" inválido - Deve ter 10 ou 11 dígitos (ex: 11987654321)',
        );
      }
    }
  }

  /// Valida dados do inquilino
  static void _validarInquilino(
    ImportacaoRow row,
    Set<String> cpfsVistos,
    Set<String> emailsVistos,
    Set<String> cpfsExistentesNoBanco,
    Set<String> emailsExistenteNoBanco,
  ) {
    // 🧹 Sanitizar email
    final rawEmail = row.inquilinoEmail?.trim() ?? '';
    final emailSanitizado = _sanitizarEmail(rawEmail);
    if (rawEmail != emailSanitizado) {
      row.inquilinoEmail = emailSanitizado;
    }

    final nome = row.inquilinoNomeCompleto?.trim() ?? '';
    final cpf = row.inquilinoCpf?.trim() ?? '';
    final email = emailSanitizado;
    final telefone = row.inquilinoCel?.trim() ?? '';

    // Se nome está preenchido, validar campos
    if (nome.isNotEmpty) {
      // Campo obrigatório: CPF
      if (cpf.isEmpty) {
        row.adicionarErro('CPF do inquilino é obrigatório quando informado nome');
      } else {
        // Validar formato do CPF
        if (!ValidadorImportacao.validarCpf(cpf)) {
          row.adicionarErro(
            'CPF inquilino "$cpf" inválido - CPF deve conter 11 dígitos',
          );
        } else {
          final cpfLimpo = ValidadorImportacao.limparCpf(cpf);

          // Verificar duplicação na planilha
          if (cpfsVistos.contains(cpfLimpo)) {
            row.adicionarErro(
              'CPF inquilino "$cpf" duplicado - Este CPF já existe em outra linha',
            );
          } else {
            cpfsVistos.add(cpfLimpo);

            // Verificar duplicação no banco de dados
            if (cpfsExistentesNoBanco.contains(cpfLimpo)) {
              row.adicionarErro(
                'CPF inquilino "$cpf" já existe no sistema',
              );
            }
          }
        }
      }

      // Campo obrigatório: Email
      if (email.isEmpty) {
        row.adicionarErro('Email do inquilino é obrigatório quando informado nome');
      } else {
        if (!ValidadorImportacao.validarEmail(email)) {
          row.adicionarErro(
            'Email inquilino "$email" inválido - Formato correto: usuario@dominio.com',
          );
        } else {
          final emailLimpo = email.toLowerCase();

          if (emailsVistos.contains(emailLimpo)) {
            row.adicionarErro(
              'Email inquilino "$email" duplicado - Já existe em outra linha',
            );
          } else {
            emailsVistos.add(emailLimpo);

            if (emailsExistenteNoBanco.contains(emailLimpo)) {
              row.adicionarErro(
                'Email inquilino "$email" já existe no sistema',
              );
            }
          }
        }
      }

      // Telefone (Opcional)
      if (telefone.isNotEmpty) {
        if (!ValidadorImportacao.validarTelefone(telefone)) {
          row.adicionarErro(
            'Telefone inquilino "$telefone" inválido - Deve ter 10 ou 11 dígitos',
          );
        }
      }
    }
  }

  /// Valida dados da imobiliária
  static void _validarImobiliaria(ImportacaoRow row) {
    // 🧹 Sanitizar email
    final rawEmail = row.emailImobiliaria?.trim() ?? '';
    final emailSanitizado = _sanitizarEmail(rawEmail);
    if (rawEmail != emailSanitizado) {
      row.emailImobiliaria = emailSanitizado;
    }

    final nome = row.nomeImobiliaria?.trim() ?? '';
    final cnpj = row.cnpjImobiliaria?.trim() ?? '';
    final email = emailSanitizado;
    final telefone = row.celImobiliaria?.trim() ?? '';

    // Se nome está preenchido, todos os campos são obrigatórios
    if (nome.isNotEmpty) {
      // Campo obrigatório: CNPJ
      if (cnpj.isEmpty) {
        row.adicionarErro('CNPJ da imobiliária é obrigatório quando informado nome');
      } else {
        if (!ValidadorImportacao.validarCnpj(cnpj)) {
          row.adicionarErro(
            'CNPJ "$cnpj" inválido - CNPJ deve conter 14 dígitos',
          );
        }
      }

      // Campo obrigatório: Email
      if (email.isEmpty) {
        row.adicionarErro('Email da imobiliária é obrigatório quando informado nome');
      } else {
        if (!ValidadorImportacao.validarEmail(email)) {
          row.adicionarErro(
            'Email imobiliária "$email" inválido',
          );
        }
      }

      // Campo obrigatório: Telefone
      if (telefone.isEmpty) {
        row.adicionarErro('Telefone da imobiliária é obrigatório quando informado nome');
      } else {
        if (!ValidadorImportacao.validarTelefone(telefone)) {
          row.adicionarErro(
            'Telefone imobiliária "$telefone" inválido',
          );
        }
      }
    }
  }

  /// Valida dados da unidade
  static void _validarUnidade(ImportacaoRow row) {
    final unidade = row.unidade?.trim() ?? '';
    final fracao = row.fracaoIdeal?.trim() ?? '';

    // Campo obrigatório: Unidade
    if (unidade.isEmpty) {
      row.adicionarErro('Número da unidade é obrigatório');
    }

    // Fração Ideal é OPCIONAL - valida apenas se preenchida
    if (fracao.isNotEmpty) {
      if (!ValidadorImportacao.validarFracaoIdeal(fracao)) {
        row.adicionarErro(
          'Fração ideal "$fracao" inválida - Deve ser um número positivo (ex: 100.50)',
        );
      }
    }
  }

  /// Verifica se há dados de inquilino preenchidos
  static bool _temDadosInquilino(ImportacaoRow row) {
    return (row.inquilinoNomeCompleto?.isNotEmpty ?? false) ||
        (row.inquilinoCpf?.isNotEmpty ?? false) ||
        (row.inquilinoEmail?.isNotEmpty ?? false) ||
        (row.inquilinoCel?.isNotEmpty ?? false);
  }

  /// Verifica se há dados de imobiliária preenchidos
  static bool _temDadosImobiliaria(ImportacaoRow row) {
    return (row.nomeImobiliaria?.isNotEmpty ?? false) ||
        (row.cnpjImobiliaria?.isNotEmpty ?? false) ||
        (row.emailImobiliaria?.isNotEmpty ?? false) ||
        (row.celImobiliaria?.isNotEmpty ?? false);
  }

  /// Mapeia as linhas validadas para entidades (ProprietarioImportacao, etc)
  /// Deve ser chamado APÓS validação com sucesso
  static Future<Map<String, dynamic>> mapearParaEntidades(
    List<ImportacaoRow> rows, {
    required String condominioId,
  }) async {
    final proprietarios = <String, ProprietarioImportacao>{};
    final inquilinos = <ProprietarioImportacao, InquilinoImportacao>{};
    final imobiliarias = <String, ImobiliarioImportacao>{};
    final blocos = <String, BlocoImportacao>{};
    final senhasProprietarios = <String, String>{};
    final senhasInquilinos = <String, String>{};

    for (final row in rows) {
      // Pula linhas com erro
      if (row.temErros) continue;

      // Processar proprietário
      final cpfProprietario =
          ValidadorImportacao.limparCpf(row.proprietarioCpf ?? '');
      final emailProprietario = (row.proprietarioEmail ?? '').toLowerCase();
      final senhaProprietario = GeradorSenha.gerarSimples();

      var proprietario = proprietarios[cpfProprietario];

      if (proprietario == null) {
        // Criar novo proprietário
        proprietario = ProprietarioImportacao(
          cpf: cpfProprietario,
          nomeCompleto: row.proprietarioNomeCompleto ?? '',
          email: emailProprietario,
          telefone: ValidadorImportacao.limparTelefone(row.proprietarioCel ?? ''),
          senha: senhaProprietario,
        );
        proprietarios[cpfProprietario] = proprietario;
        senhasProprietarios[cpfProprietario] = senhaProprietario;
      }

      // Adicionar unidade ao proprietário
      final bloco = row.bloco ?? 'A';
      proprietario.adicionarUnidade(
        bloco,
        row.unidade ?? '',
        row.fracaoIdeal ?? '',
      );

      // Criar/adicionar bloco se não existir
      if (!blocos.containsKey(bloco)) {
        blocos[bloco] = BlocoImportacao(
          nome: bloco,
          condominioId: condominioId,
        );
      }

      // Processar inquilino (se houver)
      if ((row.inquilinoNomeCompleto?.isNotEmpty ?? false) &&
          !row.temErros) {
        final cpfInquilino =
            ValidadorImportacao.limparCpf(row.inquilinoCpf ?? '');
        final emailInquilino = (row.inquilinoEmail ?? '').toLowerCase();
        final senhaInquilino = GeradorSenha.gerarSimples();

        final inquilino = InquilinoImportacao(
          cpf: cpfInquilino,
          nomeCompleto: row.inquilinoNomeCompleto ?? '',
          email: emailInquilino,
          telefone: ValidadorImportacao.limparTelefone(row.inquilinoCel ?? ''),
          senha: senhaInquilino,
          bloco: bloco,
          unidade: row.unidade ?? '',
        );

        inquilinos[proprietario] = inquilino;
        senhasInquilinos[cpfInquilino] = senhaInquilino;
      }

      // Processar imobiliária (se houver)
      if ((row.nomeImobiliaria?.isNotEmpty ?? false) && !row.temErros) {
        final cnpjImobiliaria =
            ValidadorImportacao.limparCnpj(row.cnpjImobiliaria ?? '');
        final emailImobiliaria = (row.emailImobiliaria ?? '').toLowerCase();

        if (!imobiliarias.containsKey(cnpjImobiliaria)) {
          imobiliarias[cnpjImobiliaria] = ImobiliarioImportacao(
            cnpj: cnpjImobiliaria,
            nome: row.nomeImobiliaria ?? '',
            email: emailImobiliaria,
            telefone: ValidadorImportacao.limparTelefone(row.celImobiliaria ?? ''),
          );
        }
      }
    }

    return {
      'proprietarios': proprietarios,
      'inquilinos': inquilinos,
      'imobiliarias': imobiliarias,
      'blocos': blocos,
      'senhasProprietarios': senhasProprietarios,
      'senhasInquilinos': senhasInquilinos,
    };
  }

  /// Mapeia uma ImportacaoRow validada para estrutura de inserção no Supabase
  /// Transforma dados da planilha em formato pronto para inserção no banco
  static Map<String, dynamic> mapearParaInsercao(
    ImportacaoRow row, {
    required String condominioId,
  }) {
    // Limpar e normalizar dados
    final cpfProprietario = ValidadorImportacao.limparCpf(row.proprietarioCpf ?? '');
    final emailProprietario = (row.proprietarioEmail ?? '').toLowerCase();
    final celProprietario = ValidadorImportacao.limparTelefone(row.proprietarioCel ?? '');

    final senhaProprietario = GeradorSenha.gerarSimples();

    // UNIDADE
    final bloco = (row.bloco?.trim().isEmpty ?? true) ? 'A' : row.bloco!.trim();
    final unidade = row.unidade?.trim() ?? '';
    final fracaoIdeal = _parsearFracaoIdeal(row.fracaoIdeal);

    final mapUnidade = {
      'numero': unidade,
      'bloco': bloco,
      'fracao_ideal': fracaoIdeal,
      'condominio_id': condominioId,
      'tipo_unidade': 'A',
      'ativo': true,
      // Campos com defaults
      'isencao_nenhum': true,
      'isencao_total': false,
      'isencao_cota': false,
      'isencao_fundo_reserva': false,
      'acao_judicial': false,
      'correios': false,
      'nome_pagador_boleto': 'proprietario',
    };

    // PROPRIETARIO
    final mapProprietario = {
      'condominio_id': condominioId,
      'nome': row.proprietarioNomeCompleto ?? '',
      'cpf_cnpj': cpfProprietario,
      'celular': celProprietario.isNotEmpty ? celProprietario : null,
      'email': emailProprietario.isNotEmpty ? emailProprietario : null,
      'senha_acesso': senhaProprietario,
      'ativo': true,
      // Campos opcionais como null
      'cep': null,
      'endereco': null,
      'numero': null,
      'complemento': null,
      'bairro': null,
      'cidade': null,
      'estado': null,
      'telefone': null,
      'conjuge': null,
      'multiproprietarios': null,
      'moradores': null,
      'foto_perfil': null,
    };

    // INQUILINO (opcional)
    Map<String, dynamic>? mapInquilino;
    String? senhaInquilino;

    if ((row.inquilinoNomeCompleto?.trim().isNotEmpty ?? false)) {
      final cpfInquilino = ValidadorImportacao.limparCpf(row.inquilinoCpf ?? '');
      final emailInquilino = (row.inquilinoEmail ?? '').toLowerCase();
      final celInquilino = ValidadorImportacao.limparTelefone(row.inquilinoCel ?? '');

      senhaInquilino = GeradorSenha.gerarSimples();

      mapInquilino = {
        'condominio_id': condominioId,
        'nome': row.inquilinoNomeCompleto ?? '',
        'cpf_cnpj': cpfInquilino,
        'celular': celInquilino.isNotEmpty ? celInquilino : null,
        'email': emailInquilino.isNotEmpty ? emailInquilino : null,
        'senha_acesso': senhaInquilino,
        'receber_boleto_email': true,
        'controle_locacao': true,
        'ativo': true,
        // Campos opcionais como null
        'cep': null,
        'endereco': null,
        'numero': null,
        'bairro': null,
        'cidade': null,
        'estado': null,
        'telefone': null,
        'conjuge': null,
        'multiproprietarios': null,
        'moradores': null,
        'foto_perfil': null,
      };
    }

    // IMOBILIARIA (opcional)
    Map<String, dynamic>? mapImobiliaria;

    if ((row.nomeImobiliaria?.trim().isNotEmpty ?? false)) {
      final cnpjImobiliaria = ValidadorImportacao.limparCnpj(row.cnpjImobiliaria ?? '');
      final emailImobiliaria = (row.emailImobiliaria ?? '').toLowerCase();
      final celImobiliaria = ValidadorImportacao.limparTelefone(row.celImobiliaria ?? '');

      mapImobiliaria = {
        'condominio_id': condominioId,
        'nome': row.nomeImobiliaria ?? '',
        'cnpj': cnpjImobiliaria,
        'celular': celImobiliaria.isNotEmpty ? celImobiliaria : null,
        'email': emailImobiliaria.isNotEmpty ? emailImobiliaria : null,
        'telefone': null,
        'ativo': true,
      };
    }

    return {
      'linhaNumero': row.linhaNumero,
      'unidade': mapUnidade,
      'proprietario': mapProprietario,
      'inquilino': mapInquilino,
      'imobiliaria': mapImobiliaria,
      'senhas': {
        'proprietario': senhaProprietario,
        'inquilino': senhaInquilino,
      },
    };
  }

  /// Parseia fração ideal de String para double
  /// Retorna null se vazio ou inválido, senão retorna o valor parseado
  static double? _parsearFracaoIdeal(String? fracao) {
    if (fracao == null || fracao.trim().isEmpty) return null;

    try {
      final valor = double.parse(fracao.trim().replaceAll(',', '.'));
      // Validar que está entre 0 e 1
      if (valor > 0 && valor <= 1.0) {
        return valor;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Cria o resultado da importação com estatísticas
  static ImportacaoResultado criarResultado({
    required List<ImportacaoRow> todasAsLinhas,
    required int proprietariosInseridos,
    required int inquilinosInseridos,
    required int imobiliariasInseridas,
    required int blocosInseridos,
    required Map<String, String> senhasProprietarios,
    required Map<String, String> senhasInquilinos,
  }) {
    final erros = todasAsLinhas
        .where((row) => row.temErros)
        .expand((row) => row.errosValidacao)
        .toList();

    return ImportacaoResultado(
      totalLinhas: todasAsLinhas.length,
      proprietariosCriados: proprietariosInseridos,
      inquilinosCriados: inquilinosInseridos,
      imobiliariosCriados: imobiliariasInseridas,
      blocosCriados: blocosInseridos,
      errosDetalhados: erros,
      senhasProprietarios: senhasProprietarios,
      senhasInquilinos: senhasInquilinos,
    );
  }

  /// FASE 4: ORQUESTRAÇÃO COMPLETA
  /// Executa o fluxo completo: Validação → Mapeamento → Inserção
  /// 
  /// Retorna um Map com resultado detalhado de cada linha
  static Future<Map<String, dynamic>> executarImportacaoCompleta(
    Uint8List bytes, {
    required String condominioId,
    required Set<String> cpfsExistentes,
    required Set<String> emailsExistentes,
    bool enableLogging = true,
  }) async {
    final tempoInicio = DateTime.now();
    
    print('\n╔════════════════════════════════════════════════════╗');
    print('║         INICIANDO IMPORTAÇÃO COMPLETA             ║');
    print('╚════════════════════════════════════════════════════╝\n');

    try {
      // ============================================================
      // ETAPA 1: VALIDAÇÃO
      // ============================================================
      print('📋 ETAPA 1: VALIDAÇÃO DE DADOS');
      print('═══════════════════════════════════════════════════\n');

      final rowsValidadas = await parsarEValidarArquivo(
        bytes,
        cpfsExistentesNoBanco: cpfsExistentes,
        emailsExistenteNoBanco: emailsExistentes,
        enableLogging: enableLogging,
      );

      final totalLinhas = rowsValidadas.length;
      final linhasComErro = rowsValidadas.where((r) => r.temErros).length;
      final linhasValidas = totalLinhas - linhasComErro;

      print('\n✅ VALIDAÇÃO CONCLUÍDA');
      print('   Total: $totalLinhas linhas');
      print('   ✅ Válidas: $linhasValidas');
      print('   ❌ Com erro: $linhasComErro\n');

      // Se todas têm erro, retorna erro
      if (linhasValidas == 0) {
        return {
          'sucesso': false,
          'mensagem': 'Todas as linhas contêm erros. Revise os dados e tente novamente.',
          'totalLinhas': totalLinhas,
          'linhasProcessadas': 0,
          'linhasComSucesso': 0,
          'linhasComErro': linhasComErro,
          'resultados': rowsValidadas.map((r) => {
            'linhaNumero': r.linhaNumero,
            'sucesso': false,
            'erros': r.errosValidacao,
          }).toList(),
          'tempo': DateTime.now().difference(tempoInicio).inSeconds,
        };
      }

      // ============================================================
      // ETAPA 2: MAPEAMENTO
      // ============================================================
      print('📝 ETAPA 2: MAPEAMENTO DE DADOS');
      print('═══════════════════════════════════════════════════\n');

      final dadosMapeados = <int, Map<String, dynamic>>{};
      
      for (final row in rowsValidadas) {
        if (!row.temErros) {
          try {
            final dados = mapearParaInsercao(
              row,
              condominioId: condominioId,
            );
            dadosMapeados[row.linhaNumero] = dados;
            print('✅ Linha ${row.linhaNumero}: Mapeada com sucesso');
          } catch (e) {
            print('❌ Linha ${row.linhaNumero}: Erro ao mapear - $e');
          }
        }
      }

      print('\n✅ MAPEAMENTO CONCLUÍDO: ${dadosMapeados.length} linhas mapeadas\n');

      // ============================================================
      // ETAPA 3: INSERÇÃO NO SUPABASE
      // ============================================================
      print('💾 ETAPA 3: INSERÇÃO NO SUPABASE');
      print('═══════════════════════════════════════════════════\n');

      final resultados = <Map<String, dynamic>>[];
      final todasSenhas = <Map<String, dynamic>>[];

      for (final row in rowsValidadas) {
        if (row.temErros) {
          // Linha com erro não é inserida
          resultados.add({
            'linhaNumero': row.linhaNumero,
            'sucesso': false,
            'erros': row.errosValidacao,
          });
          continue;
        }

        if (!dadosMapeados.containsKey(row.linhaNumero)) {
          // Linha que não foi mapeada
          resultados.add({
            'linhaNumero': row.linhaNumero,
            'sucesso': false,
            'erro': 'Linha não foi mapeada',
          });
          continue;
        }

        // Processar linha completa (inserir em ordem)
        final dadosLinhaFormatada = dadosMapeados[row.linhaNumero]!;
        final resultadoInsercao = 
            await ImportacaoInsercaoService.processarLinhaCompleta(
          dadosLinhaFormatada,
        );

        // Adicionar ao resultado
        resultados.add(resultadoInsercao);

        // Coletar senhas se sucesso
        if (resultadoInsercao['sucesso'] == true) {
          todasSenhas.add({
            'linhaNumero': resultadoInsercao['linhaNumero'],
            'proprietario': resultadoInsercao['proprietario'] ?? 
                           resultadoInsercao['senhas']?['proprietario'],
            'senhaProprietario': resultadoInsercao['senhas']?['proprietario'],
            'inquilino': resultadoInsercao['inquilino'],
            'senhaInquilino': resultadoInsercao['senhas']?['inquilino'],
          });
        }
      }

      // ============================================================
      // RESUMO FINAL
      // ============================================================
      print('\n╔════════════════════════════════════════════════════╗');
      print('║              RESUMO DA IMPORTAÇÃO                 ║');
      print('╚════════════════════════════════════════════════════╝\n');

      final sucessos = resultados.where((r) => r['sucesso'] == true).length;
      final erros = resultados.where((r) => r['sucesso'] != true).length;

      print('✅ Linhas processadas com sucesso: $sucessos');
      print('❌ Linhas com erro: $erros');
      print('📊 Total: ${resultados.length} linhas\n');

      // Exibir senhas geradas
      if (todasSenhas.isNotEmpty) {
        print('🔐 SENHAS TEMPORÁRIAS GERADAS:');
        print('═══════════════════════════════════════════════════\n');
        for (final senha in todasSenhas) {
          print('Linha ${senha['linhaNumero']}:');
          print('  Proprietário: ${senha['senhaProprietario']}');
          if (senha['senhaInquilino'] != null) {
            print('  Inquilino: ${senha['senhaInquilino']}');
          }
          print('');
        }
      }

      final tempoTotal = DateTime.now().difference(tempoInicio).inSeconds;
      print('⏱️  Tempo total: ${tempoTotal}s\n');

      return {
        'sucesso': erros == 0,
        'mensagem': erros == 0
            ? 'Importação concluída com sucesso!'
            : 'Importação concluída com alguns erros.',
        'totalLinhas': totalLinhas,
        'linhasProcessadas': resultados.length,
        'linhasComSucesso': sucessos,
        'linhasComErro': erros,
        'resultados': resultados,
        'senhas': todasSenhas,
        'tempo': tempoTotal,
      };
    } catch (e) {
      print('❌ ERRO GERAL NA IMPORTAÇÃO: $e\n');
      return {
        'sucesso': false,
        'mensagem': 'Erro geral na importação: $e',
        'totalLinhas': 0,
        'linhasProcessadas': 0,
        'linhasComSucesso': 0,
        'linhasComErro': 0,
        'resultados': [],
        'tempo': DateTime.now().difference(tempoInicio).inSeconds,
      };
    }
  }
}
