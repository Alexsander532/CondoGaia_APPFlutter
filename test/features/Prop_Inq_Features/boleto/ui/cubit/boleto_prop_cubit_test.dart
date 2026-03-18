import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:condogaiaapp/features/Prop_Inq_Features/boleto/domain/usecases/boleto_prop_usecases.dart';
import 'package:condogaiaapp/features/Prop_Inq_Features/boleto/data/models/boleto_prop_model.dart';
import 'package:condogaiaapp/features/Prop_Inq_Features/boleto/ui/cubit/boleto_prop_cubit.dart';
import 'package:condogaiaapp/features/Prop_Inq_Features/boleto/ui/cubit/boleto_prop_state.dart';

class MockObterBoletosPropUseCase extends Mock implements ObterBoletosPropUseCase {}
class MockObterComposicaoBoletoUseCase extends Mock implements ObterComposicaoBoletoUseCase {}
class MockObterDemonstrativoFinanceiroUseCase extends Mock implements ObterDemonstrativoFinanceiroUseCase {}
class MockObterLeiturasUseCase extends Mock implements ObterLeiturasUseCase {}
class MockObterBalanceteOnlineUseCase extends Mock implements ObterBalanceteOnlineUseCase {}
class MockSincronizarBoletoUseCase extends Mock implements SincronizarBoletoUseCase {}

void main() {
  late BoletoPropCubit cubit;
  late MockObterBoletosPropUseCase mockObterBoletos;
  late MockObterComposicaoBoletoUseCase mockObterComposicao;
  late MockObterDemonstrativoFinanceiroUseCase mockObterDemonstrativo;
  late MockObterLeiturasUseCase mockObterLeituras;
  late MockObterBalanceteOnlineUseCase mockObterBalanceteOnline;
  late MockSincronizarBoletoUseCase mockSincronizarBoleto;

  const moradorId = 'morador-123';
  const condominioId = 'condominio-123';

  setUp(() {
    mockObterBoletos = MockObterBoletosPropUseCase();
    mockObterComposicao = MockObterComposicaoBoletoUseCase();
    mockObterDemonstrativo = MockObterDemonstrativoFinanceiroUseCase();
    mockObterLeituras = MockObterLeiturasUseCase();
    mockObterBalanceteOnline = MockObterBalanceteOnlineUseCase();
    mockSincronizarBoleto = MockSincronizarBoletoUseCase();

    cubit = BoletoPropCubit(
      obterBoletos: mockObterBoletos,
      obterComposicao: mockObterComposicao,
      obterDemonstrativo: mockObterDemonstrativo,
      obterLeituras: mockObterLeituras,
      obterBalanceteOnline: mockObterBalanceteOnline,
      sincronizarBoleto: mockSincronizarBoleto,
      moradorId: moradorId,
      condominioId: condominioId,
    );
  });

  tearDown(() {
    cubit.close();
  });

  group('BoletoPropCubit', () {
    final tBoleto = BoletoPropModel(
      id: 'boleto-1',
      condominioId: condominioId,
      dataVencimento: DateTime.now().add(const Duration(days: 5)),
      valor: 500.0,
      status: 'A Vencer',
      tipo: 'Mensal',
      unidadeId: 'unidade-1',
    );

    test('initial state has correct default values', () {
      expect(cubit.state.status, BoletoPropStatus.initial);
      expect(cubit.state.boletos, isEmpty);
      expect(cubit.state.filtroSelecionado, 'Vencido/ A Vencer');
    });

    blocTest<BoletoPropCubit, BoletoPropState>(
      'emits [loading, success] states when carregarBoletos is successful',
      build: () {
        when(() => mockObterBoletos.call(
              moradorId: any(named: 'moradorId'),
              filtroStatus: any(named: 'filtroStatus'),
            )).thenAnswer((_) async => [tBoleto]);
        return cubit;
      },
      act: (cubit) => cubit.carregarBoletos(),
      expect: () => [
        isA<BoletoPropState>().having((state) => state.status, 'status', BoletoPropStatus.loading),
        isA<BoletoPropState>()
            .having((state) => state.status, 'status', BoletoPropStatus.success)
            .having((state) => state.boletos, 'boletos', [tBoleto]),
      ],
      verify: (_) {
        verify(() => mockObterBoletos.call(
              moradorId: moradorId,
              filtroStatus: 'Vencido/ A Vencer',
            )).called(1);
      },
    );

    blocTest<BoletoPropCubit, BoletoPropState>(
      'emits [loading, error] states when carregarBoletos fails',
      build: () {
        when(() => mockObterBoletos.call(
              moradorId: any(named: 'moradorId'),
              filtroStatus: any(named: 'filtroStatus'),
            )).thenThrow(Exception('Failed to load'));
        return cubit;
      },
      act: (cubit) => cubit.carregarBoletos(),
      expect: () => [
        isA<BoletoPropState>().having((state) => state.status, 'status', BoletoPropStatus.loading),
        isA<BoletoPropState>()
            .having((state) => state.status, 'status', BoletoPropStatus.error)
            .having((state) => state.errorMessage, 'errorMessage', contains('Failed to load')),
      ],
    );

    blocTest<BoletoPropCubit, BoletoPropState>(
      'emits proper states when expanding a boleto and loading composicao/leituras',
      build: () {
        when(() => mockObterBoletos.call(
              moradorId: any(named: 'moradorId'),
              filtroStatus: any(named: 'filtroStatus'),
            )).thenAnswer((_) async => [tBoleto]);
        
        when(() => mockObterComposicao.call(any()))
            .thenAnswer((_) async => {'cotaCondominial': 400.0, 'fundoReserva': 40.0, 'valorTotal': 440.0});
            
        when(() => mockObterLeituras.call(
              unidadeId: any(named: 'unidadeId'),
              mes: any(named: 'mes'),
              ano: any(named: 'ano'),
            )).thenAnswer((_) async => [
              {'data_leitura': '2026-03-01', 'tipo': 'Agua', 'valor': 123.45}
            ]);

        return cubit;
      },
      // Call carregarBoletos first, then expandirBoleto to test both.
      act: (cubit) async {
        await cubit.carregarBoletos();
        cubit.expandirBoleto(tBoleto.id);
      },
      skip: 2, // skip the carregarBoletos states
      expect: () => [
        isA<BoletoPropState>().having((state) => state.boletoExpandidoId, 'boletoExpandidoId', tBoleto.id),
        isA<BoletoPropState>()
            .having((state) => state.composicaoBoleto, 'composicaoBoleto', isNotEmpty)
            .having((state) => state.leituras, 'leituras', isNotEmpty)
            .having((state) => state.leituras!.first['valor'], 'leitura valor', 123.45),
      ],
      verify: (_) {
        verify(() => mockObterComposicao.call(tBoleto.id)).called(1);
        verify(() => mockObterLeituras.call(
              unidadeId: tBoleto.unidadeId!,
              mes: any(named: 'mes'),
              ano: any(named: 'ano'),
            )).called(1);
      },
    );
  });
}
