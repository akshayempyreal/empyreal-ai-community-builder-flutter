import 'package:equatable/equatable.dart';
import '../../models/auth_models.dart';

abstract class CompleteProfileState extends Equatable {
  @override
  List<Object?> get props => [];
}

class CompleteProfileInitial extends CompleteProfileState {}

class CompleteProfileLoading extends CompleteProfileState {}

class CompleteProfileSuccess extends CompleteProfileState {
  final UpdateProfileResponse response;

  CompleteProfileSuccess(this.response);

  @override
  List<Object?> get props => [response];
}

class CompleteProfileFailure extends CompleteProfileState {
  final String error;

  CompleteProfileFailure(this.error);

  @override
  List<Object?> get props => [error];
}
