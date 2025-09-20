import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  // Singleton-Pattern
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  // Getter für Datenbank
  Future<Database> get database async =>
      _database ??= await _initDB('my_database.db');

  // Datenbank initialisieren
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    print("📂 Datenbank gespeichert unter: $path");

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  //Tabelle erstellen
  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE kletterwege(
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        datum TEXT NOT NULL,
        gebiet TEXT NOT NULL,
        gipfel TEXT NOT NULL,
        weg TEXT NOT NULL,
        schwierigkeit TEXT NOT NULL
      )
    ''');
  }

  // ------------------------------
  // CRUD-Methoden für kletterwege
  // ------------------------------

// Insert
  Future<int> insertKletterweg(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('kletterwege', row);
  }

  // Query All
  Future<List<Map<String, dynamic>>> queryAllKletterwege() async {
    final db = await instance.database;
    return await db.query('kletterwege');
  }

  // Update
  Future<int> updateKletterweg(Map<String, dynamic> row) async {
    final db = await instance.database;
    int id = row['id'];
    return await db.update(
      'kletterwege',
      row,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Delete
  Future<int> deleteKletterweg(int id) async {
    final db = await instance.database;
    return await db.delete(
      'kletterwege',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}