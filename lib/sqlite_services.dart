import 'package:flutter/cupertino.dart';
import 'package:snake/profile_data.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class SqliteService {
  Future<Database> initializeDB() async {
    String path = await getDatabasesPath();
    return openDatabase(
      join(path, 'profiles.db'),
      onCreate: (database, version) async {
        await database.execute(
          "CREATE TABLE profiles(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, highScore INTEGER NOT NULL)",
        );
      },
      version: 1,
    );
  }

  Future<int> insertItem(ProfileInfo profileInfo) async {
    final db = await initializeDB();
    int id = await db.insert('profiles', profileInfo.toMap(profileInfo),
        conflictAlgorithm: ConflictAlgorithm.replace);
    return id;
  }

  Future<List<ProfileInfo>> getItems() async {
    final db = await initializeDB();
    final List<Map<String, Object?>> profiles = await db.query(
      'profiles',
    );
    return profiles.map((e) => ProfileInfo.fromMap(e)).toList();
  }

  Future<void> deleteItem(int id) async {
    final db = await initializeDB();
    try {
      db.delete('profiles', where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      debugPrint('Somthing went wrong while deleting element');
    }
  }

  Future<void> changeScore(int id, int score) async {
    final db = await initializeDB();
    db.update('profiles', {'highScore': score},
        where: 'id = ?', whereArgs: [id]);
  }
}
