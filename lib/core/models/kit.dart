import 'package:fanfoot/core/enums/kit.dart';

class Kit {
  int? id;
  int clubId;
  int seasonYear;
  KitType type;
  String primaryColor;
  String secondaryColor;
  String? patternColor;
  KitPattern pattern;
  String? playerName;
  int? playerNumber;
  String? fontFamily;
  bool isDefault;

  Kit({
    this.id,
    required this.clubId,
    required this.seasonYear,
    required this.type,
    required this.primaryColor,
    required this.secondaryColor,
    this.patternColor,
    this.pattern = KitPattern.solid,
    this.playerName,
    this.playerNumber,
    this.fontFamily,
    this.isDefault = false,
  });

  factory Kit.fromMap(Map<String, dynamic> map) => Kit(
    id: map['id'],
    clubId: map['club_id'],
    seasonYear: map['season_year'],
    type: KitType.values.firstWhere(
      (e) => e.toString().split('.').last == map['type'],
    ),
    primaryColor: map['primary_color'],
    secondaryColor: map['secondary_color'],
    patternColor: map['pattern_color'],
    pattern: KitPattern.values.firstWhere(
      (e) => e.toString().split('.').last == map['pattern'],
      orElse: () => KitPattern.solid,
    ),
    playerName: map['player_name'],
    playerNumber: map['player_number'],
    fontFamily: map['font_family'],
    isDefault: (map['is_default'] ?? 0) == 1,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'club_id': clubId,
    'season_year': seasonYear,
    'type': type.toString().split('.').last,
    'primary_color': primaryColor,
    'secondary_color': secondaryColor,
    'pattern_color': patternColor,
    'pattern': pattern.toString().split('.').last,
    'player_name': playerName,
    'player_number': playerNumber,
    'font_family': fontFamily,
    'is_default': isDefault ? 1 : 0,
  };

  Kit copyWith({
    int? id,
    int? clubId,
    int? seasonYear,
    KitType? type,
    String? primaryColor,
    String? secondaryColor,
    String? patternColor,
    KitPattern? pattern,
    String? playerName,
    int? playerNumber,
    String? fontFamily,
    bool? isDefault,
  }) {
    return Kit(
      id: id ?? this.id,
      clubId: clubId ?? this.clubId,
      seasonYear: seasonYear ?? this.seasonYear,
      type: type ?? this.type,
      primaryColor: primaryColor ?? this.primaryColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      patternColor: patternColor ?? this.patternColor,
      pattern: pattern ?? this.pattern,
      playerName: playerName ?? this.playerName,
      playerNumber: playerNumber ?? this.playerNumber,
      fontFamily: fontFamily ?? this.fontFamily,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}
