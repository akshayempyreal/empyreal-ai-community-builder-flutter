import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repositories/event_repository.dart';
import 'attendee_event.dart';
import 'attendee_state.dart';

class AttendeeBloc extends Bloc<AttendeeEvent, AttendeeState> {
  final EventRepository _eventRepository;

  AttendeeBloc(this._eventRepository) : super(AttendeeInitial()) {
    on<FetchAttendeeList>(_onFetchAttendeeList);
  }

  Future<void> _onFetchAttendeeList(
    FetchAttendeeList event,
    Emitter<AttendeeState> emit,
  ) async {
    emit(AttendeeLoading());
    try {
      final response = await _eventRepository.getMemberList(
        event.eventId,
        event.token,
        page: event.page,
        limit: event.limit,
      );
      if (response.status && response.data != null) {
        emit(AttendeeSuccess(response));
      } else {
        emit(AttendeeFailure(response.message));
      }
    } catch (e) {
      emit(AttendeeFailure(e.toString()));
    }
  }
}
