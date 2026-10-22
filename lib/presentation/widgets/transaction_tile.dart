import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/category_style.dart';
import '../../core/utils/money.dart';
import '../../domain/entities/fin_transaction.dart';
import '../providers/finance_actions.dart';
import 'app_widgets.dart';
import 'transaction_form.dart';

/// Toque = editar · segurar = excluir · ✓ = marcar previsto como realizado.
class TransactionTile extends ConsumerWidget {
  const TransactionTile({super.key, required this.tx});
  final FinTransaction tx;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isIncome = tx.type == TxType.income;
    final amountColor = isIncome ? AppTheme.incomeColor : AppTheme.expenseColor;
    final style = CategoryStyle.of(tx.category);
    final muted = Theme.of(context).colorScheme.onSurface.withAlpha(150);
    final info = [
      tx.category,
      if (tx.place.isNotEmpty) tx.place,
      DateFormat('dd/MM').format(tx.date),
    ].join(' • ');

    return AppCard(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      padding: const EdgeInsets.fromLTRB(12, 12, 14, 12),
      onTap: () => showTransactionSheet(context, initial: tx),
      onLongPress: () => _confirmDelete(context, ref),
      child: Row(
        children: [
          IconBadge(style.icon, style.color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tx.description.isEmpty ? tx.category : tx.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 15)),
                const SizedBox(height: 2),
                Text(info,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: muted, fontSize: 12.5)),
                if (tx.planned) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.amber.withAlpha(40),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text('Previsto',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFB87400))),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${isIncome ? '+' : '-'} ${Money.format(tx.amountCents)}',
                  style: TextStyle(
                      color: amountColor,
                      fontWeight: FontWeight.w800,
                      fontSize: 15)),
              if (tx.planned)
                IconButton(
                  tooltip: 'Marcar como realizado',
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.check_circle_rounded,
                      color: AppTheme.incomeColor),
                  onPressed: () =>
                      ref.read(financeActionsProvider).markRealized(tx),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir lançamento?'),
        content: Text(tx.description.isEmpty ? tx.category : tx.description),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar')),
          FilledButton(
              style: FilledButton.styleFrom(
                  minimumSize: const Size(96, 44),
                  backgroundColor: AppTheme.expenseColor),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Excluir')),
        ],
      ),
    );
    if (ok == true && tx.id != null) {
      await ref.read(financeActionsProvider).deleteTransaction(tx.id!);
    }
  }
}
