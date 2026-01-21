import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repositories/auth_repository.dart';
import 'complete_profile_event.dart';
import 'complete_profile_state.dart';

class CompleteProfileBloc extends Bloc<CompleteProfileEvent, CompleteProfileState> {
  final AuthRepository _authRepository;

  CompleteProfileBloc(this._authRepository) : super(CompleteProfileInitial()) {
    on<ProfileSubmitted>(_onProfileSubmitted);
  }

  Future<void> _onProfileSubmitted(
    ProfileSubmitted event,
    Emitter<CompleteProfileState> emit,
  ) async {
    emit(CompleteProfileLoading());
    try {
      String profilePicUrl = "";
      
      // 1. Upload file if path exists
      if (event.imageFile != null) {
        final uploadResponse = await _authRepository.uploadFile(event.imageFile!, event.token);
        if (uploadResponse.status && uploadResponse.data != null && uploadResponse.data!.isNotEmpty) {
          profilePicUrl = uploadResponse.data!.first.url;
        } else {
          emit(CompleteProfileFailure(uploadResponse.message));
          return;
        }
      }

      // 2. Update profile
      final response = await _authRepository.updateProfile(
        event.userId,
        event.name,
        profilePicUrl,
        event.token,
      );

      if (response.status) {
        emit(CompleteProfileSuccess(response));
      } else {
        emit(CompleteProfileFailure(response.message));
      }
    } catch (e) {
      emit(CompleteProfileFailure(e.toString()));
    }
  }
}
