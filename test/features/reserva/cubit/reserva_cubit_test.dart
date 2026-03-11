import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:condogaiaapp/features/Prop_Inq_Features/reserva/domain/entities/reserva_entity.dart';
import 'package:condogaiaapp/features/Prop_Inq_Features/reserva/domain/entities/ambiente_entity.dart';
import 'package:condogaiaapp/features/Prop_Inq_Features/reserva/domain/usecases/reserva_usecases.dart';
import 'package:condogaiaapp/features/Prop_Inq_Features/reserva/ui/cubit/reserva_cubit.dart';
import 'package:condogaiaapp/features/Prop_Inq_Features/reserva/ui/cubit/reserva_state.dart';
import 'package:condogaiaapp/features/Prop_Inq_Features/reserva/domain/repositories/reserva_repository.dart';

// ─── Fake Repository ────────────────────────────────────────────────────────

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
    String? para,
    String? blocoUnidadeId,
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
      para: para ?? 'Condomínio',
      dataCriacao: DateTime.now(),
      dataAtualizacao: DateTime.now(),
      listaPresentes: listaPresentes,
    );
  }

  @override
  Future<void> cancelarReserva(String reservaId) async {
    if (throwError) throw Exception('Simulated Error');
    reservas.removeWhere((r) => r.id == reservaId);
  }

  @override
  Future<ReservaEntity> criarReserva({
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
    String? para,
    String? blocoUnidadeId,
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
      para: para ?? 'Condomínio',
      dataCriacao: DateTime.now(),
      dataAtualizacao: DateTime.now(),
      listaPresentes: listaPresentes,
    );
    reservas.add(nova);
    return nova;
  }

  @override
  Future<List<AmbienteEntity>> obterAmbientes(String condominioId) async {
    if (throwError) throw Exception('Simulated Error');
    return ambientes;
  }

  @override
  Future<List<ReservaEntity>> obterReservas(String condominioId) async {
    if (throwError) throw Exception('Simulated Error');
    return reservas;
  }

  @override
  Future<bool> verificarDisponibilidade({
    required String ambienteId,
    required DateTime data,
    String? reservaIdExcluir,
  }) async {
    if (throwError) throw Exception('Simulated Error');
    final dataStr =
        '${data.year}-${data.month.toString().padLeft(2, '0')}-${data.day.toString().padLeft(2, '0')}';
    for (final r in reservas) {
      final rDataStr =
          '${r.dataReserva.year}-${r.dataReserva.month.toString().padLeft(2, '0')}-${r.dataReserva.day.toString().padLeft(2, '0')}';
      if (r.ambienteId == ambienteId && rDataStr == dataStr) {
        if (reservaIdExcluir != null && r.id == reservaIdExcluir) continue;
        return false;
      }
    }
    return true;
  }
}

// ─── Helpers ────────────────────────────────────────────────────────────────

AmbienteEntity _makeAmbiente({String id = 'a1', String condominioId = 'c1'}) {
  return AmbienteEntity(
    id: id,
    nome: 'Churrasqueira',
    valor: 150,
    condominioId: condominioId,
    descricao: '',
    dataCriacao: DateTime.now(),
  );
}

