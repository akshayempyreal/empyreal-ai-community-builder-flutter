import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:math' as math;
import '../../models/user.dart';
import '../../models/event.dart';
import '../../models/agenda_item.dart';
import '../../models/attendee.dart';
import '../../theme/app_theme.dart';
import '../../widgets/status_badge.dart';

class EventDetailsScreen extends StatelessWidget {
  final Event event;
  final List<AgendaItem> agendaItems;
  final List<Attendee> attendees;
  final Function(String) onNavigate;
  final VoidCallback onBack;
  final User user;

  const EventDetailsScreen({
    super.key,
    required this.event,
    required this.agendaItems,
    required this.attendees,
    required this.onNavigate,
    required this.onBack,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Scaffold(
      backgroundColor: AppTheme.gray50,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: onBack,
        ),
        title: const Text('Event Details'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              backgroundColor: AppTheme.indigo100,
              child: Text(
                user.name[0].toUpperCase(),
                style: const TextStyle(color: AppTheme.primaryIndigo),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, viewport) {
            // Web: use full width. Mobile: full-width with smaller gutters.
            final useFullWidth = kIsWeb && viewport.maxWidth >= 700;
            final horizontalPadding =
                isMobile ? 16.0 : viewport.maxWidth < 900 ? 24.0 : 32.0;

            // Effective content width after constraints + padding (used for grid breakpoints).
            final effectiveWidth =
                (viewport.maxWidth - (horizontalPadding * 2)).clamp(0.0, double.infinity);

            // Smooth grid scaling on large screens (web/desktop).
            // Approx 320px min card width + gaps/padding.
            final computedCount = math.max(1, (effectiveWidth / 320).floor());
            final crossAxisCount = isMobile ? 1 : computedCount.clamp(1, 4);

            final headerPadding = isMobile ? 16.0 : 24.0;
            final titleSize = isMobile ? 22.0 : 28.0;

            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                16,
                horizontalPadding,
                24,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  // On web/desktop we want the content to span the full width
                  // inside the padding; on smaller screens we keep it natural.
                  minWidth: useFullWidth ? double.infinity : 0,
                  maxWidth: useFullWidth ? double.infinity : 860,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                      // Event header
                      Card(
                        child: Padding(
                          padding: EdgeInsets.all(headerPadding),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  StatusBadge(status: event.status),
                                  Text(
                                    event.type,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.gray500,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                event.name,
                                style: TextStyle(
                                  fontSize: titleSize,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.gray900,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                event.description,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: AppTheme.gray600,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Wrap(
                                spacing: 20,
                                runSpacing: 12,
                                children: [
                                  _buildInfoItem(
                                    Icons.calendar_today,
                                    _formatDate(event.date),
                                  ),
                                  _buildInfoItem(
                                    Icons.access_time,
                                    '${event.duration} hours',
                                  ),
                                  if (event.attendeeCount != null)
                                    _buildInfoItem(
                                      Icons.people,
                                      '${event.attendeeCount} attendees',
                                    ),
                                  _buildInfoItem(
                                    event.planningMode == 'automated'
                                        ? Icons.auto_awesome
                                        : Icons.edit,
                                    event.planningMode == 'automated' ? 'AI Generated' : 'Manual',
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Action cards grid
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: crossAxisCount,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: crossAxisCount == 1
                            ? 1.9
                            : crossAxisCount >= 4
                                ? 1.1
                                : 1.35,
                        children: [
                          _buildActionCard(
                            context,
                            title: 'Agenda',
                            subtitle: '${agendaItems.length} items',
                            icon: Icons.list_alt,
                            iconColor: AppTheme.primaryIndigo,
                            iconBg: AppTheme.indigo100,
                            onTap: () => onNavigate('agenda-view'),
                          ),
                          _buildActionCard(
                            context,
                            title: 'Attendees',
                            subtitle: '${attendees.length} registered',
                            icon: Icons.people,
                            iconColor: AppTheme.green600,
                            iconBg: AppTheme.statusOngoing,
                            onTap: () => onNavigate('attendees'),
                          ),
                          _buildActionCard(
                            context,
                            title: 'Feedback',
                            subtitle: 'Collect responses',
                            icon: Icons.feedback,
                            iconColor: AppTheme.primaryPurple,
                            iconBg: AppTheme.statusCompleted,
                            onTap: () => onNavigate('feedback-collection'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppTheme.gray600),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(fontSize: 14, color: AppTheme.gray600),
        ),
      ],
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.gray900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.gray600,
                    ),
                  ),
                ],
              ),
            ],
          ),
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
