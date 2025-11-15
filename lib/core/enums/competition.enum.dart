enum CompetitionType {
  league,
  cup,
  leagueKnockout
}

extension CompetitionTypeExtension on CompetitionType {
  String get value {
    switch (this) {
      case CompetitionType.league:
        return "LEAGUE";
      case CompetitionType.cup:
        return "CUP";
      case CompetitionType.leagueKnockout:
        return "LEAGUE & KNOCKOUT";
    }
  }

  static CompetitionType fromString(String str) {
    switch (str) {
      case "LEAGUE":
        return CompetitionType.league;
      case "CUP":
        return CompetitionType.cup;
      case "LEAGUE & KNOCKOUT":
        return CompetitionType.leagueKnockout;
      default:
        throw Exception("CompetitionType inválido: $str");
    }
  }
}