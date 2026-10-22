import '../../domain/entities/catalog_item.dart';
import '../../domain/repositories/catalog_repository.dart';
import '../datasources/app_database.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';

class CatalogRepositoryImpl implements CatalogRepository {
  CatalogRepositoryImpl(this._database);

  final AppDatabase _database;

  @override
  Future<List<CatalogItem>> list(CatalogKind kind) async {
    final rows = await _database.db.query(
      'catalog',
      where: 'kind = ?',
      whereArgs: [kind.index],
      orderBy: 'name COLLATE NOCASE',
    );
    return rows
        .map((row) => CatalogItem(
              id: row['id'] as int,
              name: row['name'] as String,
              kind: CatalogKind.values[row['kind'] as int],
            ))
        .toList();
  }

  @override
  Future<void> add(CatalogItem item) async {
    try {
      await _database.db.insert('catalog', {
        'name': item.name.trim(),
        'kind': item.kind.index,
      });
    } on DatabaseException catch (error) {
      if (error.toString().contains('UNIQUE constraint failed')) {
        throw StateError('Já existe um item com esse nome.');
      }
      rethrow;
    }
  }

  @override
  Future<void> update(CatalogItem item) async {
    if (item.id == null) throw ArgumentError('Item do catálogo sem id.');
    try {
      await _database.db.update(
        'catalog',
        {'name': item.name.trim()},
        where: 'id = ?',
        whereArgs: [item.id],
      );
    } on DatabaseException catch (error) {
      if (error.toString().contains('UNIQUE constraint failed')) {
        throw StateError('Já existe um item com esse nome.');
      }
      rethrow;
    }
  }

  @override
  Future<void> delete(int id) async {
    await _database.db.delete('catalog', where: 'id = ?', whereArgs: [id]);
  }
}
