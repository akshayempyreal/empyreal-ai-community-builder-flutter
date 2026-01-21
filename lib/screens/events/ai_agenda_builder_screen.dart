import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../../models/event.dart';
import '../../models/agenda_item.dart';
import '../../theme/app_theme.dart';

class AIAgendaBuilderScreen extends StatelessWidget {
  final Event event;
  final Function(List<AgendaItem>) onSaveAgenda;
  final VoidCallback onBack;
  final User user;

  const AIAgendaBuilderScreen({
    super.key,
    required this.event,
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
        title: const Text('AI Agenda Builder'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.auto_awesome, size: 64, color: AppTheme.primaryIndigo),
            const SizedBox(height: 16),
            const Text('AI Agenda Builder', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('For event: ${event.name}', style: const TextStyle(color: AppTheme.gray600)),
          ],
        ),
      ),
    );
  }
}
