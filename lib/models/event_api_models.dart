class CreateEventRequest {
  final String name;
  final String startDate;
  final String endDate;
  final String description;
  final List<String> attachments;
  final int hoursInDay;
  final String eventType;
  final String? otherEventType;
  final int expectedAudienceSize;
  final String location;
  final String lat;
  final String long;

  CreateEventRequest({
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.description,
    required this.attachments,
    required this.hoursInDay,
    required this.eventType,
    this.otherEventType,
    required this.expectedAudienceSize,
    required this.location,
    required this.lat,
    required this.long,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'startDate': startDate,
      'endDate': endDate,
      'description': description,
      'attachments': attachments,
      'hoursInDay': hoursInDay,
      'eventType': eventType,
      if (otherEventType != null) 'otherEventType': otherEventType,
      'expectedAudienceSize': expectedAudienceSize,
      'location': location,
      'lat': lat,
      'long': long,
    };
  }
}

class CreateEventResponse {
  final bool status;
  final String message;
  final EventData? data;

  CreateEventResponse({
    required this.status,
    required this.message,
    this.data,
  });

  factory CreateEventResponse.fromJson(Map<String, dynamic> json) {
    return CreateEventResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? EventData.fromJson(json['data']) : null,
    );
  }
}

class EventData {
  final String id;
  final String name;
  final String description;
  final List<String> attachments;
  final String startDate;
  final String endDate;
  final int hoursInDay;
  final String eventType;
  final String? otherEventType;
  final int expectedAudienceSize;
  final String location;
  final Coordinates? coordinates;
  final bool isCompleteDetails;
  final String agenda;
  final String createdBy;
  final String updatedAt;
  final String createdAt;

  EventData({
    required this.id,
    required this.name,
    required this.description,
    required this.attachments,
    required this.startDate,
    required this.endDate,
    required this.hoursInDay,
    required this.eventType,
    this.otherEventType,
    required this.expectedAudienceSize,
    required this.location,
    this.coordinates,
    required this.isCompleteDetails,
    required this.agenda,
    required this.createdBy,
    required this.updatedAt,
    required this.createdAt,
  });

  factory EventData.fromJson(Map<String, dynamic> json) {
    return EventData(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      attachments: List<String>.from(json['attachments'] ?? []),
      startDate: json['startDate'] ?? '',
      endDate: json['endDate'] ?? '',
      hoursInDay: json['hoursInDay'] ?? 0,
      eventType: json['eventType'] ?? '',
      otherEventType: json['otherEventType'],
      expectedAudienceSize: json['expectedAudienceSize'] ?? 0,
      location: json['location'] ?? '',
      coordinates: json['coordinates'] != null ? Coordinates.fromJson(json['coordinates']) : null,
      isCompleteDetails: json['isCompleteDetails'] ?? false,
      agenda: json['agenda'] ?? '',
      createdBy: json['createdBy'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      createdAt: json['createdAt'] ?? '',
    );
  }
}

class Coordinates {
  final String type;
  final List<double> coordinates;

  Coordinates({required this.type, required this.coordinates});

  factory Coordinates.fromJson(Map<String, dynamic> json) {
    return Coordinates(
      type: json['type'] ?? 'Point',
      coordinates: List<double>.from(json['coordinates']?.map((x) => x.toDouble()) ?? []),
    );
  }
}
