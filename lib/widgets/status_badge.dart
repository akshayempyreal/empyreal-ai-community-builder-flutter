import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

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
        backgroundColor = AppTheme.statusDraft;
        textColor = AppTheme.statusDraftText;
        label = 'Draft';
        break;
      case 'published':
        backgroundColor = AppTheme.statusPublished;
        textColor = AppTheme.statusPublishedText;
        label = 'Published';
        break;
      case 'ongoing':
        backgroundColor = AppTheme.statusOngoing;
        textColor = AppTheme.statusOngoingText;
        label = 'Ongoing';
        break;
      case 'completed':
        backgroundColor = AppTheme.statusCompleted;
        textColor = AppTheme.statusCompletedText;
        label = 'Completed';
        break;
      default:
        backgroundColor = AppTheme.statusDraft;
        textColor = AppTheme.statusDraftText;
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
