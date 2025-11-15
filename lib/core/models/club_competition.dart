
class ClubCompetition {
  int? id;
  int clubId;
  int competitionId;
  int seasonYear;

  ClubCompetition({
    this.id,
    required this.clubId,
    required this.competitionId,
    this.seasonYear = 2024,
  });

  factory ClubCompetition.fromMap(Map<String, dynamic> map) => ClubCompetition(
    id: map['id'],
    clubId: map['club_id'],
    competitionId: map['competition_id'],
    seasonYear: map['season_year'] ?? 2024,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'club_id': clubId,
    'competition_id': competitionId,
    'season_year': seasonYear,
  };
}
