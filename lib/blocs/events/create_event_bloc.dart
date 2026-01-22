import 'package:flutter_bloc/flutter_bloc.dart';
import 'create_event_event.dart';
import 'create_event_state.dart';

class CreateEventBloc extends Bloc<CreateEventEvent, CreateEventState> {
  CreateEventBloc() : super(const CreateEventState()) {
    on<UpdateEventDetails>(_onUpdateDetails);
    on<ChangeStep>(_onChangeStep);
    on<SubmitEvent>(_onSubmit);
  }

  void _onUpdateDetails(UpdateEventDetails event, Emitter<CreateEventState> emit) {
    final d = event.details;
    emit(state.copyWith(
      name: d['name'],
      location: d['location'],
      description: d['description'],
      type: d['type'],
      startDate: d['startDate'],
      endDate: d['endDate'],
      duration: d['duration'],
      audienceSize: d['audienceSize'],
      planningMode: d['planningMode'],
      latitude: d['latitude'],
      longitude: d['longitude'],
    ));
  }

  void _onChangeStep(ChangeStep event, Emitter<CreateEventState> emit) {
    emit(state.copyWith(currentStep: event.step));
  }

  void _onSubmit(SubmitEvent event, Emitter<CreateEventState> emit) async {
    emit(state.copyWith(status: CreateEventStatus.loading));
    try {
      // Logic for creation would go here (calling repository)
      // For now, satisfy the UI
      await Future.delayed(const Duration(seconds: 1));
      emit(state.copyWith(status: CreateEventStatus.success));
    } catch (e) {
      emit(state.copyWith(
        status: CreateEventStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }
}
