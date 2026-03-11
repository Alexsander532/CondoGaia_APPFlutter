import 'package:flutter_test/flutter_test.dart';
import 'package:condogaiaapp/features/Prop_Inq_Features/reserva/domain/entities/reserva_entity.dart';
import 'package:condogaiaapp/features/Prop_Inq_Features/reserva/domain/entities/ambiente_entity.dart';
import 'package:condogaiaapp/features/Prop_Inq_Features/reserva/domain/repositories/reserva_repository.dart';
import 'package:condogaiaapp/features/Prop_Inq_Features/reserva/domain/usecases/reserva_usecases.dart';

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
      para: para ?? antiga.para,
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
      para: para ?? 'Condomínio',
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
  Future<List<AmbienteEntity>> obterAmbientes(String condominioId) async {
    if (throwError) throw Exception('Erro simulado');
    return ambientes;
  }

  @override
  Future<List<ReservaEntity>> obterReservas(String condominioId) async {
    if (throwError) throw Exception('Erro simulado');
    return reservas;
  }

  @override
  Future<bool> verificarDisponibilidade({
    required String ambienteId,
    required DateTime data,
    String? reservaIdExcluir,
  }) async {
    if (throwError) throw Exception('Erro simulado');
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

ReservaEntity _makeReserva({
  required String id,
  required String ambienteId,
  required DateTime dataReserva,
  String horaInicio = '10:00',
  String horaFim = '12:00',
}) {
  return ReservaEntity(
    id: id,
    ambienteId: ambienteId,
    dataReserva: dataReserva,
    horaInicio: horaInicio,
    horaFim: horaFim,
    local: 'Local $id',
    valorLocacao: 100,
    termoLocacao: true,
    para: 'Condomínio',
    dataCriacao: DateTime.now(),
    dataAtualizacao: DateTime.now(),
  );
}

// ─── Testes ─────────────────────────────────────────────────────────────────

void main() {
  late FakeReservaRepository repository;

  setUp(() {
    repository = FakeReservaRepository();
  });

  // ── ObterReservasUseCase
  group('ObterReservasUseCase', () {
    test('Deve retornar a lista de reservas', () async {
      final usecase = ObterReservasUseCase(repository: repository);
      repository.reservas.add(
        _makeReserva(
          id: '1',
          ambienteId: 'a1',
          dataReserva: DateTime(2026, 1, 1),
        ),
      );

      final resultado = await usecase('cond1');
      expect(resultado.length, 1);
      expect(resultado.first.id, '1');
    });
  });

  // ── ObterAmbientesUseCase
  group('ObterAmbientesUseCase', () {
    test(
      'Deve retornar a lista de ambientes filtrada por condomínio',
      () async {
        final usecase = ObterAmbientesUseCase(repository: repository);
        repository.ambientes.add(
          AmbienteEntity(
            id: 'a1',
            nome: 'Churrasqueira',
            valor: 150,
            condominioId: 'cond1',
            descricao: 'Área de lazer',
            dataCriacao: DateTime.now(),
          ),
        );

        final resultado = await usecase('cond1');
        expect(resultado.length, 1);
        expect(resultado.first.id, 'a1');
      },
    );
  });

  // ── CriarReservaUseCase
  group('CriarReservaUseCase', () {
    test('Deve criar reserva com sucesso (sem condominioId)', () async {
      final usecase = CriarReservaUseCase(repository: repository);
      final resultado = await usecase(
        ambienteId: 'a1',
        local: 'Churrasqueira',
        dataInicio: DateTime(2026, 3, 20, 10),
        dataFim: DateTime(2026, 3, 20, 12),
        valorLocacao: 150,
        termoLocacao: true,
        inquilinoId: 'inq1',
      );

      expect(repository.reservas.length, 1);
      expect(resultado.id, 'novo_id');
      expect(resultado.local, 'Churrasqueira');
      expect(resultado.inquilinoId, 'inq1');
    });

    test('Deve criar reserva com lista de presentes (JSON)', () async {
      final usecase = CriarReservaUseCase(repository: repository);
      const listaJson = '["João","Maria","Pedro"]';
      final resultado = await usecase(
        ambienteId: 'a1',
        local: 'Salão',
        dataInicio: DateTime(2026, 3, 20, 14),
        dataFim: DateTime(2026, 3, 20, 18),
        valorLocacao: 200,
        termoLocacao: true,
        listaPresentes: listaJson,
      );

      expect(resultado.listaPresentes, listaJson);
    });

    test('Deve criar reserva com para = Bloco/Unid', () async {
      final usecase = CriarReservaUseCase(repository: repository);
      final resultado = await usecase(
        ambienteId: 'a1',
        local: 'Piscina',
        dataInicio: DateTime(2026, 3, 21, 10),
        dataFim: DateTime(2026, 3, 21, 12),
        valorLocacao: 100,
        termoLocacao: true,
        para: 'Bloco/Unid',
        blocoUnidadeId: 'bloco1',
      );

      expect(resultado.para, 'Bloco/Unid');
    });
  });

  // ── AtualizarReservaUseCase
  group('AtualizarReservaUseCase', () {
    test('Deve atualizar e retornar a reserva', () async {
      final usecase = AtualizarReservaUseCase(repository: repository);
      repository.reservas.add(
        _makeReserva(
          id: '1',
          ambienteId: 'a1',
          dataReserva: DateTime(2026, 1, 1),
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

    test('Deve atualizar reserva com nova lista de presentes', () async {
      final usecase = AtualizarReservaUseCase(repository: repository);
      repository.reservas.add(
        _makeReserva(
          id: '1',
          ambienteId: 'a1',
          dataReserva: DateTime(2026, 1, 1),
        ),
      );

      final resultado = await usecase(
        reservaId: '1',
        ambienteId: 'a1',
        local: 'L1',
        dataInicio: DateTime(2026, 1, 1, 10),
        dataFim: DateTime(2026, 1, 1, 12),
        valorLocacao: 100,
        listaPresentes: '["Alice","Bob"]',
      );

      expect(resultado.listaPresentes, '["Alice","Bob"]');
    });
  });

  // ── CancelarReservaUseCase
  group('CancelarReservaUseCase', () {
    test('Deve remover a reserva', () async {
      final usecase = CancelarReservaUseCase(repository: repository);
      repository.reservas.add(
        _makeReserva(
          id: '1',
          ambienteId: 'a1',
          dataReserva: DateTime(2026, 1, 1),
        ),
      );

      await usecase('1');
      expect(repository.reservas.isEmpty, true);
    });
  });

  // ── ValidarDisponibilidadeUseCase
  group('ValidarDisponibilidadeUseCase', () {
    late ValidarDisponibilidadeUseCase usecase;

    setUp(
      () => usecase = ValidarDisponibilidadeUseCase(repository: repository),
    );

    test('Retorna true se o dia estiver livre', () async {
      final disponivel = await usecase(
        condominioId: 'cond1',
        ambienteId: 'a1',
        dataInicio: DateTime(2026, 3, 20, 10),
        dataFim: DateTime(2026, 3, 20, 12),
      );
      expect(disponivel, true);
    });

    test(
      'Retorna false se já existe reserva no mesmo dia e mesmo ambiente',
      () async {
        repository.reservas.add(
          _makeReserva(
            id: '1',
            ambienteId: 'a1',
            dataReserva: DateTime(2026, 3, 20), // meia-noite (mesmo dia)
          ),
        );

        final disponivel = await usecase(
          condominioId: 'cond1',
          ambienteId: 'a1',
          dataInicio: DateTime(2026, 3, 20, 14),
          dataFim: DateTime(2026, 3, 20, 16),
        );
        expect(disponivel, false);
      },
    );

    test('Retorna true se reserva existente é em outro dia', () async {
      repository.reservas.add(
        _makeReserva(
          id: '1',
          ambienteId: 'a1',
          dataReserva: DateTime(2026, 3, 19),
        ),
      );

      final disponivel = await usecase(
        condominioId: 'cond1',
        ambienteId: 'a1',
        dataInicio: DateTime(2026, 3, 20, 10),
        dataFim: DateTime(2026, 3, 20, 12),
      );
      expect(disponivel, true);
    });

    test('Retorna true se reserva é de outro ambiente no mesmo dia', () async {
      repository.reservas.add(
        _makeReserva(
          id: '1',
          ambienteId: 'a2', // outro ambiente
          dataReserva: DateTime(2026, 3, 20),
        ),
      );

      final disponivel = await usecase(
        condominioId: 'cond1',
        ambienteId: 'a1', // ambiente diferente
        dataInicio: DateTime(2026, 3, 20, 10),
        dataFim: DateTime(2026, 3, 20, 12),
      );
      expect(disponivel, true);
    });

    test(
      'Retorna true ao editar se excluir própria reserva da validação',
      () async {
        repository.reservas.add(
          _makeReserva(
            id: 'minha_reserva',
            ambienteId: 'a1',
            dataReserva: DateTime(2026, 3, 20),
          ),
        );

        final disponivel = await usecase(
          condominioId: 'cond1',
          ambienteId: 'a1',
          dataInicio: DateTime(2026, 3, 20, 10),
          dataFim: DateTime(2026, 3, 20, 12),
          reservaIdExcluir: 'minha_reserva', // permite editar a própria reserva
        );
        expect(disponivel, true);
      },
    );
  });
}
