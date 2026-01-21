import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../../models/event.dart';
import '../../models/agenda_item.dart';
import '../../theme/app_theme.dart';

class ManualAgendaEditorScreen extends StatelessWidget {
  final Event event;
  final List<AgendaItem> existingAgenda;
  final Function(List<AgendaItem>) onSaveAgenda;
  final VoidCallback onBack;
  final User user;

  const ManualAgendaEditorScreen({
    super.key,
    required this.event,
    required this.existingAgenda,
    required this.onSaveAgenda,
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
        title: const Text('Manual Agenda Editor'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.edit, size: 64, color: AppTheme.primaryPurple),
            const SizedBox(height: 16),
            const Text('Manual Agenda Editor', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('For event: ${event.name}', style: const TextStyle(color: AppTheme.gray600)),
          ],
        ),
      ),
    );
  }
}
