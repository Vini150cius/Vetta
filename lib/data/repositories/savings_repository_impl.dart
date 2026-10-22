import '../../domain/entities/savings_entry.dart';
import '../../domain/repositories/savings_repository.dart';
import '../datasources/app_database.dart';
import '../models/savings_model.dart';

class SavingsRepositoryImpl implements SavingsRepository {
  SavingsRepositoryImpl(this._database);
  final AppDatabase _database;

  @override
  Future<List<SavingsEntry>> getAll() async {
    final rows =
        await _database.db.query('savings', orderBy: 'date DESC, id DESC');
    return rows.map(SavingsModel.fromMap).toList();
  }

  @override
  Future<void> add(SavingsEntry entry) async {
    await _database.db.insert('savings', SavingsModel.toMap(entry));
  }

  @override
  Future<void> delete(int id) async {
    await _database.db.delete('savings', where: 'id = ?', whereArgs: [id]);
  }
}
