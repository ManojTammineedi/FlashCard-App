import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'flashcards.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE flashcards(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        question TEXT NOT NULL,
        answer TEXT NOT NULL
      )
    ''');
  }

  Future<int> insertFlashcard(Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert('flashcards', data);
  }

  Future<List<Map<String, dynamic>>> fetchFlashcards() async {
    final db = await database;
    return await db.query('flashcards');
  }

  Future<int> updateFlashcard(int id, Map<String, dynamic> data) async {
    final db = await database;
    return await db.update('flashcards', data, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteFlashcard(int id) async {
    final db = await database;
    return await db.delete('flashcards', where: 'id = ?', whereArgs: [id]);
  }

  Future<bool> doesQuestionExist(String question) async {
    final db = await database;
    final result = await db.query(
      'flashcards',
      where: 'question = ?',
      whereArgs: [question],
    );
    return result.isNotEmpty;
  }
}
