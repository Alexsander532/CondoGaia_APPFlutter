/// Comprehensive unit tests for BrazilianCurrencyFormatter and DateInputFormatter.
///
/// Tests cover:
/// - Digit-only input
/// - Thousands separator formatting
/// - Single comma (decimal separator) enforcement
/// - Leading zeros removal
/// - Empty input passthrough
/// - Date auto-slashing DD/MM/AAAA
/// - Max length enforcement

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:condogaiaapp/utils/input_formatters.dart';

/// Helper to simulate a sequence of key presses through a formatter.
TextEditingValue _format(
  TextInputFormatter formatter,
  String newText, [
  String oldText = '',
]) {
  return formatter.formatEditUpdate(
    TextEditingValue(text: oldText),
    TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    ),
  );
}

void main() {
  // ════════════════════════════════════════════════════════
  //  BRAZILIAN CURRENCY FORMATTER
  // ════════════════════════════════════════════════════════

  group('BrazilianCurrencyFormatter', () {
    late BrazilianCurrencyFormatter formatter;

    setUp(() {
      formatter = BrazilianCurrencyFormatter();
    });

    test('texto vazio deve retornar vazio', () {
      final result = _format(formatter, '');
      expect(result.text, '');
    });

    test('dígitos simples sem formatação', () {
      final result = _format(formatter, '5');
      expect(result.text, '5');
    });

    test('dois dígitos sem separador de milhar', () {
      final result = _format(formatter, '99');
      expect(result.text, '99');
    });

    test('três dígitos sem separador de milhar', () {
      final result = _format(formatter, '999');
      expect(result.text, '999');
    });

    test('quatro dígitos deve ter ponto de milhar', () {
      final result = _format(formatter, '1234');
      expect(result.text, '1.234');
    });

    test('sete dígitos deve ter dois pontos de milhar', () {
      final result = _format(formatter, '1234567');
      expect(result.text, '1.234.567');
    });

    test('deve aceitar vírgula decimal', () {
      final result = _format(formatter, '100,50');
      expect(result.text, '100,50');
    });

    test('deve formatar parte inteira com vírgula presente', () {
      final result = _format(formatter, '1234,56');
      expect(result.text, '1.234,56');
    });

    test('deve rejeitar segunda vírgula (manter valor antigo)', () {
      final result = _format(formatter, '100,50,', '100,50');
      expect(result.text, '100,50');
    });

    test('deve remover zeros à esquerda da parte inteira', () {
      final result = _format(formatter, '007');
      expect(result.text, '7');
    });

    test('deve manter zero único na parte inteira', () {
      final result = _format(formatter, '0,50');
      expect(result.text, '0,50');
    });

    test('deve remover caracteres não numéricos (exceto vírgula)', () {
      final result = _format(formatter, '12a3b4');
      expect(result.text, '1.234');
    });

    test('cursor deve estar no final do texto formatado', () {
      final result = _format(formatter, '5235');
      expect(result.text, '5.235');
      expect(result.selection.baseOffset, result.text.length);
    });
  });

  // ════════════════════════════════════════════════════════
  //  DATE INPUT FORMATTER
  // ════════════════════════════════════════════════════════

  group('DateInputFormatter', () {
    late DateInputFormatter formatter;

    setUp(() {
      formatter = DateInputFormatter();
    });

    test('texto vazio deve retornar vazio', () {
      final result = _format(formatter, '');
      expect(result.text, '');
    });

    test('um dígito deve retornar apenas o dígito', () {
      final result = _format(formatter, '1');
      expect(result.text, '1');
    });

    test('dois dígitos devem retornar sem barra', () {
      final result = _format(formatter, '15');
      expect(result.text, '15');
    });

    test('três dígitos devem inserir barra após DD', () {
      final result = _format(formatter, '150');
      expect(result.text, '15/0');
    });

    test('quatro dígitos devem manter formato DD/MM', () {
      final result = _format(formatter, '1503');
      expect(result.text, '15/03');
    });

    test('cinco dígitos devem inserir segunda barra DD/MM/A', () {
      final result = _format(formatter, '15032');
      expect(result.text, '15/03/2');
    });

    test('oito dígitos devem formar DD/MM/AAAA completo', () {
      final result = _format(formatter, '15032026');
      expect(result.text, '15/03/2026');
    });

    test('deve rejeitar texto com mais de 10 caracteres', () {
      final result = _format(formatter, '15/03/20261', '15/03/2026');
      expect(result.text, '15/03/2026');
    });

    test('deve remover caracteres não numéricos antes de formatar', () {
      final result = _format(formatter, '1a5b0c3');
      expect(result.text, '15/03');
    });

    test('cursor deve estar no final', () {
      final result = _format(formatter, '15032026');
      expect(result.selection.baseOffset, '15/03/2026'.length);
    });
  });
}
