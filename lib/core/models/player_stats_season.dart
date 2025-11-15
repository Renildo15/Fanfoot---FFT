
class PlayerStatsSeason {
  int? id;
  int playerId;
  int? clubId;
  int? competitionId;
  int seasonYear;
  int matchesPlayed;
  int goals;
  int assists;
  int yellowCards;
  int redCards;
  double avgRating;

  PlayerStatsSeason({
    this.id,
    required this.playerId,
    this.clubId,
    this.competitionId,
    required this.seasonYear,
    this.matchesPlayed = 0,
    this.goals = 0,
    this.assists = 0,
    this.yellowCards = 0,
    this.redCards = 0,
    this.avgRating = 0.0,
  });

  factory PlayerStatsSeason.fromMap(Map<String, dynamic> map) =>
    PlayerStatsSeason(
      id: map['id'],
      playerId: map['player_id'],
      clubId: map['club_id'],
      competitionId: map['competition_id'],
      seasonYear: map['season_year'],
      matchesPlayed: map['matches_played'] ?? 0,
      goals: map['goals'] ?? 0,
      assists: map['assists'] ?? 0,
      yellowCards: map['yellow_cards'] ?? 0,
      redCards: map['red_cards'] ?? 0,
      avgRating: map['avg_rating']?.toDouble() ?? 0.0,
    );

  Map<String, dynamic> toMap() => {
    'id': id,
    'player_id': playerId,
    'club_id': clubId,
    'competition_id': competitionId,
    'season_year': seasonYear,
    'matches_played': matchesPlayed,
    'goals': goals,
    'assists': assists,
    'yellow_cards': yellowCards,
    'red_cards': redCards,
    'avg_rating': avgRating,
  };
}
