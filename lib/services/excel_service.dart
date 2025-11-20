import 'dart:io';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';

/// Serviço para leitura e processamento de arquivos Excel (.xlsx)
class ExcelService {
  /// Lê um arquivo Excel e extrai todos os nomes da coluna A
  /// 
  /// Parâmetros:
  ///   - [caminhoOuArquivo]: Caminho (String) ou PlatformFile do arquivo .xlsx
  ///   - [colunaIndex]: Índice da coluna a ler (padrão: 0 = coluna A)
  /// 
  /// Retorna:
  ///   - [List<String>]: Lista de nomes encontrados
  /// 
  /// Lança exceção se o arquivo não existir ou for inválido
  static Future<List<String>> lerColuna(
    dynamic caminhoOuArquivo, {
    int colunaIndex = 0,
  }) async {
    try {
      late final List<int> bytes;

      // Verificar o tipo de entrada
      if (caminhoOuArquivo is String) {
        // É um caminho de arquivo
        if (!File(caminhoOuArquivo).existsSync()) {
          throw Exception('Arquivo não encontrado: $caminhoOuArquivo');
        }
        bytes = File(caminhoOuArquivo).readAsBytesSync();
      } else if (caminhoOuArquivo is PlatformFile) {
        // É um PlatformFile (do file_picker)
        if (caminhoOuArquivo.bytes != null) {
          // Web: bytes disponíveis
          bytes = caminhoOuArquivo.bytes!;
        } else if (caminhoOuArquivo.path != null) {
          // Mobile: ler do caminho
          bytes = File(caminhoOuArquivo.path!).readAsBytesSync();
        } else {
          throw Exception('PlatformFile sem bytes ou path');
        }
      } else {
        throw Exception('Tipo inválido. Use String (path) ou PlatformFile');
      }

      // Decodificar arquivo Excel
      final excel = Excel.decodeBytes(bytes);

      // Obter primeira sheet
      if (excel.tables.isEmpty) {
        throw Exception('Arquivo Excel vazio ou inválido');
      }

      final Sheet sheet = excel.tables.values.first;

      // Extrair dados
      List<String> dados = [];
      for (int rowIndex = 0; rowIndex < sheet.maxRows; rowIndex++) {
        final cell = sheet.cell(CellIndex.indexByColumnRow(
          columnIndex: colunaIndex,
          rowIndex: rowIndex,
        ));

        if (cell.value != null && cell.value.toString().trim().isNotEmpty) {
          dados.add(cell.value.toString().trim());
        }
      }

      return dados;
    } catch (e) {
      throw Exception('Erro ao ler arquivo Excel: $e');
    }
  }

  /// Lê um arquivo Excel e retorna uma lista de objetos personalizados
  /// 
  /// Parâmetros:
  ///   - [caminhoArquivo]: Caminho completo do arquivo .xlsx
  ///   - [processador]: Função que processa cada linha
  /// 
  /// Retorna:
  ///   - [List<T>]: Lista de objetos processados
  static Future<List<T>> lerComProcessador<T>(
    String caminhoArquivo,
    T Function(List<dynamic> linha) processador, {
    int linhaInicio = 0,
  }) async {
    try {
      if (!File(caminhoArquivo).existsSync()) {
        throw Exception('Arquivo não encontrado: $caminhoArquivo');
      }

      final bytes = File(caminhoArquivo).readAsBytesSync();
      final excel = Excel.decodeBytes(bytes);

      if (excel.tables.isEmpty) {
        throw Exception('Arquivo Excel vazio ou inválido');
      }

      final Sheet sheet = excel.tables.values.first;
      List<T> resultado = [];

      for (int rowIndex = linhaInicio; rowIndex < sheet.maxRows; rowIndex++) {
        List<dynamic> linha = [];

        // Iterar sobre as células da linha
        for (var cellValue in sheet.row(rowIndex)) {
          linha.add(cellValue?.value);
        }

        // Verificar se linha tem algum dado
        if (linha.any((cell) => cell != null && cell.toString().trim().isNotEmpty)) {
          resultado.add(processador(linha));
        }
      }

      return resultado;
    } catch (e) {
      throw Exception('Erro ao processar arquivo Excel: $e');
    }
  }

  /// Imprime os dados de uma coluna de forma formatada no console
  /// 
  /// Parâmetros:
  ///   - [dados]: Lista de dados a imprimir
  ///   - [titulo]: Título da seção (opcional)
  static void imprimirDados(List<String> dados, {String? titulo}) {
    print('\n' + '═' * 70);
    if (titulo != null) {
      print('📋 $titulo');
    } else {
      print('📋 DADOS ENCONTRADOS');
    }
    print('═' * 70);

    for (int i = 0; i < dados.length; i++) {
      print('${i + 1} - ${dados[i]}');
    }

    print('─' * 70);
    print('✅ Total: ${dados.length} registro(s)');
    print('═' * 70 + '\n');
  }
}
