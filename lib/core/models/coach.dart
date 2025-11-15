import 'package:fanfoot/core/enums/coach.dart';

class Coach {
  int? id;
  String fullName;
  String? surname;
  int age;
  CoachStyle style;
  int reputation;
  int experience;
  double salaryWeekly;
  String contractUntil;
  int? clubId;
  int? countryId;

  Coach({
    this.id,
    required this.fullName,
    this.surname,
    this.age = 35,
    this.style = CoachStyle.balanced,
    this.reputation = 50,
    this.experience = 1,
    this.salaryWeekly = 0.0,
    this.contractUntil = "2025-06-30",
    this.clubId,
    this.countryId,
  });

  factory Coach.fromMap(Map<String, dynamic> map) => Coach(
    id: map['id'],
    fullName: map['full_name'],
    surname: map['surname'],
    age: map['age'] ?? 35,
    style: CoachStyleExtension.fromString(map['style']),
    reputation: map['reputation'] ?? 50,
    experience: map['experience'] ?? 1,
    salaryWeekly: map['salary_weekly']?.toDouble() ?? 0.0,
    contractUntil: map['contract_until'] ?? "2025-06-30",
    clubId: map['club_id'],
    countryId: map['country_id'],
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'full_name': fullName,
    'surname': surname,
    'age': age,
    'style': style.value,
    'reputation': reputation,
    'experience': experience,
    'salary_weekly': salaryWeekly,
    'contract_until': contractUntil,
    'club_id': clubId,
    'country_id': countryId,
  };
}
