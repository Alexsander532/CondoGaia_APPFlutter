import 'package:flutter_test/flutter_test.dart';
import 'package:condogaiaapp/features/Prop_Inq_Features/reserva/data/models/ambiente_model.dart';

void main() {
  group('AmbienteModel', () {
    test('Deve converter JSON completo para AmbienteModel corretamente', () {
      final json = {
        'id': '123',
        'titulo': 'Salao de Festas',
        'valor': 200.0,
        'condominio_id': 'cond1',
        'descricao': 'Salao para 50 pessoas',
        'created_at': '2026-01-01T10:00:00.000Z',
        'locacao_url': 'http://link.com/termo.pdf',
        'foto_url': 'http://foto.com/img.jpg',
      };

      final model = AmbienteModel.fromJson(json);

      expect(model.id, '123');
      expect(model.nome, 'Salao de Festas');
      expect(model.valor, 200.0);
      expect(model.condominioId, 'cond1');
      expect(model.descricao, 'Salao para 50 pessoas');
      expect(model.locacaoUrl, 'http://link.com/termo.pdf');
      expect(model.fotoUrl, 'http://foto.com/img.jpg');
      expect(model.dataCriacao, DateTime.parse('2026-01-01T10:00:00.000Z'));
    });

    test('Deve usar valores padrão para campos ausentes no JSON', () {
      final json = <String, dynamic>{
        // Todos os campos ausentes
      };

      final model = AmbienteModel.fromJson(json);

      expect(model.id, '');
      expect(model.nome, '');
      expect(model.valor, 0.0);
      expect(model.condominioId, '');
      expect(model.descricao, '');
      expect(model.locacaoUrl, isNull);
      expect(model.fotoUrl, isNull);
    });

    test('Deve converter AmbienteModel para JSON completo', () {
      final model = AmbienteModel(
        id: '123',
        nome: 'Salao',
        valor: 100.0,
        condominioId: 'cond1',
        descricao: 'Salao para festas',
        locacaoUrl: 'http://termo.pdf',
        fotoUrl: 'http://foto.jpg',
        dataCriacao: DateTime(2026, 1, 1),
      );

      final json = model.toJson();

      expect(json['id'], '123');
      expect(json['titulo'], 'Salao');
      expect(json['valor'], 100.0);
      expect(json['condominio_id'], 'cond1');
      expect(json['descricao'], 'Salao para festas');
      expect(json['locacao_url'], 'http://termo.pdf');
      expect(json['foto_url'], 'http://foto.jpg');
    });

    test('Campos opcionais null não aparecem indevidamente no toJson', () {
      final model = AmbienteModel(
        id: '456',
        nome: 'Piscina',
        valor: 0.0,
        condominioId: 'cond2',
      );

      final json = model.toJson();

      expect(json['locacao_url'], isNull);
      expect(json['foto_url'], isNull);
      expect(json['descricao'], '');
    });

    test('fromJson → toJson mantém consistência de dados', () {
      final originalJson = {
        'id': 'abc',
        'titulo': 'Quadra',
        'valor': 75.5,
        'condominio_id': 'c1',
        'descricao': 'Quadra poliesportiva',
        'locacao_url': 'http://link.com',
        'foto_url': 'http://img.com',
        'created_at': '2026-06-15T08:30:00.000Z',
      };

      final model = AmbienteModel.fromJson(originalJson);
      final resultJson = model.toJson();

      expect(resultJson['id'], originalJson['id']);
      expect(resultJson['titulo'], originalJson['titulo']);
      expect(resultJson['valor'], originalJson['valor']);
      expect(resultJson['condominio_id'], originalJson['condominio_id']);
      expect(resultJson['locacao_url'], originalJson['locacao_url']);
      expect(resultJson['foto_url'], originalJson['foto_url']);
    });
  });
}
