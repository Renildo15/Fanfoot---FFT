import 'package:fanfoot/core/models/competition.dart';
import 'package:fanfoot/core/models/season_competition.dart';
import 'package:fanfoot/core/models/match.dart';

/// Serviço para gerenciar competições de temporada em memória
/// Por enquanto funciona sem banco de dados, armazenando tudo em memória
class SeasonCompetitionService {
  static final SeasonCompetitionService _instance =
      SeasonCompetitionService._internal();

  factory SeasonCompetitionService() {
    return _instance;
  }

  SeasonCompetitionService._internal();

  // Armazena as competições de temporada em memória
  // Chave: "competitionId_seasonYear" (ex: "1_2024")
  final Map<String, SeasonCompetition> _competitions = {};

  /// Retorna a chave única para uma competição e temporada
  String _getKey(int competitionId, int seasonYear) {
    return '${competitionId}_$seasonYear';
  }

  /// Cria ou retorna uma competição de temporada
  /// Se já existe, retorna a existente; senão, cria uma nova
  SeasonCompetition getOrCreateSeasonCompetition({
    required Competition competition,
    required int seasonYear,
    required List<int> clubIds,
    bool generateMatches = true,
  }) {
    final key = _getKey(competition.id ?? 0, seasonYear);

    if (_competitions.containsKey(key)) {
      return _competitions[key]!;
    }

    final seasonCompetition = SeasonCompetition(
      competition: competition,
      seasonYear: seasonYear,
      clubIds: clubIds,
    );

    // Inicializa a tabela
    seasonCompetition.initializeTable();

    // Gera as partidas se for uma liga
    if (generateMatches && competition.type.toString().contains('league')) {
      seasonCompetition.generateLeagueMatches();
    }

    _competitions[key] = seasonCompetition;
    return seasonCompetition;
  }

  /// Busca uma competição de temporada
  SeasonCompetition? getSeasonCompetition(int competitionId, int seasonYear) {
    final key = _getKey(competitionId, seasonYear);
    return _competitions[key];
  }

  /// Retorna todas as competições de uma temporada
  List<SeasonCompetition> getCompetitionsForSeason(int seasonYear) {
    return _competitions.values
        .where((sc) => sc.seasonYear == seasonYear)
        .toList();
  }

  /// Retorna todas as partidas de uma semana específica para todas as competições
  List<Match> getAllMatchesForWeek(int week, int seasonYear) {
    final List<Match> allMatches = [];

    for (final seasonComp in _competitions.values) {
      if (seasonComp.seasonYear == seasonYear) {
        allMatches.addAll(seasonComp.getMatchesForWeek(week));
      }
    }

    return allMatches;
  }

  /// Simula uma partida (define resultado aleatório ou calculado)
  /// Por enquanto, vamos apenas marcar como jogada com resultado fictício
  void simulateMatch(Match match, SeasonCompetition seasonCompetition) {
    // TODO: Implementar lógica de simulação real de partida
    // Por enquanto, apenas marca como jogada com placar fictício
    // Em uma implementação real, você calcularia o placar baseado em:
    // - Força dos times
    // - Forma atual
    // - Fator casa/visitante
    // - Aleatoriedade

    if (!match.isPlayed) {
      match.isPlayed = true;
      match.homeScore = 1; // TODO: calcular resultado real
      match.awayScore = 0; // TODO: calcular resultado real
      match.playedDate = DateTime.now();

      // Atualiza a tabela
      seasonCompetition.processMatch(match);
    }
  }

  /// Simula todas as partidas de uma semana
  void simulateWeek(int week, int seasonYear) {
    final matches = getAllMatchesForWeek(week, seasonYear);

    for (final match in matches) {
      if (!match.isPlayed) {
        final seasonComp = getSeasonCompetition(
          match.competitionId,
          seasonYear,
        );

        if (seasonComp != null) {
          simulateMatch(match, seasonComp);
        }
      }
    }
  }

  /// Limpa todas as competições (útil para testes ou reset)
  void clearAll() {
    _competitions.clear();
  }

  /// Retorna todas as competições gerenciadas
  List<SeasonCompetition> getAllCompetitions() {
    return _competitions.values.toList();
  }
}
