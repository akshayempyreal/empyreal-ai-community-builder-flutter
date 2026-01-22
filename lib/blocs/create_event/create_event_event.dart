import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/event_api_models.dart';

abstract class CreateEventEvent extends Equatable {
  const CreateEventEvent();

  @override
  List<Object> get props => [];
}

class CreateEventSubmitted extends CreateEventEvent {
  final CreateEventRequest request;
  final String token;

  const CreateEventSubmitted({required this.request, required this.token});

  @override
  List<Object> get props => [request, token];
}

class UpdateEventSubmitted extends CreateEventEvent {
  final UpdateEventRequest request;
  final String token;

  const UpdateEventSubmitted({required this.request, required this.token});

  @override
  List<Object> get props => [request, token];
}

class CreateEventFileUploading extends CreateEventEvent {
  final XFile file;
  final String token;

  const CreateEventFileUploading({required this.file, required this.token});

  @override
  List<Object> get props => [file, token];
}
