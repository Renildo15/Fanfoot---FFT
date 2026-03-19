/// Modelo que representa uma entrada na tabela de classificação
/// Cada entrada corresponde a um clube em uma competição em uma temporada
class LeagueTableEntry {
  int clubId;
  int competitionId;
  int seasonYear;

  // Estatísticas
  int played; // Partidas jogadas
  int wins; // Vitórias
  int draws; // Empates
  int losses; // Derrotas
  int goalsFor; // Gols marcados
  int goalsAgainst; // Gols sofridos
  int goalDifference; // Saldo de gols
  int points; // Pontos

  LeagueTableEntry({
    required this.clubId,
    required this.competitionId,
    required this.seasonYear,
    this.played = 0,
    this.wins = 0,
    this.draws = 0,
    this.losses = 0,
    this.goalsFor = 0,
    this.goalsAgainst = 0,
    this.goalDifference = 0,
    this.points = 0,
  });

  /// Atualiza as estatísticas com base em um resultado de partida
  /// [isHome]: true se o clube jogou em casa
  /// [goalsForClub]: gols marcados pelo clube
  /// [goalsAgainstClub]: gols sofridos pelo clube
  /// [pointsWin], [pointsDraw], [pointsLose]: pontos por vitória/empate/derrota
  void updateFromMatchResult({
    required int goalsForClub,
    required int goalsAgainstClub,
    required int pointsWin,
    required int pointsDraw,
    required int pointsLose,
  }) {
    played++;
    goalsFor += goalsForClub;
    goalsAgainst += goalsAgainstClub;
    goalDifference = goalsFor - goalsAgainst;

    if (goalsForClub > goalsAgainstClub) {
      wins++;
      points += pointsWin;
    } else if (goalsForClub < goalsAgainstClub) {
      losses++;
      points += pointsLose;
    } else {
      draws++;
      points += pointsDraw;
    }
  }

  factory LeagueTableEntry.fromMap(Map<String, dynamic> map) =>
      LeagueTableEntry(
        clubId: map['club_id'],
        competitionId: map['competition_id'],
        seasonYear: map['season_year'],
        played: map['played'] ?? 0,
        wins: map['wins'] ?? 0,
        draws: map['draws'] ?? 0,
        losses: map['losses'] ?? 0,
        goalsFor: map['goals_for'] ?? 0,
        goalsAgainst: map['goals_against'] ?? 0,
        goalDifference: map['goal_difference'] ?? 0,
        points: map['points'] ?? 0,
      );

  Map<String, dynamic> toMap() => {
    'club_id': clubId,
    'competition_id': competitionId,
    'season_year': seasonYear,
    'played': played,
    'wins': wins,
    'draws': draws,
    'losses': losses,
    'goals_for': goalsFor,
    'goals_against': goalsAgainst,
    'goal_difference': goalDifference,
    'points': points,
  };

  /// Cria uma cópia do objeto
  LeagueTableEntry copyWith({
    int? clubId,
    int? competitionId,
    int? seasonYear,
    int? played,
    int? wins,
    int? draws,
    int? losses,
    int? goalsFor,
    int? goalsAgainst,
    int? goalDifference,
    int? points,
  }) {
    return LeagueTableEntry(
      clubId: clubId ?? this.clubId,
      competitionId: competitionId ?? this.competitionId,
      seasonYear: seasonYear ?? this.seasonYear,
      played: played ?? this.played,
      wins: wins ?? this.wins,
      draws: draws ?? this.draws,
      losses: losses ?? this.losses,
      goalsFor: goalsFor ?? this.goalsFor,
      goalsAgainst: goalsAgainst ?? this.goalsAgainst,
      goalDifference: goalDifference ?? this.goalDifference,
      points: points ?? this.points,
    );
  }
}
