import '../../models/event_api_models.dart';

abstract class EventListEvent {}

class FetchEventList extends EventListEvent {
  final EventListRequest request;
  final String token;

  FetchEventList({required this.request, required this.token});
}

class FetchMoreEvents extends EventListEvent {
  final EventListRequest request;
  final String token;

  FetchMoreEvents({required this.request, required this.token});
}
