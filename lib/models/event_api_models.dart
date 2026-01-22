import '../core/enums/event_enums.dart';

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
  final int membersCount;
  final bool isMember;

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
    this.membersCount = 0,
    this.isMember = false,
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
      membersCount: json['membersCount'] ?? 0,
      isMember: json['isMember'] ?? false,
    );
  }
}

class EventListRequest {
  final int page;
  final int limit;
  final EventOwnership ownBy;
  final EventStatus? status;

  EventListRequest({
    this.page = 1,
    this.limit = 10,
    this.ownBy = EventOwnership.all,
    this.status,
  });

  Map<String, dynamic> toJson() => {
    'page': page,
    'limit': limit,
    'ownBy': ownBy.toJson(),
    'status': status?.toJson() ?? '',
  };
}

class EventListResponse {
  final bool status;
  final String message;
  final EventListData? data;

  EventListResponse({
    required this.status,
    required this.message,
    this.data,
  });

  factory EventListResponse.fromJson(Map<String, dynamic> json) {
    return EventListResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? EventListData.fromJson(json['data']) : null,
    );
  }
}

class EventListData {
  final List<EventData> events;
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  EventListData({
    required this.events,
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  factory EventListData.fromJson(Map<String, dynamic> json) {
    return EventListData(
      events: (json['events'] as List?)?.map((x) => EventData.fromJson(x)).toList() ?? [],
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 10,
      totalPages: json['totalPages'] ?? 1,
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

class GenerateAgendaResponse {
  final bool status;
  final String message;
  final GenerateAgendaData? data;

  GenerateAgendaResponse({
    required this.status,
    required this.message,
    this.data,
  });

  factory GenerateAgendaResponse.fromJson(Map<String, dynamic> json) {
    return GenerateAgendaResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? GenerateAgendaData.fromJson(json['data']) : null,
    );
  }
}

class GenerateAgendaData {
  final String agenda;

  GenerateAgendaData({
    required this.agenda,
  });

  factory GenerateAgendaData.fromJson(Map<String, dynamic> json) {
    return GenerateAgendaData(
      agenda: json['agenda'] ?? '',
    );
  }
}

class SaveAgendaResponse {
  final bool status;
  final String message;
  final EventData? data;

  SaveAgendaResponse({
    required this.status,
    required this.message,
    this.data,
  });

  factory SaveAgendaResponse.fromJson(Map<String, dynamic> json) {
    return SaveAgendaResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? EventData.fromJson(json['data']) : null,
    );
  }
}
