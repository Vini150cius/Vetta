import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/cents_input_formatter.dart';
import '../../core/utils/money.dart';
import '../../core/utils/period_utils.dart';
import '../../domain/entities/fin_transaction.dart';
import '../providers/data_providers.dart';
import '../providers/finance_actions.dart';
import 'field_decoration.dart';

Future<void> showTransactionSheet(BuildContext context,
        {FinTransaction? initial}) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => TransactionForm(initial: initial),
    );

List<String> _merge(List<String> defaults, List<String> used) {
  final seen = <String>{};
  final out = <String>[];
  for (final v in [...used, ...defaults]) {
    if (seen.add(v.toLowerCase())) out.add(v);
  }
  return out;
}

/// Lançamento rápido: só o VALOR é obrigatório (categoria vira "Outros" se vazia).
class TransactionForm extends ConsumerStatefulWidget {
  const TransactionForm({super.key, this.initial});
  final FinTransaction? initial;

  @override
  ConsumerState<TransactionForm> createState() => _TransactionFormState();
}

class _TransactionFormState extends ConsumerState<TransactionForm> {
  final _formKey = GlobalKey<FormState>();
  late TxType _type;
  late DateTime _date;
  late bool _planned;
  late final TextEditingController _amount;
  late final TextEditingController _desc;
  String _category = '';
  String _place = '';

  @override
  void initState() {
    super.initState();
    final t = widget.initial;
    _type = t?.type ?? TxType.expense;
    _date = t?.date ?? PeriodUtils.today();
    _planned = t?.planned ?? false;
    _amount = TextEditingController(
        text: t == null ? '' : Money.format(t.amountCents));
    _desc = TextEditingController(text: t?.description ?? '');
    _category = t?.category ?? '';
    _place = t?.place ?? '';
  }

  @override
  void dispose() {
    _amount.dispose();
    _desc.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    setState(() {
      _date = picked;
      if (picked.isAfter(PeriodUtils.today()))
        _planned = true; // data futura => previsto
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final tx = FinTransaction(
      id: widget.initial?.id,
      type: _type,
      amountCents: Money.parseCents(_amount.text)!,
      description: _desc.text.trim(),
      category: _category.trim().isEmpty ? 'Outros' : _category.trim(),
      place: _place.trim(),
      date: _date,
      planned: _planned,
    );
    await ref.read(financeActionsProvider).saveTransaction(tx);
    if (mounted) Navigator.pop(context);
  }

  Widget _autocomplete({
    required String label,
    required IconData icon,
    required String initial,
    required List<String> options,
    required ValueChanged<String> onChanged,
  }) =>
      Autocomplete<String>(
        initialValue: TextEditingValue(text: initial),
        optionsBuilder: (v) => options
            .where((o) => o.toLowerCase().contains(v.text.toLowerCase())),
        onSelected: onChanged,
        fieldViewBuilder: (context, controller, focusNode, onSubmit) =>
            TextFormField(
          controller: controller,
          focusNode: focusNode,
          decoration: fieldDecoration(label, icon: icon),
          textCapitalization: TextCapitalization.sentences,
          onChanged: onChanged,
        ),
      );

  @override
  Widget build(BuildContext context) {
    final savedCategories = ref
        .watch(catalogCategoriesProvider)
        .valueOrNull
        ?.map((e) => e.name)
        .toList();
    final savedPlaces = ref
        .watch(catalogPlacesProvider)
        .valueOrNull
        ?.map((e) => e.name)
        .toList();
    final categories = _merge(savedCategories ?? kDefaultCategories,
        ref.watch(usedCategoriesProvider).valueOrNull ?? const []);
    final places = _merge(savedPlaces ?? kDefaultPlaces,
        ref.watch(usedPlacesProvider).valueOrNull ?? const []);

    return Padding(
      padding: EdgeInsets.fromLTRB(
          16, 0, 16, 16 + MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SegmentedButton<TxType>(
                segments: const [
                  ButtonSegment(
                      value: TxType.expense,
                      label: Text('Gasto'),
                      icon: Icon(Icons.arrow_upward)),
                  ButtonSegment(
                      value: TxType.income,
                      label: Text('Ganho'),
                      icon: Icon(Icons.arrow_downward)),
                ],
                selected: {_type},
                onSelectionChanged: (s) => setState(() => _type = s.first),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _amount,
                autofocus: widget.initial == null,
                keyboardType: TextInputType.number,
                inputFormatters: [CentsInputFormatter()],
                style: Theme.of(context).textTheme.headlineSmall,
                decoration: fieldDecoration('Valor', icon: Icons.attach_money),
                validator: (v) => (Money.parseCents(v ?? '') ?? 0) <= 0
                    ? 'Informe um valor'
                    : null,
              ),
              const SizedBox(height: 12),
              _autocomplete(
                label: 'Categoria',
                icon: Icons.category_outlined,
                initial: _category,
                options: categories,
                onChanged: (v) => _category = v,
              ),
              const SizedBox(height: 12),
              _autocomplete(
                label: 'Local (ex.: Shopee)',
                icon: Icons.place_outlined,
                initial: _place,
                options: places,
                onChanged: (v) => _place = v,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _desc,
                decoration:
                    fieldDecoration('Descrição (opcional)', icon: Icons.notes),
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: _pickDate,
                    icon: const Icon(Icons.event),
                    label: Text(DateFormat('dd/MM/yyyy').format(_date)),
                  ),
                  const Spacer(),
                  const Text('Previsto'),
                  Switch(
                      value: _planned,
                      onChanged: (v) => setState(() => _planned = v)),
                ],
              ),
              const SizedBox(height: 8),
              FilledButton.icon(
                  onPressed: _save,
                  icon: const Icon(Icons.check),
                  label: const Text('Salvar')),
            ],
          ),
        ),
      ),
    );
  }
}
