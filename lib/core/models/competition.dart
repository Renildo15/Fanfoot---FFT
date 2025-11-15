import 'package:fanfoot/core/enums/competition.enum.dart';

class Competition {
  int? id;
  String name;
  CompetitionType type;
  int level;
  int maxTeams;
  int pointsWin;
  int pointsDraw;
  int pointsLose;
  int gdFirst;
  String? logoPath;
  String? primaryColor;
  String? secondaryColor;
  int? countryId;

  Competition({
    this.id,
    required this.name,
    required this.type,
    this.level = 1,
    this.maxTeams = 0,
    this.pointsWin = 3,
    this.pointsDraw = 1,
    this.pointsLose = 0,
    this.gdFirst = 1,
    this.logoPath,
    this.primaryColor,
    this.secondaryColor,
    this.countryId,
  });

  factory Competition.fromMap(Map<String, dynamic> map) => Competition(
    id: map['id'],
    name: map['name'],
    type: CompetitionTypeExtension.fromString(map['type']),
    level: map['level'] ?? 1,
    maxTeams: map['max_teams'] ?? 0,
    pointsWin: map['points_win'] ?? 3,
    pointsDraw: map['points_draw'] ?? 1,
    pointsLose: map['points_lose'] ?? 0,
    gdFirst: map['gd_first'] ?? 1,
    logoPath: map['logo_path'],
    primaryColor: map['primary_color'],
    secondaryColor: map['secondary_color'],
    countryId: map['country_id'],
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'type': type.value,
    'level': level,
    'max_teams': maxTeams,
    'points_win': pointsWin,
    'points_draw': pointsDraw,
    'points_lose': pointsLose,
    'gd_first': gdFirst,
    'logo_path': logoPath,
    'primary_color': primaryColor,
    'secondary_color': secondaryColor,
    'country_id': countryId,
  };
}
