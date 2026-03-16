import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:condogaiaapp/features/Prop_Inq_Features/boleto/ui/widgets/boleto_acoes_expandidas.dart';
import 'package:condogaiaapp/features/Prop_Inq_Features/boleto/ui/cubit/boleto_prop_cubit.dart';
import 'package:condogaiaapp/features/Prop_Inq_Features/boleto/ui/cubit/boleto_prop_state.dart';

class MockBoletoPropCubit extends Mock implements BoletoPropCubit {}

void main() {
  late MockBoletoPropCubit mockCubit;

  setUp(() {
    mockCubit = MockBoletoPropCubit();
    when(() => mockCubit.state).thenReturn(const BoletoPropState());
    when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());
  });

  Widget createWidgetUnderTest(String? codigoBarras) {
    return MaterialApp(
      home: Scaffold(
        body: BlocProvider<BoletoPropCubit>.value(
          value: mockCubit,
          child: BoletoAcoesExpandidas(
            codigoBarras: codigoBarras,
            boletoId: '123',
            tipo: 'Taxa Condominial',
            isVencido: false,
          ),
        ),
      ),
    );
  }

  testWidgets('Deve exibir o código de barras quando fornecido', (tester) async {
    const barcode = '12345678901234567890123456789012345678901234567';
    
    await tester.pumpWidget(createWidgetUnderTest(barcode));

    expect(find.text('Código de Barras (Linha Digitável):'), findsOneWidget);
    expect(find.text(barcode), findsOneWidget);
    expect(find.byIcon(Icons.copy), findsOneWidget);
  });

  testWidgets('Não deve exibir a seção de código de barras quando for null', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest(null));

    expect(find.text('Código de Barras (Linha Digitável):'), findsNothing);
  });

  testWidgets('Não deve exibir a seção de código de barras quando for vazio', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest(''));

    expect(find.text('Código de Barras (Linha Digitável):'), findsNothing);
  });
}
