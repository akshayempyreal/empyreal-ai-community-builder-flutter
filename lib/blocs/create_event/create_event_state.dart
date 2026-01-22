import 'package:equatable/equatable.dart';
import '../../models/event_api_models.dart';

abstract class CreateEventState extends Equatable {
  const CreateEventState();
  
  @override
  List<Object> get props => [];
}

class CreateEventInitial extends CreateEventState {}

class CreateEventLoading extends CreateEventState {}

class CreateEventSuccess extends CreateEventState {
  final CreateEventResponse response;

  const CreateEventSuccess(this.response);

  @override
  List<Object> get props => [response];
}

class CreateEventFailure extends CreateEventState {
  final String error;

  const CreateEventFailure(this.error);

  @override
  List<Object> get props => [error];
}

class CreateEventFileUploadLoading extends CreateEventState {}

class CreateEventFileUploadSuccess extends CreateEventState {
  final String fileUrl;

  const CreateEventFileUploadSuccess(this.fileUrl);

  @override
  List<Object> get props => [fileUrl];
}
