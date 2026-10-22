import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/money.dart';
import '../providers/data_providers.dart';
import '../widgets/transaction_form.dart';
import '../widgets/transaction_tile.dart';

/// Saldo REAL (só o que já aconteceu) x saldo PREVISTO (real + lançamentos futuros).
class BalancePage extends ConsumerWidget {
  const BalancePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totals = ref.watch(balanceProvider);
    final planned = ref.watch(plannedProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Saldo real x previsto')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showTransactionSheet(context),
        icon: const Icon(Icons.add),
        label: const Text('Lançar'),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 88),
        children: [
          totals.when(
            skipLoadingOnReload: true,
            loading: () => const Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: CircularProgressIndicator())),
            error: (e, _) => Padding(
                padding: const EdgeInsets.all(16), child: Text('Erro: $e')),
            data: (s) => Column(
              children: [
                _BalanceCard(
                    title: 'Saldo real',
                    subtitle: 'Receitas − despesas já realizadas',
                    cents: s.balance),
                _BalanceCard(
                  title: 'Saldo previsto',
                  subtitle:
                      'Real + previstos (${Money.format(s.plannedIncome)} a receber, ${Money.format(s.plannedExpense)} a pagar)',
                  cents: s.projectedBalance,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Text('Lançamentos previstos',
                style: Theme.of(context).textTheme.titleMedium),
          ),
          planned.when(
            skipLoadingOnReload: true,
            loading: () => const SizedBox.shrink(),
            error: (e, _) => Text('Erro: $e'),
            data: (list) => list.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                        'Nada previsto. Marque "Previsto" ao lançar uma despesa futura.'))
                : Column(
                    children: [for (final t in list) TransactionTile(tx: t)]),
          ),
        ],
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard(
      {required this.title, required this.subtitle, required this.cents});
  final String title;
  final String subtitle;
  final int cents;

  @override
  Widget build(BuildContext context) => Card(
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(
                Money.format(cents),
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: cents >= 0
                          ? AppTheme.incomeColor
                          : AppTheme.expenseColor,
                    ),
              ),
              const SizedBox(height: 4),
              Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      );
}
