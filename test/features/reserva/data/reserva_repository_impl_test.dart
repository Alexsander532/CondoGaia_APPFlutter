import 'package:flutter_test/flutter_test.dart';
import 'package:condogaiaapp/features/Prop_Inq_Features/reserva/data/repositories/reserva_repository_impl.dart';
import 'package:condogaiaapp/features/Prop_Inq_Features/reserva/data/datasources/reserva_remote_datasource.dart';
import 'package:condogaiaapp/features/Prop_Inq_Features/reserva/data/models/reserva_model.dart';
import 'package:condogaiaapp/features/Prop_Inq_Features/reserva/data/models/ambiente_model.dart';

class FakeRemoteDataSource implements ReservaRemoteDataSource {
  bool throwError = false;
  List<ReservaModel> _reservas = [];

  @override
  Future<ReservaModel> atualizarReserva({
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
      para: para ?? 'Condomínio',
      dataCriacao: DateTime.now(),
      dataAtualizacao: DateTime.now(),
      listaPresentes: listaPresentes,
    );
  }

  @override
  Future<void> cancelarReserva(String reservaId) async {
    if (throwError) throw Exception('Erro na fonte de dados');
  }

  @override
  Future<ReservaModel> criarReserva({
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
      para: para ?? 'Condomínio',
      dataCriacao: DateTime.now(),
      dataAtualizacao: DateTime.now(),
      listaPresentes: listaPresentes,
    );
  }

  @override
  Future<List<AmbienteModel>> obterAmbientes(String condominioId) async {
    if (throwError) throw Exception('Erro na fonte de dados');
    return [
      AmbienteModel(
        id: '1',
        nome: 'Churrasqueira',
        valor: 150,
        condominioId: condominioId,
        descricao: 'Área de lazer',
        dataCriacao: DateTime.now(),
      ),
    ];
  }

  @override
  Future<List<ReservaModel>> obterReservas(String condominioId) async {
    if (throwError) throw Exception('Erro na fonte de dados');
    if (_reservas.isNotEmpty) return _reservas;
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
        para: 'Condomínio',
        dataCriacao: DateTime.now(),
        dataAtualizacao: DateTime.now(),
      ),
    ];
  }

  @override
  Future<bool> verificarDisponibilidade({
    required String ambienteId,
    required DateTime data,
    String? reservaIdExcluir,
  }) async {
    if (throwError) throw Exception('Erro na fonte de dados');
    final dataStr = data.toIso8601String().split('T')[0];
    for (final r in _reservas) {
      if (r.ambienteId == ambienteId &&
          r.dataReserva.toIso8601String().split('T')[0] == dataStr) {
        if (reservaIdExcluir != null && r.id == reservaIdExcluir) continue;
        return false;
      }
    }
    return true;
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

    test('ObterAmbientes - Sucesso filtrado por condominioId', () async {
      final ambientes = await repository.obterAmbientes('cond1');
      expect(ambientes.length, 1);
      expect(ambientes.first.id, '1');
    });

    test('ObterAmbientes - Erro propagado', () async {
      dataSource.throwError = true;
      expect(() => repository.obterAmbientes('cond1'), throwsException);
    });

    test('CriarReserva - Sucesso (sem condominioId)', () async {
      final reserva = await repository.criarReserva(
        ambienteId: 'a1',
        local: 'Churrasqueira',
        dataInicio: DateTime(2026, 3, 20, 10),
        dataFim: DateTime(2026, 3, 20, 12),
        valorLocacao: 150,
        termoLocacao: true,
        inquilinoId: 'inq1',
      );
      expect(reserva.id, 'novo_id');
    });

    test('CriarReserva - Com lista de presentes', () async {
      const lista = '["João","Maria"]';
      final reserva = await repository.criarReserva(
        ambienteId: 'a1',
        local: 'Salão',
        dataInicio: DateTime(2026, 3, 20, 14),
        dataFim: DateTime(2026, 3, 20, 18),
        valorLocacao: 200,
        termoLocacao: true,
        listaPresentes: lista,
      );
      expect(reserva.listaPresentes, lista);
    });

    test('CancelarReserva - Sucesso', () async {
      await expectLater(repository.cancelarReserva('1'), completes);
    });

    test('AtualizarReserva - Sucesso', () async {
      final reserva = await repository.atualizarReserva(
        reservaId: '1',
        ambienteId: 'a1',
        local: 'Novo Local',
        dataInicio: DateTime(2026, 3, 20, 10),
        dataFim: DateTime(2026, 3, 20, 12),
        valorLocacao: 200,
      );
      expect(reserva.id, '1');
      expect(reserva.local, 'Novo Local');
    });
  });
}
