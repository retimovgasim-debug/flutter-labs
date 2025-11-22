import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class LocalStorageService {
  static const _databaseName = 'PasswordManager.db';
  static const _databaseVersion = 1;

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE passwords (
        id TEXT PRIMARY KEY,
        password TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        strength INTEGER NOT NULL
      )
    ''');
  }

  Future<void> insertPassword(Map<String, dynamic> password) async {
    final db = await database;
    await db.insert('passwords', password);
  }

  Future<List<Map<String, dynamic>>> getPasswords() async {
    final db = await database;
    return await db.query('passwords', orderBy: 'createdAt DESC');
  }

  Future<void> deletePassword(String id) async {
    final db = await database;
    await db.delete('passwords', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> clearPasswords() async {
    final db = await database;
    await db.delete('passwords');
  }
}