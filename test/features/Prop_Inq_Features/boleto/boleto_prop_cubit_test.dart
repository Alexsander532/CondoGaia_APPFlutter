import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:condogaiaapp/features/Prop_Inq_Features/boleto/ui/cubit/boleto_prop_cubit.dart';
import 'package:condogaiaapp/features/Prop_Inq_Features/boleto/ui/cubit/boleto_prop_state.dart';
import 'package:condogaiaapp/features/Prop_Inq_Features/boleto/data/models/boleto_prop_model.dart';
import 'package:condogaiaapp/features/Prop_Inq_Features/boleto/domain/usecases/boleto_prop_usecases.dart';

class MockObterBoletosPropUseCase extends Mock implements ObterBoletosPropUseCase {}
class MockObterComposicaoBoletoUseCase extends Mock implements ObterComposicaoBoletoUseCase {}
class MockObterDemonstrativoFinanceiroUseCase extends Mock implements ObterDemonstrativoFinanceiroUseCase {}
class MockObterLeiturasUseCase extends Mock implements ObterLeiturasUseCase {}
class MockObterBalanceteOnlineUseCase extends Mock implements ObterBalanceteOnlineUseCase {}

void main() {
  group('BoletoPropCubit Tests', () {
    late MockObterBoletosPropUseCase mockObterBoletos;
    late MockObterComposicaoBoletoUseCase mockObterComposicao;
    late MockObterDemonstrativoFinanceiroUseCase mockObterDemonstrativo;
    late MockObterLeiturasUseCase mockObterLeituras;
    late MockObterBalanceteOnlineUseCase mockObterBalanceteOnline;
    
    const moradorId = 'morador_123';
    const condominioId = 'cond_123';

    setUp(() {
      mockObterBoletos = MockObterBoletosPropUseCase();
      mockObterComposicao = MockObterComposicaoBoletoUseCase();
      mockObterDemonstrativo = MockObterDemonstrativoFinanceiroUseCase();
      mockObterLeituras = MockObterLeiturasUseCase();
      mockObterBalanceteOnline = MockObterBalanceteOnlineUseCase();
    });

    BoletoPropCubit createCubit() {
      return BoletoPropCubit(
        obterBoletos: mockObterBoletos,
        obterComposicao: mockObterComposicao,
        obterDemonstrativo: mockObterDemonstrativo,
        obterLeituras: mockObterLeituras,
        obterBalanceteOnline: mockObterBalanceteOnline,
        moradorId: moradorId,
        condominioId: condominioId,
      );
    }

    final testBoletos = [
      BoletoPropModel.fromJson({
        'id': '1',
        'condominio_id': 'cond_1',
        'data_vencimento': '2024-01-10',
        'valor': 500.0,
        'status': 'Pago',
        'is_vencido': false,
      }),
      BoletoPropModel.fromJson({
        'id': '2',
        'condominio_id': 'cond_1',
        'data_vencimento': '2024-01-15',
        'valor': 600.0,
        'status': 'Aberto',
        'is_vencido': true,
      }),
    ];

    test('Estado inicial deve estar correto', () {
      final cubit = createCubit();
      final state = cubit.state;
      
      expect(state.status, BoletoPropStatus.initial);
      expect(state.boletos, isEmpty);
      expect(state.filtroSelecionado, 'Vencido/ A Vencer');
      expect(state.boletoExpandidoId, null);
    });

    blocTest<BoletoPropCubit, BoletoPropState>(
      'Deve carregar boletos com sucesso',
      setUp: () {
        when(() => mockObterBoletos.call(
          moradorId: moradorId,
          filtroStatus: null,
        )).thenAnswer((_) async => testBoletos);
      },
      build: createCubit,
      act: (cubit) => cubit.carregarBoletos(),
      expect: () => [
        isA<BoletoPropState>()
            .having((s) => s.status, 'status', BoletoPropStatus.loading),
        isA<BoletoPropState>()
            .having((s) => s.status, 'status', BoletoPropStatus.success)
            .having((s) => s.boletos, 'boletos', hasLength(2)),
      ],
    );

    blocTest<BoletoPropCubit, BoletoPropState>(
      'Deve tratar erro ao carregar boletos',
      setUp: () {
        when(() => mockObterBoletos.call(
          moradorId: moradorId,
          filtroStatus: null,
        )).thenThrow(Exception('Erro de conexão'));
      },
      build: createCubit,
      act: (cubit) => cubit.carregarBoletos(),
      expect: () => [
        isA<BoletoPropState>()
            .having((s) => s.status, 'status', BoletoPropStatus.loading),
        isA<BoletoPropState>()
            .having((s) => s.status, 'status', BoletoPropStatus.error)
            .having((s) => s.errorMessage, 'errorMessage', isNotNull),
      ],
    );

    blocTest<BoletoPropCubit, BoletoPropState>(
      'Deve expandir boleto',
      build: () {
        final cubit = createCubit();
        cubit.emit(BoletoPropState(
          status: BoletoPropStatus.success,
          boletos: testBoletos,
        ));
        return cubit;
      },
      act: (cubit) => cubit.expandirBoleto('1'),
      expect: () => [
        isA<BoletoPropState>()
            .having((s) => s.boletoExpandidoId, 'boletoExpandidoId', '1'),
      ],
    );

    blocTest<BoletoPropCubit, BoletoPropState>(
      'Deve colapsar boleto já expandido',
      build: () {
        final cubit = createCubit();
        cubit.emit(BoletoPropState(
          status: BoletoPropStatus.success,
          boletos: testBoletos,
          boletoExpandidoId: '1',
        ));
        return cubit;
      },
      act: (cubit) => cubit.expandirBoleto('1'),
      expect: () => [
        isA<BoletoPropState>()
            .having((s) => s.boletoExpandidoId, 'boletoExpandidoId', null),
      ],
    );

    blocTest<BoletoPropCubit, BoletoPropState>(
      'Deve alternar seções expansíveis',
      build: createCubit,
      act: (cubit) {
        cubit.toggleComposicaoBoleto();
        cubit.toggleLeituras();
        cubit.toggleBalanceteOnline();
      },
      expect: () => [
        isA<BoletoPropState>()
            .having((s) => s.composicaoBoletoExpandida, 'composicaoBoletoExpandida', true),
        isA<BoletoPropState>()
            .having((s) => s.leiturasExpandida, 'leiturasExpandida', true),
        isA<BoletoPropState>()
            .having((s) => s.balanceteOnlineExpandido, 'balanceteOnlineExpandido', true),
      ],
    );

    test('Deve filtrar boletos corretamente', () {
      final cubit = createCubit();
      
      // Simular estado com boletos
      cubit.emit(BoletoPropState(
        status: BoletoPropStatus.success,
        boletos: testBoletos,
      ));
      
      // Testar filtro 'Pago'
      cubit.emit(cubit.state.copyWith(filtroSelecionado: 'Pago'));
      expect(cubit.state.boletosFiltrados.length, 1);
      expect(cubit.state.boletosFiltrados.first.status, 'Pago');
      
      // Testar filtro 'Vencido/ A Vencer'
      cubit.emit(cubit.state.copyWith(filtroSelecionado: 'Vencido/ A Vencer'));
      expect(cubit.state.boletosFiltrados.length, 1);
      expect(cubit.state.boletosFiltrados.first.status, 'Aberto');
    });

    test('copyWith deve funcionar corretamente', () {
      final cubit = createCubit();
      final originalState = cubit.state;
      
      final newState = originalState.copyWith(
        status: BoletoPropStatus.success,
        errorMessage: 'Test error',
        mesSelecionado: 2,
        anoSelecionado: 2025,
        composicaoBoletoExpandida: true,
      );
      
      expect(newState.status, BoletoPropStatus.success);
      expect(newState.errorMessage, 'Test error');
      expect(newState.mesSelecionado, 2);
      expect(newState.anoSelecionado, 2025);
      expect(newState.composicaoBoletoExpandida, true);
    });
  });
}
