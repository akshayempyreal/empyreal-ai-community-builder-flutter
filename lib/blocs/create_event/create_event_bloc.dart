import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repositories/event_repository.dart';
import 'create_event_event.dart';
import 'create_event_state.dart';

class CreateEventBloc extends Bloc<CreateEventEvent, CreateEventState> {
  final EventRepository _eventRepository;

  CreateEventBloc(this._eventRepository) : super(CreateEventInitial()) {
    on<CreateEventSubmitted>(_onCreateEventSubmitted);
    on<CreateEventFileUploading>(_onFileUpload);
  }

  Future<void> _onCreateEventSubmitted(
    CreateEventSubmitted event,
    Emitter<CreateEventState> emit,
  ) async {
    emit(CreateEventLoading());
    try {
      final response = await _eventRepository.createEvent(event.request, event.token);
      if (response.status) {
        emit(CreateEventSuccess(response));
      } else {
        emit(CreateEventFailure(response.message));
      }
    } catch (e) {
      emit(CreateEventFailure(e.toString()));
    }
  }

  Future<void> _onFileUpload(
    CreateEventFileUploading event,
    Emitter<CreateEventState> emit,
  ) async {
    emit(CreateEventFileUploadLoading());
    try {
      final response = await _eventRepository.uploadFile(event.file, event.token);
      if (response.status && response.data != null && response.data!.isNotEmpty) {
        emit(CreateEventFileUploadSuccess(response.data![0].url));
      } else {
        emit(CreateEventFailure(response.message));
      }
    } catch (e) {
      emit(CreateEventFailure(e.toString()));
    }
  }
}
