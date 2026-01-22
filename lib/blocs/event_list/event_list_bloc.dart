import 'package:empyreal_ai_community_builder_flutter/models/event_api_models.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repositories/event_repository.dart';
import 'event_list_event.dart';
import 'event_list_state.dart';

class EventListBloc extends Bloc<EventListEvent, EventListState> {
  final EventRepository _eventRepository;

  EventListBloc(this._eventRepository) : super(EventListInitial()) {
    on<FetchEventList>(_onFetchEventList);
    on<FetchMoreEvents>(_onFetchMoreEvents);
  }

  Future<void> _onFetchEventList(
    FetchEventList event,
    Emitter<EventListState> emit,
  ) async {
    emit(EventListLoading());
    try {
      final response = await _eventRepository.getEvents(event.request, event.token);
      if (response.status) {
        // Ensure allEvents is never null - explicitly handle all cases
        List<EventData> events;
        if (response.data != null && response.data!.events != null) {
          events = response.data!.events!;
        } else {
          events = <EventData>[];
        }
        emit(EventListSuccess(
          response: response,
          allEvents: events,
        ));
      } else {
        emit(EventListFailure(response.message));
      }
    } catch (e) {
      emit(EventListFailure(e.toString()));
    }
  }

  Future<void> _onFetchMoreEvents(
    FetchMoreEvents event,
    Emitter<EventListState> emit,
  ) async {
    final currentState = state;
    if (currentState is! EventListSuccess || !currentState.hasMore) {
      return; // Don't fetch if already loading or no more pages
    }

    try {
      final response = await _eventRepository.getEvents(event.request, event.token);
      if (response.status && response.data != null) {
        // Append new events to existing list
        final newEvents = response.data!.events ?? <EventData>[];
        final updatedEvents = [
          ...currentState.allEvents,
          ...newEvents,
        ];
        
        emit(currentState.copyWith(
          response: response,
          allEvents: updatedEvents,
          currentPage: response.data!.page,
          hasMore: response.data!.page < response.data!.totalPages,
        ));
      } else {
        emit(EventListFailure(response.message));
      }
    } catch (e) {
      emit(EventListFailure(e.toString()));
    }
  }
}
