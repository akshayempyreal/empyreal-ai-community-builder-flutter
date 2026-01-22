import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repositories/event_repository.dart';
import 'dashboard_stats_event.dart';
import 'dashboard_stats_state.dart';

class DashboardStatsBloc extends Bloc<DashboardStatsEvent, DashboardStatsState> {
  final EventRepository _eventRepository;

  DashboardStatsBloc(this._eventRepository) : super(DashboardStatsInitial()) {
    on<FetchDashboardStats>(_onFetchDashboardStats);
  }

  Future<void> _onFetchDashboardStats(
    FetchDashboardStats event,
    Emitter<DashboardStatsState> emit,
  ) async {
    emit(DashboardStatsLoading());
    try {
      final response = await _eventRepository.getDashboardCounts(event.token);
      if (response.status && response.data != null) {
        emit(DashboardStatsLoaded(response.data!));
      } else {
        emit(DashboardStatsError(response.message));
      }
    } catch (e) {
      emit(DashboardStatsError(e.toString()));
    }
  }
}
