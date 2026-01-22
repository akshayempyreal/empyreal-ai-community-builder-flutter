import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repositories/auth_repository.dart';
import '../../models/auth_models.dart';
import '../../services/notification_service.dart';
import 'otp_event.dart';
import 'otp_state.dart';

class OtpBloc extends Bloc<OtpEvent, OtpState> {
  final AuthRepository _authRepository;

  OtpBloc(this._authRepository) : super(OtpInitial()) {
    on<OtpSubmitted>(_onOtpSubmitted);
    on<OtpResendRequested>(_onOtpResendRequested);
  }

  Future<void> _onOtpSubmitted(
    OtpSubmitted event,
    Emitter<OtpState> emit,
  ) async {
    emit(OtpLoading());
    try {
      final request = VerifyOtpRequest(userId: event.userId, otp: event.otp);
      final response = await _authRepository.verifyOtp(request);
      if (response.status) {
        emit(OtpSuccess(response));
      } else {
        emit(OtpFailure(response.message));
      }
    } catch (e) {
      emit(OtpFailure(e.toString()));
    }
  }

  Future<void> _onOtpResendRequested(
    OtpResendRequested event,
    Emitter<OtpState> emit,
  ) async {
    // Re-use login API for resending OTP
    emit(OtpLoading()); // Emit loading state
    try {
      String? deviceToken;
      try {
        deviceToken = await NotificationService().getToken();
      } catch (e) {
        // If token retrieval fails, continue with empty token
        if (kDebugMode) {
          print('OTP: Failed to get device token: $e');
        }
        deviceToken = null;
      }
      
      String deviceType = 'Web';
      if (!kIsWeb) {
        deviceType = defaultTargetPlatform == TargetPlatform.android ? 'Android' : 'iOS';
      }

      final request = LoginRequest(
        mobileNo: event.mobileNo,
        deviceToken: deviceToken ?? '',
        deviceType: deviceType,
      );
      final response = await _authRepository.login(request);
      if (response.status) {
        emit(OtpResendSuccess(response.message));
      } else {
        emit(OtpFailure(response.message));
      }
    } catch (e) {
      if (kDebugMode) {
        print('OTP Resend Error: $e');
      }
      emit(OtpFailure(e.toString()));
    }
  }
}
