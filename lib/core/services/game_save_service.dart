import 'package:fanfoot/core/models/game_save.dart';
import 'package:fanfoot/db/database_helper.dart';

/// Serviço para gerenciar saves/jogos do simulador
class GameSaveService {
  static final GameSaveService _instance = GameSaveService._internal();

  factory GameSaveService() {
    return _instance;
  }

  GameSaveService._internal();

  final dbHelper = DatabaseHelper.instance;

  /// Cria um novo save
  Future<int> createGameSave(GameSave gameSave) async {
    final db = await dbHelper.database;
    gameSave.createdAt = DateTime.now();
    gameSave.updatedAt = DateTime.now();
    return await db.insert('game_save', gameSave.toMap());
  }

  /// Busca todos os saves
  Future<List<GameSave>> getAllGameSaves() async {
    final db = await dbHelper.database;
    final result = await db.query('game_save', orderBy: 'updated_at DESC');
    return result.map((e) => GameSave.fromMap(e)).toList();
  }

  /// Busca um save específico por ID
  Future<GameSave?> getGameSave(int gameSaveId) async {
    final db = await dbHelper.database;
    final result = await db.query(
      'game_save',
      where: 'id=?',
      whereArgs: [gameSaveId],
    );

    if (result.isNotEmpty) {
      return GameSave.fromMap(result.first);
    }

    return null;
  }

  /// Busca o save ativo (em jogo)
  Future<GameSave?> getActiveGameSave() async {
    final db = await dbHelper.database;
    final result = await db.query(
      'game_save',
      where: 'is_active=?',
      whereArgs: [1],
      limit: 1,
    );

    if (result.isNotEmpty) {
      return GameSave.fromMap(result.first);
    }

    return null;
  }

  /// Define um save como ativo e desativa os demais
  Future<void> setActiveGameSave(int gameSaveId) async {
    final db = await dbHelper.database;

    // Desativa todos os saves
    await db.update('game_save', {'is_active': 0});

    // Ativa o save especificado
    await db.update(
      'game_save',
      {'is_active': 1, 'updated_at': DateTime.now().toIso8601String()},
      where: 'id=?',
      whereArgs: [gameSaveId],
    );
  }

  /// Atualiza um save
  Future<int> updateGameSave(GameSave gameSave) async {
    final db = await dbHelper.database;
    gameSave.updatedAt = DateTime.now();
    return await db.update(
      'game_save',
      gameSave.toMap(),
      where: 'id = ?',
      whereArgs: [gameSave.id],
    );
  }

  /// Deleta um save e todos os dados relacionados (CASCADE)
  Future<int> deleteGameSave(int gameSaveId) async {
    final db = await dbHelper.database;
    return db.delete('game_save', where: 'id = ?', whereArgs: [gameSaveId]);
  }

  /// Avança uma semana no save ativo
  Future<void> advanceWeek(int gameSaveId) async {
    final gameSave = await getGameSave(gameSaveId);

    if (gameSave != null) {
      int newWeek = gameSave.currentWeek + 1;
      // Assumindo 52 semanas por temporada
      if (newWeek > 52) {
        newWeek = 1;
        gameSave.currentSeason += 1;
      }

      gameSave.currentWeek = newWeek;
      await updateGameSave(gameSave);
    }
  }

  /// Busca saves por nome (pesquisa)
  Future<List<GameSave>> searchGameSaves(String query) async {
    final db = await dbHelper.database;
    final result = await db.query(
      'game_save',
      where: 'name LIKE ?',
      whereArgs: ['%$query%'],
      orderBy: 'updated_at DESC',
    );
    return result.map((e) => GameSave.fromMap(e)).toList();
  }
}
