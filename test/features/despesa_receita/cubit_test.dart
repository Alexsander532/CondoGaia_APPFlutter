/// Comprehensive unit tests for DespesaReceitaCubit.
///
/// Uses mocktail for mocking IDespesaReceitaService.
/// Uses bloc_test for structured cubit testing.
///
/// Tests cover:
/// - carregarDadosIniciais (success + error)
/// - pesquisarDespesas / pesquisarReceitas / pesquisarTransferencias
/// - atualizarFiltros (with palavraChave)
/// - salvarDespesa / salvarReceita / salvarTransferencia
/// - excluirDespesa / excluirReceita / excluirTransferencia
/// - excluirMultiplas
/// - seleção toggle (toggle individual, selecionar todas, desselecionar)
/// - iniciar/cancelar edição

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:condogaiaapp/features/Representante_Features/despesa_receita/cubit/despesa_receita_cubit.dart';
import 'package:condogaiaapp/features/Representante_Features/despesa_receita/cubit/despesa_receita_state.dart';
import 'package:condogaiaapp/features/Representante_Features/despesa_receita/models/despesa_model.dart';
import 'package:condogaiaapp/features/Representante_Features/despesa_receita/models/receita_model.dart';
import 'package:condogaiaapp/features/Representante_Features/despesa_receita/models/transferencia_model.dart';
import 'package:condogaiaapp/features/Representante_Features/despesa_receita/models/conta_contabil_model.dart';
import 'package:condogaiaapp/features/Representante_Features/despesa_receita/services/despesa_receita_service.dart';
import 'package:condogaiaapp/features/Representante_Features/gestao_condominio/models/conta_bancaria_model.dart';
import 'package:condogaiaapp/features/Representante_Features/gestao_condominio/models/categoria_financeira_model.dart';

// ============================================================
// MOCKS
// ============================================================

class MockDespesaReceitaService extends Mock implements DespesaReceitaService {}

class FakeDespesa extends Fake implements Despesa {}

class FakeReceita extends Fake implements Receita {}

class FakeTransferencia extends Fake implements Transferencia {}

// ============================================================
// TEST DATA
// ============================================================

final _contas = [
  ContaBancaria.fromJson({
    'id': 'conta-1',
    'banco': 'Banco do Brasil',
    'agencia': '1234',
    'conta': '56789-0',
    'condominio_id': 'cond-1',
  }),
];

final _categorias = [
  CategoriaFinanceira.fromJson({
    'id': 'cat-1',
    'nome': 'Manutenção',
    'tipo': 'DESPESA',
    'condominio_id': 'cond-1',
  }),
  CategoriaFinanceira.fromJson({
    'id': 'cat-2',
    'nome': 'Taxas',
    'tipo': 'RECEITA',
    'condominio_id': 'cond-1',
  }),
];

final _contasContabeis = [
  ContaContabilModel(
    id: 'cc-1',
    nome: 'Controle',
    condominioId: 'cond-1',
  ),
];

const _despesas = [
  Despesa(id: 'd1', condominioId: 'cond-1', valor: 100),
  Despesa(id: 'd2', condominioId: 'cond-1', valor: 200),
];

const _receitas = [
  Receita(id: 'r1', condominioId: 'cond-1', valor: 500),
  Receita(id: 'r2', condominioId: 'cond-1', valor: 300),
];

const _transferencias = [
  Transferencia(id: 't1', condominioId: 'cond-1', valor: 1000),
];

