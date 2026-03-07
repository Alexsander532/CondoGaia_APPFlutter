import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:condogaiaapp/features/Representante_Features/leitura/screens/leitura_configuracao_screen.dart';
import 'package:condogaiaapp/features/Representante_Features/leitura/services/leitura_service.dart';
import 'package:condogaiaapp/features/Representante_Features/leitura/models/leitura_configuracao_model.dart';
import 'package:condogaiaapp/features/Representante_Features/leitura/models/leitura_model.dart';

class MockLeituraService extends Mock implements LeituraService {}

class FakeLeituraConfiguracaoModel extends Fake
    implements LeituraConfiguracaoModel {}

class FakeFaixaLeitura extends Fake implements FaixaLeitura {}

void main() {
  late MockLeituraService mockService;

  setUpAll(() {
    registerFallbackValue(FakeLeituraConfiguracaoModel());
  });

  setUp(() {
    mockService = MockLeituraService();
  });

  Widget buildTestableWidget() {
    return MaterialApp(
      home: Scaffold(
        body: LeituraConfiguracaoScreen(
          condominioId: 'cond-1',
          tipoInicial: 'Agua',
          service: mockService,
          onConfigSaved: () {},
        ),
      ),
    );
  }

  group('LeituraConfiguracaoScreen Tests', () {
    testWidgets('exibe Loading vazio durante loadConfig', (tester) async {
      when(
        () => mockService.fetchConfiguracao(
          condominioId: any(named: 'condominioId'),
          tipo: any(named: 'tipo'),
        ),
      ).thenAnswer((_) async => null);

      when(
        () => mockService.fetchTodasConfiguracoes(any()),
      ).thenAnswer((_) async => []);

      await tester.pumpWidget(buildTestableWidget());
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle();
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('renderiza config perfeitamente com faixas', (tester) async {
      final tConfig = LeituraConfiguracaoModel(
        condominioId: 'cond-1',
        tipo: 'Agua',
        unidadeMedida: 'M³',
        valorBase: 50.0,
        cobrancaTipo: 2,
        faixas: [
          FaixaLeitura(inicio: 0, fim: 10, valor: 30),
          FaixaLeitura(inicio: 11, fim: 20, valor: 40),
        ],
      );

      when(
        () => mockService.fetchConfiguracao(
          condominioId: any(named: 'condominioId'),
          tipo: any(named: 'tipo'),
        ),
      ).thenAnswer((_) async => tConfig);

      when(
        () => mockService.fetchTodasConfiguracoes(any()),
      ).thenAnswer((_) async => [tConfig]);

      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      // Verifica valor base
      expect(find.text('50.0'), findsOneWidget);

      // Verifica Faixa 1 (0 -> 10 = 30)
      expect(find.text('10'), findsOneWidget); // Fim da faixa 1
      expect(find.text('30'), findsOneWidget); // Valor da faixa 1

      // Verifica Faixa 2 (11 -> 20 = 40)
      expect(find.text('11'), findsOneWidget); // Início faixa 2
      expect(find.text('20'), findsOneWidget); // Fim faixa 2
      expect(find.text('40'), findsOneWidget); // Valor faixa 2
    });

    testWidgets('gravar configuração chama mockService.saveConfiguracao', (
      tester,
    ) async {
      when(
        () => mockService.fetchConfiguracao(
          condominioId: any(named: 'condominioId'),
          tipo: any(named: 'tipo'),
        ),
      ).thenAnswer((_) async => null);
      when(
        () => mockService.fetchTodasConfiguracoes(any()),
      ).thenAnswer((_) async => []);

      when(() => mockService.saveConfiguracao(any())).thenAnswer((_) async {});

      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      // Tap on the gravar button
      await tester.ensureVisible(find.text('Gravar'));
      await tester.tap(find.text('Gravar'));
      await tester.pumpAndSettle(); // Start saving

      verify(() => mockService.saveConfiguracao(any())).called(1);
    });
  });
}
