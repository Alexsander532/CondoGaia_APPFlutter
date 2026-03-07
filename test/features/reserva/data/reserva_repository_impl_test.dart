import 'package:flutter_test/flutter_test.dart';
import 'package:condogaiaapp/features/Prop_Inq_Features/reserva/data/repositories/reserva_repository_impl.dart';
import 'package:condogaiaapp/features/Prop_Inq_Features/reserva/data/datasources/reserva_remote_datasource.dart';
import 'package:condogaiaapp/features/Prop_Inq_Features/reserva/data/models/reserva_model.dart';
import 'package:condogaiaapp/features/Prop_Inq_Features/reserva/data/models/ambiente_model.dart';

class FakeRemoteDataSource implements ReservaRemoteDataSource {
  bool throwError = false;

  @override
  Future<ReservaModel> atualizarReserva({
    required String reservaId,
    required String ambienteId,
    required String local,
    required DateTime dataInicio,
    required DateTime dataFim,
    required double valorLocacao,
    String? listaPresentes,
  }) async {
    if (throwError) throw Exception('Erro na fonte de dados');
    return ReservaModel(
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
    if (throwError) throw Exception('Erro na fonte de dados');
  }

  @override
  Future<ReservaModel> criarReserva({
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
    if (throwError) throw Exception('Erro na fonte de dados');
    return ReservaModel(
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
  }

  @override
  Future<List<AmbienteModel>> obterAmbientes() async {
    if (throwError) throw Exception('Erro na fonte de dados');
    return [
      AmbienteModel(
        id: '1',
        nome: 'Amb',
        valor: 10,
        descricao: 'D',
        dataCriacao: DateTime.now(),
      ),
    ];
  }

  @override
  Future<List<ReservaModel>> obterReservas(String condominioId) async {
    if (throwError) throw Exception('Erro na fonte de dados');
    return [
      ReservaModel(
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
      ),
    ];
  }
}

void main() {
  late FakeRemoteDataSource dataSource;
  late ReservaRepositoryImpl repository;

  setUp(() {
    dataSource = FakeRemoteDataSource();
    repository = ReservaRepositoryImpl(remoteDataSource: dataSource);
  });

  group('ReservaRepositoryImpl', () {
    test('ObterReservas - Sucesso', () async {
      final reservas = await repository.obterReservas('c1');
      expect(reservas.length, 1);
      expect(reservas.first.id, '1');
    });

    test('ObterReservas - Erro propagado', () async {
      dataSource.throwError = true;
      expect(() => repository.obterReservas('c1'), throwsException);
    });

    test('ObterAmbientes - Sucesso', () async {
      final ambientes = await repository.obterAmbientes();
      expect(ambientes.length, 1);
      expect(ambientes.first.id, '1');
    });

    test('CriarReserva - Sucesso', () async {
      final reserva = await repository.criarReserva(
        condominioId: 'c1',
        ambienteId: 'a1',
        local: 'L1',
        dataInicio: DateTime.now(),
        dataFim: DateTime.now(),
        valorLocacao: 10,
        termoLocacao: true,
      );
      expect(reserva.id, 'novo_id');
    });

    test('CancelarReserva - Sucesso', () async {
      await expectLater(repository.cancelarReserva('1'), completes);
    });

    test('AtualizarReserva - Sucesso', () async {
      final reserva = await repository.atualizarReserva(
        reservaId: '1',
        ambienteId: 'a1',
        local: 'L1',
        dataInicio: DateTime.now(),
        dataFim: DateTime.now(),
        valorLocacao: 10,
      );
      expect(reserva.id, '1');
    });
  });
}
