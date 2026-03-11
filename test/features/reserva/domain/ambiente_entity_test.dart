import 'package:flutter_test/flutter_test.dart';
import 'package:condogaiaapp/features/Prop_Inq_Features/reserva/domain/entities/ambiente_entity.dart';

void main() {
  group('AmbienteEntity', () {
    test('Deve ser possivel instanciar AmbienteEntity com todos os campos', () {
      final ambiente = AmbienteEntity(
        id: '123',
        nome: 'Salao de Festas',
        valor: 200.0,
        condominioId: 'cond1',
        descricao: 'Salao para 50 pessoas',
        dataCriacao: DateTime(2026, 1, 1),
        locacaoUrl: 'http://link.com',
        fotoUrl: 'http://foto.com/img.jpg',
      );

      expect(ambiente.id, '123');
      expect(ambiente.nome, 'Salao de Festas');
      expect(ambiente.valor, 200.0);
      expect(ambiente.condominioId, 'cond1');
      expect(ambiente.descricao, 'Salao para 50 pessoas');
      expect(ambiente.dataCriacao, DateTime(2026, 1, 1));
      expect(ambiente.locacaoUrl, 'http://link.com');
      expect(ambiente.fotoUrl, 'http://foto.com/img.jpg');
    });

    test('Campos opcionais (locacaoUrl, fotoUrl) podem ser null', () {
      final ambiente = AmbienteEntity(
        id: '456',
        nome: 'Piscina',
        valor: 0.0,
        condominioId: 'cond2',
        descricao: '',
        dataCriacao: DateTime.now(),
      );

      expect(ambiente.locacaoUrl, isNull);
      expect(ambiente.fotoUrl, isNull);
    });
  });
}
