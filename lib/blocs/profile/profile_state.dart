import 'package:equatable/equatable.dart';
import '../../models/auth_models.dart';

abstract class ProfileState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileSuccess extends ProfileState {
  final UserModel user;

  ProfileSuccess(this.user);

  @override
  List<Object?> get props => [user];
}

class ProfileFailure extends ProfileState {
  final String error;

  ProfileFailure(this.error);

  @override
  List<Object?> get props => [error];
}
