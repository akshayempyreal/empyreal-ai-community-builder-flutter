import '../../models/event_api_models.dart';

abstract class EventListState {}

class EventListInitial extends EventListState {}

class EventListLoading extends EventListState {}

class EventListSuccess extends EventListState {
  final EventListResponse response;
  final List<EventData> allEvents; // Accumulated events from all pages
  final int currentPage;
  final bool hasMore;

  EventListSuccess({
    required this.response,
    List<EventData>? allEvents,
    int? currentPage,
    bool? hasMore,
  })  : allEvents = _ensureNonNullList(allEvents, response),
        currentPage = currentPage ?? (response.data?.page ?? 1),
        hasMore = hasMore ?? ((response.data?.page ?? 1) < (response.data?.totalPages ?? 1));

  static List<EventData> _ensureNonNullList(List<EventData>? provided, EventListResponse response) {
    if (provided != null) return provided;
    if (response.data != null && response.data!.events.isNotEmpty) {
      return response.data!.events;
    }
    return <EventData>[];
  }

  EventListSuccess copyWith({
    EventListResponse? response,
    List<EventData>? allEvents,
    int? currentPage,
    bool? hasMore,
  }) {
    return EventListSuccess(
      response: response ?? this.response,
      allEvents: allEvents != null ? allEvents : this.allEvents,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

class EventListFailure extends EventListState {
  final String error;

  EventListFailure(this.error);
}
