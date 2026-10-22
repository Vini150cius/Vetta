import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/money.dart';
import '../../domain/entities/finance_summary.dart';

class SummaryCard extends StatelessWidget {
  const SummaryCard({super.key, required this.summary});
  final FinanceSummary summary;

  @override
  Widget build(BuildContext context) {
    final balanceColor =
        summary.balance >= 0 ? AppTheme.incomeColor : AppTheme.expenseColor;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _Metric('Receitas', summary.income, AppTheme.incomeColor),
                _Metric('Despesas', summary.expense, AppTheme.expenseColor),
                _Metric('Saldo', summary.balance, balanceColor),
              ],
            ),
            if (summary.hasPlanned) ...[
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Saldo previsto',
                      style: Theme.of(context).textTheme.bodyMedium),
                  Text(Money.format(summary.projectedBalance),
                      style: Theme.of(context).textTheme.titleSmall),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric(this.label, this.cents, this.color);
  final String label;
  final int cents;
  final Color color;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Text(label, style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: 4),
          Text(Money.format(cents),
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(color: color, fontWeight: FontWeight.bold)),
        ],
      );
}
