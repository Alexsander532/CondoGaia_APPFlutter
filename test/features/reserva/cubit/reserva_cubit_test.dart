import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:condogaiaapp/features/Prop_Inq_Features/reserva/domain/entities/reserva_entity.dart';
import 'package:condogaiaapp/features/Prop_Inq_Features/reserva/domain/entities/ambiente_entity.dart';
import 'package:condogaiaapp/features/Prop_Inq_Features/reserva/domain/usecases/reserva_usecases.dart';
import 'package:condogaiaapp/features/Prop_Inq_Features/reserva/ui/cubit/reserva_cubit.dart';
import 'package:condogaiaapp/features/Prop_Inq_Features/reserva/ui/cubit/reserva_state.dart';
import 'package:condogaiaapp/features/Prop_Inq_Features/reserva/domain/repositories/reserva_repository.dart';

class FakeReservaRepository implements ReservaRepository {
  List<ReservaEntity> reservas = [];
  List<AmbienteEntity> ambientes = [];
  bool throwError = false;

  @override
  Future<ReservaEntity> atualizarReserva({
    required String reservaId,
    required String ambienteId,
    required String local,
    required DateTime dataInicio,
    required DateTime dataFim,
    required double valorLocacao,
    String? listaPresentes,
  }) async {
    if (throwError) throw Exception('Simulated Error');
    return ReservaEntity(
      id: reservaId,
      ambienteId: ambienteId,
      local: local,
      dataReserva: dataInicio,
      horaInicio: '10:00',
      horaFim: '12:00',
      valorLocacao: valorLocacao,
      termoLocacao: true,
      para: 'Condominio',
      dataCriacao: DateTime.now(),
      dataAtualizacao: DateTime.now(),
    );
  }

  @override
  Future<void> cancelarReserva(String reservaId) async {
    if (throwError) throw Exception('Simulated Error');
    reservas.removeWhere((r) => r.id == reservaId);
  }

  @override
  Future<ReservaEntity> criarReserva({
    required String condominioId,
    required String ambienteId,
    String? representanteId,
    String? inquilinoId,
    String? proprietarioId,
    required String local,
    required DateTime dataInicio,
    required DateTime dataFim,
    required double valorLocacao,
    required bool termoLocacao,
    String? listaPresentes,
  }) async {
    if (throwError) throw Exception('Simulated Error');
    final nova = ReservaEntity(
      id: 'novo_id',
      ambienteId: ambienteId,
      local: local,
      dataReserva: dataInicio,
      horaInicio: '10:00',
      horaFim: '12:00',
      valorLocacao: valorLocacao,
      termoLocacao: termoLocacao,
      para: 'Condominio',
      dataCriacao: DateTime.now(),
      dataAtualizacao: DateTime.now(),
    );
    reservas.add(nova);
    return nova;
  }

  @override
  Future<List<AmbienteEntity>> obterAmbientes() async {
    if (throwError) throw Exception('Simulated Error');
    return ambientes;
  }

  @override
  Future<List<ReservaEntity>> obterReservas(String condominioId) async {
    if (throwError) throw Exception('Simulated Error');
    return reservas;
  }
}

void main() {
  late FakeReservaRepository repository;
  late ObterReservasUseCase obterReservas;
  late ObterAmbientesUseCase obterAmbientes;
  late CriarReservaUseCase criarReserva;
  late CancelarReservaUseCase cancelarReserva;
  late ValidarDisponibilidadeUseCase validarDisponibilidade;
  late AtualizarReservaUseCase atualizarReserva;

  setUp(() {
    repository = FakeReservaRepository();
    obterReservas = ObterReservasUseCase(repository: repository);
    obterAmbientes = ObterAmbientesUseCase(repository: repository);
    criarReserva = CriarReservaUseCase(repository: repository);
    cancelarReserva = CancelarReservaUseCase(repository: repository);
    validarDisponibilidade = ValidarDisponibilidadeUseCase(
      repository: repository,
    );
    atualizarReserva = AtualizarReservaUseCase(repository: repository);
  });

  ReservaCubit buildCubit() {
    return ReservaCubit(
      obterReservasUseCase: obterReservas,
      obterAmbientesUseCase: obterAmbientes,
      criarReservaUseCase: criarReserva,
      cancelarReservaUseCase: cancelarReserva,
      validarDisponibilidadeUseCase: validarDisponibilidade,
      atualizarReservaUseCase: atualizarReserva,
    );
  }

  group('ReservaCubit', () {
    test('O estado inicial deve ser ReservaInitial', () {
      final cubit = buildCubit();
      expect(cubit.state, const ReservaInitial());
      cubit.close();
    });

    blocTest<ReservaCubit, ReservaState>(
      'Emitir [ReservaLoading, ReservaCarregada] ao carregar ambientes com sucesso',
      build: () => buildCubit(),
      act: (cubit) => cubit.carregarAmbientes(),
      expect: () => [const ReservaLoading(), isA<ReservaCarregada>()],
    );

    blocTest<ReservaCubit, ReservaState>(
      'Emitir [ReservaLoading, ReservaCarregada] ao carregar reservas com sucesso',
      build: () => buildCubit(),
      act: (cubit) => cubit.carregarReservas('cond1'),
      expect: () => [const ReservaLoading(), isA<ReservaCarregada>()],
    );

    blocTest<ReservaCubit, ReservaState>(
      'Emitir [ReservaErro] ao tentar criar reserva sem ambiente',
      build: () => buildCubit(),
      act: (cubit) => cubit.criarReserva(
        condominioId: 'c1',
        usuarioId: 'u1',
        termoLocacaoAceito: true,
      ),
      expect: () => [const ReservaErro(mensagem: 'Selecione um ambiente')],
    );

    blocTest<ReservaCubit, ReservaState>(
      'Emitir [ReservaFormularioAtualizado] ao interagir com form',
      build: () => buildCubit(),
      act: (cubit) {
        cubit.atualizarDescricao('Nova festa');
        cubit.atualizarDataInicio(DateTime(2026, 1, 10, 10));
      },
      expect: () => [
        isA<ReservaFormularioAtualizado>(),
        isA<ReservaFormularioAtualizado>(),
      ],
    );

    blocTest<ReservaCubit, ReservaState>(
      'Emitir [ReservaCriada] ao criar reserva com sucesso',
      build: () => buildCubit(),
      act: (cubit) {
        cubit.atualizarAmbienteSelecionado(
          AmbienteEntity(
            id: '1',
            nome: 'Amb',
            valor: 10,
            condominioId: 'c1',
            descricao: '',
            tipo: '',
            capacidadeMaxima: 10,
            dataCriacao: DateTime.now(),
          ),
        );
        cubit.atualizarDataInicio(DateTime(2026, 1, 10, 10));
        cubit.atualizarDataFim(DateTime(2026, 1, 10, 12));
        cubit.criarReserva(
          condominioId: 'c1',
          usuarioId: 'u1',
          termoLocacaoAceito: true,
        );
      },
      expect: () => [
        isA<ReservaFormularioAtualizado>(),
        isA<ReservaFormularioAtualizado>(),
        isA<ReservaFormularioAtualizado>(),
        const ReservaLoading(),
        isA<ReservaCriada>(),
      ],
    );

    blocTest<ReservaCubit, ReservaState>(
      'Emitir [ReservaCancelada] ao cancelar reserva',
      build: () => buildCubit(),
      act: (cubit) => cubit.cancelarReserva('1'),
      expect: () => [const ReservaLoading(), isA<ReservaCancelada>()],
    );
  });
}
