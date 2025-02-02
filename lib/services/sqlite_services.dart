import 'package:snake/model/profile_data.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class SqliteService {
  Future<Database?> initializeDB() async {
    try {
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
    } catch (e) {
      print(e);
      return null;

    }
  }

  Future<int?> insertItem(ProfileData profileInfo) async {
    try {
      final db = await initializeDB();
      int id = await db!.insert('profiles', profileInfo.toMap(profileInfo),
          conflictAlgorithm: ConflictAlgorithm.replace);
      return id;
    } catch (e) {
      print(e);
      return null;

    }
  }

  Future<List<ProfileData>?> getItems() async {
    try {
      final db = await initializeDB();
      final List<Map<String, Object?>> profiles = await db!.query(
        'profiles',
      );
      return profiles.map((e) => ProfileData.fromMap(e)).toList();
    } catch (e) {
      print(e);
      return null;

    }
  }

  Future<int?> deleteItem(int id) async {
    try {
      final db = await initializeDB();
      int count =
          await db!.delete('profiles', where: 'id = ?', whereArgs: [id]);
      return count;
    } catch (e) {
      print(e);
      return null;

    }
  }

  Future<int?> changeScore(int id, int score) async {
    try {
      final db = await initializeDB();
      int count = await db!.update('profiles', {'highScore': score},
          where: 'id = ?', whereArgs: [id]);
      return count;
    } catch (e) {
      print(e);
      return null;
    }
  }
}
