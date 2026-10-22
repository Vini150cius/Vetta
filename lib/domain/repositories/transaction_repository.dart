import '../entities/fin_transaction.dart';
import '../entities/finance_summary.dart';
import '../entities/transaction_filter.dart';

abstract class TransactionRepository {
  Future<List<FinTransaction>> query(TransactionFilter filter);
  Future<FinanceSummary> totals();
  Future<void> add(FinTransaction t);
  Future<void> addAll(List<FinTransaction> items);
  Future<void> update(FinTransaction t);
  Future<void> delete(int id);
  Future<List<String>> distinctCategories();
  Future<List<String>> distinctPlaces();
}
