/// Modelo que representa um save/jogo do simulador
/// Cada instância representa um mundo/save completo com suas competições, clubes, jogadores, etc.
class GameSave {
  int? id;
  String name;
  String? description;
  int currentSeason;
  int currentWeek; // Semana atual da temporada
  DateTime createdAt;
  DateTime updatedAt;
  bool isActive; // Save ativo (em jogo)

  GameSave({
    this.id,
    required this.name,
    this.description,
    this.currentSeason = 2024,
    this.currentWeek = 1,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.isActive = false,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  factory GameSave.fromMap(Map<String, dynamic> map) => GameSave(
    id: map['id'],
    name: map['name'],
    description: map['description'],
    currentSeason: map['current_season'] ?? 2024,
    currentWeek: map['current_week'] ?? 1,
    createdAt: map['created_at'] != null
        ? DateTime.parse(map['created_at'])
        : DateTime.now(),
    updatedAt: map['updated_at'] != null
        ? DateTime.parse(map['updated_at'])
        : DateTime.now(),
    isActive: map['is_active'] == 1 || map['is_active'] == true,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'description': description,
    'current_season': currentSeason,
    'current_week': currentWeek,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
    'is_active': isActive ? 1 : 0,
  };
}
