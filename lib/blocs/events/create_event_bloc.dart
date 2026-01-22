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
      name: d.containsKey('name') ? d['name'] : state.name,
      location: d.containsKey('location') ? d['location'] : state.location,
      description: d.containsKey('description') ? d['description'] : state.description,
      type: d.containsKey('type') ? d['type'] : state.type,
      startDate: d.containsKey('startDate') ? d['startDate'] : state.startDate,
      endDate: d.containsKey('endDate') ? d['endDate'] : state.endDate,
      startTime: d.containsKey('startTime') ? d['startTime'] : state.startTime,
      endTime: d.containsKey('endTime') ? d['endTime'] : state.endTime,
      duration: d.containsKey('duration') ? d['duration'] : state.duration,
      audienceSize: d.containsKey('audienceSize') ? d['audienceSize'] : state.audienceSize,
      planningMode: d.containsKey('planningMode') ? d['planningMode'] : state.planningMode,
      latitude: d.containsKey('latitude') ? d['latitude'] : state.latitude,
      longitude: d.containsKey('longitude') ? d['longitude'] : state.longitude,
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
