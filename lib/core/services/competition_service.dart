import 'package:fanfoot/core/models/competition.dart';
import 'package:fanfoot/db/database_helper.dart';

class CompetitionService {
  static final CompetitionService _instance = CompetitionService._internal();

  factory CompetitionService() {
    return _instance;
  }

  CompetitionService._internal();

  final dbHelper = DatabaseHelper.instance;

  Future<int> insertCompetition(Competition competition) async {
    final db = await dbHelper.database;
    return await db.insert('competition', competition.toMap());
  }

  Future<List<Competition>> getAllCompetitions() async {
    final db = await dbHelper.database;
    final result = await db.query('competition', orderBy: 'name ASC');
    return result.map((e) => Competition.fromMap(e)).toList();
  }

  Future<Competition?> getCompetition(int competitionId) async {
    final db = await dbHelper.database;
    final result = await db.query(
      'competition',
      where: 'id=?',
      whereArgs: [competitionId],
    );

    if (result.isNotEmpty) {
      return Competition.fromMap(result.first);
    }

    return null;
  }

  Future<int> updateCompetition(Competition competition) async {
    final db = await dbHelper.database;
    return await db.update(
      'competition',
      competition.toMap(),
      where: 'id = ?',
      whereArgs: [competition.id],
    );
  }

  Future<int> deleteCompetition(int competitionId) async {
    final db = await dbHelper.database;
    return db.delete(
      'competition',
      where: ' id = ?',
      whereArgs: [competitionId],
    );
  }

  Future<List<Competition>> searchCompetition(String query) async {
    final db = await dbHelper.database;
    final result = await db.query(
      'competition',
      where: 'name LIKE ?',
      whereArgs: ['%$query%'],
    );
    return result.map((e) => Competition.fromMap(e)).toList();
  }
}
