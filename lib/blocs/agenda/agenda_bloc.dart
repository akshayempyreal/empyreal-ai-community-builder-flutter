import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../models/session_models.dart';
import '../../repositories/event_repository.dart';

// Events
abstract class AgendaEvent extends Equatable {
  const AgendaEvent();
  @override
  List<Object> get props => [];
}

class GenerateSessionsRequested extends AgendaEvent {
  final String eventId;
  final String token;

  const GenerateSessionsRequested({required this.eventId, required this.token});

  @override
  List<Object> get props => [eventId, token];
}

// States
abstract class AgendaState extends Equatable {
  const AgendaState();
  @override
  List<Object> get props => [];
}

class AgendaInitial extends AgendaState {}

class AgendaLoading extends AgendaState {}

class AgendaSuccess extends AgendaState {
  final GenerateSessionsResponse response;
  const AgendaSuccess(this.response);
  @override
  List<Object> get props => [response];
}

class AgendaFailure extends AgendaState {
  final String error;
  const AgendaFailure(this.error);
  @override
  List<Object> get props => [error];
}

// Bloc
class AgendaBloc extends Bloc<AgendaEvent, AgendaState> {
  final EventRepository _eventRepository;

  AgendaBloc(this._eventRepository) : super(AgendaInitial()) {
    on<GenerateSessionsRequested>(_onGenerateSessionsRequested);
  }

  Future<void> _onGenerateSessionsRequested(
    GenerateSessionsRequested event,
    Emitter<AgendaState> emit,
  ) async {
    emit(AgendaLoading());
    try {
      final response = await _eventRepository.generateSessions(event.eventId, event.token);
      if (response.status) {
        emit(AgendaSuccess(response));
      } else {
        emit(AgendaFailure(response.message));
      }
    } catch (e) {
      emit(AgendaFailure(e.toString()));
    }
  }
}
