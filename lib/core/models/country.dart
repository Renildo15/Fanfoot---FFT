class Country {
  int? id;
  String code;
  String name;
  String flag;

  Country({
    this.id,
    required this.code,
    required this.name,
    required this.flag,
  });

  factory Country.fromMap(Map<String, dynamic> map) => Country(
    id: map['id'],
    code: map['code'],
    name: map['name'],
    flag: map['flag'],
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'code': code,
    'name': name,
    'flag': flag,
  };
}
