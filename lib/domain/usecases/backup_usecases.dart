import 'dart:typed_data';

import '../entities/transaction_filter.dart';
import '../repositories/transaction_repository.dart';
import '../services/spreadsheet_codec.dart';

class ExportTransactions {
  const ExportTransactions(this._repo, this._codec);
  final TransactionRepository _repo;
  final SpreadsheetCodec _codec;

  Future<Uint8List> call(SpreadsheetFormat format) async =>
      _codec.encode(await _repo.query(const TransactionFilter()), format);
}

class ImportTransactions {
  const ImportTransactions(this._repo, this._codec);
  final TransactionRepository _repo;
  final SpreadsheetCodec _codec;

  /// Tudo-ou-nada: se qualquer linha for inválida, `decode` lança e nada é gravado.
  Future<int> call(Uint8List bytes, SpreadsheetFormat format) async {
    final items = _codec.decode(bytes, format);
    await _repo.addAll(items);
    return items.length;
  }
}
