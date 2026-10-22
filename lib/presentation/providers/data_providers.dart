import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/period_utils.dart';
import '../../domain/entities/fin_transaction.dart';
import '../../domain/entities/catalog_item.dart';
import '../../domain/entities/finance_summary.dart';
import '../../domain/entities/savings_entry.dart';
import '../../domain/entities/transaction_filter.dart';
import '../../domain/usecases/savings_usecases.dart';
import '../../domain/usecases/summary_calculator.dart';
import '../../domain/usecases/transaction_usecases.dart';
import 'auth_controller.dart';
import 'di_providers.dart';

// ---- Estado de UI (o que o usuário selecionou) ----
/// Incrementado a cada escrita no banco; todas as consultas o observam e se refazem.
final dataVersionProvider = StateProvider<int>((ref) => 0);

final selectedMonthProvider = StateProvider<DateTime>((ref) {
  final n = DateTime.now();
  return DateTime(n.year, n.month);
});
final selectedWeekProvider =
    StateProvider<int?>((ref) => null); // null = mês todo
final selectedYearProvider = StateProvider<int>((ref) => DateTime.now().year);

/// Filtros por categoria/local/tipo — compartilhados entre as abas Mês e Ano.
final filterProvider =
    StateProvider<TransactionFilter>((ref) => const TransactionFilter());

// ---- Consultas derivadas ----
// Todas checam isUnlockedProvider: com o app travado nenhuma consulta toca o banco.
final monthTransactionsProvider =
    FutureProvider.autoDispose<List<FinTransaction>>((ref) async {
  if (!ref.watch(isUnlockedProvider)) return const <FinTransaction>[];
  ref.watch(dataVersionProvider);
  final month = ref.watch(selectedMonthProvider);
  final week = ref.watch(selectedWeekProvider);
  final filter = ref.watch(filterProvider);

  final weeks = PeriodUtils.weeksOfMonth(month);
  final range = week == null
      ? PeriodUtils.month(month)
      : weeks[week.clamp(0, weeks.length - 1)];
  return QueryTransactions(ref.watch(transactionRepositoryProvider))(
    filter.copyWith(from: range.start, to: range.end),
  );
});

final monthSummaryProvider = Provider.autoDispose<FinanceSummary>(
  (ref) => SummaryCalculator.summarize(
      ref.watch(monthTransactionsProvider).valueOrNull ?? const []),
);

final yearSummariesProvider =
    FutureProvider.autoDispose<List<FinanceSummary>>((ref) async {
  if (!ref.watch(isUnlockedProvider))
    return List.filled(12, const FinanceSummary());
  ref.watch(dataVersionProvider);
  final year = ref.watch(selectedYearProvider);
  final filter = ref.watch(filterProvider);
  final range = PeriodUtils.year(year);
  final items =
      await QueryTransactions(ref.watch(transactionRepositoryProvider))(
    filter.copyWith(from: range.start, to: range.end),
  );
  return SummaryCalculator.byMonth(items);
});

/// Saldo real x previsto de todo o histórico (agregado direto no SQL).
final balanceProvider = FutureProvider.autoDispose<FinanceSummary>((ref) async {
  if (!ref.watch(isUnlockedProvider)) return const FinanceSummary();
  ref.watch(dataVersionProvider);
  return GetTotals(ref.watch(transactionRepositoryProvider))();
});

final plannedProvider =
    FutureProvider.autoDispose<List<FinTransaction>>((ref) async {
  if (!ref.watch(isUnlockedProvider)) return const <FinTransaction>[];
  ref.watch(dataVersionProvider);
  final list =
      await QueryTransactions(ref.watch(transactionRepositoryProvider))(
    const TransactionFilter(planned: true),
  );
  return list
    ..sort((a, b) => a.date.compareTo(b.date)); // próximos vencimentos primeiro
});

final usedCategoriesProvider =
    FutureProvider.autoDispose<List<String>>((ref) async {
  if (!ref.watch(isUnlockedProvider)) return const <String>[];
  ref.watch(dataVersionProvider);
  return GetUsedCategories(ref.watch(transactionRepositoryProvider))();
});

final usedPlacesProvider =
    FutureProvider.autoDispose<List<String>>((ref) async {
  if (!ref.watch(isUnlockedProvider)) return const <String>[];
  ref.watch(dataVersionProvider);
  return GetUsedPlaces(ref.watch(transactionRepositoryProvider))();
});

final catalogCategoriesProvider =
    FutureProvider.autoDispose<List<CatalogItem>>((ref) async {
  if (!ref.watch(isUnlockedProvider)) return const <CatalogItem>[];
  ref.watch(dataVersionProvider);
  return ref.watch(catalogRepositoryProvider).list(CatalogKind.category);
});

final catalogPlacesProvider =
    FutureProvider.autoDispose<List<CatalogItem>>((ref) async {
  if (!ref.watch(isUnlockedProvider)) return const <CatalogItem>[];
  ref.watch(dataVersionProvider);
  return ref.watch(catalogRepositoryProvider).list(CatalogKind.place);
});

final savingsProvider =
    FutureProvider.autoDispose<List<SavingsEntry>>((ref) async {
  if (!ref.watch(isUnlockedProvider)) return const <SavingsEntry>[];
  ref.watch(dataVersionProvider);
  return GetSavings(ref.watch(savingsRepositoryProvider))();
});
