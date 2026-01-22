import '../../models/event_api_models.dart';

abstract class EventListState {}

class EventListInitial extends EventListState {}

class EventListLoading extends EventListState {}

class EventListSuccess extends EventListState {
  final EventListResponse response;

  EventListSuccess(this.response);
}

class EventListFailure extends EventListState {
  final String error;

  EventListFailure(this.error);
}
