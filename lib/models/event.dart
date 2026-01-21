class Event {
  final String id;
  final String name;
  final String description;
  final String location;
  final String type;
  final String date;
  final String? endDate;
  final int duration;
  final int? audienceSize;
  final String planningMode; // 'automated' or 'manual'
  final String status; // 'draft', 'published', 'ongoing', 'completed'
  final String createdAt;
  final int? attendeeCount;

  Event({
    required this.id,
    required this.name,
    required this.description,
    required this.location,
    required this.type,
    required this.date,
    this.endDate,
    required this.duration,
    this.audienceSize,
    required this.planningMode,
    required this.status,
    required this.createdAt,
    this.attendeeCount,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      location: json['location'] as String? ?? 'TBD', // Handle existing data
      type: json['type'] as String,
      date: json['date'] as String,
      endDate: json['endDate'] as String?,
      duration: json['duration'] as int,
      audienceSize: json['audienceSize'] as int?,
      planningMode: json['planningMode'] as String,
      status: json['status'] as String,
      createdAt: json['createdAt'] as String,
      attendeeCount: json['attendeeCount'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'location': location,
      'type': type,
      'date': date,
      'endDate': endDate,
      'duration': duration,
      'audienceSize': audienceSize,
      'planningMode': planningMode,
      'status': status,
      'createdAt': createdAt,
      'attendeeCount': attendeeCount,
    };
  }
}
