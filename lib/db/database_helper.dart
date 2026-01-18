import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('fanfoot.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2, // Incrementado para adicionar suporte a saves
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  /// Migração do banco de dados
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Adicionar tabela game_save
      await db.execute('''
        CREATE TABLE IF NOT EXISTS game_save (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          description TEXT,
          current_season INTEGER DEFAULT 2024,
          current_week INTEGER DEFAULT 1,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL,
          is_active INTEGER DEFAULT 0
        );
      ''');

      // Adicionar game_id nas tabelas relacionadas (tornando opcional para dados existentes)
      await db.execute('''
        ALTER TABLE competition ADD COLUMN game_id INTEGER;
      ''');

      await db.execute('''
        ALTER TABLE club ADD COLUMN game_id INTEGER;
      ''');

      await db.execute('''
        ALTER TABLE player ADD COLUMN game_id INTEGER;
      ''');

      await db.execute('''
        ALTER TABLE coach ADD COLUMN game_id INTEGER;
      ''');

      // Adicionar índices para melhor performance
      await db.execute('''
        CREATE INDEX IF NOT EXISTS idx_competition_game_id ON competition(game_id);
      ''');

      await db.execute('''
        CREATE INDEX IF NOT EXISTS idx_club_game_id ON club(game_id);
      ''');

      await db.execute('''
        CREATE INDEX IF NOT EXISTS idx_player_game_id ON player(game_id);
      ''');

      await db.execute('''
        CREATE INDEX IF NOT EXISTS idx_coach_game_id ON coach(game_id);
      ''');
    }
  }

  Future _createDB(Database db, int version) async {
    // Tabela de países (dados globais, não específicos de save)
    await db.execute('''
      CREATE TABLE country (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        code TEXT UNIQUE NOT NULL,
        name TEXT NOT NULL,
        flag TEXT NOT NULL
      );
    ''');

    // Tabela de saves/jogos
    await db.execute('''
      CREATE TABLE game_save (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT,
        current_season INTEGER DEFAULT 2024,
        current_week INTEGER DEFAULT 1,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        is_active INTEGER DEFAULT 0
      );
    ''');

    // Tabela de competições (relacionada a um save específico)
    await db.execute('''
      CREATE TABLE competition (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        level INTEGER DEFAULT 1,
        max_teams INTEGER DEFAULT 0,
        points_win INTEGER DEFAULT 3,
        points_draw INTEGER DEFAULT 1,
        points_lose INTEGER DEFAULT 0,
        gd_first INTEGER DEFAULT 1,
        logo_path TEXT,
        primary_color TEXT,
        secondary_color TEXT,
        country_id INTEGER,
        game_id INTEGER,
        FOREIGN KEY(country_id) REFERENCES country(id) ON DELETE SET NULL,
        FOREIGN KEY(game_id) REFERENCES game_save(id) ON DELETE CASCADE
      );
    ''');

    // Tabela de clubes (relacionada a um save específico)
    await db.execute('''
      CREATE TABLE club (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT UNIQUE NOT NULL,
        short_name TEXT,
        reputation INTEGER DEFAULT 0,
        budget REAL DEFAULT 0.0,
        wage_budget REAL DEFAULT 0.0,
        federation TEXT,
        stadium TEXT,
        crest_path TEXT,
        primary_color TEXT,
        secondary_color TEXT,
        country_id INTEGER,
        game_id INTEGER,
        FOREIGN KEY(country_id) REFERENCES country(id) ON DELETE SET NULL,
        FOREIGN KEY(game_id) REFERENCES game_save(id) ON DELETE CASCADE
      );
    ''');

    // Tabela de jogadores (relacionada a um save específico)
    await db.execute('''
      CREATE TABLE player (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        full_name TEXT NOT NULL,
        surname TEXT,
        age INTEGER DEFAULT 16,
        position TEXT NOT NULL,
        secondary_position TEXT,
        preferred_foot TEXT NOT NULL,
        height_cm INTEGER DEFAULT 170,
        weight_kg REAL DEFAULT 70.0,
        overall INTEGER DEFAULT 50,
        potential INTEGER DEFAULT 50,
        fitness INTEGER DEFAULT 100,
        status TEXT DEFAULT 'ACTIVE',
        shirt_number INTEGER DEFAULT 0,
        salary_weekly REAL DEFAULT 0.0,
        contract_until INTEGER DEFAULT 0,
        current_club_id INTEGER,
        country_id INTEGER,
        game_id INTEGER,
        FOREIGN KEY(current_club_id) REFERENCES club(id) ON DELETE SET NULL,
        FOREIGN KEY(country_id) REFERENCES country(id) ON DELETE SET NULL,
        FOREIGN KEY(game_id) REFERENCES game_save(id) ON DELETE CASCADE
      );
    ''');

    await db.execute('''
      CREATE TABLE player_stats_season (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        player_id INTEGER NOT NULL,
        club_id INTEGER,
        competition_id INTEGER,
        season_year INTEGER NOT NULL,
        matches_played INTEGER DEFAULT 0,
        goals INTEGER DEFAULT 0,
        assists INTEGER DEFAULT 0,
        yellow_cards INTEGER DEFAULT 0,
        red_cards INTEGER DEFAULT 0,
        avg_rating REAL DEFAULT 0.0,
        FOREIGN KEY(player_id) REFERENCES player(id) ON DELETE CASCADE,
        FOREIGN KEY(club_id) REFERENCES club(id) ON DELETE SET NULL,
        FOREIGN KEY(competition_id) REFERENCES competition(id) ON DELETE SET NULL
      );
    ''');

    await db.execute('''
      CREATE TABLE club_competition (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        club_id INTEGER NOT NULL,
        competition_id INTEGER NOT NULL,
        season_year INTEGER DEFAULT 2024,
        FOREIGN KEY(club_id) REFERENCES club(id) ON DELETE CASCADE,
        FOREIGN KEY(competition_id) REFERENCES competition(id) ON DELETE CASCADE
      );
    ''');

    // Tabela de treinadores (relacionada a um save específico)
    await db.execute('''
      CREATE TABLE coach (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        full_name TEXT NOT NULL,
        surname TEXT,
        age INTEGER DEFAULT 35,
        style TEXT DEFAULT 'BALANCED',
        reputation INTEGER DEFAULT 50,
        experience INTEGER DEFAULT 1,
        salary_weekly REAL DEFAULT 0.0,
        contract_until TEXT DEFAULT '2025-06-30',
        club_id INTEGER UNIQUE,
        country_id INTEGER,
        game_id INTEGER,
        FOREIGN KEY(club_id) REFERENCES club(id) ON DELETE SET NULL,
        FOREIGN KEY(country_id) REFERENCES country(id) ON DELETE SET NULL,
        FOREIGN KEY(game_id) REFERENCES game_save(id) ON DELETE CASCADE
      );
    ''');

    await db.execute('''
      CREATE TABLE coach_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        coach_id INTEGER NOT NULL,
        club_id INTEGER NOT NULL,
        season_start INTEGER DEFAULT 2024,
        season_end INTEGER,
        matches INTEGER DEFAULT 0,
        wins INTEGER DEFAULT 0,
        draws INTEGER DEFAULT 0,
        losses INTEGER DEFAULT 0,
        FOREIGN KEY(coach_id) REFERENCES coach(id) ON DELETE CASCADE,
        FOREIGN KEY(club_id) REFERENCES club(id) ON DELETE CASCADE
      );
    ''');

    // Índices para melhor performance
    await db.execute('''
      CREATE INDEX idx_competition_game_id ON competition(game_id);
    ''');

    await db.execute('''
      CREATE INDEX idx_club_game_id ON club(game_id);
    ''');

    await db.execute('''
      CREATE INDEX idx_player_game_id ON player(game_id);
    ''');

    await db.execute('''
      CREATE INDEX idx_coach_game_id ON coach(game_id);
    ''');
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
