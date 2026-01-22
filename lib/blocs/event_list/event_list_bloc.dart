import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repositories/event_repository.dart';
import 'event_list_event.dart';
import 'event_list_state.dart';

class EventListBloc extends Bloc<EventListEvent, EventListState> {
  final EventRepository _eventRepository;

  EventListBloc(this._eventRepository) : super(EventListInitial()) {
    on<FetchEventList>(_onFetchEventList);
  }

  Future<void> _onFetchEventList(
    FetchEventList event,
    Emitter<EventListState> emit,
  ) async {
    emit(EventListLoading());
    try {
      final response = await _eventRepository.getEvents(event.request, event.token);
      if (response.status) {
        emit(EventListSuccess(response));
      } else {
        emit(EventListFailure(response.message));
      }
    } catch (e) {
      emit(EventListFailure(e.toString()));
    }
  }
}
