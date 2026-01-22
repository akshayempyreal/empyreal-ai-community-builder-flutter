import 'event_api_models.dart';

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
  final String createdBy;
  final int? attendeeCount;
  final double? latitude;
  final double? longitude;

  final String? image;

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
    required this.createdBy,
    this.attendeeCount,
    this.latitude,
    this.longitude,
    this.image,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      location: json['location'] as String? ?? 'TBD',
      type: json['type'] as String,
      date: json['date'] as String,
      endDate: json['endDate'] as String?,
      duration: json['duration'] as int,
      audienceSize: json['audienceSize'] as int?,
      planningMode: json['planningMode'] as String,
      status: json['status'] as String,
      createdAt: json['createdAt'] as String,
      createdBy: json['createdBy'] as String? ?? '',
      attendeeCount: json['attendeeCount'] as int?,
      latitude: json['latitude'] as double?,
      longitude: json['longitude'] as double?,
      image: json['image'] as String?,
    );
  }

  factory Event.fromEventData(EventData data) {
    return Event(
      id: data.id,
      name: data.name,
      description: data.description,
      location: data.location,
      type: data.eventType,
      date: data.startDate,
      endDate: data.endDate,
      duration: data.hoursInDay,
      audienceSize: data.expectedAudienceSize,
      planningMode: data.agenda.isNotEmpty ? 'automated' : 'manual',
      status: data.isCompleteDetails ? 'published' : 'draft',
      createdAt: data.createdAt,
      createdBy: data.createdBy,
      attendeeCount: data.membersCount,
      latitude: data.coordinates?.coordinates[1],
      longitude: data.coordinates?.coordinates[0],
      image: data.attachments.isNotEmpty ? data.attachments.first : null,
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
      'createdBy': createdBy,
      'attendeeCount': attendeeCount,
      'latitude': latitude,
      'longitude': longitude,
      'image': image,
    };
  }
}
