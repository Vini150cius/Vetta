import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/fin_transaction.dart';
import '../../domain/entities/catalog_item.dart';
import '../../domain/entities/savings_entry.dart';
import '../../domain/services/spreadsheet_codec.dart';
import '../../domain/usecases/backup_usecases.dart';
import '../../domain/usecases/savings_usecases.dart';
import '../../domain/usecases/transaction_usecases.dart';
import 'data_providers.dart';
import 'di_providers.dart';

final financeActionsProvider =
    Provider<FinanceActions>((ref) => FinanceActions(ref));

/// Escritas (comandos). Cada uma invalida as consultas via [dataVersionProvider].
class FinanceActions {
  FinanceActions(this._ref) {
    final tx = _ref.read(transactionRepositoryProvider);
    final savings = _ref.read(savingsRepositoryProvider);
    final codec = _ref.read(spreadsheetCodecProvider);
    _save = SaveTransaction(tx);
    _delete = DeleteTransaction(tx);
    _markRealized = MarkAsRealized(tx);
    _addSavings = AddSavingsEntry(savings);
    _deleteSavings = DeleteSavingsEntry(savings);
    _export = ExportTransactions(tx, codec);
    _import = ImportTransactions(tx, codec);
  }

  final Ref _ref;
  late final SaveTransaction _save;
  late final DeleteTransaction _delete;
  late final MarkAsRealized _markRealized;
  late final AddSavingsEntry _addSavings;
  late final DeleteSavingsEntry _deleteSavings;
  late final ExportTransactions _export;
  late final ImportTransactions _import;

  void _bump() => _ref.read(dataVersionProvider.notifier).state++;

  Future<void> saveTransaction(FinTransaction t) async {
    await _save(t);
    _bump();
  }

  Future<void> deleteTransaction(int id) async {
    await _delete(id);
    _bump();
  }

  Future<void> markRealized(FinTransaction t) async {
    await _markRealized(t);
    _bump();
  }

  Future<void> addSavings(SavingsEntry e) async {
    await _addSavings(e);
    _bump();
  }

  Future<void> deleteSavings(int id) async {
    await _deleteSavings(id);
    _bump();
  }

  Future<Uint8List> exportData(SpreadsheetFormat f) => _export(f);

  Future<int> importData(Uint8List bytes, SpreadsheetFormat f) async {
    final n = await _import(bytes, f);
    _bump();
    return n;
  }

  Future<void> addCatalogItem(CatalogItem item) async {
    await _ref.read(catalogRepositoryProvider).add(item);
    _bump();
  }

  Future<void> updateCatalogItem(CatalogItem item) async {
    await _ref.read(catalogRepositoryProvider).update(item);
    _bump();
  }

  Future<void> deleteCatalogItem(int id) async {
    await _ref.read(catalogRepositoryProvider).delete(id);
    _bump();
  }
}
