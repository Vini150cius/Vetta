import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/money.dart';
import '../../domain/entities/finance_summary.dart';
import '../providers/data_providers.dart';
import '../widgets/filter_sheet.dart';
import '../widgets/period_navigator.dart';
import '../widgets/summary_card.dart';

class YearPage extends ConsumerWidget {
  const YearPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final year = ref.watch(selectedYearProvider);
    final months = ref.watch(yearSummariesProvider);

    void goToYear(int delta) =>
        ref.read(selectedYearProvider.notifier).state = year + delta;

    return Scaffold(
      appBar: AppBar(
          title: const Text('Visão anual'), actions: const [FilterButton()]),
      body: months.when(
        skipLoadingOnReload: true,
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro ao carregar: $e')),
        data: (list) => ListView(
          children: [
            PeriodNavigator(
                label: '$year',
                onPrevious: () => goToYear(-1),
                onNext: () => goToYear(1)),
            SummaryCard(summary: FinanceSummary.combine(list)),
            SizedBox(
                height: 200,
                child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: _YearChart(list))),
            const SizedBox(height: 8),
            for (var m = 0; m < 12; m++)
              ListTile(
                title: Text(toBeginningOfSentenceCase(
                    DateFormat.MMMM('pt_BR').format(DateTime(year, m + 1)))),
                subtitle: Text(
                    'Receitas ${Money.format(list[m].income)}  •  Despesas ${Money.format(list[m].expense)}'),
                trailing: Text(
                  Money.format(list[m].balance),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: list[m].balance >= 0
                        ? AppTheme.incomeColor
                        : AppTheme.expenseColor,
                  ),
                ),
                onTap: () {
                  ref.read(selectedMonthProvider.notifier).state =
                      DateTime(year, m + 1);
                  ref.read(selectedWeekProvider.notifier).state = null;
                  context.go('/month'); // detalha o mês tocado
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _YearChart extends StatelessWidget {
  const _YearChart(this.months);
  final List<FinanceSummary> months;

  static const _labels = [
    'J',
    'F',
    'M',
    'A',
    'M',
    'J',
    'J',
    'A',
    'S',
    'O',
    'N',
    'D'
  ];

  @override
  Widget build(BuildContext context) {
    const hidden = AxisTitles(sideTitles: SideTitles(showTitles: false));
    return BarChart(
      BarChartData(
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(
          leftTitles: hidden,
          topTitles: hidden,
          rightTitles: hidden,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (v, meta) => SideTitleWidget(
                axisSide: meta.axisSide,
                child: Text(_labels[v.toInt()],
                    style: const TextStyle(fontSize: 11)),
              ),
            ),
          ),
        ),
        barGroups: [
          for (var i = 0; i < 12; i++)
            BarChartGroupData(
              x: i,
              barsSpace: 2,
              barRods: [
                BarChartRodData(
                    toY: months[i].income / 100,
                    color: AppTheme.incomeColor,
                    width: 6),
                BarChartRodData(
                    toY: months[i].expense / 100,
                    color: AppTheme.expenseColor,
                    width: 6),
              ],
            ),
        ],
      ),
    );
  }
}
