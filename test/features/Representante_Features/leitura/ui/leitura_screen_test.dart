import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:condogaiaapp/features/Representante_Features/leitura/screens/leitura_screen.dart';
import 'package:condogaiaapp/features/Representante_Features/leitura/services/leitura_service.dart';
import 'package:condogaiaapp/features/Representante_Features/leitura/models/leitura_model.dart';
import 'package:condogaiaapp/features/Representante_Features/leitura/models/leitura_configuracao_model.dart';
import 'package:condogaiaapp/models/unidade.dart';

class MockLeituraService extends Mock implements LeituraService {}

class FakeLeituraModel extends Fake implements LeituraModel {}

void main() {
  late MockLeituraService mockService;

  final tUnidade = Unidade(
    id: 'uni-1',
    condominioId: 'cond-1',
    bloco: 'A',
    numero: '101',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
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

    // Setup success responses for initial load
    when(
      () => mockService.clearLeiturasCache(any(), any()),
    ).thenAnswer((_) async {});
    when(
      () => mockService.clearConfigCache(any(), any()),
    ).thenAnswer((_) async {});
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
    ).thenAnswer((_) async => []);
    when(
      () => mockService.fetchConfiguracao(
        condominioId: any(named: 'condominioId'),
        tipo: any(named: 'tipo'),
      ),
    ).thenAnswer((_) async => tConfig);
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
    ).thenAnswer((_) async => [tConfig]);
  });

  Widget buildTestableWidget() {
    return MaterialApp(
      home: LeituraScreen(condominioId: 'cond-1', service: mockService),
    );
  }

  group('LeituraScreen Tests (Integrating Cubit)', () {
    testWidgets('renderiza layout básico e carrega dados com sucesso', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestableWidget());

      // Initially, it shows CircularProgressIndicator internally, but it loads so fast we just let it pump
      await tester.pumpAndSettle();

      expect(find.text('CondoGaia'), findsOneWidget);
      expect(find.text('Cadastrar'), findsOneWidget);
      expect(find.text('Configurar'), findsOneWidget);

      // Should display the Unidade we mocked
      expect(find.text('101 / A'), findsOneWidget);

      // Verify Service calls for loadLeituras
      verify(() => mockService.fetchUnidades('cond-1')).called(1);
    });

    testWidgets('exibe erro no SnackBar quando carregar falha', (tester) async {
      when(
        () => mockService.fetchUnidades(any()),
      ).thenThrow(Exception('Falha ao conectar'));

      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      expect(find.textContaining('Falha ao conectar'), findsWidgets);
    });

    testWidgets('pesquisa filtra a tabela', (tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      // Find Unidade normally
      expect(find.text('101 / A'), findsOneWidget);

      // Type in Search
      final searchField = find.byType(TextField).first;
      await tester.enterText(searchField, '999');
      await tester.pumpAndSettle();

      // 101/A should be gone
      expect(find.text('101 / A'), findsNothing);

      // Back to 101
      await tester.enterText(searchField, '101');
      await tester.pumpAndSettle();

      expect(find.text('101 / A'), findsOneWidget);
    });

    testWidgets('aba de configuracao mostra configuracoes de preco', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Configurar'));
      await tester.pumpAndSettle();

      expect(find.text('Faixa de valores'), findsOneWidget);
    });
  });
}
