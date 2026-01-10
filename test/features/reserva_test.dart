import 'package:flutter_test/flutter_test.dart';
import 'package:condogaiaapp/features/Prop_Inq_Features/reserva/domain/entities/reserva_entity.dart';
import 'package:condogaiaapp/features/Prop_Inq_Features/reserva/data/models/reserva_model.dart';

void main() {
  group('ReservaEntity', () {
    test('Deve criar uma ReservaEntity com os campos corretos', () {
      final reserva = ReservaEntity(
        id: '1',
        ambienteId: 'amb-1',
        representanteId: 'rep-1',
        dataReserva: DateTime(2026, 1, 10),
        horaInicio: '10:00',
        horaFim: '12:00',
        local: 'Salão de Festas',
        valorLocacao: 150.00,
        termoLocacao: true,
        para: 'Condomínio',
        dataCriacao: DateTime.now(),
        dataAtualizacao: DateTime.now(),
      );

      expect(reserva.id, '1');
      expect(reserva.ambienteId, 'amb-1');
      expect(reserva.representanteId, 'rep-1');
      expect(reserva.local, 'Salão de Festas');
      expect(reserva.valorLocacao, 150.00);
      expect(reserva.para, 'Condomínio');
    });
  });

  group('ReservaModel', () {
    test('Deve converter JSON para ReservaModel corretamente', () {
      final json = {
        'id': '1',
        'ambiente_id': 'amb-1',
        'representante_id': 'rep-1',
        'data_reserva': '2026-01-10',
        'hora_inicio': '10:00:00',
        'hora_fim': '12:00:00',
        'local': 'Salão de Festas',
        'valor_locacao': 150.00,
        'termo_locacao': true,
        'para': 'Condomínio',
        'created_at': '2026-01-03T10:00:00Z',
        'updated_at': '2026-01-03T10:00:00Z',
      };

      final model = ReservaModel.fromJson(json);

      expect(model.id, '1');
      expect(model.ambienteId, 'amb-1');
      expect(model.representanteId, 'rep-1');
      expect(model.local, 'Salão de Festas');
      expect(model.valorLocacao, 150.00);
      expect(model.termoLocacao, true);
    });

    test('Deve converter ReservaModel para JSON corretamente', () {
      final reserva = ReservaModel(
        id: '1',
        ambienteId: 'amb-1',
        representanteId: 'rep-1',
        dataReserva: DateTime(2026, 1, 10),
        horaInicio: '10:00',
        horaFim: '12:00',
        local: 'Salão de Festas',
        valorLocacao: 150.00,
        termoLocacao: true,
        para: 'Condomínio',
        dataCriacao: DateTime(2026, 1, 3),
        dataAtualizacao: DateTime(2026, 1, 3),
      );

      final json = reserva.toJson();

      expect(json['id'], '1');
      expect(json['ambiente_id'], 'amb-1');
      expect(json['representante_id'], 'rep-1');
      expect(json['local'], 'Salão de Festas');
      expect(json['valor_locacao'], 150.00);
      expect(json['termo_locacao'], true);
    });
  });
}
