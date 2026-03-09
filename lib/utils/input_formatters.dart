import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

/// Formatter for Brazilian currency (thousands dots and single decimal comma).
/// Example: 1234,56 -> 1.234,56
class BrazilianCurrencyFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Allow only digits and one comma
    String text = newValue.text.replaceAll(RegExp(r'[^\d,]'), '');

    // Ensure only one comma exists
    int commaCount = ','.allMatches(text).length;
    if (commaCount > 1) {
      return oldValue;
    }

    // Split integer and decimal
    List<String> parts = text.split(',');
    String integerPart = parts[0];
    String decimalPart = parts.length > 1 ? parts[1] : '';

    // Remove leading zeros from integer part
    if (integerPart.length > 1 && integerPart.startsWith('0')) {
      integerPart = integerPart.replaceFirst(RegExp(r'^0+'), '');
      if (integerPart.isEmpty) integerPart = '0';
    }

    // Format integer part with dots for thousands
    if (integerPart.isNotEmpty) {
      final number = int.tryParse(integerPart);
      if (number != null) {
        final formatter = NumberFormat.decimalPattern('pt_BR');
        integerPart = formatter.format(number);
      }
    }

    String formatted =
        integerPart + (parts.length > 1 ? ',' + decimalPart : '');

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// Formatter for Dates in DD/MM/AAAA format.
class DateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;

    if (text.length > 10) return oldValue;
    if (newValue.selection.baseOffset < text.length) return newValue;

    String newText = text.replaceAll(RegExp(r'[^\d]'), '');
    String formatted = '';

    for (int i = 0; i < newText.length; i++) {
      if (i == 2 || i == 4) formatted += '/';
      formatted += newText[i];
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
