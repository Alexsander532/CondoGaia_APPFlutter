import 'dart:io';
import 'package:excel/excel.dart';

/// Script para debugar valores das células
void main() async {
  final file = File('assets/planilha_importacao.xlsx');

  final bytes = await file.readAsBytes();
  final excel = Excel.decodeBytes(bytes);

  final sheet = excel.tables.values.first;

  print('\n═══════════════════════════════════════════════════════');
  print('🔍 DEBUG: Verificando coluna [1] (UNIDADE)');
  print('═══════════════════════════════════════════════════════\n');

  // Procura a linha com cabeçalho
  for (int i = 0; i < sheet.rows.length; i++) {
    final row = sheet.rows[i];
    if (row.length > 1 && row[1] != null) {
      final cell = row[1];
      final value = cell?.value;

      print('Linha ${i + 1}:');
      print('  value: $value');
      print('  value.runtimeType: ${value.runtimeType}');
      print('  cellType: ${cell?.cellType}');

      if (value is DateTime) {
        print('  DateTime details:');
        print('    - year: ${value.year}');
        print('    - month: ${value.month}');
        print('    - day: ${value.day}');

        // Tenta calcular dias desde diferentes bases
        final base1 = DateTime(1899, 12, 30);
        final dias1 = value.difference(base1).inDays;
        print('    - Dias desde 1899-12-30: $dias1');

        final base2 = DateTime(1900, 1, 1);
        final dias2 = value.difference(base2).inDays;
        print('    - Dias desde 1900-01-01: $dias2');

        // Se dias der 101, é para a unidade 101
        print('    - Possível valor original: ${dias1 > 0 ? dias1 : dias2}');
      } else if (value is num) {
        print('  Number value: $value');
      } else {
        print('  String value: $value');
      }

      print('');
    }
  }

  print('═══════════════════════════════════════════════════════\n');
}