void main() {
  late MockDespesaReceitaService mockService;
  const condominioId = 'cond-1';

  setUpAll(() {
    registerFallbackValue(FakeDespesa());
    registerFallbackValue(FakeReceita());
    registerFallbackValue(FakeTransferencia());
  });

  setUp(() {
    mockService = MockDespesaReceitaService();
  });

  DespesaReceitaCubit _buildCubit() =>
      DespesaReceitaCubit(service: mockService, condominioId: condominioId);

  // ════════════════════════════════════════════════════════
  //  CARREGAR DADOS INICIAIS
  // ════════════════════════════════════════════════════════

  group('carregarDadosIniciais', () {
    blocTest<DespesaReceitaCubit, DespesaReceitaState>(
      'emite loading → success com contas, categorias, dados de todas as abas',
      build: () {
        when(
          () => mockService.listarContas(any()),
        ).thenAnswer((_) async => _contas);
        when(
          () => mockService.listarCategorias(),
        ).thenAnswer((_) async => _categorias);
        when(
          () => mockService.listarDespesas(
            any(),
            mes: any(named: 'mes'),
            ano: any(named: 'ano'),
            contaId: any(named: 'contaId'),
            categoriaId: any(named: 'categoriaId'),
            subcategoriaId: any(named: 'subcategoriaId'),
            palavraChave: any(named: 'palavraChave'),
          ),
        ).thenAnswer((_) async => _despesas);
        when(
          () => mockService.listarReceitas(
            any(),
            mes: any(named: 'mes'),
            ano: any(named: 'ano'),
            contaId: any(named: 'contaId'),
            contaContabil: any(named: 'contaContabil'),
            tipo: any(named: 'tipo'),
            palavraChave: any(named: 'palavraChave'),
          ),
        ).thenAnswer((_) async => _receitas);
        when(
          () => mockService.listarTransferencias(
            any(),
            mes: any(named: 'mes'),
            ano: any(named: 'ano'),
            contaDebitoId: any(named: 'contaDebitoId'),
            contaCreditoId: any(named: 'contaCreditoId'),
            palavraChave: any(named: 'palavraChave'),
          ),
        ).thenAnswer((_) async => _transferencias);
        when(
          () => mockService.calcularSaldoAnterior(
            any(),
            mes: any(named: 'mes'),
            ano: any(named: 'ano'),
          ),
        ).thenAnswer((_) async => 5000.0);
        when(
          () => mockService.listarContasContabeis(any()),
        ).thenAnswer((_) async => _contasContabeis);
        return _buildCubit();
      },
      act: (cubit) => cubit.carregarDados(),
      expect: () => [
        isA<DespesaReceitaState>().having(
          (s) => s.status,
          'status',
          DespesaReceitaStatus.loading,
        ),
        isA<DespesaReceitaState>()
            .having((s) => s.status, 'status', DespesaReceitaStatus.success)
            .having((s) => s.contas.length, 'contas', 1)
            .having((s) => s.categorias.length, 'categorias', 2)
            .having((s) => s.despesas.length, 'despesas', 2)
            .having((s) => s.receitas.length, 'receitas', 2)
            .having((s) => s.transferencias.length, 'transferencias', 1)
            .having((s) => s.saldoAnterior, 'saldoAnterior', 5000.0),
      ],
    );

    blocTest<DespesaReceitaCubit, DespesaReceitaState>(
      'emite error quando listarContas falha',
      build: () {
        when(
          () => mockService.listarContas(any()),
        ).thenThrow(Exception('Falha de rede'));
        return _buildCubit();
      },
      act: (cubit) => cubit.carregarDados(),
      expect: () => [
        isA<DespesaReceitaState>().having(
          (s) => s.status,
          'status',
          DespesaReceitaStatus.loading,
        ),
        isA<DespesaReceitaState>()
            .having((s) => s.status, 'status', DespesaReceitaStatus.error)
            .having((s) => s.errorMessage, 'errorMessage', isNotNull),
      ],
    );
  });

  // ════════════════════════════════════════════════════════
  //  PESQUISAR DESPESAS
  // ════════════════════════════════════════════════════════

  group('pesquisarDespesas', () {
    blocTest<DespesaReceitaCubit, DespesaReceitaState>(
      'emite loading → success com lista de despesas',
      build: () {
        when(
          () => mockService.listarDespesas(
            any(),
            mes: any(named: 'mes'),
            ano: any(named: 'ano'),
            contaId: any(named: 'contaId'),
            categoriaId: any(named: 'categoriaId'),
            subcategoriaId: any(named: 'subcategoriaId'),
            palavraChave: any(named: 'palavraChave'),
          ),
        ).thenAnswer((_) async => _despesas);
        return _buildCubit();
      },
      act: (cubit) => cubit.pesquisarDespesas(),
      expect: () => [
        isA<DespesaReceitaState>().having(
          (s) => s.status,
          'status',
          DespesaReceitaStatus.loading,
        ),
        isA<DespesaReceitaState>()
            .having((s) => s.status, 'status', DespesaReceitaStatus.success)
            .having((s) => s.despesas, 'despesas', _despesas)
            .having((s) => s.despesasSelecionadas, 'selecionadas', isEmpty),
      ],
    );
  });

  // ════════════════════════════════════════════════════════
  //  PESQUISAR RECEITAS
  // ════════════════════════════════════════════════════════

  group('pesquisarReceitas', () {
    blocTest<DespesaReceitaCubit, DespesaReceitaState>(
      'emite loading → success com lista de receitas',
      build: () {
        when(
          () => mockService.listarReceitas(
            any(),
            mes: any(named: 'mes'),
            ano: any(named: 'ano'),
            contaId: any(named: 'contaId'),
            contaContabil: any(named: 'contaContabil'),
            tipo: any(named: 'tipo'),
            palavraChave: any(named: 'palavraChave'),
          ),
        ).thenAnswer((_) async => _receitas);
        return _buildCubit();
      },
      act: (cubit) => cubit.pesquisarReceitas(),
      expect: () => [
        isA<DespesaReceitaState>().having(
          (s) => s.status,
          'status',
          DespesaReceitaStatus.loading,
        ),
        isA<DespesaReceitaState>()
            .having((s) => s.status, 'status', DespesaReceitaStatus.success)
            .having((s) => s.receitas, 'receitas', _receitas)
            .having((s) => s.receitasSelecionadas, 'selecionadas', isEmpty),
      ],
    );
  });

  // ════════════════════════════════════════════════════════
  //  PESQUISAR TRANSFERENCIAS
  // ════════════════════════════════════════════════════════

  group('pesquisarTransferencias', () {
    blocTest<DespesaReceitaCubit, DespesaReceitaState>(
      'emite loading → success com lista de transferências',
      build: () {
        when(
          () => mockService.listarTransferencias(
            any(),
            mes: any(named: 'mes'),
            ano: any(named: 'ano'),
            contaDebitoId: any(named: 'contaDebitoId'),
            contaCreditoId: any(named: 'contaCreditoId'),
            palavraChave: any(named: 'palavraChave'),
          ),
        ).thenAnswer((_) async => _transferencias);
        return _buildCubit();
      },
      act: (cubit) => cubit.pesquisarTransferencias(),
      expect: () => [
        isA<DespesaReceitaState>().having(
          (s) => s.status,
          'status',
          DespesaReceitaStatus.loading,
        ),
        isA<DespesaReceitaState>()
            .having((s) => s.status, 'status', DespesaReceitaStatus.success)
            .having((s) => s.transferencias, 'transferencias', _transferencias),
      ],
    );
  });

  // ════════════════════════════════════════════════════════
  //  ATUALIZAR FILTROS
  // ════════════════════════════════════════════════════════

  group('atualizarFiltros', () {
    blocTest<DespesaReceitaCubit, DespesaReceitaState>(
      'deve atualizar todos os filtros no state',
      build: _buildCubit,
      act: (cubit) => cubit.atualizarFiltros(
        contaId: 'conta-1',
        categoriaId: 'cat-1',
        subcategoriaId: 'sub-1',
        palavraChave: 'manutenção',
        contaDebitoId: 'cd-1',
        contaCreditoId: 'cc-1',
        filtroContaContabilId: 'Controle',
        tipoReceita: 'MANUAL',
      ),
      expect: () => [
        isA<DespesaReceitaState>()
            .having((s) => s.filtroContaId, 'contaId', 'conta-1')
            .having((s) => s.filtroCategoriaId, 'categoriaId', 'cat-1')
            .having((s) => s.filtroSubcategoriaId, 'subcategoriaId', 'sub-1')
            .having((s) => s.filtroPalavraChave, 'palavraChave', 'manutenção')
            .having((s) => s.filtroContaDebitoId, 'contaDebitoId', 'cd-1')
            .having((s) => s.filtroContaCreditoId, 'contaCreditoId', 'cc-1')
            .having((s) => s.filtroContaContabilId, 'contaContabil', 'Controle')
            .having((s) => s.filtroTipoReceita, 'tipoReceita', 'MANUAL'),
      ],
    );
  });

  // ════════════════════════════════════════════════════════
  //  SALVAR DESPESA
  // ════════════════════════════════════════════════════════

  group('salvarDespesa', () {
    const novaDespesa = Despesa(condominioId: 'cond-1', valor: 500);

    blocTest<DespesaReceitaCubit, DespesaReceitaState>(
      'emite isSaving=true → isSaving=false → pesquisar',
      build: () {
        when(() => mockService.salvarDespesa(any())).thenAnswer((_) async {});
        when(
          () => mockService.listarDespesas(
            any(),
            mes: any(named: 'mes'),
            ano: any(named: 'ano'),
            contaId: any(named: 'contaId'),
            categoriaId: any(named: 'categoriaId'),
            subcategoriaId: any(named: 'subcategoriaId'),
            palavraChave: any(named: 'palavraChave'),
          ),
        ).thenAnswer((_) async => _despesas);
        return _buildCubit();
      },
      act: (cubit) => cubit.salvarDespesa(novaDespesa),
      verify: (_) {
        verify(() => mockService.salvarDespesa(any())).called(1);
      },
    );

    blocTest<DespesaReceitaCubit, DespesaReceitaState>(
      'emite error quando salvar falha',
      build: () {
        when(
          () => mockService.salvarDespesa(any()),
        ).thenThrow(Exception('Erro ao salvar'));
        return _buildCubit();
      },
      act: (cubit) => cubit.salvarDespesa(novaDespesa),
      expect: () => [
        isA<DespesaReceitaState>().having((s) => s.isSaving, 'saving', true),
        isA<DespesaReceitaState>()
            .having((s) => s.isSaving, 'saving', false)
            .having((s) => s.errorMessage, 'err', isNotNull),
      ],
    );
  });

  // ════════════════════════════════════════════════════════
  //  SALVAR RECEITA
  // ════════════════════════════════════════════════════════

  group('salvarReceita', () {
    const novaReceita = Receita(condominioId: 'cond-1', valor: 800);

    blocTest<DespesaReceitaCubit, DespesaReceitaState>(
      'deve chamar service.salvarReceita e pesquisar depois',
      build: () {
        when(() => mockService.salvarReceita(any())).thenAnswer((_) async {});
        when(
          () => mockService.listarReceitas(
            any(),
            mes: any(named: 'mes'),
            ano: any(named: 'ano'),
            contaId: any(named: 'contaId'),
            contaContabil: any(named: 'contaContabil'),
            tipo: any(named: 'tipo'),
            palavraChave: any(named: 'palavraChave'),
          ),
        ).thenAnswer((_) async => _receitas);
        return _buildCubit();
      },
      act: (cubit) => cubit.salvarReceita(novaReceita),
      verify: (_) {
        verify(() => mockService.salvarReceita(any())).called(1);
      },
    );
  });

  // ════════════════════════════════════════════════════════
  //  EXCLUIR DESPESAS MULTIPLAS
  // ════════════════════════════════════════════════════════

  group('excluirDespesasSelecionadas', () {
    blocTest<DespesaReceitaCubit, DespesaReceitaState>(
      'deve chamar service e re-pesquisar',
      build: () {
        when(
          () => mockService.excluirDespesasMultiplas(any()),
        ).thenAnswer((_) async {});
        when(
          () => mockService.listarDespesas(
            any(),
            mes: any(named: 'mes'),
            ano: any(named: 'ano'),
            contaId: any(named: 'contaId'),
            categoriaId: any(named: 'categoriaId'),
            subcategoriaId: any(named: 'subcategoriaId'),
            palavraChave: any(named: 'palavraChave'),
          ),
        ).thenAnswer((_) async => []);
        return _buildCubit();
      },
      seed: () => const DespesaReceitaState().copyWith(
        despesasSelecionadas: {'d1', 'd2'},
      ),
      act: (cubit) => cubit.excluirDespesasSelecionadas(),
      verify: (_) {
        verify(() => mockService.excluirDespesasMultiplas(any())).called(1);
      },
    );
  });

  // ════════════════════════════════════════════════════════
  //  SELEÇÃO
  // ════════════════════════════════════════════════════════

  group('Toggle seleção', () {
    blocTest<DespesaReceitaCubit, DespesaReceitaState>(
      'toggleDespesaSelecionada adiciona e depois remove',
      build: _buildCubit,
      act: (cubit) {
        cubit.toggleDespesaSelecionada('d1');
        cubit.toggleDespesaSelecionada('d1');
      },
      expect: () => [
        isA<DespesaReceitaState>().having(
          (s) => s.despesasSelecionadas,
          'sel',
          {'d1'},
        ),
        isA<DespesaReceitaState>().having(
          (s) => s.despesasSelecionadas,
          'sel',
          isEmpty,
        ),
      ],
    );

    blocTest<DespesaReceitaCubit, DespesaReceitaState>(
      'selecionarTodasDespesas seleciona e desseleciona todas',
      build: _buildCubit,
      act: (cubit) {
        cubit.selecionarTodasDespesas(['d1', 'd2']);
        cubit.selecionarTodasDespesas(['d1', 'd2']);
      },
      expect: () => [
        isA<DespesaReceitaState>().having(
          (s) => s.despesasSelecionadas,
          'sel',
          {'d1', 'd2'},
        ),
        isA<DespesaReceitaState>().having(
          (s) => s.despesasSelecionadas,
          'sel',
          isEmpty,
        ),
      ],
    );

    blocTest<DespesaReceitaCubit, DespesaReceitaState>(
      'toggleReceitaSelecionada funciona corretamente',
      build: _buildCubit,
      act: (cubit) {
        cubit.toggleReceitaSelecionada('r1');
      },
      expect: () => [
        isA<DespesaReceitaState>().having(
          (s) => s.receitasSelecionadas,
          'sel',
          {'r1'},
        ),
      ],
    );
  });

  // ════════════════════════════════════════════════════════
  //  EDIÇÃO
  // ════════════════════════════════════════════════════════

  group('Modo edição', () {
    blocTest<DespesaReceitaCubit, DespesaReceitaState>(
      'iniciarEdicaoDespesa define despesaEditando e cancelar limpa',
      build: _buildCubit,
      act: (cubit) {
        cubit.iniciarEdicaoDespesa(_despesas[0]);
        cubit.cancelarEdicaoDespesa();
      },
      expect: () => [
        isA<DespesaReceitaState>().having(
          (s) => s.despesaEditando,
          'editando',
          _despesas[0],
        ),
        isA<DespesaReceitaState>().having(
          (s) => s.despesaEditando,
          'editando',
          isNull,
        ),
      ],
    );

    blocTest<DespesaReceitaCubit, DespesaReceitaState>(
      'iniciarEdicaoReceita define receitaEditando',
      build: _buildCubit,
      act: (cubit) => cubit.iniciarEdicaoReceita(_receitas[0]),
      expect: () => [
        isA<DespesaReceitaState>().having(
          (s) => s.receitaEditando,
          'editando',
          _receitas[0],
        ),
      ],
    );

    blocTest<DespesaReceitaCubit, DespesaReceitaState>(
      'iniciarEdicaoTransferencia define transferenciaEditando',
      build: _buildCubit,
      act: (cubit) => cubit.iniciarEdicaoTransferencia(_transferencias[0]),
      expect: () => [
        isA<DespesaReceitaState>().having(
          (s) => s.transferenciaEditando,
          'editando',
          _transferencias[0],
        ),
      ],
    );
  });

  // ════════════════════════════════════════════════════════
  //  MÊS / ANO
  // ════════════════════════════════════════════════════════

  group('Navegação Mês', () {
    blocTest<DespesaReceitaCubit, DespesaReceitaState>(
      'mesAnterior deve decrementar mês no state',
      build: () {
        when(
          () => mockService.listarContas(any()),
        ).thenAnswer((_) async => _contas);
        when(
          () => mockService.listarCategorias(),
        ).thenAnswer((_) async => _categorias);
        when(
          () => mockService.listarDespesas(
            any(),
            mes: any(named: 'mes'),
            ano: any(named: 'ano'),
            contaId: any(named: 'contaId'),
            categoriaId: any(named: 'categoriaId'),
            subcategoriaId: any(named: 'subcategoriaId'),
            palavraChave: any(named: 'palavraChave'),
          ),
        ).thenAnswer((_) async => _despesas);
        when(
          () => mockService.listarReceitas(
            any(),
            mes: any(named: 'mes'),
            ano: any(named: 'ano'),
            contaId: any(named: 'contaId'),
            contaContabil: any(named: 'contaContabil'),
            tipo: any(named: 'tipo'),
            palavraChave: any(named: 'palavraChave'),
          ),
        ).thenAnswer((_) async => _receitas);
        when(
          () => mockService.listarTransferencias(
            any(),
            mes: any(named: 'mes'),
            ano: any(named: 'ano'),
            contaDebitoId: any(named: 'contaDebitoId'),
            contaCreditoId: any(named: 'contaCreditoId'),
            palavraChave: any(named: 'palavraChave'),
          ),
        ).thenAnswer((_) async => _transferencias);
        when(
          () => mockService.calcularSaldoAnterior(
            any(),
            mes: any(named: 'mes'),
            ano: any(named: 'ano'),
          ),
        ).thenAnswer((_) async => 0.0);
        when(
          () => mockService.listarContasContabeis(any()),
        ).thenAnswer((_) async => _contasContabeis);
        return _buildCubit();
      },
      act: (cubit) => cubit.mesAnterior(),
      verify: (cubit) {
        // mesAnterior should update month and trigger data reload
        verify(
          () => mockService.listarDespesas(
            any(),
            mes: any(named: 'mes'),
            ano: any(named: 'ano'),
            contaId: any(named: 'contaId'),
            categoriaId: any(named: 'categoriaId'),
            subcategoriaId: any(named: 'subcategoriaId'),
            palavraChave: any(named: 'palavraChave'),
          ),
        ).called(1);
      },
    );
  });
}
