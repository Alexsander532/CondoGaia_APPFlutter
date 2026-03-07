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
        tipo: 'Comum',
        capacidadeMaxima: 50,
        dataCriacao: DateTime(2026, 1, 1),
        locacaoUrl: 'http://link.com',
      );

      expect(ambiente.id, '123');
      expect(ambiente.nome, 'Salao de Festas');
      expect(ambiente.valor, 200.0);
      expect(ambiente.condominioId, 'cond1');
      expect(ambiente.descricao, 'Salao para 50 pessoas');
      expect(ambiente.tipo, 'Comum');
      expect(ambiente.capacidadeMaxima, 50);
      expect(ambiente.dataCriacao, DateTime(2026, 1, 1));
      expect(ambiente.locacaoUrl, 'http://link.com');
    });
  });
}
