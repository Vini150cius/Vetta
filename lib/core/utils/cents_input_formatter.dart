import 'package:flutter/services.dart';

import 'money.dart';

/// Máscara de moeda "estilo caixa registradora": digita 1250 → R$ 12,50.
/// Acelera a inserção de gastos (só números, sem vírgula).
class CentsInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return const TextEditingValue();
    if (digits.length > 12) return oldValue;
    final text = Money.format(int.parse(digits));
    return TextEditingValue(
        text: text, selection: TextSelection.collapsed(offset: text.length));
  }
}
