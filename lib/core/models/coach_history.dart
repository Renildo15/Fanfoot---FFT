
class CoachHistory {
  int? id;
  int coachId;
  int clubId;
  int seasonStart;
  int? seasonEnd;
  int matches;
  int wins;
  int draws;
  int losses;

  CoachHistory({
    this.id,
    required this.coachId,
    required this.clubId,
    this.seasonStart = 2024,
    this.seasonEnd,
    this.matches = 0,
    this.wins = 0,
    this.draws = 0,
    this.losses = 0,
  });

  factory CoachHistory.fromMap(Map<String, dynamic> map) => CoachHistory(
    id: map['id'],
    coachId: map['coach_id'],
    clubId: map['club_id'],
    seasonStart: map['season_start'] ?? 2024,
    seasonEnd: map['season_end'],
    matches: map['matches'] ?? 0,
    wins: map['wins'] ?? 0,
    draws: map['draws'] ?? 0,
    losses: map['losses'] ?? 0,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'coach_id': coachId,
    'club_id': clubId,
    'season_start': seasonStart,
    'season_end': seasonEnd,
    'matches': matches,
    'wins': wins,
    'draws': draws,
    'losses': losses,
  };
}
