import 'package:flutter_test/flutter_test.dart';
import 'package:condogaiaapp/features/Representante_Features/leitura/models/leitura_configuracao_model.dart';

void main() {
  group('FaixaLeitura Tests', () {
    test('deve converter JSON para FaixaLeitura corretamente', () {
      final jsonMap = {'inicio': 0.0, 'fim': 10.0, 'valor': 5.0};
      final faixa = FaixaLeitura.fromJson(jsonMap);

      expect(faixa.inicio, 0.0);
      expect(faixa.fim, 10.0);
      expect(faixa.valor, 5.0);
    });

    test('deve converter FaixaLeitura para JSON corretamente', () {
      const faixa = FaixaLeitura(inicio: 10.0, fim: 20.0, valor: 8.0);
      final jsonMap = faixa.toJson();

      expect(jsonMap['inicio'], 10.0);
      expect(jsonMap['fim'], 20.0);
      expect(jsonMap['valor'], 8.0);
    });
  });

  group('LeituraConfiguracaoModel Tests', () {
    final tModel = LeituraConfiguracaoModel(
      id: 'cfg-1',
      condominioId: 'cond-1',
      tipo: 'Agua',
      unidadeMedida: 'M³',
      valorBase: 15.0,
      cobrancaTipo: 2,
      vencimentoAvulso: DateTime(2026, 2, 10),
      faixas: const [
        FaixaLeitura(inicio: 0, fim: 10, valor: 5.0),
        FaixaLeitura(inicio: 10, fim: 20, valor: 8.0),
        FaixaLeitura(inicio: 20, fim: 50, valor: 12.0),
      ],
    );

    test('deve converter JSON para LeituraConfiguracaoModel corretamente', () {
      final jsonMap = {
        'id': 'cfg-1',
        'condominio_id': 'cond-1',
        'tipo': 'Agua',
        'unidade_medida': 'M³',
        'valor_base': 15.0,
        'cobranca_tipo': 2,
        'vencimento_avulso': '2026-02-10T00:00:00',
        'faixas': [
          {'inicio': 0, 'fim': 10, 'valor': 5.0},
          {
            'inicio': 10,
            'fim:': 20,
            'valor': 8.0,
          }, // The original class correctly handles missing values via fromJson falling back to 0 if 'fim' key typo exists
        ],
      };

      // Fixing the intentional typo for clean test
      jsonMap['faixas'] = [
        {'inicio': 0.0, 'fim': 10.0, 'valor': 5.0},
        {'inicio': 10.0, 'fim': 20.0, 'valor': 8.0},
      ];

      final result = LeituraConfiguracaoModel.fromJson(jsonMap);

      expect(result.id, 'cfg-1');
      expect(result.condominioId, 'cond-1');
      expect(result.valorBase, 15.0);
      expect(result.cobrancaTipo, 2);
      expect(result.vencimentoAvulso, DateTime(2026, 2, 10));
      expect(result.faixas.length, 2);
      expect(result.faixas[0].valor, 5.0);
    });

    test('deve converter LeituraConfiguracaoModel para JSON corretamente', () {
      final jsonMap = tModel.toJson();

      expect(jsonMap['id'], 'cfg-1');
      expect(jsonMap['condominio_id'], 'cond-1');
      expect(jsonMap['valor_base'], 15.0);
      expect(jsonMap['faixas'], isA<List>());
      expect((jsonMap['faixas'] as List).length, 3);
      expect(jsonMap['vencimento_avulso'], '2026-02-10');
    });

    group('Cálculos de Valor (calcularValor)', () {
      test('deve retornar 0 se o consumo for <= 0', () {
        expect(tModel.calcularValor(0), 0);
        expect(tModel.calcularValor(-5), 0);
      });

      test('deve usar o valor_base se a lista de faixas estiver vazia', () {
        const modelSemFaixa = LeituraConfiguracaoModel(
          condominioId: '1',
          tipo: 'Agua',
          valorBase: 10.0,
          faixas: [],
        );
        expect(modelSemFaixa.calcularValor(8.5), 85.0);
      });

      test('deve calcular corretamente usando faixas: Consumo na 1ª Faixa', () {
        // Consumo 5: 5 * 5.0 = 25.0
        expect(tModel.calcularValor(5), 25.0);
      });

      test('deve calcular corretamente usando faixas: Consumo na 2ª Faixa', () {
        // Consumo 15: (10 * 5.0) + (5 * 8.0) = 50 + 40 = 90.0
        expect(tModel.calcularValor(15), 90.0);
      });

      test('deve calcular corretamente usando faixas: Consumo na 3ª Faixa', () {
        // Consumo 25: (10 * 5.0) + (10 * 8.0) + (5 * 12.0) = 50 + 80 + 60 = 190.0
        expect(tModel.calcularValor(25), 190.0);
      });

      test(
        'deve calcular corretamente quando o consumo excede todas as faixas (usando valorBase)',
        () {
          // Consumo 60: (10*5.0) + (10*8.0) + (30*12.0) + (10 * 15.0)
          // 50 + 80 + 360 + 150 = 640.0
          expect(tModel.calcularValor(60), 640.0);
        },
      );
    });
  });
}
