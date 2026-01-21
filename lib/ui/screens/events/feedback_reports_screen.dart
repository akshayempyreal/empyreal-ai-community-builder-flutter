import 'package:empyreal_ai_community_builder_flutter/models/event.dart';
import 'package:empyreal_ai_community_builder_flutter/models/feedback_response.dart';
import 'package:empyreal_ai_community_builder_flutter/models/user.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

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
            const Icon(Icons.bar_chart, size: 64, color: AppColors.info),
            const SizedBox(height: 16),
            const Text('Feedback Reports', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('${feedbackResponses.length} responses', style: const TextStyle(color: AppColors.gray600)),
          ],
        ),
      ),
    );
  }
}
