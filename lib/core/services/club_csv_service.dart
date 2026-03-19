import 'dart:io';
import 'package:fanfoot/core/enums/club.dart';
import 'package:fanfoot/core/models/club.dart';
import 'package:fanfoot/core/services/club_service.dart';
import 'package:fanfoot/core/services/country_service.dart';

class ClubCsvService {
  static final ClubCsvService _instance = ClubCsvService._internal();
  factory ClubCsvService() => _instance;
  ClubCsvService._internal();

  final _clubService = ClubService();
  final _countryService = CountryService();

  String generateCsvTemplate() {
    final headers = [
      'name',
      'short_name',
      'reputation',
      'budget',
      'wage_budget',
      'federation',
      'stadium',
      'primary_color',
      'secondary_color',
      'country_name',
    ];
    return headers.join(',') + '\n${headers.map((h) => 'exemplo').join(',')}';
  }

  String exportClubsToCsv(List<Club> clubs) {
    final buffer = StringBuffer();
    buffer.writeln(
      'name,short_name,reputation,budget,wage_budget,federation,stadium,primary_color,secondary_color,country_name',
    );

    for (final club in clubs) {
      final row = [
        _escapeCsv(club.name),
        _escapeCsv(club.shortName ?? ''),
        club.reputation.toString(),
        club.budget.toString(),
        club.wageBudget.toString(),
        club.federation?.name ?? '',
        _escapeCsv(club.stadium ?? ''),
        club.primaryColor ?? '',
        club.secondaryColor ?? '',
        club.countryId?.toString() ?? '',
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

  Future<ClubImportResult> importClubsFromFile(File file) async {
    final lines = await file.readAsLines();
    if (lines.isEmpty) {
      return ClubImportResult(success: 0, errors: ['Arquivo vazio']);
    }

    final headers = _parseCsvLine(lines[0]);
    final requiredHeaders = ['name', 'short_name'];
    final missingHeaders = requiredHeaders
        .where((h) => !headers.contains(h))
        .toList();

    if (missingHeaders.isNotEmpty) {
      return ClubImportResult(
        success: 0,
        errors: [
          'Cabeçalhos obrigatórios faltando: ${missingHeaders.join(', ')}',
        ],
      );
    }

    final nameIndex = headers.indexOf('name');
    final shortNameIndex = headers.indexOf('short_name');
    final reputationIndex = headers.indexOf('reputation');
    final budgetIndex = headers.indexOf('budget');
    final wageBudgetIndex = headers.indexOf('wage_budget');
    final federationIndex = headers.indexOf('federation');
    final stadiumIndex = headers.indexOf('stadium');
    final primaryColorIndex = headers.indexOf('primary_color');
    final secondaryColorIndex = headers.indexOf('secondary_color');
    final countryNameIndex = headers.indexOf('country_name');

    final countries = await _countryService.getAllCountries();
    final countryMap = {for (var c in countries) c.name.toLowerCase(): c.id};

    int successCount = 0;
    final errors = <String>[];

    for (int i = 1; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;

      try {
        final values = _parseCsvLine(line);

        if (values.length <= nameIndex || values[nameIndex].isEmpty) {
          errors.add('Linha ${i + 1}: Nome é obrigatório');
          continue;
        }

        int? countryId;
        if (countryNameIndex >= 0 &&
            countryNameIndex < values.length &&
            values[countryNameIndex].isNotEmpty) {
          countryId = countryMap[values[countryNameIndex].toLowerCase()];
        }

        ClubFederation? federation;
        if (federationIndex >= 0 &&
            federationIndex < values.length &&
            values[federationIndex].isNotEmpty) {
          try {
            federation = ClubFederation.values.firstWhere(
              (f) =>
                  f.name.toUpperCase() == values[federationIndex].toUpperCase(),
            );
          } catch (_) {
            errors.add(
              'Linha ${i + 1}: Federação inválida "${values[federationIndex]}"',
            );
          }
        }

        final club = Club(
          name: values[nameIndex],
          shortName: shortNameIndex >= 0 && shortNameIndex < values.length
              ? values[shortNameIndex]
              : null,
          reputation: reputationIndex >= 0 && reputationIndex < values.length
              ? int.tryParse(values[reputationIndex]) ?? 0
              : 0,
          budget: budgetIndex >= 0 && budgetIndex < values.length
              ? double.tryParse(values[budgetIndex]) ?? 0.0
              : 0.0,
          wageBudget: wageBudgetIndex >= 0 && wageBudgetIndex < values.length
              ? double.tryParse(values[wageBudgetIndex]) ?? 0.0
              : 0.0,
          federation: federation,
          stadium: stadiumIndex >= 0 && stadiumIndex < values.length
              ? values[stadiumIndex]
              : null,
          primaryColor:
              primaryColorIndex >= 0 && primaryColorIndex < values.length
              ? values[primaryColorIndex]
              : null,
          secondaryColor:
              secondaryColorIndex >= 0 && secondaryColorIndex < values.length
              ? values[secondaryColorIndex]
              : null,
          countryId: countryId,
        );

        await _clubService.insertClub(club);
        successCount++;
      } catch (e) {
        errors.add('Linha ${i + 1}: ${e.toString()}');
      }
    }

    return ClubImportResult(success: successCount, errors: errors);
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

class ClubImportResult {
  final int success;
  final List<String> errors;

  ClubImportResult({required this.success, required this.errors});
}
