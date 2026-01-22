import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repositories/event_repository.dart';
import 'event_actions_event.dart';
import 'event_actions_state.dart';

class EventActionsBloc extends Bloc<EventActionsEvent, EventActionsState> {
  final EventRepository _eventRepository;

  EventActionsBloc(this._eventRepository) : super(EventActionsInitial()) {
    on<ToggleJoinLeave>(_onJoinLeaveEvent);
    on<DeleteEvent>(_onDeleteEvent);
  }

  Future<void> _onJoinLeaveEvent(
    ToggleJoinLeave event,
    Emitter<EventActionsState> emit,
  ) async {
    emit(EventActionLoading());
    try {
      final response = await _eventRepository.joinLeaveEvent(event.eventId, event.token);
      if (response.status) {
        emit(EventJoinLeaveSuccess(response));
      } else {
        emit(EventActionFailure(response.message));
      }
    } catch (e) {
      emit(EventActionFailure(e.toString()));
    }
  }

  Future<void> _onDeleteEvent(
    DeleteEvent event,
    Emitter<EventActionsState> emit,
  ) async {
    emit(EventActionLoading());
    try {
      final response = await _eventRepository.deleteEvent(event.eventId, event.token);
      if (response.status) {
        emit(DeleteEventSuccess(response.message));
      } else {
        emit(EventActionFailure(response.message));
      }
    } catch (e) {
      emit(EventActionFailure(e.toString()));
    }
  }
}
