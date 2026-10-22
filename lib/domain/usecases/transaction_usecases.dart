import '../entities/fin_transaction.dart';
import '../entities/finance_summary.dart';
import '../entities/transaction_filter.dart';
import '../repositories/transaction_repository.dart';

class QueryTransactions {
  const QueryTransactions(this._repo);
  final TransactionRepository _repo;
  Future<List<FinTransaction>> call(TransactionFilter filter) =>
      _repo.query(filter);
}

class SaveTransaction {
  const SaveTransaction(this._repo);
  final TransactionRepository _repo;

  Future<void> call(FinTransaction t) {
    if (t.amountCents <= 0)
      throw ArgumentError('O valor deve ser maior que zero.');
    return t.id == null ? _repo.add(t) : _repo.update(t);
  }
}

class DeleteTransaction {
  const DeleteTransaction(this._repo);
  final TransactionRepository _repo;
  Future<void> call(int id) => _repo.delete(id);
}

/// Transforma um lançamento previsto em realizado (passa a compor o saldo real).
class MarkAsRealized {
  const MarkAsRealized(this._repo);
  final TransactionRepository _repo;
  Future<void> call(FinTransaction t) =>
      _repo.update(t.copyWith(planned: false));
}

class GetTotals {
  const GetTotals(this._repo);
  final TransactionRepository _repo;
  Future<FinanceSummary> call() => _repo.totals();
}

class GetUsedCategories {
  const GetUsedCategories(this._repo);
  final TransactionRepository _repo;
  Future<List<String>> call() => _repo.distinctCategories();
}

class GetUsedPlaces {
  const GetUsedPlaces(this._repo);
  final TransactionRepository _repo;
  Future<List<String>> call() => _repo.distinctPlaces();
}
