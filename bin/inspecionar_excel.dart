import 'dart:io';
import 'package:excel/excel.dart';

/// Script para inspecionar a planilha Excel
void main() async {
  final file = File('assets/planilha_importacao.xlsx');
  
  if (!file.existsSync()) {
    print('❌ Arquivo não encontrado!');
    exit(1);
  }

  final bytes = await file.readAsBytes();
  final excel = Excel.decodeBytes(bytes);
  
  print('\n═══════════════════════════════════════════════════════');
  print('📊 INSPEÇÃO DA PLANILHA EXCEL');
  print('═══════════════════════════════════════════════════════\n');
  
  for (var sheet in excel.tables.keys) {
    final table = excel.tables[sheet]!;
    
    print('📄 Aba: $sheet');
    print('   Total de linhas: ${table.maxRows}');
    print('   Total de colunas: ${table.maxCols}\n');
    
    // Mostrar todas as linhas
    for (int lineNum = 0; lineNum < table.rows.length; lineNum++) {
      final row = table.rows[lineNum];
      print('   LINHA ${lineNum + 1}:');
      print('   ─────────────────────────────────────────────────────');
      
      for (int i = 0; i < row.length; i++) {
        final cell = row[i];
        final value = cell?.value ?? 'VAZIO';
        print('   [$i] = "$value" (tipo: ${cell?.cellType})');
      }
      print('');
    }
  }
  
  print('═══════════════════════════════════════════════════════');
  print('✅ Inspeção concluída!\n');
}
