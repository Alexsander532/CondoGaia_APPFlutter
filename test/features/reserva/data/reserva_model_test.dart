import 'package:flutter_test/flutter_test.dart';
import 'package:condogaiaapp/features/Prop_Inq_Features/reserva/data/models/reserva_model.dart';

void main() {
  group('ReservaModel', () {
    test('Deve converter JSON para ReservaModel com Inquilino', () {
      final json = {
        'id': '1',
        'ambiente_id': 'amb-1',
        'inquilinos': {'nome': 'Joao Inquilino'},
        'data_reserva': '2026-01-10',
        'hora_inicio': '10:00',
        'hora_fim': '12:00',
        'local': 'Salao de Festas',
        'valor_locacao': 150.00,
      };

      final model = ReservaModel.fromJson(json);
      expect(model.id, '1');
      expect(model.para, 'Joao Inquilino');
    });

    test('Deve converter JSON para ReservaModel com Representante', () {
      final json = {
        'id': '1',
        'representantes': {'nome_completo': 'Maria Representante'},
        'data_reserva': '2026-01-10',
      };

      final model = ReservaModel.fromJson(json);
      expect(model.para, 'Maria Representante');
    });

    test('Deve converter JSON para ReservaModel com Proprietario', () {
      final json = {
        'id': '1',
        'proprietarios': {'nome': 'Carlos Proprietario'},
        'data_reserva': '2026-01-10',
      };

      final model = ReservaModel.fromJson(json);
      expect(model.para, 'Carlos Proprietario');
    });

    test('Deve converter ReservaModel para JSON', () {
      final reserva = ReservaModel(
        id: '1',
        ambienteId: 'amb-1',
        dataReserva: DateTime(2026, 1, 10),
        horaInicio: '10:00',
        horaFim: '12:00',
        local: 'Salao de Festas',
        valorLocacao: 150.00,
        termoLocacao: true,
        para: 'Condominio',
        dataCriacao: DateTime(2026, 1, 3),
        dataAtualizacao: DateTime(2026, 1, 3),
      );

      final json = reserva.toJson();

      expect(json['id'], '1');
      expect(json['ambiente_id'], 'amb-1');
      expect(json['local'], 'Salao de Festas');
      expect(json['valor_locacao'], 150.00);
      expect(json['termo_locacao'], true);
    });
  });
}
