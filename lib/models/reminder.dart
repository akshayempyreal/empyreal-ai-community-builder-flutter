class Reminder {
  final String id;
  final String type; // 'event-start', 'session-start', 'announcement'
  final String timing;
  final String message;
  final bool enabled;

  Reminder({
    required this.id,
    required this.type,
    required this.timing,
    required this.message,
    required this.enabled,
  });

  factory Reminder.fromJson(Map<String, dynamic> json) {
    return Reminder(
      id: json['id'] as String,
      type: json['type'] as String,
      timing: json['timing'] as String,
      message: json['message'] as String,
      enabled: json['enabled'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'timing': timing,
      'message': message,
      'enabled': enabled,
    };
  }
}
