/// Modelo que representa uma partida entre dois clubes
class Match {
  int? id;
  int competitionId;
  int seasonYear;
  int week; // Semana da temporada em que a partida ocorre
  int homeClubId;
  int awayClubId;
  int? homeScore; // null = partida não jogada ainda
  int? awayScore; // null = partida não jogada ainda
  bool isPlayed; // Se a partida já foi jogada
  DateTime? playedDate; // Data/hora em que a partida foi jogada

  Match({
    this.id,
    required this.competitionId,
    required this.seasonYear,
    required this.week,
    required this.homeClubId,
    required this.awayClubId,
    this.homeScore,
    this.awayScore,
    this.isPlayed = false,
    this.playedDate,
  });

  /// Retorna o clube vencedor (null se empate ou não jogado)
  int? get winnerClubId {
    if (!isPlayed || homeScore == null || awayScore == null) {
      return null;
    }
    if (homeScore! > awayScore!) return homeClubId;
    if (awayScore! > homeScore!) return awayClubId;
    return null; // Empate
  }

  /// Retorna o clube perdedor (null se empate ou não jogado)
  int? get loserClubId {
    if (!isPlayed || homeScore == null || awayScore == null) {
      return null;
    }
    if (homeScore! > awayScore!) return awayClubId;
    if (awayScore! > homeScore!) return homeClubId;
    return null; // Empate
  }

  /// Verifica se houve empate
  bool get isDraw {
    if (!isPlayed || homeScore == null || awayScore == null) {
      return false;
    }
    return homeScore == awayScore;
  }

  /// Retorna o resultado como String (ex: "3-1")
  String get resultString {
    if (!isPlayed || homeScore == null || awayScore == null) {
      return '-';
    }
    return '$homeScore-$awayScore';
  }

  factory Match.fromMap(Map<String, dynamic> map) => Match(
    id: map['id'],
    competitionId: map['competition_id'],
    seasonYear: map['season_year'],
    week: map['week'],
    homeClubId: map['home_club_id'],
    awayClubId: map['away_club_id'],
    homeScore: map['home_score'],
    awayScore: map['away_score'],
    isPlayed: map['is_played'] == 1 || map['is_played'] == true,
    playedDate: map['played_date'] != null
        ? DateTime.parse(map['played_date'])
        : null,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'competition_id': competitionId,
    'season_year': seasonYear,
    'week': week,
    'home_club_id': homeClubId,
    'away_club_id': awayClubId,
    'home_score': homeScore,
    'away_score': awayScore,
    'is_played': isPlayed ? 1 : 0,
    'played_date': playedDate?.toIso8601String(),
  };
}
