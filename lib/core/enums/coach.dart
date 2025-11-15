enum CoachStyle {
  offensive,
  defensive,
  balanced,
  counterAttack,
  possession,
  pressing,
}

extension CoachStyleExtension on CoachStyle {
  String get value {
    switch (this) {
      case CoachStyle.offensive:
        return "OFFENSIVE";
      case CoachStyle.defensive:
        return "DEFENSIVE";
      case CoachStyle.balanced:
        return "BALANCED";
      case CoachStyle.counterAttack:
        return "COUNTER_ATTACK";
      case CoachStyle.possession:
        return "POSSESSION";
      case CoachStyle.pressing:
        return "PRESSING";
    }
  }

  static CoachStyle fromString(String str) {
    switch (str) {
      case "OFFENSIVE":
        return CoachStyle.offensive;
      case "DEFENSIVE":
        return CoachStyle.defensive;
      case "BALANCED":
        return CoachStyle.balanced;
      case "COUNTER_ATTACK":
        return CoachStyle.counterAttack;
      case "POSSESSION":
        return CoachStyle.possession;
      case "PRESSING":
        return CoachStyle.pressing;
      default:
        throw Exception("CoachStyle inválido: $str");
    }
  }
}