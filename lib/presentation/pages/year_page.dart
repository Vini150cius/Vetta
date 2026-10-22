import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/money.dart';
import '../../domain/entities/finance_summary.dart';
import '../providers/data_providers.dart';
import '../widgets/app_widgets.dart';
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
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            PeriodNavigator(
                label: '$year',
                onPrevious: () => goToYear(-1),
                onNext: () => goToYear(1)),
            SummaryCard(
                summary: FinanceSummary.combine(list), title: 'Saldo do ano'),
            AppCard(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('Receitas x despesas',
                          style: Theme.of(context).textTheme.titleSmall),
                      const Spacer(),
                      const _Legend('Receitas', AppTheme.incomeColor),
                      const SizedBox(width: 12),
                      const _Legend('Despesas', AppTheme.expenseColor),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(height: 180, child: _YearChart(list)),
                ],
              ),
            ),
            const SectionTitle('Mês a mês'),
            for (var m = 0; m < 12; m++)
              AppCard(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                onTap: () {
                  ref.read(selectedMonthProvider.notifier).state =
                      DateTime(year, m + 1);
                  ref.read(selectedWeekProvider.notifier).state = null;
                  context.go('/month'); // detalha o mês tocado
                },
                child: Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withAlpha(30),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        DateFormat.MMM('pt_BR')
                            .format(DateTime(year, m + 1))
                            .replaceAll('.', '')
                            .toUpperCase(),
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: Theme.of(context).colorScheme.primary),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              toBeginningOfSentenceCase(DateFormat.MMMM('pt_BR')
                                  .format(DateTime(year, m + 1))),
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700, fontSize: 15)),
                          const SizedBox(height: 2),
                          Text(
                            '+ ${Money.format(list[m].income)}   − ${Money.format(list[m].expense)}',
                            style: TextStyle(
                                fontSize: 12.5,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withAlpha(150)),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      Money.format(list[m].balance),
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: list[m].balance >= 0
                            ? AppTheme.incomeColor
                            : AppTheme.expenseColor,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend(this.label, this.color);
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 11.5)),
        ],
      );
}

class _YearChart extends StatelessWidget {
  const _YearChart(this.months);
  final List<FinanceSummary> months;

  static const _labels = [
    'J', 'F', 'M', 'A', 'M', 'J', 'J', 'A', 'S', 'O', 'N', 'D' //
  ];

  @override
  Widget build(BuildContext context) {
    const hidden = AxisTitles(sideTitles: SideTitles(showTitles: false));
    const radius = BorderRadius.vertical(top: Radius.circular(6));
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
                    style: const TextStyle(
                        fontSize: 11, fontWeight: FontWeight.w600)),
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
                    borderRadius: radius,
                    width: 7),
                BarChartRodData(
                    toY: months[i].expense / 100,
                    color: AppTheme.expenseColor,
                    borderRadius: radius,
                    width: 7),
              ],
            ),
        ],
      ),
    );
  }
}
