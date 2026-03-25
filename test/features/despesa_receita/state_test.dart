/// Comprehensive unit tests for DespesaReceitaState.
///
/// Tests cover:
/// - Initial state defaults
/// - copyWith (all fields, clear flags, partial updates)
/// - Computed getters: categoriasDespesa, categoriasReceita,
///   subcategoriasFiltradas, totalDespesas, totalReceitas, saldoAtual

import 'package:flutter_test/flutter_test.dart';
import 'package:condogaiaapp/features/Representante_Features/despesa_receita/cubit/despesa_receita_state.dart';
import 'package:condogaiaapp/features/Representante_Features/despesa_receita/models/despesa_model.dart';
import 'package:condogaiaapp/features/Representante_Features/despesa_receita/models/receita_model.dart';
import 'package:condogaiaapp/features/Representante_Features/despesa_receita/models/transferencia_model.dart';
import 'package:condogaiaapp/features/Representante_Features/gestao_condominio/models/categoria_financeira_model.dart';

void main() {
  // ════════════════════════════════════════════════════════
  //  ESTADO INICIAL
  // ════════════════════════════════════════════════════════

  group('DespesaReceitaState - Estado Inicial', () {
    test('deve ter todos os valores padrão corretos', () {
      const state = DespesaReceitaState();

      expect(state.status, DespesaReceitaStatus.initial);
      expect(state.despesas, isEmpty);
      expect(state.receitas, isEmpty);
      expect(state.transferencias, isEmpty);
      expect(state.contas, isEmpty);
      expect(state.categorias, isEmpty);
      expect(state.mesSelecionado, 0);
      expect(state.anoSelecionado, 0);
      expect(state.filtroContaId, isNull);
      expect(state.filtroCategoriaId, isNull);
      expect(state.filtroSubcategoriaId, isNull);
      expect(state.filtroPalavraChave, isNull);
      expect(state.filtroContaContabilId, isNull);
      expect(state.filtroContaCreditoId, isNull);
      expect(state.filtroContaDebitoId, isNull);
      expect(state.filtroTipoReceita, 'Todos');
      expect(state.despesasSelecionadas, isEmpty);
      expect(state.receitasSelecionadas, isEmpty);
      expect(state.transferenciasSelecionadas, isEmpty);
      expect(state.despesaEditando, isNull);
      expect(state.receitaEditando, isNull);
      expect(state.transferenciaEditando, isNull);
      expect(state.saldoAnterior, 0);
      expect(state.cadastroExpandido, false);
      expect(state.isSaving, false);
      expect(state.errorMessage, isNull);
    });
  });

  // ════════════════════════════════════════════════════════
  //  COPY WITH
  // ════════════════════════════════════════════════════════

  group('DespesaReceitaState - copyWith', () {
    test('deve atualizar status mantendo demais campos', () {
      const original = DespesaReceitaState();
      final updated = original.copyWith(status: DespesaReceitaStatus.loading);

      expect(updated.status, DespesaReceitaStatus.loading);
      expect(updated.despesas, original.despesas);
      expect(updated.mesSelecionado, original.mesSelecionado);
    });

    test('deve atualizar listas de dados', () {
      const original = DespesaReceitaState();
      final despesas = [const Despesa(condominioId: 'c1', valor: 100)];
      final receitas = [const Receita(condominioId: 'c1', valor: 200)];
      final updated = original.copyWith(despesas: despesas, receitas: receitas);

      expect(updated.despesas, hasLength(1));
      expect(updated.receitas, hasLength(1));
    });

    test('deve atualizar filtros', () {
      const original = DespesaReceitaState();
      final updated = original.copyWith(
        filtroContaId: 'conta-1',
        filtroCategoriaId: 'cat-1',
        filtroSubcategoriaId: 'sub-1',
        filtroPalavraChave: 'aluguel',
        filtroTipoReceita: 'MANUAL',
      );

      expect(updated.filtroContaId, 'conta-1');
      expect(updated.filtroCategoriaId, 'cat-1');
      expect(updated.filtroSubcategoriaId, 'sub-1');
      expect(updated.filtroPalavraChave, 'aluguel');
      expect(updated.filtroTipoReceita, 'MANUAL');
    });

    test('clearDespesaEditando deve limpar despesaEditando', () {
      final despesa = const Despesa(condominioId: 'c1');
      final state = const DespesaReceitaState().copyWith(
        despesaEditando: despesa,
      );
      expect(state.despesaEditando, isNotNull);

      final cleared = state.copyWith(clearDespesaEditando: true);
      expect(cleared.despesaEditando, isNull);
    });

    test('clearReceitaEditando deve limpar receitaEditando', () {
      final receita = const Receita(condominioId: 'c1');
      final state = const DespesaReceitaState().copyWith(
        receitaEditando: receita,
      );
      expect(state.receitaEditando, isNotNull);

      final cleared = state.copyWith(clearReceitaEditando: true);
      expect(cleared.receitaEditando, isNull);
    });

    test('clearTransferenciaEditando deve limpar transferenciaEditando', () {
      final t = const Transferencia(condominioId: 'c1');
      final state = const DespesaReceitaState().copyWith(
        transferenciaEditando: t,
      );

      final cleared = state.copyWith(clearTransferenciaEditando: true);
      expect(cleared.transferenciaEditando, isNull);
    });

    test('clearErrorMessage deve limpar errorMessage', () {
      final state = const DespesaReceitaState().copyWith(
        errorMessage: 'Erro de rede',
      );
      expect(state.errorMessage, 'Erro de rede');

      final cleared = state.copyWith(clearErrorMessage: true);
      expect(cleared.errorMessage, isNull);
    });

    test('deve atualizar seleções por aba', () {
      const original = DespesaReceitaState();
      final updated = original.copyWith(
        despesasSelecionadas: {'d1', 'd2'},
        receitasSelecionadas: {'r1'},
        transferenciasSelecionadas: {'t1', 't2', 't3'},
      );

      expect(updated.despesasSelecionadas, hasLength(2));
      expect(updated.receitasSelecionadas, hasLength(1));
      expect(updated.transferenciasSelecionadas, hasLength(3));
    });
  });

  // ════════════════════════════════════════════════════════
  //  COMPUTED GETTERS
  // ════════════════════════════════════════════════════════

  group('DespesaReceitaState - Computed Getters', () {
    final categorias = [
      CategoriaFinanceira.fromJson({
        'id': 'cat-desp-1',
        'nome': 'Manutenção',
        'tipo': 'DESPESA',
        'condominio_id': 'c1',
        'subcategorias_financeiras': [
          {'id': 'sub-1', 'nome': 'Elevador', 'categoria_id': 'cat-desp-1'},
          {'id': 'sub-2', 'nome': 'Piscina', 'categoria_id': 'cat-desp-1'},
        ],
      }),
      CategoriaFinanceira.fromJson({
        'id': 'cat-desp-2',
        'nome': 'Pessoal',
        'tipo': 'DESPESA',
        'condominio_id': 'c1',
      }),
      CategoriaFinanceira.fromJson({
        'id': 'cat-rec-1',
        'nome': 'Taxas',
        'tipo': 'RECEITA',
        'condominio_id': 'c1',
      }),
    ];

    test('categoriasDespesa deve filtrar apenas tipo DESPESA', () {
      final state = const DespesaReceitaState().copyWith(
        categorias: categorias,
      );
      expect(state.categoriasDespesa, hasLength(2));
      expect(state.categoriasDespesa.every((c) => c.tipo == 'DESPESA'), true);
    });

    test('categoriasReceita deve filtrar apenas tipo RECEITA', () {
      final state = const DespesaReceitaState().copyWith(
        categorias: categorias,
      );
      expect(state.categoriasReceita, hasLength(1));
      expect(state.categoriasReceita.first.nome, 'Taxas');
    });

    test('subcategoriasFiltradas sem categoria selecionada retorna vazio', () {
      final state = const DespesaReceitaState().copyWith(
        categorias: categorias,
      );
      expect(state.subcategoriasFiltradas, isEmpty);
    });

    test(
      'subcategoriasFiltradas com categoria selecionada retorna suas subs',
      () {
        final state = const DespesaReceitaState().copyWith(
          categorias: categorias,
          filtroCategoriaId: 'cat-desp-1',
        );
        expect(state.subcategoriasFiltradas, hasLength(2));
        expect(state.subcategoriasFiltradas[0].nome, 'Elevador');
      },
    );

    test(
      'subcategoriasFiltradas com categoria sem subcategorias retorna vazio',
      () {
        final state = const DespesaReceitaState().copyWith(
          categorias: categorias,
          filtroCategoriaId: 'cat-desp-2',
        );
        expect(state.subcategoriasFiltradas, isEmpty);
      },
    );

    test(
      'subcategoriasFiltradas com categoriaId inexistente retorna vazio',
      () {
        final state = const DespesaReceitaState().copyWith(
          categorias: categorias,
          filtroCategoriaId: 'cat-nao-existe',
        );
        expect(state.subcategoriasFiltradas, isEmpty);
      },
    );

    test('totalDespesas deve somar valores de todas as despesas', () {
      final state = const DespesaReceitaState().copyWith(
        despesas: [
          const Despesa(condominioId: 'c1', valor: 100.50),
          const Despesa(condominioId: 'c1', valor: 200.00),
          const Despesa(condominioId: 'c1', valor: 50.25),
        ],
      );
      expect(state.totalDespesas, closeTo(350.75, 0.01));
    });

    test('totalReceitas deve somar valores de todas as receitas', () {
      final state = const DespesaReceitaState().copyWith(
        receitas: [
          const Receita(condominioId: 'c1', valor: 1000),
          const Receita(condominioId: 'c1', valor: 500),
        ],
      );
      expect(state.totalReceitas, 1500.0);
    });

    test('totalDespesas com lista vazia deve ser zero', () {
      const state = DespesaReceitaState();
      expect(state.totalDespesas, 0.0);
    });

    test('saldoAtual deve ser saldoAnterior + receitas - despesas', () {
      final state = const DespesaReceitaState().copyWith(
        saldoAnterior: 1000,
        despesas: [const Despesa(condominioId: 'c1', valor: 300)],
        receitas: [const Receita(condominioId: 'c1', valor: 500)],
      );
      // 1000 + 500 - 300 = 1200
      expect(state.saldoAtual, 1200.0);
    });

    test('saldoAtual negativo quando despesas > receitas + saldoAnterior', () {
      final state = const DespesaReceitaState().copyWith(
        saldoAnterior: 100,
        despesas: [const Despesa(condominioId: 'c1', valor: 500)],
        receitas: [const Receita(condominioId: 'c1', valor: 200)],
      );
      // 100 + 200 - 500 = -200
      expect(state.saldoAtual, -200.0);
    });
  });

  // ════════════════════════════════════════════════════════
  //  EQUATABLE
  // ════════════════════════════════════════════════════════

  group('DespesaReceitaState - Equatable', () {
    test('dois estados iniciais devem ser iguais', () {
      const s1 = DespesaReceitaState();
      const s2 = DespesaReceitaState();
      expect(s1, equals(s2));
    });

    test('estados com filtros diferentes devem ser diferentes', () {
      const s1 = DespesaReceitaState();
      final s2 = s1.copyWith(filtroPalavraChave: 'teste');
      expect(s1, isNot(equals(s2)));
    });

    test('estados com status diferente devem ser diferentes', () {
      const s1 = DespesaReceitaState();
      final s2 = s1.copyWith(status: DespesaReceitaStatus.loading);
      expect(s1, isNot(equals(s2)));
    });
  });
}
