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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: onBack,
        ),
        title: const Text('Analytics'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildChartPlaceholder(context, isDark),
            const SizedBox(height: 24),
            _buildSentimentAnalysis(context, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildChartPlaceholder(BuildContext context, bool isDark) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Satisfaction Trend', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                Icon(Icons.trending_up, color: AppColors.success),
              ],
            ),
            const SizedBox(height: 40),
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: isDark ? AppColors.slate900 : AppColors.slate50,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Icon(Icons.show_chart, size: 64, color: AppColors.primary.withOpacity(0.3)),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '${feedbackResponses.length} total responses analyzed',
              style: TextStyle(color: AppColors.slate500, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSentimentAnalysis(BuildContext context, bool isDark) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('AI Sentiment Analysis', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 20),
            _SentimentProgress(label: 'Positive', percentage: 0.85, color: AppColors.success),
            const SizedBox(height: 16),
            _SentimentProgress(label: 'Neutral', percentage: 0.10, color: AppColors.info),
            const SizedBox(height: 16),
            _SentimentProgress(label: 'Critical', percentage: 0.05, color: AppColors.error),
          ],
        ),
      ),
    );
  }
}

class _SentimentProgress extends StatelessWidget {
  final String label;
  final double percentage;
  final Color color;

  const _SentimentProgress({required this.label, required this.percentage, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            Text('${(percentage * 100).toInt()}%', style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percentage,
            backgroundColor: color.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }
}
