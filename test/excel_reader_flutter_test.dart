import 'dart:io';
import 'package:excel/excel.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Testes de Leitura de Arquivo Excel', () {
    test('Ler arquivo .xlsx e extrair nomes da coluna A', () {
      print('\n' + '═' * 70);
      print('TESTE: Leitura de Arquivo Excel (.xlsx)');
      print('═' * 70);

      // Caminho do arquivo
      const String caminhoArquivo = 'assets/planilha_importacao.xlsx';

      // Verificar existência do arquivo
      expect(File(caminhoArquivo).existsSync(), true,
          reason: 'Arquivo não encontrado: $caminhoArquivo');

      // Ler o arquivo
      final bytes = File(caminhoArquivo).readAsBytesSync();
      final excel = Excel.decodeBytes(bytes);
      final Sheet sheet = excel.tables.values.first;

      // Lista para armazenar os nomes
      List<String> nomes = [];

      // Ler a coluna A
      for (int rowIndex = 0; rowIndex < sheet.maxRows; rowIndex++) {
        final cell = sheet.cell(CellIndex.indexByColumnRow(
          columnIndex: 0,
          rowIndex: rowIndex,
        ));

        if (cell.value != null && cell.value.toString().trim().isNotEmpty) {
          nomes.add(cell.value.toString().trim());
        }
      }

      // Imprimir resultado formatado
      print('\n📋 NOMES EXTRAÍDOS DA COLUNA A:');
      print('─' * 70);

      for (int i = 0; i < nomes.length; i++) {
        print('${i + 1} - ${nomes[i]}');
      }

      print('─' * 70);
      print('✅ Total: ${nomes.length} nome(s) encontrado(s)');
      print('═' * 70 + '\n');

      // Assertions
      expect(nomes.isNotEmpty, true, reason: 'Nenhum nome foi encontrado');
      expect(nomes.length, greaterThan(0), reason: 'Lista de nomes está vazia');
    });

    test('Validar que nomes não contêm espaços em branco desnecessários', () {
      const String caminhoArquivo = 'assets/planilha_importacao.xlsx';
      final bytes = File(caminhoArquivo).readAsBytesSync();
      final excel = Excel.decodeBytes(bytes);
      final Sheet sheet = excel.tables.values.first;

      List<String> nomes = [];
      for (int rowIndex = 0; rowIndex < sheet.maxRows; rowIndex++) {
        final cell = sheet.cell(CellIndex.indexByColumnRow(
          columnIndex: 0,
          rowIndex: rowIndex,
        ));

        if (cell.value != null && cell.value.toString().trim().isNotEmpty) {
          nomes.add(cell.value.toString().trim());
        }
      }

      // Verificar que nenhum nome tem espaços extras
      for (String nome in nomes) {
        expect(nome, isNot(contains('  ')),
            reason: 'Nome com espaços múltiplos: $nome');
        expect(nome, isNot(startsWith(' ')),
            reason: 'Nome começando com espaço: $nome');
        expect(nome, isNot(endsWith(' ')),
            reason: 'Nome terminando com espaço: $nome');
      }

      print('✅ Todos os nomes estão bem formatados (sem espaços extras)');
    });
  });
}
