import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/money.dart';
import '../providers/data_providers.dart';
import '../widgets/app_widgets.dart';
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
        icon: const Icon(Icons.add_rounded),
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
                  icon: Icons.account_balance_wallet_rounded,
                  gradient: AppTheme.heroGradient,
                  cents: s.balance,
                ),
                _BalanceCard(
                  title: 'Saldo previsto',
                  subtitle:
                      'Real + previstos (${Money.format(s.plannedIncome)} a receber, ${Money.format(s.plannedExpense)} a pagar)',
                  icon: Icons.insights_rounded,
                  gradient: AppTheme.sunsetGradient,
                  cents: s.projectedBalance,
                ),
              ],
            ),
          ),
          const SectionTitle('Lançamentos previstos'),
          planned.when(
            skipLoadingOnReload: true,
            loading: () => const SizedBox.shrink(),
            error: (e, _) => Text('Erro: $e'),
            data: (list) => list.isEmpty
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: EmptyState(Icons.event_available_rounded,
                        'Nada previsto.\nMarque "Previsto" ao lançar uma despesa futura.'))
                : Column(
                    children: [for (final t in list) TransactionTile(tx: t)]),
          ),
        ],
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    required this.cents,
  });
  final String title;
  final String subtitle;
  final IconData icon;
  final Gradient gradient;
  final int cents;

  @override
  Widget build(BuildContext context) => HeroCard(
        gradient: gradient,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: Colors.white.withAlpha(46),
                      borderRadius: BorderRadius.circular(14)),
                  child: Icon(icon, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 10),
                Text(title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16)),
              ],
            ),
            const SizedBox(height: 14),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(Money.format(cents),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1)),
            ),
            const SizedBox(height: 6),
            Text(subtitle,
                style: TextStyle(
                    color: Colors.white.withAlpha(210), fontSize: 12.5)),
          ],
        ),
      );
}
