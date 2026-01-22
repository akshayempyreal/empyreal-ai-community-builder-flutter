import 'package:equatable/equatable.dart';
import '../../models/event_api_models.dart';

abstract class EventActionsState extends Equatable {
  const EventActionsState();

  @override
  List<Object?> get props => [];
}

class EventActionsInitial extends EventActionsState {}

class EventActionLoading extends EventActionsState {}

class EventJoinLeaveSuccess extends EventActionsState {
  final CreateEventResponse response;

  const EventJoinLeaveSuccess(this.response);

  @override
  List<Object?> get props => [response];
}

class EventActionFailure extends EventActionsState {
  final String error;

  const EventActionFailure(this.error);

  @override
  List<Object?> get props => [error];
}
