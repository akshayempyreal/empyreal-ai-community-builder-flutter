import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;
    String label;

    switch (status.toLowerCase()) {
      case 'draft':
        backgroundColor = AppColors.statusDraft;
        textColor = AppColors.statusDraftText;
        label = 'Draft';
        break;
      case 'published':
        backgroundColor = AppColors.statusPublished;
        textColor = AppColors.statusPublishedText;
        label = 'Published';
        break;
      case 'ongoing':
        backgroundColor = AppColors.statusOngoing;
        textColor = AppColors.statusOngoingText;
        label = 'Ongoing';
        break;
      case 'upcoming':
        backgroundColor = Colors.blue.withOpacity(0.1);
        textColor = Colors.blue.shade700;
        label = 'Upcoming';
        break;
      case 'past':
        backgroundColor = Colors.grey.withOpacity(0.1);
        textColor = Colors.grey.shade700;
        label = 'Past';
        break;
      case 'completed':
        backgroundColor = AppColors.statusCompleted;
        textColor = AppColors.statusCompletedText;
        label = 'Completed';
        break;
      default:
        backgroundColor = AppColors.statusDraft;
        textColor = AppColors.statusDraftText;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
