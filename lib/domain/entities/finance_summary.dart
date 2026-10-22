/// Totais de um período. "Real" = lançamentos realizados; "previsto" soma os planejados.
class FinanceSummary {
  const FinanceSummary({
    this.income = 0,
    this.expense = 0,
    this.plannedIncome = 0,
    this.plannedExpense = 0,
  });

  final int income;
  final int expense;
  final int plannedIncome;
  final int plannedExpense;

  int get balance => income - expense; // saldo REAL
  int get projectedBalance =>
      balance + plannedIncome - plannedExpense; // saldo PREVISTO
  bool get hasPlanned => plannedIncome != 0 || plannedExpense != 0;

  static FinanceSummary combine(Iterable<FinanceSummary> items) => items.fold(
        const FinanceSummary(),
        (a, b) => FinanceSummary(
          income: a.income + b.income,
          expense: a.expense + b.expense,
          plannedIncome: a.plannedIncome + b.plannedIncome,
          plannedExpense: a.plannedExpense + b.plannedExpense,
        ),
      );
}
