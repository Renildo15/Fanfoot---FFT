import 'package:fanfoot/core/enums/kit.dart';
import 'package:fanfoot/core/models/kit.dart';
import 'package:fanfoot/db/database_helper.dart';

class KitService {
  static final KitService _instance = KitService._internal();
  factory KitService() => _instance;
  KitService._internal();

  final dbHelper = DatabaseHelper.instance;

  Future<int> insertKit(Kit kit) async {
    final db = await dbHelper.database;
    return await db.insert('kit', kit.toMap());
  }

  Future<List<Kit>> getKitsByClub(int clubId) async {
    final db = await dbHelper.database;
    final result = await db.query(
      'kit',
      where: 'club_id = ?',
      whereArgs: [clubId],
      orderBy: 'season_year DESC, type ASC',
    );
    return result.map((e) => Kit.fromMap(e)).toList();
  }

  Future<List<Kit>> getKitsByClubAndSeason(int clubId, int seasonYear) async {
    final db = await dbHelper.database;
    final result = await db.query(
      'kit',
      where: 'club_id = ? AND season_year = ?',
      whereArgs: [clubId, seasonYear],
      orderBy: 'type ASC',
    );
    return result.map((e) => Kit.fromMap(e)).toList();
  }

  Future<Kit?> getDefaultKit(int clubId, int seasonYear, KitType type) async {
    final db = await dbHelper.database;
    final result = await db.query(
      'kit',
      where: 'club_id = ? AND season_year = ? AND type = ? AND is_default = 1',
      whereArgs: [clubId, seasonYear, type.toString().split('.').last],
    );
    if (result.isNotEmpty) {
      return Kit.fromMap(result.first);
    }
    return null;
  }

  Future<Kit?> getKit(int kitId) async {
    final db = await dbHelper.database;
    final result = await db.query('kit', where: 'id = ?', whereArgs: [kitId]);
    if (result.isNotEmpty) {
      return Kit.fromMap(result.first);
    }
    return null;
  }

  Future<int> updateKit(Kit kit) async {
    final db = await dbHelper.database;
    return await db.update(
      'kit',
      kit.toMap(),
      where: 'id = ?',
      whereArgs: [kit.id],
    );
  }

  Future<int> deleteKit(int kitId) async {
    final db = await dbHelper.database;
    return await db.delete('kit', where: 'id = ?', whereArgs: [kitId]);
  }

  Future<void> setDefaultKit(
    int kitId,
    int clubId,
    int seasonYear,
    KitType type,
  ) async {
    final db = await dbHelper.database;
    await db.update(
      'kit',
      {'is_default': 0},
      where: 'club_id = ? AND season_year = ? AND type = ?',
      whereArgs: [clubId, seasonYear, type.toString().split('.').last],
    );
    await db.update(
      'kit',
      {'is_default': 1},
      where: 'id = ?',
      whereArgs: [kitId],
    );
  }

  Future<List<int>> getAvailableSeasons(int clubId) async {
    final db = await dbHelper.database;
    final result = await db.rawQuery(
      'SELECT DISTINCT season_year FROM kit WHERE club_id = ? ORDER BY season_year DESC',
      [clubId],
    );
    return result.map((e) => e['season_year'] as int).toList();
  }

  Future<Kit?> getHomeKit(int clubId, int seasonYear) async {
    return getDefaultKit(clubId, seasonYear, KitType.home);
  }

  Future<Kit?> getAwayKit(int clubId, int seasonYear) async {
    return getDefaultKit(clubId, seasonYear, KitType.away);
  }
}
