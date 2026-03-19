import 'package:fanfoot/core/models/competition.dart';
import 'package:fanfoot/core/models/match.dart';
import 'package:fanfoot/core/models/league_table_entry.dart';

/// Modelo que representa uma competição em uma temporada específica
/// Gerencia todas as partidas e a tabela de classificação da competição
class SeasonCompetition {
  final Competition competition;
  final int seasonYear;
  final List<int> clubIds; // IDs dos clubes participantes
  final List<Match> matches; // Todas as partidas da competição
  final Map<int, LeagueTableEntry>
  tableEntries; // Tabela: clubId -> LeagueTableEntry

  SeasonCompetition({
    required this.competition,
    required this.seasonYear,
    required this.clubIds,
    List<Match>? matches,
    Map<int, LeagueTableEntry>? tableEntries,
  }) : matches = matches ?? [],
       tableEntries = tableEntries ?? {};

  /// Retorna a tabela ordenada (por pontos, saldo, gols pró, etc.)
  List<LeagueTableEntry> get sortedTable {
    final entries = tableEntries.values.toList();

    entries.sort((a, b) {
      // 1. Por pontos (maior primeiro)
      if (b.points != a.points) {
        return b.points.compareTo(a.points);
      }

      // 2. Por saldo de gols (maior primeiro)
      if (b.goalDifference != a.goalDifference) {
        return b.goalDifference.compareTo(a.goalDifference);
      }

      // 3. Por gols marcados (maior primeiro)
      if (b.goalsFor != a.goalsFor) {
        return b.goalsFor.compareTo(a.goalsFor);
      }

      // 4. Por número de vitórias (maior primeiro)
      if (b.wins != a.wins) {
        return b.wins.compareTo(a.wins);
      }

      return 0; // Empate em tudo
    });

    return entries;
  }

  /// Retorna a posição de um clube na tabela (1-indexed)
  int? getClubPosition(int clubId) {
    final sorted = sortedTable;
    for (int i = 0; i < sorted.length; i++) {
      if (sorted[i].clubId == clubId) {
        return i + 1;
      }
    }
    return null;
  }

  /// Retorna a entrada da tabela de um clube
  LeagueTableEntry? getTableEntry(int clubId) {
    return tableEntries[clubId];
  }

  /// Retorna todas as partidas de uma semana específica
  List<Match> getMatchesForWeek(int week) {
    return matches.where((match) => match.week == week).toList();
  }

  /// Retorna as partidas não jogadas de uma semana específica
  List<Match> getUnplayedMatchesForWeek(int week) {
    return matches
        .where((match) => match.week == week && !match.isPlayed)
        .toList();
  }

  /// Retorna as partidas já jogadas de uma semana específica
  List<Match> getPlayedMatchesForWeek(int week) {
    return matches
        .where((match) => match.week == week && match.isPlayed)
        .toList();
  }

  /// Retorna todas as partidas de um clube (casa ou visitante)
  List<Match> getMatchesForClub(int clubId) {
    return matches
        .where(
          (match) => match.homeClubId == clubId || match.awayClubId == clubId,
        )
        .toList();
  }

  /// Retorna as próximas partidas de um clube (não jogadas)
  List<Match> getUpcomingMatchesForClub(int clubId) {
    return matches
        .where(
          (match) =>
              (match.homeClubId == clubId || match.awayClubId == clubId) &&
              !match.isPlayed,
        )
        .toList();
  }

  /// Gera todas as partidas da competição (para competições do tipo liga)
  /// Cada clube joga contra todos os outros duas vezes (casa e fora)
  void generateLeagueMatches() {
    if (competition.type.toString().contains('cup')) {
      // Para copas, a geração é diferente (chaves eliminatórias)
      return;
    }

    matches.clear();
    int matchWeek = 1;
    int matchesPerWeek = clubIds.length ~/ 2;

    // Primeira rodada: cada clube contra todos os outros
    for (int i = 0; i < clubIds.length; i++) {
      for (int j = i + 1; j < clubIds.length; j++) {
        matches.add(
          Match(
            competitionId: competition.id ?? 0,
            seasonYear: seasonYear,
            week: matchWeek,
            homeClubId: clubIds[i],
            awayClubId: clubIds[j],
          ),
        );

        if (matches.length % matchesPerWeek == 0) {
          matchWeek++;
        }
      }
    }

    // Segunda rodada: partidas de volta (time que jogou em casa agora joga fora)
    int returnMatchWeek = matchWeek;
    for (int i = 0; i < clubIds.length; i++) {
      for (int j = i + 1; j < clubIds.length; j++) {
        matches.add(
          Match(
            competitionId: competition.id ?? 0,
            seasonYear: seasonYear,
            week: returnMatchWeek,
            homeClubId: clubIds[j], // Invertido
            awayClubId: clubIds[i], // Invertido
          ),
        );

        if ((matches.length - (clubIds.length * (clubIds.length - 1) ~/ 2)) %
                matchesPerWeek ==
            0) {
          returnMatchWeek++;
        }
      }
    }
  }

  /// Inicializa a tabela de classificação com todos os clubes
  void initializeTable() {
    tableEntries.clear();
    for (int clubId in clubIds) {
      tableEntries[clubId] = LeagueTableEntry(
        clubId: clubId,
        competitionId: competition.id ?? 0,
        seasonYear: seasonYear,
      );
    }
  }

  /// Processa uma partida e atualiza a tabela
  void processMatch(Match match) {
    if (!match.isPlayed || match.homeScore == null || match.awayScore == null) {
      return;
    }

    final homeEntry = tableEntries[match.homeClubId];
    final awayEntry = tableEntries[match.awayClubId];

    if (homeEntry != null && awayEntry != null) {
      // Atualiza entrada do time da casa
      homeEntry.updateFromMatchResult(
        goalsForClub: match.homeScore!,
        goalsAgainstClub: match.awayScore!,
        pointsWin: competition.pointsWin,
        pointsDraw: competition.pointsDraw,
        pointsLose: competition.pointsLose,
      );

      // Atualiza entrada do time visitante
      awayEntry.updateFromMatchResult(
        goalsForClub: match.awayScore!,
        goalsAgainstClub: match.homeScore!,
        pointsWin: competition.pointsWin,
        pointsDraw: competition.pointsDraw,
        pointsLose: competition.pointsLose,
      );
    }
  }

  /// Processa todas as partidas já jogadas para atualizar a tabela
  void processAllPlayedMatches() {
    for (final match in matches) {
      if (match.isPlayed) {
        processMatch(match);
      }
    }
  }
}
