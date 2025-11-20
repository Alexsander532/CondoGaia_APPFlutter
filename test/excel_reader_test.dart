import 'dart:io';
import 'package:excel/excel.dart';

/// Teste para ler arquivo .xlsx e extrair nomes da coluna A
/// Imprime os nomes numerados no terminal de forma dinâmica
void main() {
  print('═' * 60);
  print('TESTE DE LEITURA DE ARQUIVO EXCEL (.xlsx)');
  print('═' * 60);

  // Caminho do arquivo Excel na pasta assets
  const String caminhoArquivo = 'assets/planilha_importacao.xlsx';

  // Verificar se o arquivo existe
  if (!File(caminhoArquivo).existsSync()) {
    print('❌ ERRO: Arquivo não encontrado em: $caminhoArquivo');
    print('\nVerifique se o arquivo está na pasta assets/');
    return;
  }

  try {
    print('✅ Arquivo encontrado!');
    print('📂 Caminho: $caminhoArquivo\n');

    // Ler o arquivo Excel
    final bytes = File(caminhoArquivo).readAsBytesSync();
    final excel = Excel.decodeBytes(bytes);

    // Obter a primeira sheet (planilha)
    final Sheet sheet = excel.tables.values.first;

    print('📋 NOMES ENCONTRADOS:');
    print('─' * 60);

    // Variável para contar os nomes
    int contador = 1;

    // Iterar sobre as linhas da planilha
    for (int rowIndex = 0; rowIndex < sheet.maxRows; rowIndex++) {
      // Obter a célula da coluna A (índice 0)
      final cell = sheet.cell(CellIndex.indexByColumnRow(
        columnIndex: 0,
        rowIndex: rowIndex,
      ));

      // Verificar se a célula tem valor
      if (cell.value != null && cell.value.toString().trim().isNotEmpty) {
        final nome = cell.value.toString().trim();
        print('$contador - $nome');
        contador++;
      } else {
        // Se encontrar uma célula vazia, pode significar fim dos dados
        // Mas continua procurando (pode ter espaços em branco)
        if (rowIndex > 0 && contador > 1) {
          // Verificar se as próximas 5 linhas também estão vazias
          bool todasVazias = true;
          for (int i = 1; i <= 5 && rowIndex + i < sheet.maxRows; i++) {
            final proximaCell = sheet.cell(CellIndex.indexByColumnRow(
              columnIndex: 0,
              rowIndex: rowIndex + i,
            ));
            if (proximaCell.value != null &&
                proximaCell.value.toString().trim().isNotEmpty) {
              todasVazias = false;
              break;
            }
          }

          // Se próximas 5 linhas estão vazias, para a leitura
          if (todasVazias) {
            break;
          }
        }
      }
    }

    print('─' * 60);
    print('✅ Total de nomes encontrados: ${contador - 1}');
    print('═' * 60);
  } catch (e) {
    print('❌ ERRO ao processar arquivo: $e');
    print('═' * 60);
  }
}
