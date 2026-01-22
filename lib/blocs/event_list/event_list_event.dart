import '../../models/event_api_models.dart';

abstract class EventListEvent {}

class FetchEventList extends EventListEvent {
  final EventListRequest request;
  final String token;

  FetchEventList({required this.request, required this.token});
}
