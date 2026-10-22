import '../entities/savings_entry.dart';
import '../repositories/savings_repository.dart';

class GetSavings {
  const GetSavings(this._repo);
  final SavingsRepository _repo;
  Future<List<SavingsEntry>> call() => _repo.getAll();
}

class AddSavingsEntry {
  const AddSavingsEntry(this._repo);
  final SavingsRepository _repo;

  Future<void> call(SavingsEntry e) {
    if (e.amountCents == 0)
      throw ArgumentError('O valor deve ser diferente de zero.');
    return _repo.add(e);
  }
}

class DeleteSavingsEntry {
  const DeleteSavingsEntry(this._repo);
  final SavingsRepository _repo;
  Future<void> call(int id) => _repo.delete(id);
}
