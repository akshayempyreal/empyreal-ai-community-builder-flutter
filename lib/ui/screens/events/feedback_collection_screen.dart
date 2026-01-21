import 'package:empyreal_ai_community_builder_flutter/models/event.dart';
import 'package:empyreal_ai_community_builder_flutter/models/feedback_response.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class FeedbackCollectionScreen extends StatelessWidget {
  final Event event;
  final Function(FeedbackResponse) onSubmitFeedback;
  final VoidCallback onBack;

  static final _mockFeedback = [
    FeedbackResponse(
      id: 'f1',
      attendeeId: '1',
      attendeeName: 'Alex Rivera',
      rating: 5,
      comments: 'The prompt engineering workshop was a game changer for my workflow.',
      submittedAt: '2h ago',
    ),
    FeedbackResponse(
      id: 'f2',
      attendeeId: '2',
      attendeeName: 'Sarah Chen',
      rating: 4,
      comments: 'Great event overall! The networking was excellent.',
      submittedAt: '5h ago',
    ),
  ];

  const FeedbackCollectionScreen({
    super.key,
    required this.event,
    required this.onSubmitFeedback,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: onBack,
        ),
        title: const Text('Feedback Hub'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatBanner(context, isDark),
            const SizedBox(height: 32),
            Text(
              'Recent Reviews',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ..._mockFeedback.map((f) => _buildFeedbackCard(context, f, isDark)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBanner(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(label: 'Avg Rating', value: '4.8', icon: Icons.star),
          _StatItem(label: 'Responses', value: '24', icon: Icons.chat_bubble_outline),
        ],
      ),
    );
  }

  Widget _buildFeedbackCard(BuildContext context, FeedbackResponse feedback, bool isDark) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: Text(feedback.attendeeName[0]),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(feedback.attendeeName, style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(feedback.submittedAt, style: TextStyle(color: AppColors.slate500, fontSize: 12)),
                    ],
                  ),
                ),
                Row(
                  children: List.generate(5, (index) => Icon(
                    Icons.star,
                    size: 16,
                    color: index < feedback.rating ? AppColors.warning : AppColors.slate300,
                  )),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              feedback.comments,
              style: const TextStyle(height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatItem({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white.withOpacity(0.8), size: 24),
        const SizedBox(height: 8),
        Text(value, style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w400)),
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12)),
      ],
    );
  }
}
