import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repositories/auth_repository.dart';
import '../../models/auth_models.dart';
import '../../services/notification_service.dart';
import 'login_event.dart';
import 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthRepository _authRepository;

  LoginBloc(this._authRepository) : super(LoginInitial()) {
    on<LoginSubmitted>(_onLoginSubmitted);
  }

  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    emit(LoginLoading());
    try {
      final String? deviceToken = await NotificationService().getToken();
      String deviceType = 'Web';
      if (!kIsWeb) {
        deviceType = Platform.isAndroid ? 'Android' : 'iOS';
      }

      final request = LoginRequest(
        mobileNo: event.mobileNo,
        deviceToken: deviceToken ?? '',
        deviceType: deviceType,
      );
      final response = await _authRepository.login(request);
      if (response.status) {
        emit(LoginSuccess(response));
      } else {
        emit(LoginFailure(response.message));
      }
    } catch (e) {
      emit(LoginFailure(e.toString()));
    }
  }
}
