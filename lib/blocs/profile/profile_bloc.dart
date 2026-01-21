import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repositories/auth_repository.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final AuthRepository _authRepository;

  ProfileBloc(this._authRepository) : super(ProfileInitial()) {
    on<ProfileFetched>(_onProfileFetched);
  }

  Future<void> _onProfileFetched(
    ProfileFetched event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    try {
      final response = await _authRepository.getProfile(event.token);
      if (response.status && response.data != null) {
        emit(ProfileSuccess(response.data!));
      } else {
        emit(ProfileFailure(response.message));
      }
    } catch (e) {
      emit(ProfileFailure(e.toString()));
    }
  }
}
