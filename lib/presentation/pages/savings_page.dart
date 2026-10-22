import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/cents_input_formatter.dart';
import '../../core/utils/money.dart';
import '../../core/utils/period_utils.dart';
import '../../domain/entities/savings_entry.dart';
import '../providers/data_providers.dart';
import '../providers/finance_actions.dart';
import '../widgets/app_widgets.dart';
import '../widgets/field_decoration.dart';

/// Aba do dinheiro guardado: total acumulado + histórico de depósitos/retiradas.
class SavingsPage extends ConsumerWidget {
  const SavingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(savingsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Dinheiro guardado')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showDialog<void>(
            context: context, builder: (_) => const _SavingsDialog()),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Movimentar'),
      ),
      body: entries.when(
        skipLoadingOnReload: true,
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro ao carregar: $e')),
        data: (list) {
          final total = list.fold<int>(0, (sum, e) => sum + e.amountCents);
          return ListView(
            padding: const EdgeInsets.only(bottom: 88),
            children: [
              HeroCard(
                gradient: AppTheme.mintGradient,
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
                          child: const Icon(Icons.savings_rounded,
                              color: Colors.white, size: 20),
                        ),
                        const SizedBox(width: 10),
                        const Text('Total guardado',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 16)),
                      ],
                    ),
                    const SizedBox(height: 14),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(Money.format(total),
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 36,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -1)),
                    ),
                  ],
                ),
              ),
              const SectionTitle('Movimentações'),
              if (list.isEmpty)
                const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: EmptyState(
                        Icons.savings_rounded, 'Nenhuma movimentação ainda.')),
              for (final e in list) _EntryTile(entry: e),
            ],
          );
        },
      ),
    );
  }
}

class _EntryTile extends ConsumerWidget {
  const _EntryTile({required this.entry});
  final SavingsEntry entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deposit = entry.amountCents > 0;
    final color = deposit ? AppTheme.incomeColor : AppTheme.expenseColor;
    return AppCard(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      padding: const EdgeInsets.fromLTRB(12, 10, 4, 10),
      child: Row(
        children: [
          IconBadge(
              deposit ? Icons.savings_rounded : Icons.output_rounded, color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    entry.note.isEmpty
                        ? (deposit ? 'Depósito' : 'Retirada')
                        : entry.note,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 15)),
                Text(DateFormat('dd/MM/yyyy').format(entry.date),
                    style: TextStyle(
                        fontSize: 12.5,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withAlpha(150))),
              ],
            ),
          ),
          Text(
              '${deposit ? '+' : '-'} ${Money.format(entry.amountCents.abs())}',
              style: TextStyle(
                  color: color, fontWeight: FontWeight.w800, fontSize: 15)),
          IconButton(
            tooltip: 'Excluir',
            icon: const Icon(Icons.delete_outline_rounded),
            onPressed: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Excluir movimentação?'),
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
              if (ok == true && entry.id != null) {
                await ref.read(financeActionsProvider).deleteSavings(entry.id!);
              }
            },
          ),
        ],
      ),
    );
  }
}

class _SavingsDialog extends ConsumerStatefulWidget {
  const _SavingsDialog();

  @override
  ConsumerState<_SavingsDialog> createState() => _SavingsDialogState();
}

class _SavingsDialogState extends ConsumerState<_SavingsDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amount = TextEditingController();
  final _note = TextEditingController();
  bool _deposit = true;

  @override
  void dispose() {
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final cents = Money.parseCents(_amount.text)!.abs();
    await ref.read(financeActionsProvider).addSavings(SavingsEntry(
          amountCents: _deposit ? cents : -cents,
          note: _note.text.trim(),
          date: PeriodUtils.today(),
        ));
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: const Text('Dinheiro guardado'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SegmentedButton<bool>(
                showSelectedIcon: false,
                segments: const [
                  ButtonSegment(value: true, label: Text('Guardar')),
                  ButtonSegment(value: false, label: Text('Retirar')),
                ],
                selected: {_deposit},
                onSelectionChanged: (s) => setState(() => _deposit = s.first),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _amount,
                autofocus: true,
                keyboardType: TextInputType.number,
                inputFormatters: [CentsInputFormatter()],
                decoration: fieldDecoration('Valor'),
                validator: (v) => (Money.parseCents(v ?? '') ?? 0) == 0
                    ? 'Informe um valor'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                  controller: _note,
                  decoration: fieldDecoration('Observação (opcional)')),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar')),
          FilledButton(onPressed: _save, child: const Text('Salvar')),
        ],
      );
}
