import 'package:flutter_test/flutter_test.dart';
import 'package:condogaiaapp/features/Prop_Inq_Features/reserva/ui/cubit/reserva_state.dart';
import 'package:condogaiaapp/features/Prop_Inq_Features/reserva/domain/entities/reserva_entity.dart';

void main() {
  group('ReservaState', () {
    test('ReservaInitial supports value comparisons', () {
      expect(const ReservaInitial(), const ReservaInitial());
    });

    test('ReservaLoading supports value comparisons', () {
      expect(const ReservaLoading(), const ReservaLoading());
    });

    test('ReservaCarregada supports value comparisons', () {
      final state1 = ReservaCarregada(reservas: [], ambientes: []);
      final state2 = ReservaCarregada(reservas: [], ambientes: []);
      expect(state1, state2);
    });

    test('ReservaCriada supports value comparisons', () {
      final reserva = ReservaEntity(
        id: '1',
        ambienteId: 'a1',
        dataReserva: DateTime.now(),
        horaInicio: '10:00',
        horaFim: '12:00',
        local: 'L1',
        valorLocacao: 10,
        termoLocacao: true,
        para: 'P1',
        dataCriacao: DateTime.now(),
        dataAtualizacao: DateTime.now(),
      );
      final state1 = ReservaCriada(reserva: reserva, mensagem: 'Sucesso');
      final state2 = ReservaCriada(reserva: reserva, mensagem: 'Sucesso');
      expect(state1, state2);
    });

    test('ReservaCancelada supports value comparisons', () {
      final state1 = ReservaCancelada(reservaId: '1', mensagem: 'Cancelada');
      final state2 = ReservaCancelada(reservaId: '1', mensagem: 'Cancelada');
      expect(state1, state2);
    });

    test('ReservaErro supports value comparisons', () {
      final state1 = ReservaErro(mensagem: 'Erro');
      final state2 = ReservaErro(mensagem: 'Erro');
      expect(state1, state2);
    });

    test('ReservaFormularioAtualizado supports value comparisons', () {
      final state1 = ReservaFormularioAtualizado(
        descricao: 'Teste',
        ambienteSelecionado: null,
        dataInicio: null,
        dataFim: null,
        formularioValido: false,
      );
      final state2 = ReservaFormularioAtualizado(
        descricao: 'Teste',
        ambienteSelecionado: null,
        dataInicio: null,
        dataFim: null,
        formularioValido: false,
      );
      expect(state1, state2);
    });
  });
}
