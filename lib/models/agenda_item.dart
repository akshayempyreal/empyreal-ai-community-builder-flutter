class AgendaItem {
  final String id;
  final String title;
  final String startTime;
  final String endTime;
  final String type; // 'session', 'break', 'activity', 'ceremony'
  final String? description;
  final bool? isFixed;

  AgendaItem({
    required this.id,
    required this.title,
    required this.startTime,
    required this.endTime,
    required this.type,
    this.description,
    this.isFixed,
  });

  factory AgendaItem.fromJson(Map<String, dynamic> json) {
    return AgendaItem(
      id: json['id'] as String,
      title: json['title'] as String,
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
      type: json['type'] as String,
      description: json['description'] as String?,
      isFixed: json['isFixed'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'startTime': startTime,
      'endTime': endTime,
      'type': type,
      'description': description,
      'isFixed': isFixed,
    };
  }
}
