import 'package:flutter_test/flutter_test.dart';
import 'package:condogaiaapp/features/Representante_Features/leitura/models/leitura_model.dart';

void main() {
  group('LeituraModel Tests', () {
    final tDataLeitura = DateTime(2026, 2, 7);

    final tLeituraModel = LeituraModel(
      id: '123',
      unidadeId: 'uni-1',
      bloco: 'A',
      unidadeNome: '101',
      leituraAnterior: 100.0,
      leituraAtual: 110.5,
      valor: 105.0,
      dataLeitura: tDataLeitura,
      tipo: 'Agua',
      imagemUrl: 'http://example.com/image.png',
    );

    test('deve suportar value equality (equatable)', () {
      final model2 = LeituraModel(
        id: '123',
        unidadeId: 'uni-1',
        bloco: 'A',
        unidadeNome: '101',
        leituraAnterior: 100.0,
        leituraAtual: 110.5,
        valor: 105.0,
        dataLeitura: tDataLeitura,
        tipo: 'Agua',
        imagemUrl: 'http://example.com/image.png',
      );
      expect(tLeituraModel, equals(model2));
    });

    test('deve criar um modelo a partir de um JSON válido', () {
      final Map<String, dynamic> jsonMap = {
        'id': '123',
        'unidade_id': 'uni-1',
        'bloco': 'A',
        'unidade_nome': '101',
        'leitura_anterior': 100.0,
        'leitura_atual': 110.5,
        'valor': 105.0,
        'data_leitura': '2026-02-07T00:00:00',
        'tipo': 'Agua',
        'imagem_url': 'http://example.com/image.png',
      };

      final result = LeituraModel.fromJson(jsonMap);

      expect(result.id, '123');
      expect(result.unidadeId, 'uni-1');
      expect(result.bloco, 'A');
      expect(result.unidadeNome, '101');
      expect(result.leituraAnterior, 100.0);
      expect(result.leituraAtual, 110.5);
      expect(result.valor, 105.0);
      expect(result.dataLeitura, tDataLeitura);
      expect(result.tipo, 'Agua');
      expect(result.imagemUrl, 'http://example.com/image.png');
      expect(result.isSelected, false);
    });

    test('deve tratar valores nulos no JSON com defaults apropriados', () {
      final Map<String, dynamic> jsonMap = {};

      final result = LeituraModel.fromJson(jsonMap);

      expect(result.id, '');
      expect(result.unidadeId, '');
      expect(result.bloco, isNull);
      expect(result.unidadeNome, '');
      expect(result.leituraAnterior, 0.0);
      expect(result.leituraAtual, 0.0);
      expect(result.valor, 0.0);
      // data_leitura default é DateTime.now(), vamos checar se é do tipo certo
      expect(result.dataLeitura, isA<DateTime>());
      expect(result.tipo, 'Agua');
      expect(result.imagemUrl, isNull);
    });

    test('deve converter corretamente o modelo para JSON', () {
      final jsonMap = tLeituraModel.toJson();

      expect(jsonMap['unidade_id'], 'uni-1');
      expect(jsonMap['leitura_anterior'], 100.0);
      expect(jsonMap['leitura_atual'], 110.5);
      expect(jsonMap['valor'], 105.0);
      expect(jsonMap['data_leitura'], '2026-02-07');
      expect(jsonMap['tipo'], 'Agua');
      expect(jsonMap['imagem_url'], 'http://example.com/image.png');
      // note: 'id' and 'bloco' are not included in toJson currently based on implementation
    });

    test(
      'deve copiar o objeto atualizando os campos fornecidos via copyWith',
      () {
        final updatedModel = tLeituraModel.copyWith(
          leituraAtual: 120.0,
          valor: 200.0,
          isSelected: true,
        );

        expect(updatedModel.id, tLeituraModel.id);
        expect(updatedModel.leituraAnterior, tLeituraModel.leituraAnterior);
        expect(updatedModel.leituraAtual, 120.0);
        expect(updatedModel.valor, 200.0);
        expect(updatedModel.isSelected, true);
      },
    );
  });
}
