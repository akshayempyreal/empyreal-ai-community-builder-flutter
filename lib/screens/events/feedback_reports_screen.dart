import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../../models/event.dart';
import '../../models/feedback_response.dart';
import '../../theme/app_theme.dart';

class FeedbackReportsScreen extends StatelessWidget {
  final Event event;
  final List<FeedbackResponse> feedbackResponses;
  final VoidCallback onBack;
  final User user;

  const FeedbackReportsScreen({
    super.key,
    required this.event,
    required this.feedbackResponses,
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
        title: const Text('Feedback Reports'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.bar_chart, size: 64, color: AppTheme.blue600),
            const SizedBox(height: 16),
            const Text('Feedback Reports', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('${feedbackResponses.length} responses', style: const TextStyle(color: AppTheme.gray600)),
          ],
        ),
      ),
    );
  }
}
