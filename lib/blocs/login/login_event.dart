import 'package:equatable/equatable.dart';
import '../../models/auth_models.dart';

abstract class LoginEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoginSubmitted extends LoginEvent {
  final String mobileNo;

  LoginSubmitted({required this.mobileNo});

  @override
  List<Object?> get props => [mobileNo];
}
