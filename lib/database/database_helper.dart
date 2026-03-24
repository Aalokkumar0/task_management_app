// lib/database/database_helper.dart

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/task.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('tasks.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE tasks (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        due_date TEXT NOT NULL,
        status TEXT NOT NULL,
        blocked_by_id TEXT,
        sort_order INTEGER DEFAULT 0
      )
    ''');
  }

  Future<List<Task>> getTasks() async {
    final db = await database;
    final maps = await db.query('tasks', orderBy: 'sort_order ASC, due_date ASC');
    return maps.map((m) => Task.fromMap(m)).toList();
  }

  Future<void> insertTask(Task task) async {
    final db = await database;
    await db.insert(
      'tasks',
      task.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateTask(Task task) async {
    final db = await database;
    await db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  Future<void> deleteTask(String id) async {
    final db = await database;
    await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
    // Cascade: clear all references to deleted task
    await db.update(
      'tasks',
      {'blocked_by_id': null},
      where: 'blocked_by_id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateSortOrders(List<Task> tasks) async {
    final db = await database;
    final batch = db.batch();
    for (int i = 0; i < tasks.length; i++) {
      batch.update(
        'tasks',
        {'sort_order': i},
        where: 'id = ?',
        whereArgs: [tasks[i].id],
      );
    }
    await batch.commit(noResult: true);
  }
}