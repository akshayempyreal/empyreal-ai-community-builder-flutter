import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../project_helpers.dart';
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
    final horizontalPadding = context.isMobile ? 16.0 : context.width < 900 ? 24.0 : 32.0;

    return Scaffold(
      backgroundColor: AppTheme.gray50,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: onBack,
        ),
        title: const Text('Event Details'),
        actions: [
          CircleAvatar(
            backgroundColor: AppTheme.indigo100,
            child: Text(
              user.name[0].upper,
              style: const TextStyle(color: AppTheme.primaryIndigo),
            ),
          ).paddingAll(context, 8),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, viewport) {
            final effectiveWidth = (viewport.maxWidth - (horizontalPadding * 2)).clamp(0.0, double.infinity);
            final computedCount = math.max(1, (effectiveWidth / 320).floor());
            final crossAxisCount = context.isMobile ? 1 : computedCount.clamp(1, 4);
            final headerPadding = context.isMobile ? 16.0 : 24.0;
            final titleSize = context.isMobile ? 22.0 : 28.0;

            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: viewport.maxWidth >= 700 ? double.infinity : 0,
                  maxWidth: viewport.maxWidth >= 700 ? double.infinity : 860,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Event Image
                    if (event.image != null && event.image!.isNotEmpty)
                      ClipRRect(
                        borderRadius: 16.radius,
                        child: Image.network(
                          event.image!.fixImageUrl,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            height: 200,
                            width: double.infinity,
                            color: AppTheme.indigo100,
                            child: const Icon(Icons.image_not_supported_outlined, 
                                color: AppTheme.primaryIndigo, size: 48),
                          ),
                        ),
                      ).paddingOnly(bottom: 16),

                    // Event header Card
                    Card(
                      elevation: 0,
                      shape: 16.roundBorder.copyWith(
                        side: BorderSide(color: AppTheme.gray200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              StatusBadge(status: event.status),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppTheme.indigo100,
                                  borderRadius: 20.radius,
                                ),
                                child: Text(
                                  _getDaysLeft(event.date),
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryIndigo,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          16.height(context),
                          Text(
                            event.name,
                            style: TextStyle(
                              fontSize: titleSize,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.gray900,
                              letterSpacing: -0.5,
                            ),
                          ),
                          8.height(context),
                          Text(
                            event.description,
                            style: const TextStyle(
                              fontSize: 15,
                              color: AppTheme.gray600,
                              height: 1.5,
                            ),
                          ),
                          24.height(context),
                          
                          // Main info grid
                          Wrap(
                            spacing: 24,
                            runSpacing: 16,
                            children: [
                              _buildInfoItem(
                                context,
                                Icons.calendar_today_outlined,
                                'Event Dates',
                                _formatDateRange(event.date, event.endDate),
                              ),
                              _buildInfoItem(
                                context,
                                Icons.location_on_outlined,
                                'Location',
                                event.location,
                                onIconTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Opening Location on Map...')),
                                  );
                                },
                              ),
                              _buildInfoItem(
                                context,
                                Icons.access_time,
                                'Duration',
                                '${event.duration} hours / day',
                              ),
                              if (event.audienceSize != null)
                                _buildInfoItem(
                                  context,
                                  Icons.group_outlined,
                                  'Expected',
                                  '${event.audienceSize} people',
                                ),
                              if (event.attendeeCount != null)
                                _buildInfoItem(
                                  context,
                                  Icons.people_outline,
                                  'Registered',
                                  '${event.attendeeCount} members',
                                ),
                              _buildInfoItem(
                                context,
                                event.planningMode == 'automated'
                                    ? Icons.auto_awesome
                                    : Icons.edit_note,
                                'Mode',
                                event.planningMode == 'automated' ? 'AI Planned' : 'Manual',
                              ),
                            ],
                          ).paddingOnly(top: 16),
                        ],
                      ).paddingAll(context, headerPadding),
                    ),
                    24.height(context),

                    // Action cards Grid
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: crossAxisCount,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: context.isMobile
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
                ).paddingHorizontal(context, horizontalPadding).paddingVertical(context, 16),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildInfoItem(BuildContext context, IconData icon, String label, String value, {VoidCallback? onIconTap}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: AppTheme.primaryIndigo),
            if (onIconTap != null)
              const Icon(Icons.open_in_new, size: 10, color: AppTheme.primaryIndigo).paddingHorizontal(context, 4).onClick(onIconTap),
            6.width,
            Text(
              label.upper,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: AppTheme.gray500,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
        4.height(context),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppTheme.gray900,
          ),
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: 16.radius,
        border: Border.all(color: AppTheme.gray200),
        boxShadow: [
          BoxShadow(
            color: iconColor.withOpacity(0.05),
            offset: const Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconBg.withOpacity(0.15),
              borderRadius: 12.radius,
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.gray900,
                  letterSpacing: -0.4,
                ),
              ),
              4.height(context),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppTheme.gray500,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ).paddingAll(context, 16),
    ).onClick(onTap);
  }

  String _getDaysLeft(String dateStr) {
    try {
      final eventDate = DateTime.parse(dateStr);
      final now = DateTime.now();
      final difference = eventDate.difference(now).inDays;
      if (difference < 0) return 'Concluded';
      if (difference == 0) return 'Today';
      if (difference == 1) return 'Tomorrow';
      return 'In $difference days';
    } catch (e) {
      return '';
    }
  }

  String _formatDateRange(String startStr, String? endStr) {
    try {
      final start = DateTime.parse(startStr).toLocal();
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      
      String startFmt = '${months[start.month - 1]} ${start.day}, ${start.year}';
      
      if (endStr != null && endStr.isNotEmpty) {
        final end = DateTime.parse(endStr).toLocal();
        // If same month and year, simplify
        if (start.month == end.month && start.year == end.year) {
          if (start.day == end.day) return startFmt;
          return '${months[start.month - 1]} ${start.day} - ${end.day}, ${start.year}';
        }
        return '$startFmt - ${months[end.month - 1]} ${end.day}, ${end.year}';
      }
      return startFmt;
    } catch (e) {
      return startStr;
    }
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr).toLocal();
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${months[date.month - 1]} ${date.day}, ${date.year}';
    } catch (e) {
      return dateStr;
    }
  }
}
