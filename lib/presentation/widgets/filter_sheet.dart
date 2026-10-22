import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/fin_transaction.dart';
import '../../domain/entities/transaction_filter.dart';
import '../providers/data_providers.dart';

/// Botão de filtro com indicador (bolinha) quando há filtros ativos.
class FilterButton extends ConsumerWidget {
  const FilterButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final active = ref.watch(filterProvider).hasAttributeFilters;
    return IconButton(
      tooltip: 'Filtros',
      icon: Badge(isLabelVisible: active, child: const Icon(Icons.filter_list)),
      onPressed: () => showFilterSheet(context),
    );
  }
}

Future<void> showFilterSheet(BuildContext context) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => const _FilterSheet(),
    );

Set<String> _toggle(Set<String> s, String v) =>
    s.contains(v) ? ({...s}..remove(v)) : {...s, v};

class _FilterSheet extends ConsumerWidget {
  const _FilterSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final f = ref.watch(filterProvider);
    final categories =
        ref.watch(usedCategoriesProvider).valueOrNull ?? const <String>[];
    final places =
        ref.watch(usedPlacesProvider).valueOrNull ?? const <String>[];
    void update(TransactionFilter n) =>
        ref.read(filterProvider.notifier).state = n;

    Widget chips(List<String> all, Set<String> selected,
            ValueChanged<Set<String>> onChange) =>
        all.isEmpty
            ? const Text('Nada cadastrado ainda.')
            : Wrap(
                spacing: 8,
                children: [
                  for (final v in all)
                    FilterChip(
                        label: Text(v),
                        selected: selected.contains(v),
                        onSelected: (_) => onChange(_toggle(selected, v))),
                ],
              );

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Filtros', style: Theme.of(context).textTheme.titleLarge),
              TextButton(
                onPressed: f.hasAttributeFilters
                    ? () => update(const TransactionFilter())
                    : null,
                child: const Text('Limpar'),
              ),
            ],
          ),
          const Text('Tipo'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              ChoiceChip(
                  label: const Text('Todos'),
                  selected: f.type == null,
                  onSelected: (_) => update(f.copyWith(clearType: true))),
              ChoiceChip(
                  label: const Text('Ganhos'),
                  selected: f.type == TxType.income,
                  onSelected: (_) => update(f.copyWith(type: TxType.income))),
              ChoiceChip(
                  label: const Text('Gastos'),
                  selected: f.type == TxType.expense,
                  onSelected: (_) => update(f.copyWith(type: TxType.expense))),
            ],
          ),
          const SizedBox(height: 16),
          const Text('Categorias'),
          const SizedBox(height: 8),
          chips(categories, f.categories,
              (s) => update(f.copyWith(categories: s))),
          const SizedBox(height: 16),
          const Text('Locais'),
          const SizedBox(height: 8),
          chips(places, f.places, (s) => update(f.copyWith(places: s))),
          const SizedBox(height: 8),
          Text(
              'Categoria e local combinam (E); dentro de cada grupo vale qualquer um (OU).',
              style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Aplicar')),
          ),
        ],
      ),
    );
  }
}
