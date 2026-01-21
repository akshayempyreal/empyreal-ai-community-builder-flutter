import 'package:flutter/material.dart';
import '../../models/event.dart';
import '../../models/feedback_response.dart';
import '../../theme/app_theme.dart';

class FeedbackCollectionScreen extends StatelessWidget {
  final Event event;
  final Function(FeedbackResponse) onSubmitFeedback;
  final VoidCallback onBack;

  const FeedbackCollectionScreen({
    super.key,
    required this.event,
    required this.onSubmitFeedback,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: onBack,
        ),
        title: const Text('Feedback Collection'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.feedback, size: 64, color: AppTheme.primaryPurple),
            const SizedBox(height: 16),
            const Text('Feedback Collection', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('For event: ${event.name}', style: const TextStyle(color: AppTheme.gray600)),
          ],
        ),
      ),
    );
  }
}
