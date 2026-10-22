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
        icon: const Icon(Icons.add),
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
              Card(
                margin: const EdgeInsets.all(16),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Text('Total guardado'),
                      const SizedBox(height: 4),
                      Text(Money.format(total),
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              if (list.isEmpty)
                const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: Text('Nenhuma movimentação ainda.'))),
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
    return ListTile(
      leading:
          Icon(deposit ? Icons.savings_outlined : Icons.output, color: color),
      title: Text(entry.note.isEmpty
          ? (deposit ? 'Depósito' : 'Retirada')
          : entry.note),
      subtitle: Text(DateFormat('dd/MM/yyyy').format(entry.date)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
              '${deposit ? '+' : '-'} ${Money.format(entry.amountCents.abs())}',
              style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          IconButton(
            tooltip: 'Excluir',
            icon: const Icon(Icons.delete_outline),
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
