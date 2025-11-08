import 'dart:typed_data';
import 'package:excel/excel.dart';
import 'importacao_row.dart';

/// Utilitário para fazer parsing de arquivos Excel/ODS
class ParseadorExcel {
  /// Nomes das colunas esperadas na planilha
  static const List<String> colunasEsperadas = [
    'bloco',
    'unidade',
    'fracao_ideal',
    'proprietario_nome_completo',
    'proprietario_cpf',
    'proprietario_cel',
    'proprietario_email',
    'inquilino_nome_completo',
    'inquilino_cpf',
    'inquilino_cel',
    'inquilino_email',
    'nome_imobiliaria',
    'cnpj_imobiliaria',
    'cel_imobiliaria',
    'email_imobiliaria',
  ];

  /// Faz o parsing de um arquivo Excel e retorna lista de ImportacaoRow
  /// Valida se as colunas existem e estão na ordem correta
  static Future<List<ImportacaoRow>> parseExcel(
    Uint8List bytes, {
    bool validarColunas = true,
  }) async {
    try {
      final excel = Excel.decodeBytes(bytes);
      final sheet = excel.tables.values.first;

      // Encontra a linha com o cabeçalho (pode não ser a primeira)
      // Se a primeira linha não tiver as colunas esperadas, tenta a próxima
      int headerRowIndex = 0;
      List<String> headers = [];

      for (int i = 0; i < sheet.rows.length; i++) {
        final row = sheet.rows[i];
        final candidateHeaders = row
            .map((cell) =>
                (cell?.value ?? '').toString().toLowerCase().trim())
            .toList();

        // Verifica se esta linha tem as colunas esperadas
        if (candidateHeaders.contains('bloco')) {
          headerRowIndex = i;
          headers = candidateHeaders;
          break;
        }
      }

      // Valida se as colunas estão presentes
      if (validarColunas) {
        _validarColunas(headers);
      }

      // Encontra os índices das colunas
      final indices = _encontrarIndicesColunas(headers);

      // Processa cada linha (pulando a linha de header)
      final rows = <ImportacaoRow>[];
      int linhaNumero = headerRowIndex + 2; // Número da linha na planilha

      for (int i = headerRowIndex + 1; i < sheet.rows.length; i++) {
        final cellRow = sheet.rows[i];

        // Pula linhas completamente vazias
        if (_linhaEstaVazia(cellRow)) {
          continue;
        }

        try {
          final row = _parseLinhaExcel(
            cellRow,
            indices,
            linhaNumero,
          );
          rows.add(row);
          linhaNumero++;
        } catch (e) {
          // Se falhar em uma linha, continua com as próximas
          print('Erro ao processar linha $linhaNumero: $e');
          linhaNumero++;
        }
      }

      if (rows.isEmpty) {
        throw Exception('Arquivo Excel não contém dados válidos');
      }

      return rows;
    } on FormatException catch (e) {
      throw Exception('Erro ao ler arquivo Excel: ${e.message}');
    } catch (e) {
      throw Exception('Erro ao processar arquivo: $e');
    }
  }

  /// Valida se as colunas obrigatórias existem
  static void _validarColunas(List<String> headers) {
    for (final coluna in colunasEsperadas) {
      if (!headers.contains(coluna)) {
        throw Exception(
          'Coluna obrigatória "$coluna" não encontrada na planilha.\n'
          'Colunas esperadas: ${colunasEsperadas.join(", ")}',
        );
      }
    }
  }

  /// Encontra os índices de cada coluna esperada
  static Map<String, int> _encontrarIndicesColunas(List<String> headers) {
    final indices = <String, int>{};

    for (final coluna in colunasEsperadas) {
      final index = headers.indexOf(coluna);
      if (index >= 0) {
        indices[coluna] = index;
      }
    }

    return indices;
  }

  /// Verifica se uma linha está completamente vazia
  static bool _linhaEstaVazia(List<Data?> cellRow) {
    return cellRow.every(
      (cell) =>
          cell == null ||
          cell.value == null ||
          cell.value.toString().trim().isEmpty,
    );
  }

  /// Faz o parsing de uma linha do Excel para ImportacaoRow
  static ImportacaoRow _parseLinhaExcel(
    List<Data?> cellRow,
    Map<String, int> indices,
    int linhaNumero,
  ) {
    String _extrairValor(String chave) {
      final index = indices[chave];
      if (index == null || index >= cellRow.length) return '';

      final cell = cellRow[index];
      if (cell == null || cell.value == null) return '';

      final valor = cell.value;

      // Converte para string e limpa
      return valor.toString().trim();
    }

    return ImportacaoRow(
      linhaNumero: linhaNumero,
      bloco: _extrairValor('bloco'),
      unidade: _extrairValor('unidade'),
      fracaoIdeal: _extrairValor('fracao_ideal'),
      proprietarioNomeCompleto: _extrairValor('proprietario_nome_completo'),
      proprietarioCpf: _extrairValor('proprietario_cpf'),
      proprietarioCel: _extrairValor('proprietario_cel'),
      proprietarioEmail: _extrairValor('proprietario_email'),
      inquilinoNomeCompleto: _extrairValor('inquilino_nome_completo'),
      inquilinoCpf: _extrairValor('inquilino_cpf'),
      inquilinoCel: _extrairValor('inquilino_cel'),
      inquilinoEmail: _extrairValor('inquilino_email'),
      nomeImobiliaria: _extrairValor('nome_imobiliaria'),
      cnpjImobiliaria: _extrairValor('cnpj_imobiliaria'),
      celImobiliaria: _extrairValor('cel_imobiliaria'),
      emailImobiliaria: _extrairValor('email_imobiliaria'),
    );
  }

  /// Retorna o mapa de colunas esperadas com descrição
  static Map<String, String> get descricaoColunas => {
    'bloco': 'Letra ou nome do bloco (ex: A, Bloco A, A1)',
    'unidade': 'Número ou identificação da unidade (ex: 101, Apt. 101)',
    'fracao_ideal': 'Fração ideal da unidade (ex: 100.50)',
    'proprietario_nome_completo': 'Nome completo do proprietário',
    'proprietario_cpf': 'CPF do proprietário (11 dígitos)',
    'proprietario_cel': 'Telefone do proprietário (10-11 dígitos)',
    'proprietario_email': 'Email do proprietário',
    'inquilino_nome_completo': 'Nome completo do inquilino (opcional)',
    'inquilino_cpf': 'CPF do inquilino (opcional, 11 dígitos)',
    'inquilino_cel': 'Telefone do inquilino (opcional, 10-11 dígitos)',
    'inquilino_email': 'Email do inquilino (opcional)',
    'nome_imobiliaria': 'Nome da imobiliária (opcional)',
    'cnpj_imobiliaria': 'CNPJ da imobiliária (opcional, 14 dígitos)',
    'cel_imobiliaria': 'Telefone da imobiliária (opcional, 10-11 dígitos)',
    'email_imobiliaria': 'Email da imobiliária (opcional)',
  };
}
