import 'package:equatable/equatable.dart';

abstract class OtpEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class OtpSubmitted extends OtpEvent {
  final String userId;
  final String otp;

  OtpSubmitted({required this.userId, required this.otp});

  @override
  List<Object?> get props => [userId, otp];
}

class OtpResendRequested extends OtpEvent {
  final String mobileNo;

  OtpResendRequested({required this.mobileNo});

  @override
  List<Object?> get props => [mobileNo];
}
