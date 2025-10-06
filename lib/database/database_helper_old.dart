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

    // Datenbank öffnen oder erstellen
    final db = await openDatabase(
      path,
      version: 1,
      onOpen: (db) async {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS klettereintraege(
            id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
            datum TEXT NOT NULL,
            gebiet TEXT NOT NULL,
            gipfel TEXT NOT NULL,
            weg TEXT NOT NULL,
            schwierigkeit TEXT NOT NULL
          )
        ''');
      },
    );

    return db;
  }

  // ------------------------------
  // CRUD-Methoden für Klettereintrag
  // ------------------------------

  // Insert
  Future<int> insertKletterEintrag(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('klettereintraege', row);
  }

  // Query All
  Future<List<Map<String, dynamic>>> queryAllKletterEintraege() async {
    final db = await instance.database;
    return await db.query('klettereintraege');
  }

  // Update
  Future<int> updateKletterEintrag(Map<String, dynamic> row) async {
    final db = await instance.database;
    int id = row['id'];
    return await db.update(
      'klettereintraege',
      row,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Delete
  Future<int> deleteKletterEintrag(int id) async {
    final db = await instance.database;
    return await db.delete(
      'klettereintraege',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
