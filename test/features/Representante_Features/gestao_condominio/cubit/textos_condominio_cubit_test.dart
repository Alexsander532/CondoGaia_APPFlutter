import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:condogaiaapp/features/Representante_Features/gestao_condominio/cubit/textos_condominio_cubit.dart';
import 'package:condogaiaapp/features/Representante_Features/gestao_condominio/cubit/textos_condominio_state.dart';
import 'package:condogaiaapp/features/Representante_Features/gestao_condominio/models/textos_condominio_model.dart';
import 'package:condogaiaapp/features/Representante_Features/gestao_condominio/services/gestao_condominio_service.dart';

class MockGestaoCondominioService extends Mock
    implements GestaoCondominioService {}

void main() {
  late TextosCondominioCubit cubit;
  late MockGestaoCondominioService mockService;
  final String testCondominioId = 'cond-123';

  setUp(() {
    mockService = MockGestaoCondominioService();
    cubit = TextosCondominioCubit(service: mockService);
  });

  tearDown(() {
    cubit.close();
  });

  group('TextosCondominioCubit - ', () {
    test('Initial state is correct', () {
      expect(cubit.state.status, TextosStatus.initial);
      expect(cubit.state.textos, isNull);
    });

    test('carregarTextos emits loading then success with valid data', () async {
      final mockTextos = TextosCondominio(
        id: 'text-123',
        condominioId: testCondominioId,
        comunicadoBoletoCota: 'Cota',
      );
      when(
        () => mockService.obterTextos(testCondominioId),
      ).thenAnswer((_) async => mockTextos);

      // Verify the stream of states emitted
      expectLater(
        cubit.stream,
        emitsInOrder([
          const TextosCondominioState(status: TextosStatus.loading),
          TextosCondominioState(
            status: TextosStatus.success,
            textos: mockTextos,
          ),
        ]),
      );

      await cubit.carregarTextos(testCondominioId);
    });

    test(
      'carregarTextos emits success with empty text object if null',
      () async {
        when(
          () => mockService.obterTextos(testCondominioId),
        ).thenAnswer((_) async => null);

        expectLater(
          cubit.stream,
          emitsInOrder([
            const TextosCondominioState(status: TextosStatus.loading),
            predicate<TextosCondominioState>((state) {
              return state.status == TextosStatus.success &&
                  state.textos != null &&
                  state.textos!.condominioId == testCondominioId;
            }),
          ]),
        );

        await cubit.carregarTextos(testCondominioId);
      },
    );

    test('salvarTextos emits loading then success', () async {
      final mockTextos = TextosCondominio(condominioId: testCondominioId);

      when(
        () => mockService.salvarTextos(mockTextos),
      ).thenAnswer((_) async => Future.value());

      expectLater(
        cubit.stream,
        emitsInOrder([
          const TextosCondominioState(status: TextosStatus.loading),
          TextosCondominioState(
            status: TextosStatus.success,
            textos: mockTextos,
          ),
        ]),
      );

      await cubit.salvarTextos(mockTextos);
      verify(() => mockService.salvarTextos(mockTextos)).called(1);
    });

    test('salvarTextos emits error on exception', () async {
      final mockTextos = TextosCondominio(condominioId: testCondominioId);

      when(
        () => mockService.salvarTextos(mockTextos),
      ).thenThrow(Exception('Failed to save texts'));

      expectLater(
        cubit.stream,
        emitsInOrder([
          const TextosCondominioState(status: TextosStatus.loading),
          const TextosCondominioState(
            status: TextosStatus.error,
            errorMessage: 'Failed to save texts',
          ),
        ]),
      );

      await cubit.salvarTextos(mockTextos);
    });
  });
}
