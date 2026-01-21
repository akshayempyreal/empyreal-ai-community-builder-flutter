import 'package:equatable/equatable.dart';
import '../../models/event.dart';

abstract class CreateEventEvent extends Equatable {
  const CreateEventEvent();

  @override
  List<Object?> get props => [];
}

class UpdateEventDetails extends CreateEventEvent {
  final Map<String, dynamic> details;
  const UpdateEventDetails(this.details);

  @override
  List<Object?> get props => [details];
}

class ChangeStep extends CreateEventEvent {
  final int step;
  const ChangeStep(this.step);

  @override
  List<Object?> get props => [step];
}

class SubmitEvent extends CreateEventEvent {
  const SubmitEvent();
}
