import 'package:flutter_test/flutter_test.dart';
import 'package:condogaiaapp/features/Prop_Inq_Features/reserva/domain/entities/reserva_entity.dart';

void main() {
  group('ReservaEntity', () {
    test(
      'Deve ser possivel instanciar ReservaEntity com todos os campos obrigatorios e opcionais nulos',
      () {
        final reserva = ReservaEntity(
          id: '123',
          ambienteId: 'amb1',
          dataReserva: DateTime(2026, 1, 1),
          horaInicio: '10:00',
          horaFim: '12:00',
          local: 'Churrasqueira',
          valorLocacao: 150.0,
          termoLocacao: true,
          para: 'Condominio',
          dataCriacao: DateTime(2026, 1, 1),
          dataAtualizacao: DateTime(2026, 1, 1),
        );

        expect(reserva.id, '123');
        expect(reserva.ambienteId, 'amb1');
        expect(reserva.representanteId, isNull);
        expect(reserva.inquilinoId, isNull);
        expect(reserva.proprietarioId, isNull);
        expect(reserva.listaPresentes, isNull);
        expect(reserva.blocoUnidadeId, isNull);
      },
    );

    test(
      'Deve ser possivel instanciar ReservaEntity com campos opcionais preenchidos',
      () {
        final reserva = ReservaEntity(
          id: '123',
          ambienteId: 'amb1',
          representanteId: 'rep1',
          inquilinoId: 'inq1',
          proprietarioId: 'prop1',
          dataReserva: DateTime(2026, 1, 1),
          horaInicio: '10:00',
          horaFim: '12:00',
          local: 'Churrasqueira',
          valorLocacao: 150.0,
          termoLocacao: true,
          para: 'Condominio',
          listaPresentes: '[{"nome": "Joao"}]',
          blocoUnidadeId: 'bloco1-uid',
          dataCriacao: DateTime(2026, 1, 1),
          dataAtualizacao: DateTime(2026, 1, 1),
        );

        expect(reserva.representanteId, 'rep1');
        expect(reserva.inquilinoId, 'inq1');
        expect(reserva.proprietarioId, 'prop1');
        expect(reserva.listaPresentes, '[{"nome": "Joao"}]');
        expect(reserva.blocoUnidadeId, 'bloco1-uid');
      },
    );
  });
}
