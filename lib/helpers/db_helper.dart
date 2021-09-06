import 'package:sqflite/sqflite.dart' as sql;
import 'package:path/path.dart' as path;
import 'package:sqflite/sqlite_api.dart';

class DBHelper {  
  static Future<Database> database() async {
    final dbPath = await sql.getDatabasesPath();
    return await sql.openDatabase(path.join(dbPath, 'notes.db'), onCreate: (db, version) => _createDb(db), version: 1);
  }

  static void _createDb(Database db) {
    db.execute("CREATE TABLE notes (id TEXT PRIMARY KEY, title TEXT)");
    db.execute("CREATE TABLE descs (id TEXT PRIMARY KEY, title TEXT)");
    db.execute("CREATE TABLE note_descs (id TEXT PRIMARY KEY, note_id TEXT, desc_id TEXT)");
  }

  static Future<void> insert(String table, Map<String, Object> data) async {
    final db = await DBHelper.database();
    db.insert(table, data, conflictAlgorithm: sql.ConflictAlgorithm.replace);
  }

  static Future<void> delete(String table, String id) async {
    final db = await DBHelper.database();
    return db.delete(table, where: 'id = ?', whereArgs: [id]);
  }

  static Future<List<Map<String, dynamic>>> getData() async {
    final db = await DBHelper.database();
    return db.rawQuery("SELECT a.id note_id, b.id note_desc_id, c.id desc_id, GROUP_CONCAT(DISTINCT a.title) parentTitle, GROUP_CONCAT(DISTINCT c.id) childId, GROUP_CONCAT(DISTINCT c.title) childTitle FROM notes a LEFT JOIN note_descs b ON a.id = b.note_id LEFT JOIN descs c ON c.id = b.desc_id GROUP BY a.id");
  }
}