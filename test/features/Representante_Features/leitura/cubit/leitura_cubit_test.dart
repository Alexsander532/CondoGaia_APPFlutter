import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:condogaiaapp/features/Representante_Features/leitura/cubit/leitura_cubit.dart';
import 'package:condogaiaapp/features/Representante_Features/leitura/cubit/leitura_state.dart';
import 'package:condogaiaapp/features/Representante_Features/leitura/services/leitura_service.dart';
import 'package:condogaiaapp/features/Representante_Features/leitura/models/leitura_model.dart';
import 'package:condogaiaapp/features/Representante_Features/leitura/models/leitura_configuracao_model.dart';
import 'package:condogaiaapp/models/unidade.dart';

class MockLeituraService extends Mock implements LeituraService {}

class FakeLeituraModel extends Fake implements LeituraModel {}

void main() {
  late MockLeituraService mockService;
  late LeituraCubit cubit;

  final tUnidade = Unidade(
    id: 'uni-1',
    condominioId: 'cond-1',
    bloco: 'A',
    numero: '101',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  final tLeituraModel = LeituraModel(
    id: 'leit-1',
    unidadeId: 'uni-1',
    bloco: 'A',
    unidadeNome: '101',
    leituraAnterior: 100.0,
    leituraAtual: 110.0,
    valor: 100.0,
    dataLeitura: DateTime(2026, 2, 7),
    tipo: 'Agua',
  );

  final tConfig = LeituraConfiguracaoModel(
    condominioId: 'cond-1',
    tipo: 'Agua',
    valorBase: 10.0,
  );

  setUpAll(() {
    registerFallbackValue(FakeLeituraModel());
  });

  setUp(() {
    mockService = MockLeituraService();

    when(
      () => mockService.clearLeiturasCache(any(), any()),
    ).thenAnswer((_) async {});
    when(
      () => mockService.clearConfigCache(any(), any()),
    ).thenAnswer((_) async {});
    when(() => mockService.fetchUnidades(any())).thenAnswer((_) async => []);
    when(
      () => mockService.fetchLeituras(
        condominioId: any(named: 'condominioId'),
        tipo: any(named: 'tipo'),
        month: any(named: 'month'),
        year: any(named: 'year'),
      ),
    ).thenAnswer((_) async => []);
    when(
      () => mockService.fetchConfiguracao(
        condominioId: any(named: 'condominioId'),
        tipo: any(named: 'tipo'),
      ),
    ).thenAnswer((_) async => null);
    when(
      () => mockService.fetchLeiturasAnteriores(
        condominioId: any(named: 'condominioId'),
        tipo: any(named: 'tipo'),
        month: any(named: 'month'),
        year: any(named: 'year'),
      ),
    ).thenAnswer((_) async => {});
    when(
      () => mockService.fetchTodasConfiguracoes(any()),
    ).thenAnswer((_) async => []);

    cubit = LeituraCubit(service: mockService, condominioId: 'cond-1');
  });

  tearDown(() {
    cubit.close();
  });

  group('LeituraCubit - Load e Filtros', () {
    test('estado inicial está correto', () {
      expect(cubit.state.status, LeituraStatus.initial);
      expect(cubit.state.selectedTipo, 'Agua');
      expect(cubit.state.selectedDate.day, DateTime.now().day);
    });

    blocTest<LeituraCubit, LeituraState>(
      'loadLeituras: emite success com as listas mergeadas corretamente',
      build: () {
        when(
          () => mockService.fetchUnidades(any()),
        ).thenAnswer((_) async => [tUnidade]);
        when(
          () => mockService.fetchLeituras(
            condominioId: any(named: 'condominioId'),
            tipo: any(named: 'tipo'),
            month: any(named: 'month'),
            year: any(named: 'year'),
          ),
        ).thenAnswer((_) async => [tLeituraModel]);
        when(
          () => mockService.fetchConfiguracao(
            condominioId: any(named: 'condominioId'),
            tipo: any(named: 'tipo'),
          ),
        ).thenAnswer((_) async => tConfig);
        return cubit;
      },
      act: (cubit) => cubit.loadLeituras(),
      expect: () => [
        isA<LeituraState>().having(
          (s) => s.status,
          'status',
          LeituraStatus.loading,
        ),
        isA<LeituraState>()
            .having((s) => s.status, 'status', LeituraStatus.success)
            .having((s) => s.leituras.length, 'length', 1)
            .having((s) => s.leituras.first.unidadeId, 'unidadeId', 'uni-1')
            .having((s) => s.configuracao?.valorBase, 'valorBase', 10.0),
      ],
    );

    blocTest<LeituraCubit, LeituraState>(
      'loadLeituras: emite error em caso de exceção',
      build: () {
        when(
          () => mockService.fetchUnidades(any()),
        ).thenThrow(Exception('Falha na rede'));
        return cubit;
      },
      act: (cubit) => cubit.loadLeituras(),
      expect: () => [
        isA<LeituraState>().having(
          (s) => s.status,
          'status',
          LeituraStatus.loading,
        ),
        isA<LeituraState>()
            .having((s) => s.status, 'status', LeituraStatus.error)
            .having(
              (s) => s.errorMessage,
              'errorMessage',
              contains('Falha na rede'),
            ),
      ],
    );

    blocTest<LeituraCubit, LeituraState>(
      'updateTipo: altera o tipo e dispara loadLeituras',
      build: () => cubit,
      act: (cubit) => cubit.updateTipo('Gas'),
      expect: () => [
        isA<LeituraState>().having((s) => s.selectedTipo, 'tipo', 'Gas'),
        isA<LeituraState>().having(
          (s) => s.status,
          'status',
          LeituraStatus.loading,
        ),
        isA<LeituraState>().having(
          (s) => s.status,
          'status',
          LeituraStatus.success,
        ),
      ],
    );

    blocTest<LeituraCubit, LeituraState>(
      'updateSearch: atualiza o termo de pesquisa',
      build: () => cubit,
      act: (cubit) => cubit.updateSearch('Bloco A'),
      expect: () => [
        isA<LeituraState>().having(
          (s) => s.unidadePesquisa,
          'pesquisa',
          'Bloco A',
        ),
      ],
    );
  });

  group('LeituraCubit - Gravação e Deleção', () {
    final tModelSemAtual = LeituraModel(
      id: '',
      unidadeId: 'uni-1',
      bloco: 'A',
      unidadeNome: '101',
      leituraAnterior: 100.0,
      leituraAtual: 0.0,
      valor: 0.0,
      dataLeitura: DateTime(2026, 2, 7),
      tipo: 'Agua',
    );

    blocTest<LeituraCubit, LeituraState>(
      'gravarLeitura: erro se leituraAtual < leituraAnterior',
      build: () => cubit,
      seed: () => LeituraState(
        selectedDate: DateTime(2026, 2, 7),
        status: LeituraStatus.success,
        leituras: [tModelSemAtual],
      ),
      act: (cubit) =>
          cubit.gravarLeitura(unidadeId: 'uni-1', leituraAtual: 50.0),
      expect: () => [
        isA<LeituraState>().having(
          (s) => s.errorMessage,
          'errorMessage',
          'Leitura atual não pode ser menor que a anterior',
        ),
      ],
    );

    blocTest<LeituraCubit, LeituraState>(
      'gravarLeitura: calcula valor corretamente e chama service.saveLeitura',
      build: () {
        when(
          () => mockService.saveLeitura(
            any(),
            any(),
            imagem: any(named: 'imagem'),
          ),
        ).thenAnswer((_) async {});
        // Mock loadLeituras to prevent secondary states from muddying
        when(
          () => mockService.fetchUnidades(any()),
        ).thenAnswer((_) async => []);
        return cubit;
      },
      seed: () => LeituraState(
        selectedDate: DateTime(2026, 2, 7),
        status: LeituraStatus.success,
        leituras: [tModelSemAtual],
        configuracao: tConfig, // valorBase = 10
      ),
      act: (cubit) =>
          cubit.gravarLeitura(unidadeId: 'uni-1', leituraAtual: 115.0),
      // Expect the list update with calculations (115 - 100) * 10 = 150
      expect: () => [
        isA<LeituraState>()
            .having((s) => s.leituras.first.leituraAtual, 'leituraAtual', 115.0)
            .having(
              (s) => s.leituras.first.valor,
              'valorCalculado',
              150.0,
            ), // 15 * 10
        isA<LeituraState>().having(
          (s) => s.status,
          'status',
          LeituraStatus.loading,
        ), // from the automatic loadLeituras
        isA<LeituraState>().having(
          (s) => s.status,
          'status',
          LeituraStatus.success,
        ),
      ],
      verify: (_) {
        verify(
          () => mockService.saveLeitura(
            any(),
            any(),
            imagem: any(named: 'imagem'),
          ),
        ).called(1);
      },
    );

    blocTest<LeituraCubit, LeituraState>(
      'toggleSelection: atualiza o checkbox da unidade',
      build: () => cubit,
      seed: () => LeituraState(
        selectedDate: DateTime(2026, 2, 7),
        status: LeituraStatus.success,
        leituras: [tModelSemAtual],
      ),
      act: (cubit) => cubit.toggleSelection('uni-1', true),
      expect: () => [
        isA<LeituraState>().having(
          (s) => s.leituras.first.isSelected,
          'isSelected',
          true,
        ),
      ],
    );

    blocTest<LeituraCubit, LeituraState>(
      'deleteSelected: chama o delete para itens marcados e recarrega',
      build: () {
        when(() => mockService.deleteLeitura(any())).thenAnswer((_) async {});
        return cubit;
      },
      seed: () => LeituraState(
        selectedDate: DateTime(2026, 2, 7),
        status: LeituraStatus.success,
        leituras: [tLeituraModel.copyWith(isSelected: true)], // Has id: leit-1
      ),
      act: (cubit) => cubit.deleteSelected(),
      expect: () => [
        isA<LeituraState>().having(
          (s) => s.status,
          'status',
          LeituraStatus.loading,
        ),
        isA<LeituraState>().having(
          (s) => s.status,
          'status',
          LeituraStatus.success,
        ),
      ],
      verify: (_) {
        verify(() => mockService.deleteLeitura('leit-1')).called(1);
      },
    );
  });
}
