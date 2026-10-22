import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/utils/period_utils.dart';
import '../providers/data_providers.dart';
import '../widgets/filter_sheet.dart';
import '../widgets/period_navigator.dart';
import '../widgets/summary_card.dart';
import '../widgets/transaction_form.dart';
import '../widgets/transaction_tile.dart';

class MonthPage extends ConsumerWidget {
  const MonthPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final month = ref.watch(selectedMonthProvider);
    final week = ref.watch(selectedWeekProvider);
    final weeks = PeriodUtils.weeksOfMonth(month);
    final txs = ref.watch(monthTransactionsProvider);
    final label =
        toBeginningOfSentenceCase(DateFormat.yMMMM('pt_BR').format(month));

    void goToMonth(int delta) {
      ref.read(selectedMonthProvider.notifier).state =
          DateTime(month.year, month.month + delta);
      ref.read(selectedWeekProvider.notifier).state = null;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Mês'), actions: const [FilterButton()]),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showTransactionSheet(context),
        icon: const Icon(Icons.add),
        label: const Text('Lançar'),
      ),
      body: Column(
        children: [
          PeriodNavigator(
              label: label,
              onPrevious: () => goToMonth(-1),
              onNext: () => goToMonth(1)),
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: const Text('Mês todo'),
                    selected: week == null,
                    onSelected: (_) =>
                        ref.read(selectedWeekProvider.notifier).state = null,
                  ),
                ),
                for (var i = 0; i < weeks.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(
                          'Sem ${i + 1} (${weeks[i].start.day}–${weeks[i].lastDay.day})'),
                      selected: week == i,
                      onSelected: (_) =>
                          ref.read(selectedWeekProvider.notifier).state = i,
                    ),
                  ),
              ],
            ),
          ),
          SummaryCard(summary: ref.watch(monthSummaryProvider)),
          Expanded(
            child: txs.when(
              skipLoadingOnReload: true,
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Erro ao carregar: $e')),
              data: (list) => list.isEmpty
                  ? const Center(
                      child: Text(
                          'Nenhum lançamento neste período.\nToque em "Lançar" para começar.',
                          textAlign: TextAlign.center))
                  : ListView.builder(
                      padding: const EdgeInsets.only(bottom: 88),
                      itemCount: list.length,
                      itemBuilder: (_, i) => TransactionTile(tx: list[i]),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
