import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class CurrencyInputFormatter extends TextInputFormatter {
  final int maxLength;
  final String symbol;
  late final NumberFormat _formatter;

  CurrencyInputFormatter({this.maxLength = 15, this.symbol = 'R\$'}) {
    _formatter = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: symbol,
      decimalDigits: 2,
    );
  }

  

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    String newText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (newText.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // Prevent exceeding max length to avoid issues
    if (newText.length > maxLength) {
      newText = newText.substring(0, maxLength);
    }

    double value = double.parse(newText) / 100;
    String formatted = _formatter.format(value);

    return newValue.copyWith(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
