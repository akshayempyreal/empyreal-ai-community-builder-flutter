import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class ProfileFetched extends ProfileEvent {
  final String token;

  ProfileFetched(this.token);

  @override
  List<Object?> get props => [token];
}
