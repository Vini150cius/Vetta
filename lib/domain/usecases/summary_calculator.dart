import '../entities/fin_transaction.dart';
import '../entities/finance_summary.dart';

/// Regra de negócio pura (sem Flutter, sem banco) — fácil de testar.
class SummaryCalculator {
  const SummaryCalculator._();

  static FinanceSummary summarize(Iterable<FinTransaction> items) {
    var income = 0, expense = 0, plannedIncome = 0, plannedExpense = 0;
    for (final t in items) {
      final isIncome = t.type == TxType.income;
      if (t.planned) {
        if (isIncome) {
          plannedIncome += t.amountCents;
        } else {
          plannedExpense += t.amountCents;
        }
      } else if (isIncome) {
        income += t.amountCents;
      } else {
        expense += t.amountCents;
      }
    }
    return FinanceSummary(
      income: income,
      expense: expense,
      plannedIncome: plannedIncome,
      plannedExpense: plannedExpense,
    );
  }

  /// 12 posições (jan..dez) a partir de lançamentos de um mesmo ano.
  static List<FinanceSummary> byMonth(Iterable<FinTransaction> items) =>
      List.generate(
          12, (m) => summarize(items.where((t) => t.date.month == m + 1)));
}
