import 'package:financas_app/core/utils/money.dart';
import 'package:financas_app/domain/entities/fin_transaction.dart';
import 'package:financas_app/domain/usecases/summary_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

FinTransaction _tx(TxType type, int cents,
        {bool planned = false, int month = 1}) =>
    FinTransaction(
      type: type,
      amountCents: cents,
      category: 'Teste',
      date: DateTime(2026, month, 10),
      planned: planned,
    );

void main() {
  test('saldo real ignora previstos; saldo previsto os inclui', () {
    final s = SummaryCalculator.summarize([
      _tx(TxType.income, 500000),
      _tx(TxType.expense, 120000),
      _tx(TxType.expense, 80000, planned: true),
      _tx(TxType.income, 20000, planned: true),
    ]);
    expect(s.balance, 380000);
    expect(s.projectedBalance, 320000);
  });

  test('byMonth separa por mês', () {
    final m = SummaryCalculator.byMonth([
      _tx(TxType.expense, 1000, month: 3),
      _tx(TxType.expense, 500, month: 3)
    ]);
    expect(m[2].expense, 1500);
    expect(m[0].expense, 0);
  });

  test('parseCents aceita formatos brasileiros e simples', () {
    expect(Money.parseCents('R\$ 1.234,56'), 123456);
    expect(Money.parseCents('12.5'), 1250);
    expect(Money.parseCents('abc'), isNull);
  });
}
