import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/entities/catalog_item.dart';
import '../../domain/services/spreadsheet_codec.dart';
import '../providers/auth_controller.dart';
import '../providers/data_providers.dart';
import '../providers/di_providers.dart';
import '../providers/finance_actions.dart';
import '../providers/theme_controller.dart';
import '../widgets/app_widgets.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  void _toast(BuildContext context, String msg) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _export(
      BuildContext context, WidgetRef ref, SpreadsheetFormat format) async {
    // Exportar tira os dados da proteção do cofre: pedimos confirmação explícita.
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Exportar sem criptografia'),
        content: const Text(
            'O arquivo gerado NÃO é protegido por biometria nem criptografia. '
            'Compartilhe apenas com apps e pessoas de confiança.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Exportar')),
        ],
      ),
    );
    if (ok != true) return;
    try {
      final bytes = await ref.read(financeActionsProvider).exportData(format);
      final name =
          'financas_export_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}.${format.name}';
      await ref.read(authControllerProvider.notifier).withoutAutoLock(
          () => ref.read(fileExchangeProvider).shareBytes(name, bytes));
    } catch (e) {
      _toast(context, 'Falha ao exportar: $e');
    }
  }

  Future<void> _import(BuildContext context, WidgetRef ref) async {
    try {
      final picked = await ref
          .read(authControllerProvider.notifier)
          .withoutAutoLock(
              () => ref.read(fileExchangeProvider).pickSpreadsheet());
      if (picked == null) return;
      final n = await ref
          .read(financeActionsProvider)
          .importData(picked.bytes, picked.format);
      _toast(context, '$n lançamentos importados.');
    } on FormatException catch (e) {
      _toast(context, e.message);
    } catch (e) {
      _toast(context, 'Falha ao importar: $e');
    }
  }

  Future<void> _editCatalogItem(
    BuildContext context,
    WidgetRef ref, {
    required CatalogKind kind,
    CatalogItem? item,
  }) async {
    final controller = TextEditingController(text: item?.name ?? '');
    final label = kind == CatalogKind.category ? 'categoria' : 'local';
    final name = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(item == null ? 'Adicionar $label' : 'Editar $label'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(labelText: 'Nome do $label'),
          onSubmitted: (_) => Navigator.pop(dialogContext, controller.text),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancelar')),
          FilledButton(
              onPressed: () => Navigator.pop(dialogContext, controller.text),
              child: const Text('Salvar')),
        ],
      ),
    );
    controller.dispose();
    final trimmed = name?.trim() ?? '';
    if (trimmed.isEmpty) return;
    try {
      final actions = ref.read(financeActionsProvider);
      if (item == null) {
        await actions
            .addCatalogItem(CatalogItem(id: null, name: trimmed, kind: kind));
      } else {
        await actions.updateCatalogItem(
            CatalogItem(id: item.id, name: trimmed, kind: kind));
      }
    } on StateError catch (error) {
      _toast(context, error.message);
    } catch (error) {
      _toast(context, 'Falha ao salvar: $error');
    }
  }

  Future<void> _deleteCatalogItem(
      BuildContext context, WidgetRef ref, CatalogItem item) async {
    final label = item.kind == CatalogKind.category ? 'categoria' : 'local';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Excluir $label?'),
        content: Text(
            'A exclusão de "${item.name}" não altera lançamentos antigos.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancelar')),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirmed != true || item.id == null) return;
    try {
      await ref.read(financeActionsProvider).deleteCatalogItem(item.id!);
    } catch (e) {
      _toast(context, 'Falha ao excluir: $e');
    }
  }

  Widget _catalogSection(
      BuildContext context, WidgetRef ref, CatalogKind kind) {
    final isCategory = kind == CatalogKind.category;
    final items = isCategory
        ? ref.watch(catalogCategoriesProvider)
        : ref.watch(catalogPlacesProvider);
    final label = isCategory ? 'Categorias' : 'Locais';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ListTile(
          leading: IconBadge(
              isCategory ? Icons.category_rounded : Icons.place_rounded,
              isCategory ? AppTheme.pink : AppTheme.sky,
              size: 40),
          title:
              Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
          trailing: IconButton(
            tooltip: 'Adicionar',
            icon: const Icon(Icons.add),
            onPressed: () => _editCatalogItem(context, ref, kind: kind),
          ),
        ),
        items.when(
          loading: () => const LinearProgressIndicator(),
          error: (error, _) =>
              ListTile(title: Text('Falha ao carregar $label: $error')),
          data: (values) => values.isEmpty
              ? const Padding(
                  padding: EdgeInsets.fromLTRB(72, 0, 16, 16),
                  child: Text('Nenhum item cadastrado.'),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: values.length,
                  itemBuilder: (_, index) {
                    final item = values[index];
                    return ListTile(
                      contentPadding: const EdgeInsets.only(left: 72, right: 8),
                      title: Text(item.name),
                      trailing: Wrap(
                        children: [
                          IconButton(
                            tooltip: 'Editar',
                            icon: const Icon(Icons.edit_outlined),
                            onPressed: () => _editCatalogItem(context, ref,
                                kind: kind, item: item),
                          ),
                          IconButton(
                            tooltip: 'Excluir',
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () =>
                                _deleteCatalogItem(context, ref, item),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeControllerProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          const SectionTitle('Aparência'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SegmentedButton<ThemeMode>(
              showSelectedIcon: false,
              segments: const [
                ButtonSegment(
                    value: ThemeMode.system,
                    label: Text('Sistema'),
                    icon: Icon(Icons.brightness_auto_rounded)),
                ButtonSegment(
                    value: ThemeMode.light,
                    label: Text('Claro'),
                    icon: Icon(Icons.light_mode_rounded)),
                ButtonSegment(
                    value: ThemeMode.dark,
                    label: Text('Escuro'),
                    icon: Icon(Icons.dark_mode_rounded)),
              ],
              selected: {mode},
              onSelectionChanged: (s) =>
                  ref.read(themeControllerProvider.notifier).setMode(s.first),
            ),
          ),
          const SectionTitle('Dados (Excel / Google Sheets)'),
          AppCard(
            child: Column(
              children: [
                ListTile(
                  leading: const IconBadge(
                      Icons.table_view_rounded, AppTheme.incomeColor,
                      size: 40),
                  title: const Text('Exportar CSV'),
                  subtitle: const Text(
                      'Separador ";" — abre no Excel e no Google Sheets'),
                  onTap: () => _export(context, ref, SpreadsheetFormat.csv),
                ),
                ListTile(
                  leading: const IconBadge(
                      Icons.grid_on_rounded, AppTheme.primary,
                      size: 40),
                  title: const Text('Exportar XLSX'),
                  onTap: () => _export(context, ref, SpreadsheetFormat.xlsx),
                ),
                ListTile(
                  leading: const IconBadge(
                      Icons.upload_file_rounded, AppTheme.amber,
                      size: 40),
                  title: const Text('Importar CSV / XLSX'),
                  subtitle: const Text(
                      'Colunas: Data, Tipo, Valor, Descricao, Categoria, Local, Status'),
                  onTap: () => _import(context, ref),
                ),
              ],
            ),
          ),
          const SectionTitle('Cadastros',
              subtitle: 'Opções usadas nos lançamentos'),
          AppCard(
            child: Column(
              children: [
                _catalogSection(context, ref, CatalogKind.category),
                const Divider(),
                _catalogSection(context, ref, CatalogKind.place),
              ],
            ),
          ),
          const SectionTitle('Segurança'),
          AppCard(
            child: ListTile(
              leading: const IconBadge(
                  Icons.lock_rounded, AppTheme.expenseColor,
                  size: 40),
              title: const Text('Bloquear agora'),
              onTap: () => ref.read(authControllerProvider.notifier).lock(),
            ),
          ),
        ],
      ),
    );
  }
}
