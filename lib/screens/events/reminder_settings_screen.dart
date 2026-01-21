import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../../models/event.dart';
import '../../models/reminder.dart';
import '../../theme/app_theme.dart';

class ReminderSettingsScreen extends StatelessWidget {
  final Event event;
  final List<Reminder> reminders;
  final Function(List<Reminder>) onUpdateReminders;
  final VoidCallback onBack;
  final User user;

  const ReminderSettingsScreen({
    super.key,
    required this.event,
    required this.reminders,
    required this.onUpdateReminders,
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
        title: const Text('Reminder Settings'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.notifications, size: 64, color: Color(0xFFEAB308)),
            const SizedBox(height: 16),
            const Text('Reminder Settings', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('${reminders.length} reminders', style: const TextStyle(color: AppTheme.gray600)),
          ],
        ),
      ),
    );
  }
}
