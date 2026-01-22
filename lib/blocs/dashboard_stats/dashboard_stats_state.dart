import 'package:equatable/equatable.dart';
import '../../models/event_api_models.dart';

abstract class DashboardStatsState extends Equatable {
  const DashboardStatsState();

  @override
  List<Object> get props => [];
}

class DashboardStatsInitial extends DashboardStatsState {}

class DashboardStatsLoading extends DashboardStatsState {}

class DashboardStatsLoaded extends DashboardStatsState {
  final DashboardCountsData stats;

  const DashboardStatsLoaded(this.stats);

  @override
  List<Object> get props => [stats];
}

class DashboardStatsError extends DashboardStatsState {
  final String error;

  const DashboardStatsError(this.error);

  @override
  List<Object> get props => [error];
}
