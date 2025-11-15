import 'package:fanfoot/core/enums/club.dart';

class Club {
  int? id;
  String name;
  String? shortName;
  int reputation;
  double budget;
  double wageBudget;
  ClubFederation? federation;
  String? stadium;
  String? crestPath;
  String? primaryColor;
  String? secondaryColor;
  int? countryId;

  Club({
    this.id,
    required this.name,
    this.shortName,
    this.reputation = 0,
    this.budget = 0.0,
    this.wageBudget = 0.0,
    this.federation,
    this.stadium,
    this.crestPath,
    this.primaryColor,
    this.secondaryColor,
    this.countryId,
  });

  factory Club.fromMap(Map<String, dynamic> map) => Club(
    id: map['id'],
    name: map['name'],
    shortName: map['short_name'],
    reputation: map['reputation'] ?? 0,
    budget: map['budget']?.toDouble() ?? 0.0,
    wageBudget: map['wage_budget']?.toDouble() ?? 0.0,
    federation: map['federation'] != null
        ? ClubFederation.values
            .firstWhere((e) => e.toString().split('.').last == map['federation'])
        : null,
    stadium: map['stadium'],
    crestPath: map['crest_path'],
    primaryColor: map['primary_color'],
    secondaryColor: map['secondary_color'],
    countryId: map['country_id'],
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'short_name': shortName,
    'reputation': reputation,
    'budget': budget,
    'wage_budget': wageBudget,
    'federation': federation?.toString().split('.').last,
    'stadium': stadium,
    'crest_path': crestPath,
    'primary_color': primaryColor,
    'secondary_color': secondaryColor,
    'country_id': countryId,
  };
}
