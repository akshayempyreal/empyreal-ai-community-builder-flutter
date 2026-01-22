import '../../models/event_api_models.dart';

abstract class AttendeeState {}

class AttendeeInitial extends AttendeeState {}

class AttendeeLoading extends AttendeeState {}

class AttendeeSuccess extends AttendeeState {
  final MemberListResponse response;

  AttendeeSuccess(this.response);
}

class AttendeeFailure extends AttendeeState {
  final String error;

  AttendeeFailure(this.error);
}
