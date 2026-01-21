import 'package:flutter/material.dart';
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Event header
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
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
                          style: const TextStyle(
                            fontSize: 28,
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
                        const SizedBox(height: 24),
                        Wrap(
                          spacing: 24,
                          runSpacing: 16,
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
                              event.planningMode == 'automated' ? Icons.auto_awesome : Icons.edit,
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
                LayoutBuilder(
                  builder: (context, constraints) {
                    final crossAxisCount = constraints.maxWidth > 800 ? 3 : constraints.maxWidth > 500 ? 2 : 1;
                    return GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: crossAxisCount,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 1.3,
                      children: [
                        _buildActionCard(
                          context,
                          title: 'Agenda',
                          subtitle: '${agendaItems.length} items',
                          icon: Icons.list_alt,
                          iconColor: AppTheme.primaryIndigo,
                          iconBg: AppTheme.indigo100,
                          onTap: () => onNavigate(event.planningMode == 'automated' ? 'ai-agenda' : 'manual-agenda'),
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
                          title: 'Reminders',
                          subtitle: 'Manage notifications',
                          icon: Icons.notifications,
                          iconColor: const Color(0xFFEAB308),
                          iconBg: const Color(0xFFFEF3C7),
                          onTap: () => onNavigate('reminders'),
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
                        _buildActionCard(
                          context,
                          title: 'Reports',
                          subtitle: 'View analytics',
                          icon: Icons.bar_chart,
                          iconColor: AppTheme.blue600,
                          iconBg: AppTheme.statusPublished,
                          onTap: () => onNavigate('feedback-reports'),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
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
