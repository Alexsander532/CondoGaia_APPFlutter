import 'package:flutter_test/flutter_test.dart';
import 'package:condogaiaapp/features/Prop_Inq_Features/reserva/data/models/ambiente_model.dart';

void main() {
  group('AmbienteModel', () {
    test('Deve converter JSON para AmbienteModel corretamente', () {
      final json = {
        'id': '123',
        'titulo': 'Salao de Festas',
        'valor': 200.0,
        'condominio_id': 'cond1',
        'descricao': 'Salao para 50 pessoas',
        'tipo': 'Comum',
        'capacidade': 50,
        'created_at': '2026-01-01T10:00:00.000Z',
        'locacao_url': 'http://link.com',
      };

      final model = AmbienteModel.fromJson(json);

      expect(model.id, '123');
      expect(model.nome, 'Salao de Festas');
      expect(model.valor, 200.0);
      expect(model.descricao, 'Salao para 50 pessoas');
      expect(model.locacaoUrl, 'http://link.com');
    });

    test('Deve converter AmbienteModel para JSON corretamente', () {
      final model = AmbienteModel(
        id: '123',
        nome: 'Salao',
        valor: 100.0,
        condominioId: 'cond1',
        descricao: 'D',
        dataCriacao: DateTime(2026, 1, 1),
      );

      final json = model.toJson();

      expect(json['id'], '123');
      expect(json['titulo'], 'Salao');
      expect(json['valor'], 100.0);
    });
  });
}
