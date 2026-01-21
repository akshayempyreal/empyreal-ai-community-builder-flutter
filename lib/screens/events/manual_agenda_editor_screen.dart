import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/user.dart';
import '../../models/event.dart';
import '../../models/agenda_item.dart';
import '../../models/session_models.dart';
import '../../theme/app_theme.dart';
import '../../blocs/agenda/agenda_bloc.dart';
import '../../repositories/event_repository.dart';
import '../../services/api_client.dart';
import '../../project_helpers.dart';

class ManualAgendaEditorScreen extends StatefulWidget {
  final Event event;
  final List<AgendaItem> existingAgenda;
  final Function(List<AgendaItem>) onSaveAgenda;
  final VoidCallback onBack;
  final User user;
  final String token;

  const ManualAgendaEditorScreen({
    super.key,
    required this.event,
    required this.existingAgenda,
    required this.onSaveAgenda,
    required this.onBack,
    required this.user,
    required this.token,
  });

  @override
  State<ManualAgendaEditorScreen> createState() => _ManualAgendaEditorScreenState();
}

class _ManualAgendaEditorScreenState extends State<ManualAgendaEditorScreen> {
  int _selectedDayIndex = 0;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AgendaBloc(EventRepository(ApiClient())),
      child: BlocConsumer<AgendaBloc, AgendaState>(
        listener: (context, state) {
          if (state is AgendaFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            backgroundColor: AppTheme.gray50,
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: widget.onBack,
              ),
              title: Text(state is AgendaSuccess ? 'Event Agenda' : 'Event Created Successfully'),
              backgroundColor: Colors.white,
              foregroundColor: AppTheme.gray900,
              elevation: 0,
            ),
            body: state is AgendaLoading
                ? const Center(child: CircularProgressIndicator())
                : state is AgendaSuccess
                    ? _buildSessionsView(state.response.data!)
                    : _buildInitialEventDetails(context),
          );
        },
      ),
    );
  }

  Widget _buildInitialEventDetails(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green, size: 32),
                      SizedBox(width: 12),
                      Text(
                        'Event Details',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const Divider(height: 32),
                  _buildDetailRow('Event Name', widget.event.name),
                  _buildDetailRow('Description', widget.event.description),
                  _buildDetailRow('Location', widget.event.location),
                  _buildDetailRow('Event Type', widget.event.type),
                  Row(
                    children: [
                      Expanded(child: _buildDetailRow('Start Date', _formatDate(widget.event.date))),
                      Expanded(child: _buildDetailRow('End Date', widget.event.endDate != null ? _formatDate(widget.event.endDate!) : 'N/A')),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(child: _buildDetailRow('Hours per Day', '${widget.event.duration} hours')),
                      Expanded(child: _buildDetailRow('Expected Audience', '${widget.event.audienceSize ?? 0}')),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          Center(
            child: ElevatedButton(
              onPressed: () {
                context.read<AgendaBloc>().add(
                      GenerateSessionsRequested(eventId: widget.event.id, token: widget.token),
                    );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Create Agenda'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionsView(SessionData data) {
    final currentDay = data.sessions[_selectedDayIndex];

    return Column(
      children: [
        // Day selector
        Container(
          height: 100,
          padding: const EdgeInsets.symmetric(vertical: 16),
          color: Colors.white,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: data.sessions.length,
            itemBuilder: (context, index) {
              final isSelected = _selectedDayIndex == index;
              return GestureDetector(
                onTap: () => setState(() => _selectedDayIndex = index),
                child: Container(
                  width: 80,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.primaryIndigo : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isSelected ? AppTheme.primaryIndigo : AppTheme.gray300),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Day',
                        style: TextStyle(
                          color: isSelected ? Colors.white70 : AppTheme.gray500,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: isSelected ? Colors.white : AppTheme.gray900,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        // Session list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: currentDay.sessions.length,
            itemBuilder: (context, index) {
              final session = currentDay.sessions[index];
              return _buildSessionCard(session);
            },
          ),
        ),

        // Bottom Action
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => widget.onSaveAgenda([]),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Go to Dashboard'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSessionCard(SessionItem session) {
    final startTime = _formatTime(session.startDateTime);
    final endTime = _formatTime(session.endDateTime);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Time column
          SizedBox(
            width: 80,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  startTime,
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.gray900),
                ),
                Text(
                  endTime,
                  style: const TextStyle(fontSize: 12, color: AppTheme.gray500),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Timeline indicator
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  color: AppTheme.primaryIndigo,
                  shape: BoxShape.circle,
                ),
              ),
              Container(
                width: 2,
                height: 100, // Approximate height
                color: AppTheme.indigo100,
              ),
            ],
          ),
          const SizedBox(width: 16),
          // Content card
          Expanded(
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      session.sessionTitle,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      session.sessionDescription,
                      style: const TextStyle(color: AppTheme.gray600, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 14, color: AppTheme.primaryIndigo),
                        const SizedBox(width: 4),
                        Text(
                          '${session.durationMinutes} min',
                          style: const TextStyle(fontSize: 12, color: AppTheme.primaryIndigo),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14, color: AppTheme.gray500, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 16, color: AppTheme.gray900, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateStr;
    }
  }

  String _formatTime(String dateTimeStr) {
    try {
      final dateTime = DateTime.parse(dateTimeStr);
      final hour = dateTime.hour > 12 ? dateTime.hour - 12 : (dateTime.hour == 0 ? 12 : dateTime.hour);
      final minute = dateTime.minute.toString().padLeft(2, '0');
      final period = dateTime.hour >= 12 ? 'PM' : 'AM';
      return '$hour:$minute $period';
    } catch (e) {
      return dateTimeStr;
    }
  }
}
