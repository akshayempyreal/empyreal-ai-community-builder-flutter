import 'package:equatable/equatable.dart';
import '../../models/auth_models.dart';

abstract class OtpState extends Equatable {
  @override
  List<Object?> get props => [];
}

class OtpInitial extends OtpState {}

class OtpLoading extends OtpState {}

class OtpSuccess extends OtpState {
  final VerifyOtpResponse response;

  OtpSuccess(this.response);

  @override
  List<Object?> get props => [response];
}

class OtpFailure extends OtpState {
  final String error;

  OtpFailure(this.error);

  @override
  List<Object?> get props => [error];
}

class OtpResendSuccess extends OtpState {
  final String message;

  OtpResendSuccess(this.message);

  @override
  List<Object?> get props => [message];
}
