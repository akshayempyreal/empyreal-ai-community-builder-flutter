import 'package:equatable/equatable.dart';

abstract class EventActionsEvent extends Equatable {
  const EventActionsEvent();

  @override
  List<Object?> get props => [];
}

class ToggleJoinLeave extends EventActionsEvent {
  final String eventId;
  final String token;

  const ToggleJoinLeave({required this.eventId, required this.token});

  @override
  List<Object?> get props => [eventId, token];
}
