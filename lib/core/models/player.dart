import 'package:fanfoot/core/enums/player.dart';


class Player {
  int? id;
  String fullName;
  String? surname;
  int age;
  Position position;
  Position? secondaryPosition;
  PlayerPreferredFoot preferredFoot;
  int heightCm;
  double weightKg;
  int overall;
  int potential;
  int fitness;
  PlayerStatus status;
  int shirtNumber;
  double salaryWeekly;
  int contractUntil;
  int? currentClubId;
  int? countryId;

  Player({
    this.id,
    required this.fullName,
    this.surname,
    this.age = 16,
    required this.position,
    this.secondaryPosition,
    required this.preferredFoot,
    this.heightCm = 170,
    this.weightKg = 70.0,
    this.overall = 50,
    this.potential = 50,
    this.fitness = 100,
    this.status = PlayerStatus.active,
    this.shirtNumber = 0,
    this.salaryWeekly = 0.0,
    this.contractUntil = 0,
    this.currentClubId,
    this.countryId,
  });

  factory Player.fromMap(Map<String, dynamic> map) => Player(
        id: map['id'],
        fullName: map['full_name'],
        surname: map['surname'],
        age: map['age'] ?? 16,
        position: Position.values.firstWhere(
            (e) => e.toString().split('.').last == map['position']),
        secondaryPosition: map['secondary_position'] != null
            ? Position.values
                .firstWhere((e) => e.toString().split('.').last == map['secondary_position'])
            : null,
        preferredFoot: PlayerPreferredFoot.values
            .firstWhere((e) => e.toString().split('.').last == map['preferred_foot']),
        heightCm: map['height_cm'] ?? 170,
        weightKg: map['weight_kg']?.toDouble() ?? 70.0,
        overall: map['overall'] ?? 50,
        potential: map['potential'] ?? 50,
        fitness: map['fitness'] ?? 100,
        status: PlayerStatus.values
            .firstWhere((e) => e.toString().split('.').last.toUpperCase() == map['status']),
        shirtNumber: map['shirt_number'] ?? 0,
        salaryWeekly: map['salary_weekly']?.toDouble() ?? 0.0,
        contractUntil: map['contract_until'] ?? 0,
        currentClubId: map['current_club_id'],
        countryId: map['country_id'],
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'full_name': fullName,
        'surname': surname,
        'age': age,
        'position': position.toString().split('.').last,
        'secondary_position':
            secondaryPosition?.toString().split('.').last,
        'preferred_foot': preferredFoot.toString().split('.').last,
        'height_cm': heightCm,
        'weight_kg': weightKg,
        'overall': overall,
        'potential': potential,
        'fitness': fitness,
        'status': status.toString().split('.').last.toUpperCase(),
        'shirt_number': shirtNumber,
        'salary_weekly': salaryWeekly,
        'contract_until': contractUntil,
        'current_club_id': currentClubId,
        'country_id': countryId,
      };
}
