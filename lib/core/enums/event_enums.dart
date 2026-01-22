enum EventOwnership {
  all,
  me,
  other;

  String toJson() => name;

  static EventOwnership fromJson(String value) {
    return EventOwnership.values.firstWhere(
      (e) => e.name == value,
      orElse: () => EventOwnership.all,
    );
  }
}

enum EventStatus {
  upcoming,
  past,
  current;

  String toJson() => name;

  static EventStatus fromJson(String value) {
    return EventStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => EventStatus.upcoming,
    );
  }
}
