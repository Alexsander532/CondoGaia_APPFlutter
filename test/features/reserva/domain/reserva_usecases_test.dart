import 'package:flutter_test/flutter_test.dart';
import 'package:condogaiaapp/features/Prop_Inq_Features/reserva/domain/entities/reserva_entity.dart';
import 'package:condogaiaapp/features/Prop_Inq_Features/reserva/domain/entities/ambiente_entity.dart';
import 'package:condogaiaapp/features/Prop_Inq_Features/reserva/domain/repositories/reserva_repository.dart';
import 'package:condogaiaapp/features/Prop_Inq_Features/reserva/domain/usecases/reserva_usecases.dart';

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
    if (throwError) throw Exception('Erro simulado');
    final index = reservas.indexWhere((r) => r.id == reservaId);
    final antiga = reservas[index];
    final atualizada = ReservaEntity(
      id: reservaId,
      ambienteId: ambienteId,
      local: local,
      dataReserva: dataInicio,
      horaInicio: '${dataInicio.hour}:${dataInicio.minute}',
      horaFim: '${dataFim.hour}:${dataFim.minute}',
      valorLocacao: valorLocacao,
      termoLocacao: antiga.termoLocacao,
      para: antiga.para,
      dataCriacao: antiga.dataCriacao,
      dataAtualizacao: DateTime.now(),
      listaPresentes: listaPresentes,
    );
    reservas[index] = atualizada;
    return atualizada;
  }

  @override
  Future<void> cancelarReserva(String reservaId) async {
    if (throwError) throw Exception('Erro simulado');
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
    if (throwError) throw Exception('Erro simulado');
    final nova = ReservaEntity(
      id: 'novo_id',
      ambienteId: ambienteId,
      local: local,
      dataReserva: DateTime(dataInicio.year, dataInicio.month, dataInicio.day),
      horaInicio: '${dataInicio.hour}:${dataInicio.minute}',
      horaFim: '${dataFim.hour}:${dataFim.minute}',
      valorLocacao: valorLocacao,
      termoLocacao: termoLocacao,
      para: 'Condominio',
      representanteId: representanteId,
      inquilinoId: inquilinoId,
      proprietarioId: proprietarioId,
      dataCriacao: DateTime.now(),
      dataAtualizacao: DateTime.now(),
      listaPresentes: listaPresentes,
    );
    reservas.add(nova);
    return nova;
  }

  @override
  Future<List<AmbienteEntity>> obterAmbientes() async {
    if (throwError) throw Exception('Erro simulado');
    return ambientes;
  }

  @override
  Future<List<ReservaEntity>> obterReservas(String condominioId) async {
    if (throwError) throw Exception('Erro simulado');
    return reservas;
  }
}

void main() {
  late FakeReservaRepository repository;

  setUp(() {
    repository = FakeReservaRepository();
  });

  group('ObterReservasUseCase', () {
    test('Deve retornar a lista de reservas', () async {
      final usecase = ObterReservasUseCase(repository: repository);
      repository.reservas.add(
        ReservaEntity(
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
      );

      final resultado = await usecase('cond1');
      expect(resultado.length, 1);
      expect(resultado.first.id, '1');
    });
  });

  group('ObterAmbientesUseCase', () {
    test('Deve retornar a lista de ambientes', () async {
      final usecase = ObterAmbientesUseCase(repository: repository);
      repository.ambientes.add(
        AmbienteEntity(
          id: 'a1',
          nome: 'Amb',
          valor: 10,
          condominioId: 'c1',
          descricao: 'D',
          tipo: 'T',
          capacidadeMaxima: 10,
          dataCriacao: DateTime.now(),
        ),
      );

      final resultado = await usecase();
      expect(resultado.length, 1);
      expect(resultado.first.id, 'a1');
    });
  });

  group('CriarReservaUseCase', () {
    test('Deve criar reserva com sucesso', () async {
      final usecase = CriarReservaUseCase(repository: repository);
      final resultado = await usecase(
        condominioId: 'c1',
        ambienteId: 'a1',
        local: 'L1',
        dataInicio: DateTime(2026, 1, 1, 10),
        dataFim: DateTime(2026, 1, 1, 12),
        valorLocacao: 100,
        termoLocacao: true,
      );
      expect(repository.reservas.length, 1);
      expect(resultado.id, 'novo_id');
      expect(resultado.local, 'L1');
    });
  });

  group('AtualizarReservaUseCase', () {
    test('Deve atualizar e retornar a reserva', () async {
      final usecase = AtualizarReservaUseCase(repository: repository);
      repository.reservas.add(
        ReservaEntity(
          id: '1',
          ambienteId: 'a1',
          dataReserva: DateTime(2026, 1, 1),
          horaInicio: '10:00',
          horaFim: '12:00',
          local: 'L1',
          valorLocacao: 10,
          termoLocacao: true,
          para: 'P1',
          dataCriacao: DateTime.now(),
          dataAtualizacao: DateTime.now(),
        ),
      );

      final resultado = await usecase(
        reservaId: '1',
        ambienteId: 'a1',
        local: 'Novo Local',
        dataInicio: DateTime(2026, 1, 1, 14),
        dataFim: DateTime(2026, 1, 1, 16),
        valorLocacao: 200,
      );

      expect(resultado.local, 'Novo Local');
      expect(resultado.valorLocacao, 200.0);
    });
  });

  group('CancelarReservaUseCase', () {
    test('Deve remover a reserva', () async {
      final usecase = CancelarReservaUseCase(repository: repository);
      repository.reservas.add(
        ReservaEntity(
          id: '1',
          ambienteId: 'a1',
          dataReserva: DateTime(2026, 1, 1),
          horaInicio: '10:00',
          horaFim: '12:00',
          local: 'L1',
          valorLocacao: 10,
          termoLocacao: true,
          para: 'P1',
          dataCriacao: DateTime.now(),
          dataAtualizacao: DateTime.now(),
        ),
      );

      await usecase('1');
      expect(repository.reservas.isEmpty, true);
    });
  });

  group('ValidarDisponibilidadeUseCase', () {
    late ValidarDisponibilidadeUseCase usecase;

    setUp(
      () => usecase = ValidarDisponibilidadeUseCase(repository: repository),
    );

    test('Retorna true se o dia esta livre', () async {
      final disp = await usecase(
        condominioId: 'c1',
        ambienteId: 'a1',
        dataInicio: DateTime(2026, 1, 10, 10),
        dataFim: DateTime(2026, 1, 10, 12),
      );
      expect(disp, true);
    });

    test('Retorna false se sobrepoe no mesmo moment (mesmo dia)', () async {
      repository.reservas.add(
        ReservaEntity(
          id: '1',
          ambienteId: 'a1',
          dataReserva: DateTime(2026, 1, 10), // meia-noite
          horaInicio: '08:00',
          horaFim: '18:00',
          local: 'L1',
          valorLocacao: 10,
          termoLocacao: true,
          para: 'P1',
          dataCriacao: DateTime.now(),
          dataAtualizacao: DateTime.now(),
        ),
      );

      final disp = await usecase(
        condominioId: 'c1',
        ambienteId: 'a1',
        dataInicio: DateTime(2026, 1, 10), // mesmo moment
        dataFim: DateTime(2026, 1, 10),
      );
      expect(disp, false);
    });
  });
}
