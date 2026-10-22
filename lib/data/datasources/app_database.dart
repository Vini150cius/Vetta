import 'package:path/path.dart' as p;
import 'package:sqflite_sqlcipher/sqflite.dart';

import '../../core/constants/app_constants.dart';

/// SQLite criptografado (SQLCipher, AES-256). O arquivo em disco é ilegível sem a chave.
/// Ciclo de vida atrelado à biometria: [open] só é chamado após autenticar e [close]
/// ao travar o app — fora disso não existe handle aberto nem chave em memória.
class AppDatabase {
  Database? _db;

  bool get isOpen => _db != null;

  Database get db {
    final d = _db;
    if (d == null) throw StateError('Banco bloqueado: autentique-se primeiro.');
    return d;
  }

  Future<void> open(String passphrase) async {
    if (_db != null) return;
    final dir = await getDatabasesPath();
    // Chave errada/arquivo corrompido => DatabaseException (tratada no AuthController).
    _db = await openDatabase(
      p.join(dir, 'financas.db'),
      password: passphrase,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> close() async {
    final d = _db;
    _db =
        null; // zera antes de fechar: novas leituras já falham como "bloqueado"
    await d?.close();
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE transactions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type INTEGER NOT NULL,            -- 0 = receita, 1 = despesa
        amount_cents INTEGER NOT NULL,
        description TEXT NOT NULL DEFAULT '',
        category TEXT NOT NULL,
        place TEXT NOT NULL DEFAULT '',
        date INTEGER NOT NULL,            -- epoch ms (meia-noite local)
        planned INTEGER NOT NULL DEFAULT 0 -- 1 = previsto/futuro
      )''');
    await db.execute('CREATE INDEX idx_tx_date ON transactions(date)');
    await db.execute('CREATE INDEX idx_tx_category ON transactions(category)');
    await db.execute('CREATE INDEX idx_tx_place ON transactions(place)');
    await db.execute('''
      CREATE TABLE savings(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        amount_cents INTEGER NOT NULL,    -- positivo = guardou, negativo = retirou
        note TEXT NOT NULL DEFAULT '',
        date INTEGER NOT NULL
      )''');
    await _createCatalog(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) await _createCatalog(db);
  }

  Future<void> _createCatalog(Database db) async {
    await db.execute('''
      CREATE TABLE catalog(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL COLLATE NOCASE,
        kind INTEGER NOT NULL,
        UNIQUE(name, kind)
      )''');
    final batch = db.batch();
    for (final name in kDefaultCategories) {
      batch.insert('catalog', {'name': name, 'kind': 0});
    }
    for (final name in kDefaultPlaces) {
      batch.insert('catalog', {'name': name, 'kind': 1});
    }
    await batch.commit(noResult: true);
  }
}
