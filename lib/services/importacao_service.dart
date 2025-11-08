import 'dart:typed_data';
import 'package:condogaiaapp/models/importacao_row.dart';
import 'package:condogaiaapp/models/importacao_resultado.dart';
import 'package:condogaiaapp/models/importacao_entidades.dart';
import 'package:condogaiaapp/models/validador_importacao.dart';
import 'package:condogaiaapp/models/gerador_senha.dart';
import 'package:condogaiaapp/models/parseador_excel.dart';
import 'package:condogaiaapp/services/logger_importacao.dart';

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

  /// Valida dados obrigatórios do proprietário
  static void _validarProprietario(
    ImportacaoRow row,
    Set<String> cpfsVistos,
    Set<String> emailsVistos,
    Set<String> cpfsExistentesNoBanco,
    Set<String> emailsExistenteNoBanco,
  ) {
    final nome = row.proprietarioNomeCompleto?.trim() ?? '';
    final cpf = row.proprietarioCpf?.trim() ?? '';
    final email = row.proprietarioEmail?.trim() ?? '';
    final telefone = row.proprietarioCel?.trim() ?? '';

    // Campo obrigatório: nome
    if (nome.isEmpty) {
      row.adicionarErro('Nome do proprietário é obrigatório');
      return;
    }

    // Campo obrigatório: CPF
    if (cpf.isEmpty) {
      row.adicionarErro('CPF do proprietário é obrigatório');
    } else {
      // Validar formato do CPF
      if (!ValidadorImportacao.validarCpf(cpf)) {
        row.adicionarErro(
          'CPF "$cpf" inválido - CPF deve conter 11 dígitos (ex: 123.456.789-01)',
        );
      } else {
        final cpfLimpo = ValidadorImportacao.limparCpf(cpf);

        // Verificar duplicação na planilha
        if (cpfsVistos.contains(cpfLimpo)) {
          row.adicionarErro(
            'CPF "$cpf" duplicado - Este CPF já existe em outra linha desta importação',
          );
        } else {
          cpfsVistos.add(cpfLimpo);

          // Verificar duplicação no banco de dados
          if (cpfsExistentesNoBanco.contains(cpfLimpo)) {
            row.adicionarErro(
              'CPF "$cpf" já existe no sistema - Este proprietário já foi cadastrado anteriormente',
            );
          }
        }
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

        // Verificar duplicação na planilha
        if (emailsVistos.contains(emailLimpo)) {
          row.adicionarErro(
            'Email "$email" duplicado - Este email já existe em outra linha desta importação',
          );
        } else {
          emailsVistos.add(emailLimpo);

          // Verificar duplicação no banco de dados
          if (emailsExistenteNoBanco.contains(emailLimpo)) {
            row.adicionarErro(
              'Email "$email" já existe no sistema - Este email já foi cadastrado anteriormente',
            );
          }
        }
      }
    }

    // Campo obrigatório: Telefone
    if (telefone.isEmpty) {
      row.adicionarErro('Telefone do proprietário é obrigatório');
    } else {
      // Validar formato do telefone
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
    final nome = row.inquilinoNomeCompleto?.trim() ?? '';
    final cpf = row.inquilinoCpf?.trim() ?? '';
    final email = row.inquilinoEmail?.trim() ?? '';
    final telefone = row.inquilinoCel?.trim() ?? '';

    // Se nome está preenchido, todos os campos são obrigatórios
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

      // Campo obrigatório: Telefone
      if (telefone.isEmpty) {
        row.adicionarErro('Telefone do inquilino é obrigatório quando informado nome');
      } else {
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
    final nome = row.nomeImobiliaria?.trim() ?? '';
    final cnpj = row.cnpjImobiliaria?.trim() ?? '';
    final email = row.emailImobiliaria?.trim() ?? '';
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
}
