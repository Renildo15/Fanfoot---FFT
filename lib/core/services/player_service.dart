import 'package:fanfoot/core/enums/player.dart';
import 'package:fanfoot/core/models/player.dart';
import 'package:fanfoot/db/database_helper.dart';

class PlayerService {
  static final PlayerService _instance = PlayerService._internal();

  factory PlayerService() => _instance;

  PlayerService._internal();

  final dbHelper = DatabaseHelper.instance;

  Future<int> insertPlayer(Player player) async {
    final db = await dbHelper.database;
    return await db.insert('player', player.toMap());
  }

  Future<List<Player>> getAllPlayers() async {
    final db = await dbHelper.database;
    final result = await db.query('player', orderBy: 'full_name ASC');
    return result.map((e) => Player.fromMap(e)).toList();
  }

  Future<Player?> getPlayer(int playerId) async {
    final db = await dbHelper.database;
    final result = await db.query(
      'player',
      where: 'id = ?',
      whereArgs: [playerId],
    );

    if (result.isNotEmpty) {
      return Player.fromMap(result.first);
    }

    return null;
  }

  Future<List<Player>> getPlayersByClub(int clubId) async {
    final db = await dbHelper.database;
    final result = await db.query(
      'player',
      where: 'current_club_id = ?',
      whereArgs: [clubId],
      orderBy: 'full_name ASC',
    );
    return result.map((e) => Player.fromMap(e)).toList();
  }

  Future<int> updatePlayer(Player player) async {
    final db = await dbHelper.database;
    return await db.update(
      'player',
      player.toMap(),
      where: 'id = ?',
      whereArgs: [player.id],
    );
  }

  Future<int> deletePlayer(int playerId) async {
    final db = await dbHelper.database;
    return db.delete('player', where: 'id = ?', whereArgs: [playerId]);
  }

  Future<List<Player>> searchPlayer(String query) async {
    final db = await dbHelper.database;
    final result = await db.query(
      'player',
      where: 'full_name LIKE ? OR surname LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
    );
    return result.map((e) => Player.fromMap(e)).toList();
  }

  Future<List<Player>> filterPlayers({
    String? name,
    Position? position,
    PlayerStatus? status,
    int? clubId,
    int? countryId,
    int? minOverall,
    int? maxOverall,
  }) async {
    final db = await dbHelper.database;
    final conditions = <String>[];
    final args = <dynamic>[];

    if (name != null && name.isNotEmpty) {
      conditions.add('(full_name LIKE ? OR surname LIKE ?)');
      args.addAll(['%$name%', '%$name%']);
    }
    if (position != null) {
      conditions.add('position = ?');
      args.add(position.toString().split('.').last);
    }
    if (status != null) {
      conditions.add('status = ?');
      args.add(status.toString().split('.').last.toUpperCase());
    }
    if (clubId != null) {
      conditions.add('current_club_id = ?');
      args.add(clubId);
    }
    if (countryId != null) {
      conditions.add('country_id = ?');
      args.add(countryId);
    }
    if (minOverall != null) {
      conditions.add('overall >= ?');
      args.add(minOverall);
    }
    if (maxOverall != null) {
      conditions.add('overall <= ?');
      args.add(maxOverall);
    }

    final result = await db.query(
      'player',
      where: conditions.isEmpty ? null : conditions.join(' AND '),
      whereArgs: args.isEmpty ? null : args,
      orderBy: 'full_name ASC',
    );
    return result.map((e) => Player.fromMap(e)).toList();
  }
}