// ─── Testes ─────────────────────────────────────────────────────────────────

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
      'Emitir [Loading, Carregada] ao carregar ambientes com condominioId',
      build: () => buildCubit(),
      act: (cubit) => cubit.carregarAmbientes('cond1'),
      expect: () => [const ReservaLoading(), isA<ReservaCarregada>()],
    );

    blocTest<ReservaCubit, ReservaState>(
      'Emitir [Loading, Carregada] ao carregar reservas',
      build: () => buildCubit(),
      act: (cubit) => cubit.carregarReservas('cond1'),
      expect: () => [const ReservaLoading(), isA<ReservaCarregada>()],
    );

    blocTest<ReservaCubit, ReservaState>(
      'Emitir [Loading, Carregada] ao carregar tudo com carregarTudo',
      build: () => buildCubit(),
      act: (cubit) => cubit.carregarTudo('cond1'),
      expect: () => [const ReservaLoading(), isA<ReservaCarregada>()],
    );

    blocTest<ReservaCubit, ReservaState>(
      'Emitir [ReservaErro] ao tentar criar reserva sem ambiente selecionado',
      build: () => buildCubit(),
      act: (cubit) => cubit.criarReserva(
        condominioId: 'c1',
        usuarioId: 'u1',
        termoLocacaoAceito: true,
      ),
      expect: () => [const ReservaErro(mensagem: 'Selecione um ambiente')],
    );

    blocTest<ReservaCubit, ReservaState>(
      'Emitir [ReservaErro] ao criar reserva sem aceitar o termo',
      build: () => buildCubit(),
      act: (cubit) {
        cubit.atualizarAmbienteSelecionado(_makeAmbiente());
        cubit.atualizarDataInicio(DateTime(2026, 3, 20, 10));
        cubit.atualizarDataFim(DateTime(2026, 3, 20, 12));
        cubit.criarReserva(
          condominioId: 'c1',
          usuarioId: 'u1',
          termoLocacaoAceito: false, // não aceitou
        );
      },
      expect: () => [
        isA<ReservaFormularioAtualizado>(),
        isA<ReservaFormularioAtualizado>(),
        isA<ReservaFormularioAtualizado>(),
        const ReservaErro(
          mensagem: 'É necessário aceitar os termos de locação',
        ),
      ],
    );

    blocTest<ReservaCubit, ReservaState>(
      'Emitir [FormularioAtualizado] ao interagir com os campos',
      build: () => buildCubit(),
      act: (cubit) {
        cubit.atualizarDescricao('Festa de aniversário');
        cubit.atualizarDataInicio(DateTime(2026, 3, 20, 10));
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
        cubit.atualizarAmbienteSelecionado(_makeAmbiente());
        cubit.atualizarDataInicio(DateTime(2026, 3, 20, 10));
        cubit.atualizarDataFim(DateTime(2026, 3, 20, 12));
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
      'Emitir [ReservaCriada] ao criar reserva com lista de presentes',
      build: () => buildCubit(),
      act: (cubit) {
        cubit.atualizarAmbienteSelecionado(_makeAmbiente());
        cubit.atualizarDataInicio(DateTime(2026, 3, 25, 14));
        cubit.atualizarDataFim(DateTime(2026, 3, 25, 18));
        cubit.criarReserva(
          condominioId: 'c1',
          usuarioId: 'u1',
          termoLocacaoAceito: true,
          listaPresentes: '["João","Maria"]',
        );
      },
      expect: () => [
        isA<ReservaFormularioAtualizado>(),
        isA<ReservaFormularioAtualizado>(),
        isA<ReservaFormularioAtualizado>(),
        const ReservaLoading(),
        isA<ReservaCriada>(),
      ],
      verify: (cubit) {
        expect(repository.reservas.first.listaPresentes, '["João","Maria"]');
      },
    );

    blocTest<ReservaCubit, ReservaState>(
      'Emitir [ReservaCancelada] ao cancelar reserva',
      build: () => buildCubit(),
      act: (cubit) => cubit.cancelarReserva('1'),
      expect: () => [const ReservaLoading(), isA<ReservaCancelada>()],
    );

    blocTest<ReservaCubit, ReservaState>(
      'Emitir [ReservaErro] ao criar reserva em dia já ocupado',
      build: () {
        // Adicionar reserva existente no mesmo dia
        repository.reservas.add(
          ReservaEntity(
            id: 'existente',
            ambienteId: 'a1',
            dataReserva: DateTime(2026, 3, 20),
            horaInicio: '08:00',
            horaFim: '18:00',
            local: 'Reserva existente',
            valorLocacao: 150,
            termoLocacao: true,
            para: 'Condomínio',
            dataCriacao: DateTime.now(),
            dataAtualizacao: DateTime.now(),
          ),
        );
        return buildCubit();
      },
      act: (cubit) {
        cubit.atualizarAmbienteSelecionado(_makeAmbiente(id: 'a1'));
        cubit.atualizarDataInicio(DateTime(2026, 3, 20, 14)); // mesmo dia
        cubit.atualizarDataFim(DateTime(2026, 3, 20, 16));
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
        isA<ReservaErro>(),
      ],
      verify: (cubit) {
        expect(cubit.state, isA<ReservaErro>());
        final erro = cubit.state as ReservaErro;
        expect(erro.mensagem, contains('reserva nesta data'));
      },
    );
  });
}
