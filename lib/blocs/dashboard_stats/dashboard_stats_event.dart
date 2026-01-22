import 'package:equatable/equatable.dart';

abstract class DashboardStatsEvent extends Equatable {
  const DashboardStatsEvent();

  @override
  List<Object> get props => [];
}

class FetchDashboardStats extends DashboardStatsEvent {
  final String token;

  const FetchDashboardStats(this.token);

  @override
  List<Object> get props => [token];
}
