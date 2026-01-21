import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../../models/event.dart';
import '../../models/attendee.dart';
import '../../theme/app_theme.dart';

class AttendeeManagementScreen extends StatelessWidget {
  final Event event;
  final List<Attendee> attendees;
  final Function(Attendee) onAddAttendee;
  final VoidCallback onBack;
  final User user;

  const AttendeeManagementScreen({
    super.key,
    required this.event,
    required this.attendees,
    required this.onAddAttendee,
    required this.onBack,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: onBack,
        ),
        title: const Text('Attendee Management'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.people, size: 64, color: AppTheme.green600),
            const SizedBox(height: 16),
            const Text('Attendee Management', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('${attendees.length} attendees', style: const TextStyle(color: AppTheme.gray600)),
          ],
        ),
      ),
    );
  }
}
