import 'dart:io';
import 'package:fanfoot/core/enums/player.dart';
import 'package:fanfoot/core/models/player.dart';
import 'package:fanfoot/core/services/club_service.dart';
import 'package:fanfoot/core/services/country_service.dart';
import 'package:fanfoot/core/services/player_service.dart';

class PlayerCsvService {
  static final PlayerCsvService _instance = PlayerCsvService._internal();
  factory PlayerCsvService() => _instance;
  PlayerCsvService._internal();

  final _playerService = PlayerService();
  final _clubService = ClubService();
  final _countryService = CountryService();

  String generateCsvTemplate() {
    final headers = [
      'full_name',
      'surname',
      'age',
      'position',
      'secondary_position',
      'preferred_foot',
      'height_cm',
      'weight_kg',
      'overall',
      'potential',
      'fitness',
      'status',
      'shirt_number',
      'salary_weekly',
      'contract_until',
      'club_name',
      'country_name',
    ];
    return '${headers.join(',')}\n${headers.map((h) => 'exemplo').join(',')}';
  }

  String exportPlayersToCsv(List<Player> players) {
    final buffer = StringBuffer();
    buffer.writeln(
      'full_name,surname,age,position,secondary_position,preferred_foot,height_cm,weight_kg,overall,potential,fitness,status,shirt_number,salary_weekly,contract_until,club_name,country_name',
    );

    for (final player in players) {
      final row = [
        _escapeCsv(player.fullName),
        _escapeCsv(player.surname ?? ''),
        player.age.toString(),
        player.position.name,
        player.secondaryPosition?.name ?? '',
        player.preferredFoot.name,
        player.heightCm.toString(),
        player.weightKg.toString(),
        player.overall.toString(),
        player.potential.toString(),
        player.fitness.toString(),
        player.status.name.toUpperCase(),
        player.shirtNumber.toString(),
        player.salaryWeekly.toString(),
        player.contractUntil.toString(),
        player.currentClubId?.toString() ?? '',
        player.countryId?.toString() ?? '',
      ];
      buffer.writeln(row.join(','));
    }

    return buffer.toString();
  }

  String _escapeCsv(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }

