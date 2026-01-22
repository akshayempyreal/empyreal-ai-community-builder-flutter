abstract class AttendeeEvent {}

class FetchAttendeeList extends AttendeeEvent {
  final String eventId;
  final String token;
  final int page;
  final int limit;

  FetchAttendeeList({
    required this.eventId,
    required this.token,
    this.page = 1,
    this.limit = 10,
  });
}
