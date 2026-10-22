import 'package:intl/intl.dart';

/// Dinheiro SEMPRE em centavos (int): evita erros de ponto flutuante nas somas.
class Money {
  Money._();

  static final _fmt = NumberFormat.currency(locale: 'pt_BR', symbol: r'R$');

  static String format(int cents) => _fmt.format(cents / 100);

  /// Aceita "1.234,56", "R$ 12,50", "12.5", "-3,00"... Retorna null se inválido.
  static int? parseCents(String raw) {
    var s = raw.replaceAll(RegExp(r'[^0-9,.\-]'), '');
    if (s.isEmpty) return null;
    if (s.contains(',')) s = s.replaceAll('.', '').replaceAll(',', '.');
    final v = double.tryParse(s);
    return v == null ? null : (v * 100).round();
  }
}
