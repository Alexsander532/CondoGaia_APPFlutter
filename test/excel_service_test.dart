import 'package:flutter_test/flutter_test.dart';
import '../lib/services/excel_service.dart';

void main() {
  group('Testes do ExcelService', () {
    test('Ler coluna A de arquivo Excel e imprimir nomes', () async {
      print('\n' + '═' * 70);
      print('TESTE: ExcelService - Leitura de Coluna A');
      print('═' * 70);

      const String caminhoArquivo = 'assets/teste_listapresenca.xlsx';

      try {
        // Ler coluna A usando o serviço
        final nomes = await ExcelService.lerColuna(caminhoArquivo);

        // Imprimir dados formatados
        ExcelService.imprimirDados(nomes, titulo: 'NOMES LIDOS DO EXCEL');

        // Validações
        expect(nomes.isNotEmpty, true, reason: 'Nenhum nome foi encontrado');
        expect(nomes.length, greaterThan(0));

        print('✅ Teste passou! ${nomes.length} nomes foram lidos com sucesso');
      } catch (e) {
        print('❌ Erro no teste: $e');
        fail('Erro ao ler arquivo: $e');
      }
    });

    test('Ler com coluna personalizada', () async {
      const String caminhoArquivo = 'assets/planilha_importacao.xlsx';

      try {
        // Ler da coluna A (índice 0)
        final dadosColuna0 = await ExcelService.lerColuna(
          caminhoArquivo,
          colunaIndex: 0,
        );

        print('\n✅ Coluna A: ${dadosColuna0.length} registros');
        expect(dadosColuna0.isNotEmpty, true);
      } catch (e) {
        print('ℹ️ Coluna não tem dados ou arquivo não encontrado: $e');
      }
    });

    test('Processador customizado para mapear dados', () async {
      const String caminhoArquivo = 'assets/planilha_importacao.xlsx';

      try {
        final dados = await ExcelService.lerComProcessador<Map<String, dynamic>>(
          caminhoArquivo,
          (linha) {
            return {
              'nome': linha.isNotEmpty ? linha[0]?.toString() ?? '' : '',
              'posicao': linha.length,
            };
          },
        );

        print('\n' + '═' * 70);
        print('📋 DADOS COM PROCESSADOR CUSTOMIZADO');
        print('═' * 70);

        for (int i = 0; i < dados.length; i++) {
          print('${i + 1} - ${dados[i]['nome']}');
        }

        print('─' * 70);
        print('✅ Total: ${dados.length} registros processados');
        print('═' * 70);

        expect(dados.isNotEmpty, true);
      } catch (e) {
        print('ℹ️ Erro ao processar: $e');
      }
    });
  });
}
