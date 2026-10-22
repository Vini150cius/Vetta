import '../../domain/entities/fin_transaction.dart';
import '../../domain/entities/finance_summary.dart';
import '../../domain/entities/transaction_filter.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../datasources/app_database.dart';
import '../models/transaction_model.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  TransactionRepositoryImpl(this._database);
  final AppDatabase _database;

  static const _table = 'transactions';

  String _placeholders(int n) => List.filled(n, '?').join(',');

  @override
  Future<List<FinTransaction>> query(TransactionFilter f) async {
    // Filtros montados com placeholders (?) — nunca concatenamos texto do usuário no SQL.
    final where = <String>[];
    final args = <Object?>[];
    if (f.from != null) {
      where.add('date >= ?');
      args.add(f.from!.millisecondsSinceEpoch);
    }
    if (f.to != null) {
      where.add('date < ?');
      args.add(f.to!.millisecondsSinceEpoch);
    }
    if (f.categories.isNotEmpty) {
      where.add(
          'category COLLATE NOCASE IN (${_placeholders(f.categories.length)})');
      args.addAll(f.categories);
    }
    if (f.places.isNotEmpty) {
      where.add('place COLLATE NOCASE IN (${_placeholders(f.places.length)})');
      args.addAll(f.places);
    }
    if (f.type != null) {
      where.add('type = ?');
      args.add(f.type!.index);
    }
    if (f.planned != null) {
      where.add('planned = ?');
      args.add(f.planned! ? 1 : 0);
    }
    final rows = await _database.db.query(
      _table,
      where: where.isEmpty ? null : where.join(' AND '),
      whereArgs: args,
      orderBy: 'date DESC, id DESC',
    );
    return rows.map(TransactionModel.fromMap).toList();
  }

  @override
  Future<FinanceSummary> totals() async {
    final rows = await _database.db.rawQuery(
      'SELECT type, planned, COALESCE(SUM(amount_cents), 0) AS total FROM $_table GROUP BY type, planned',
    );
    var income = 0, expense = 0, plannedIncome = 0, plannedExpense = 0;
    for (final r in rows) {
      final isIncome = r['type'] == TxType.income.index;
      final planned = r['planned'] == 1;
      final total = (r['total'] as num).toInt();
      if (planned && isIncome) {
        plannedIncome += total;
      } else if (planned) {
        plannedExpense += total;
      } else if (isIncome) {
        income += total;
      } else {
        expense += total;
      }
    }
    return FinanceSummary(
      income: income,
      expense: expense,
      plannedIncome: plannedIncome,
      plannedExpense: plannedExpense,
    );
  }

  @override
  Future<void> add(FinTransaction t) async {
    await _database.db.insert(_table, TransactionModel.toMap(t));
  }

  @override
  Future<void> addAll(List<FinTransaction> items) async {
    // Uma única transação SQL: ou importa tudo ou nada.
    await _database.db.transaction((txn) async {
      final batch = txn.batch();
      for (final t in items) {
        batch.insert(_table, TransactionModel.toMap(t));
      }
      await batch.commit(noResult: true);
    });
  }

  @override
  Future<void> update(FinTransaction t) async {
    await _database.db.update(_table, TransactionModel.toMap(t),
        where: 'id = ?', whereArgs: [t.id]);
  }

  @override
  Future<void> delete(int id) async {
    await _database.db.delete(_table, where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<List<String>> distinctCategories() => _distinct('category');

  @override
  Future<List<String>> distinctPlaces() => _distinct('place');

  // [column] vem apenas de constantes internas acima (nunca de entrada do usuário).
  Future<List<String>> _distinct(String column) async {
    final rows = await _database.db.rawQuery(
      "SELECT MIN($column) AS v FROM $_table WHERE $column <> '' "
      'GROUP BY LOWER($column) ORDER BY v COLLATE NOCASE',
    );
    return rows.map((r) => r['v'] as String).toList();
  }
}
