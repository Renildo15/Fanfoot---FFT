import 'package:fanfoot/core/models/club.dart';
import 'package:fanfoot/db/database_helper.dart';

class ClubService {
  static final ClubService _instance = ClubService._internal();

  factory ClubService() {
    return _instance;
  }

  ClubService._internal();

  final dbHelper = DatabaseHelper.instance;

  Future<int> insertClub(Club club) async {
    final db = await dbHelper.database;
    return await db.insert('club', club.toMap());
  }

  Future<List<Club>> getAllClubs() async {
    final db = await dbHelper.database;
    final result = await db.query('club', orderBy: 'name ASC');
    return result.map((e) => Club.fromMap(e)).toList();
  }

  Future<Club?> getClub(int clubId) async {
    final db = await dbHelper.database;
    final result = await db.query('club', where: 'id=?', whereArgs: [clubId]);

    if (result.isNotEmpty) {
      return Club.fromMap(result.first);
    }

    return null;
  }

  Future<int> updateClub(Club club) async {
    final db = await dbHelper.database;
    return await db.update(
      'club',
      club.toMap(),
      where: 'id = ?',
      whereArgs: [club.id],
    );
  }

  Future<int> deleteClub(int clubId) async {
    final db = await dbHelper.database;
    return db.delete('club', where: ' id = ?', whereArgs: [clubId]);
  }

  Future<List<Club>> searchClub(String query) async {
    final db = await dbHelper.database;
    final result = await db.query(
      'club',
      where: 'name LIKE ?',
      whereArgs: ['%$query%'],
    );
    return result.map((e) => Club.fromMap(e)).toList();
  }
}
