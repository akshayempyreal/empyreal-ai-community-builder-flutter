import 'package:flutter/material.dart';
import '../models/event.dart';
import '../theme/app_theme.dart';
import 'status_badge.dart';
import '../project_helpers.dart';


class EventCard extends StatelessWidget {
  final Event event;
  final VoidCallback onTap;

  const EventCard({
    super.key,
    required this.event,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event Image or Placeholder
            if (event.image != null && event.image!.isNotEmpty)
              Container(
                height: 140,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  image: DecorationImage(
                    image: NetworkImage(event.image!.fixImageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              )
            else
              Container(
                height: 140,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppTheme.indigo100,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: const Icon(Icons.image, color: AppTheme.primaryIndigo, size: 48),
              ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with status and type
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      StatusBadge(status: event.status),
                      Text(
                        event.type.upper,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.gray500,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  // Event name
                  Text(
                    event.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.gray900,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  
                  // Description
                  Text(
                    event.description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.gray600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),
                  
                  // Event details
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 14, color: AppTheme.gray600),
                      const SizedBox(width: 8),
                      Text(
                        _formatDate(event.date),
                        style: const TextStyle(fontSize: 13, color: AppTheme.gray600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 14, color: AppTheme.gray600),
                      const SizedBox(width: 8),
                      Text(
                        '${event.duration} hours / day',
                        style: const TextStyle(fontSize: 13, color: AppTheme.gray600),
                      ),
                    ],
                  ),
                  
                  if (event.attendeeCount != null) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.people, size: 14, color: AppTheme.gray600),
                        const SizedBox(width: 8),
                        Text(
                          '${event.attendeeCount} ${event.attendeeCount == 1 ? 'member' : 'members'}',
                          style: const TextStyle(fontSize: 13, color: AppTheme.gray600),
                        ),
                      ],
                    ),
                  ],
                  
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 8),
                  
                  // Planning mode badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppTheme.gray300),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      event.planningMode == 'automated' ? '🤖 AI Generated' : '✏️ Manual',
                      style: const TextStyle(fontSize: 11),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${months[date.month - 1]} ${date.day}, ${date.year}';
    } catch (e) {
      return dateStr;
    }
  }
}
