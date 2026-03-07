import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:condogaiaapp/features/Representante_Features/leitura/widgets/leitura_table_widget.dart';
import 'package:condogaiaapp/features/Representante_Features/leitura/models/leitura_model.dart';
import 'package:intl/intl.dart';

void main() {
  Widget buildTestableWidget(Widget widget) {
    return MaterialApp(home: Scaffold(body: widget));
  }

  final tDate = DateTime(2026, 2, 7);
  final formattedDate = DateFormat('dd/MM/yyyy').format(tDate);

  final tLeituraModelSaved = LeituraModel(
    id: 'leit-1',
    unidadeId: 'uni-1',
    bloco: 'A',
    unidadeNome: '101',
    leituraAnterior: 100.0,
    leituraAtual: 110.0,
    valor: 45.5,
    dataLeitura: tDate,
    tipo: 'Agua',
    isSelected: false,
  );

  final tLeituraModelUnsaved = LeituraModel(
    id: '',
    unidadeId: 'uni-2',
    bloco: 'B',
    unidadeNome: '102',
    leituraAnterior: 50.0,
    leituraAtual: 0.0,
    valor: 0.0,
    dataLeitura: tDate,
    tipo: 'Agua',
    isSelected: true,
  );

  group('LeituraTableWidget Tests', () {
    testWidgets('exibe mensagem quando lista está vazia', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          LeituraTableWidget(
            leituras: const [],
            onSelectionChanged: (_, __) {},
          ),
        ),
      );

      expect(find.text('Nenhuma unidade encontrada.'), findsOneWidget);
    });

    testWidgets('exibe cabecalho da tabela corretamente', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          LeituraTableWidget(
            leituras: const [],
            onSelectionChanged: (_, __) {},
          ),
        ),
      );

      expect(find.text('UNID/BLOCO'), findsOneWidget);
      expect(find.text('LEITURA ANT'), findsOneWidget);
      expect(find.text('LEITURA ATUAL'), findsOneWidget);
      expect(find.text('VALOR'), findsOneWidget);
      expect(find.text('DATA LEITURA'), findsOneWidget);
      expect(find.text('IMAGEM'), findsOneWidget);
    });

    testWidgets('renderiza itens da lista corretamente', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          LeituraTableWidget(
            leituras: [tLeituraModelSaved, tLeituraModelUnsaved],
            onSelectionChanged: (_, __) {},
          ),
        ),
      );

      // Verifies Unidade/Bloco column
      expect(find.text('101 / A'), findsOneWidget);
      expect(find.text('102 / B'), findsOneWidget);

      // Verifies Leitura Anterior
      expect(find.text('100.000'), findsOneWidget);
      expect(find.text('50.000'), findsOneWidget);

      // Verifies variables dependent on `id.isNotEmpty` status
      // Saved item
      expect(find.text('110.000'), findsOneWidget);
      expect(find.text('R\$ 45.50'), findsOneWidget);

      // Unsaved item
      // The widget renders '-' for empty IDs in Atual, Valor, Data fields:
      // Since it renders '-' three times for unsaved item (Atual, Valor, Data),
      // we expect multiple dashes. Actually, there's 3 '-' per unsaved reading + maybe image column.
      expect(find.text('-'), findsWidgets);

      // Dates
      expect(
        find.text(formattedDate),
        findsOneWidget,
      ); // Rendered once for saved item
    });

    testWidgets('Checkbox chama onSelectionChanged', (tester) async {
      String? changedId;
      bool? changedVal;

      await tester.pumpWidget(
        buildTestableWidget(
          LeituraTableWidget(
            leituras: [tLeituraModelSaved],
            onSelectionChanged: (id, val) {
              changedId = id;
              changedVal = val;
            },
          ),
        ),
      );

      final checkbox = find.byType(Checkbox).first;
      await tester.tap(checkbox);
      await tester.pump();

      expect(changedId, 'uni-1');
      expect(changedVal, true); // initial was false, changing to true
    });

    testWidgets('InkWell chama onRowTap quando a linha é clicada', (
      tester,
    ) async {
      LeituraModel? tappedModel;

      await tester.pumpWidget(
        buildTestableWidget(
          LeituraTableWidget(
            leituras: [tLeituraModelSaved],
            onSelectionChanged: (_, __) {},
            onRowTap: (model) {
              tappedModel = model;
            },
          ),
        ),
      );

      // Tap on the text of the row to trigger InkWell
      await tester.tap(find.text('101 / A'));
      await tester.pump();

      expect(tappedModel, equals(tLeituraModelSaved));
    });
  });
}
