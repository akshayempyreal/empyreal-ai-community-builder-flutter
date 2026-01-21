class GenerateSessionsResponse {
  final bool status;
  final String message;
  final SessionData? data;

  GenerateSessionsResponse({
    required this.status,
    required this.message,
    this.data,
  });

  factory GenerateSessionsResponse.fromJson(Map<String, dynamic> json) {
    return GenerateSessionsResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? SessionData.fromJson(json['data']) : null,
    );
  }
}

class SessionData {
  final String eventName;
  final int totalDays;
  final List<DaySession> sessions;

  SessionData({
    required this.eventName,
    required this.totalDays,
    required this.sessions,
  });

  factory SessionData.fromJson(Map<String, dynamic> json) {
    return SessionData(
      eventName: json['eventName'] ?? '',
      totalDays: json['totalDays'] ?? 0,
      sessions: (json['sessions'] as List?)
              ?.map((x) => DaySession.fromJson(x))
              .toList() ??
          [],
    );
  }
}

class DaySession {
  final int day;
  final String date;
  final String dayStartDateTime;
  final String dayEndDateTime;
  final List<SessionItem> sessions;

  DaySession({
    required this.day,
    required this.date,
    required this.dayStartDateTime,
    required this.dayEndDateTime,
    required this.sessions,
  });

  factory DaySession.fromJson(Map<String, dynamic> json) {
    return DaySession(
      day: json['day'] ?? 0,
      date: json['date'] ?? '',
      dayStartDateTime: json['dayStartDateTime'] ?? '',
      dayEndDateTime: json['dayEndDateTime'] ?? '',
      sessions: (json['sessions'] as List?)
              ?.map((x) => SessionItem.fromJson(x))
              .toList() ??
          [],
    );
  }
}

class SessionItem {
  final String sessionTitle;
  final String sessionDescription;
  final String startDateTime;
  final String endDateTime;
  final int durationMinutes;

  SessionItem({
    required this.sessionTitle,
    required this.sessionDescription,
    required this.startDateTime,
    required this.endDateTime,
    required this.durationMinutes,
  });

  factory SessionItem.fromJson(Map<String, dynamic> json) {
    return SessionItem(
      sessionTitle: json['sessionTitle'] ?? '',
      sessionDescription: json['sessionDescription'] ?? '',
      startDateTime: json['startDateTime'] ?? '',
      endDateTime: json['endDateTime'] ?? '',
      durationMinutes: json['durationMinutes'] ?? 0,
    );
  }
}
