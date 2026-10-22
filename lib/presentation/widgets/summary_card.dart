import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/money.dart';
import '../../domain/entities/finance_summary.dart';
import 'app_widgets.dart';

/// Cartão de destaque: saldo grande + receitas/despesas em "pílulas".
class SummaryCard extends StatelessWidget {
  const SummaryCard(
      {super.key, required this.summary, this.title = 'Saldo do período'});
  final FinanceSummary summary;
  final String title;

  @override
  Widget build(BuildContext context) {
    return HeroCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(
                  color: Colors.white.withAlpha(200),
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(Money.format(summary.balance),
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1)),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                  child: _Pill('Receitas', summary.income,
                      Icons.arrow_downward_rounded, AppTheme.incomeColor)),
              const SizedBox(width: 12),
              Expanded(
                  child: _Pill('Despesas', summary.expense,
                      Icons.arrow_upward_rounded, AppTheme.expenseColor)),
            ],
          ),
          if (summary.hasPlanned) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Icon(Icons.schedule_rounded,
                    size: 18, color: Colors.white.withAlpha(200)),
                const SizedBox(width: 6),
                Text('Saldo previsto',
                    style: TextStyle(color: Colors.white.withAlpha(200))),
                const Spacer(),
                Text(Money.format(summary.projectedBalance),
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w800)),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill(this.label, this.cents, this.icon, this.color);
  final String label;
  final int cents;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(36),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              child: Icon(icon, size: 18, color: Colors.white),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: TextStyle(
                          color: Colors.white.withAlpha(200), fontSize: 12)),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(Money.format(cents),
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 14)),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}
