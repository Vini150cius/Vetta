import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/money.dart';
import '../../domain/entities/fin_transaction.dart';
import '../providers/finance_actions.dart';
import 'transaction_form.dart';

/// Toque = editar · segurar = excluir · ✓ = marcar previsto como realizado.
class TransactionTile extends ConsumerWidget {
  const TransactionTile({super.key, required this.tx});
  final FinTransaction tx;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isIncome = tx.type == TxType.income;
    final color = isIncome ? AppTheme.incomeColor : AppTheme.expenseColor;
    final info = [
      tx.category,
      if (tx.place.isNotEmpty) tx.place,
      DateFormat('dd/MM').format(tx.date),
      if (tx.planned) 'Previsto',
    ].join(' • ');

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withAlpha(36),
        child: Icon(isIncome ? Icons.arrow_downward : Icons.arrow_upward,
            color: color),
      ),
      title: Text(tx.description.isEmpty ? tx.category : tx.description,
          maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(info, maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('${isIncome ? '+' : '-'} ${Money.format(tx.amountCents)}',
              style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          if (tx.planned)
            IconButton(
              tooltip: 'Marcar como realizado',
              icon: const Icon(Icons.check_circle_outline),
              onPressed: () =>
                  ref.read(financeActionsProvider).markRealized(tx),
            ),
        ],
      ),
      onTap: () => showTransactionSheet(context, initial: tx),
      onLongPress: () => _confirmDelete(context, ref),
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
