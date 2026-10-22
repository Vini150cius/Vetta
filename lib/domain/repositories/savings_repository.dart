import '../entities/savings_entry.dart';

abstract class SavingsRepository {
  Future<List<SavingsEntry>> getAll();
  Future<void> add(SavingsEntry entry);
  Future<void> delete(int id);
}