  Future<PlayerImportResult> importPlayersFromFile(File file) async {
    final lines = await file.readAsLines();
    if (lines.isEmpty) {
      return PlayerImportResult(success: 0, errors: ['Arquivo vazio']);
    }

    final headers = _parseCsvLine(lines[0]);
    final requiredHeaders = ['full_name', 'position'];
    final missingHeaders = requiredHeaders
        .where((h) => !headers.contains(h))
        .toList();

    if (missingHeaders.isNotEmpty) {
      return PlayerImportResult(
        success: 0,
        errors: [
          'Cabeçalhos obrigatórios faltando: ${missingHeaders.join(', ')}',
        ],
      );
    }

    final fullNameIndex = headers.indexOf('full_name');
    final surnameIndex = headers.indexOf('surname');
    final ageIndex = headers.indexOf('age');
    final positionIndex = headers.indexOf('position');
    final secondaryPositionIndex = headers.indexOf('secondary_position');
    final preferredFootIndex = headers.indexOf('preferred_foot');
    final heightCmIndex = headers.indexOf('height_cm');
    final weightKgIndex = headers.indexOf('weight_kg');
    final overallIndex = headers.indexOf('overall');
    final potentialIndex = headers.indexOf('potential');
    final fitnessIndex = headers.indexOf('fitness');
    final statusIndex = headers.indexOf('status');
    final shirtNumberIndex = headers.indexOf('shirt_number');
    final salaryWeeklyIndex = headers.indexOf('salary_weekly');
    final contractUntilIndex = headers.indexOf('contract_until');
    final clubNameIndex = headers.indexOf('club_name');
    final countryNameIndex = headers.indexOf('country_name');

    final clubs = await _clubService.getAllClubs();
    final clubMap = {for (var c in clubs) c.name.toLowerCase(): c.id};

    final countries = await _countryService.getAllCountries();
    final countryMap = {for (var c in countries) c.name.toLowerCase(): c.id};

    int successCount = 0;
    final errors = <String>[];

    for (int i = 1; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;

      try {
        final values = _parseCsvLine(line);

        if (values.length <= fullNameIndex || values[fullNameIndex].isEmpty) {
          errors.add('Linha ${i + 1}: Nome completo é obrigatório');
          continue;
        }
        if (values.length <= positionIndex || values[positionIndex].isEmpty) {
          errors.add('Linha ${i + 1}: Posição é obrigatória');
          continue;
        }

        Position? position;
        try {
          position = Position.values.firstWhere(
            (p) => p.name.toUpperCase() == values[positionIndex].toUpperCase(),
          );
        } catch (_) {
          errors.add(
            'Linha ${i + 1}: Posição inválida "${values[positionIndex]}"',
          );
          continue;
        }

        Position? secondaryPosition;
        if (secondaryPositionIndex >= 0 &&
            secondaryPositionIndex < values.length &&
            values[secondaryPositionIndex].isNotEmpty) {
          try {
            secondaryPosition = Position.values.firstWhere(
              (p) =>
                  p.name.toUpperCase() ==
                  values[secondaryPositionIndex].toUpperCase(),
            );
          } catch (_) {}
        }

        PlayerPreferredFoot preferredFoot = PlayerPreferredFoot.R;
        if (preferredFootIndex >= 0 &&
            preferredFootIndex < values.length &&
            values[preferredFootIndex].isNotEmpty) {
          try {
            preferredFoot = PlayerPreferredFoot.values.firstWhere(
              (f) =>
                  f.name.toUpperCase() ==
                  values[preferredFootIndex].toUpperCase(),
            );
          } catch (_) {}
        }

        PlayerStatus status = PlayerStatus.active;
        if (statusIndex >= 0 &&
            statusIndex < values.length &&
            values[statusIndex].isNotEmpty) {
          try {
            status = PlayerStatus.values.firstWhere(
              (s) => s.name.toUpperCase() == values[statusIndex].toUpperCase(),
            );
          } catch (_) {}
        }

        int? clubId;
        if (clubNameIndex >= 0 &&
            clubNameIndex < values.length &&
            values[clubNameIndex].isNotEmpty) {
          clubId = clubMap[values[clubNameIndex].toLowerCase()];
        }

        int? countryId;
        if (countryNameIndex >= 0 &&
            countryNameIndex < values.length &&
            values[countryNameIndex].isNotEmpty) {
          countryId = countryMap[values[countryNameIndex].toLowerCase()];
        }

        final player = Player(
          fullName: values[fullNameIndex],
          surname: surnameIndex >= 0 && surnameIndex < values.length
              ? values[surnameIndex]
              : null,
          age: ageIndex >= 0 && ageIndex < values.length
              ? int.tryParse(values[ageIndex]) ?? 16
              : 16,
          position: position,
          secondaryPosition: secondaryPosition,
          preferredFoot: preferredFoot,
          heightCm: heightCmIndex >= 0 && heightCmIndex < values.length
              ? int.tryParse(values[heightCmIndex]) ?? 170
              : 170,
          weightKg: weightKgIndex >= 0 && weightKgIndex < values.length
              ? double.tryParse(values[weightKgIndex]) ?? 70.0
              : 70.0,
          overall: overallIndex >= 0 && overallIndex < values.length
              ? int.tryParse(values[overallIndex]) ?? 50
              : 50,
          potential: potentialIndex >= 0 && potentialIndex < values.length
              ? int.tryParse(values[potentialIndex]) ?? 50
              : 50,
          fitness: fitnessIndex >= 0 && fitnessIndex < values.length
              ? int.tryParse(values[fitnessIndex]) ?? 100
              : 100,
          status: status,
          shirtNumber: shirtNumberIndex >= 0 && shirtNumberIndex < values.length
              ? int.tryParse(values[shirtNumberIndex]) ?? 0
              : 0,
          salaryWeekly:
              salaryWeeklyIndex >= 0 && salaryWeeklyIndex < values.length
              ? double.tryParse(values[salaryWeeklyIndex]) ?? 0.0
              : 0.0,
          contractUntil:
              contractUntilIndex >= 0 && contractUntilIndex < values.length
              ? int.tryParse(values[contractUntilIndex]) ?? 0
              : 0,
          currentClubId: clubId,
          countryId: countryId,
        );

        await _playerService.insertPlayer(player);
        successCount++;
      } catch (e) {
        errors.add('Linha ${i + 1}: ${e.toString()}');
      }
    }

    return PlayerImportResult(success: successCount, errors: errors);
  }

  List<String> _parseCsvLine(String line) {
    final result = <String>[];
    var current = StringBuffer();
    var inQuotes = false;

    for (var i = 0; i < line.length; i++) {
      final char = line[i];

      if (char == '"') {
        if (inQuotes && i + 1 < line.length && line[i + 1] == '"') {
          current.write('"');
          i++;
        } else {
          inQuotes = !inQuotes;
        }
      } else if (char == ',' && !inQuotes) {
        result.add(current.toString());
        current = StringBuffer();
      } else {
        current.write(char);
      }
    }
    result.add(current.toString());

    return result;
  }
}

class PlayerImportResult {
  final int success;
  final List<String> errors;

  PlayerImportResult({required this.success, required this.errors});
}
