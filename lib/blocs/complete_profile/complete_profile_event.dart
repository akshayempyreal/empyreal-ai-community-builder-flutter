import 'package:equatable/equatable.dart';

import 'package:image_picker/image_picker.dart';

abstract class CompleteProfileEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class ProfileSubmitted extends CompleteProfileEvent {
  final String userId;
  final String name;
  final XFile? imageFile;
  final String token;

  ProfileSubmitted({
    required this.userId,
    required this.name,
    this.imageFile,
    required this.token,
  });

  @override
  List<Object?> get props => [userId, name, imageFile, token];
}
