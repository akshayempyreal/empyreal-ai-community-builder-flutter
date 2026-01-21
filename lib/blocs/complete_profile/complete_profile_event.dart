import 'package:equatable/equatable.dart';

abstract class CompleteProfileEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class ProfileSubmitted extends CompleteProfileEvent {
  final String userId;
  final String name;
  final String? filePath;
  final String token;

  ProfileSubmitted({
    required this.userId,
    required this.name,
    this.filePath,
    required this.token,
  });

  @override
  List<Object?> get props => [userId, name, filePath, token];
}
