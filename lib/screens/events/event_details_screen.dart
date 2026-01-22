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

            final imageHeight = context.isMobile ? 260.0 : 450.0;
            final contentMaxWidth = 1100.0;
            final isDesktop = viewport.maxWidth >= 900;

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Cinematic Hero Image Header
                  Stack(
                    children: [
                      if (event.image != null && event.image!.isNotEmpty)
                        Image.network(
                          event.image!.fixImageUrl,
                          height: imageHeight,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            height: imageHeight,
                            width: double.infinity,
                            color: AppTheme.indigo100,
                            child: const Icon(Icons.image_not_supported_outlined, 
                                color: AppTheme.primaryIndigo, size: 48),
                          ),
                        )
                      else
                        Container(
                          height: 180,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [AppTheme.primaryIndigo.withOpacity(0.1), AppTheme.primaryPurple.withOpacity(0.1)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                        ),
                      // Subtle gradient overlay for better text contrast if needed
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withOpacity(0.2),
                                Colors.transparent,
                                Colors.black.withOpacity(0.1),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: contentMaxWidth),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Floating Event Header Card
                          Transform.translate(
                            offset: Offset(0, context.isMobile ? -30 : -50),
                            child: Card(
                              elevation: 8,
                              shadowColor: Colors.black.withOpacity(0.15),
                              shape: 20.roundBorder.copyWith(
                                side: const BorderSide(color: Colors.white, width: 2),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      StatusBadge(status: event.status),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: AppTheme.indigo100,
                                          borderRadius: 20.radius,
                                        ),
                                        child: Text(
                                          _getDaysLeft(event.date).upper,
                                          style: const TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w900,
                                            color: AppTheme.primaryIndigo,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  16.height(context),
                                  Text(
                                    event.name,
                                    style: TextStyle(
                                      fontSize: context.isMobile ? 24 : 36,
                                      fontWeight: FontWeight.w900,
                                      color: AppTheme.gray900,
                                      letterSpacing: -1,
                                      height: 1.1,
                                    ),
                                  ),
                                  12.height(context),
                                  Text(
                                    event.description,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: AppTheme.gray600,
                                      height: 1.6,
                                    ),
                                  ),
                                ],
                              ).paddingAll(context, context.isMobile ? 20 : 32),
                            ),
                          ),
                      
                      const SizedBox(height: 4),

                      // Logistics Card (When & Where)
                      Card(
                        elevation: 0,
                        shape: 16.roundBorder.copyWith(
                          side: BorderSide(color: AppTheme.gray200),
                        ),
                        child: Column(
                          children: [
                            _buildLogisticsItem(
                              context,
                              Icons.calendar_today_rounded,
                              'Schedule',
                              _formatDateRange(event.date, event.endDate),
                            ),
                            const Divider(height: 1, color: AppTheme.gray100).paddingHorizontal(context, 16),
                            _buildLogisticsItem(
                              context,
                              Icons.location_on_rounded,
                              'Location',
                              event.location,
                              isClickable: true,
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Opening Location on Map...')),
                                );
                              },
                            ),
                            const Divider(height: 1, color: AppTheme.gray100).paddingHorizontal(context, 16),
                            _buildLogisticsItem(
                              context,
                              Icons.timer_rounded,
                              'Typical Duration',
                              '${event.duration} hours per session',
                            ),
                          ],
                        ),
                      ),
                      20.height(context),

                      // Stats Row
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildStatBadge(
                              context,
                              event.audienceSize?.toString() ?? '0',
                              'Capacity',
                              Icons.group_rounded,
                              AppTheme.primaryIndigo,
                            ),
                            12.width,
                            _buildStatBadge(
                              context,
                              event.attendeeCount?.toString() ?? '0',
                              'Registered',
                              Icons.person_add_rounded,
                              AppTheme.green600,
                            ),
                            12.width,
                            _buildStatBadge(
                              context,
                              event.planningMode == 'automated' ? 'AI' : 'Manual',
                              'Mode',
                              event.planningMode == 'automated' ? Icons.auto_awesome : Icons.edit_note_rounded,
                              AppTheme.primaryPurple,
                            ),
                          ],
                        ),
                      ).paddingHorizontal(context, 4),
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
                    const SizedBox(height: 32),
                    ],
                  ).paddingHorizontal(context, horizontalPadding),
                ),
              ),
            ],
          ),
        );
          },
        ),
      ),
    );
  }

  Widget _buildLogisticsItem(
    BuildContext context, 
    IconData icon, 
    String label, 
    String value, 
    {bool isClickable = false, VoidCallback? onTap}
  ) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.gray50,
              borderRadius: 12.radius,
            ),
            child: Icon(icon, size: 20, color: AppTheme.primaryIndigo),
          ),
          16.width,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.gray500,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.gray900,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (isClickable)
            const Icon(Icons.chevron_right_rounded, color: AppTheme.gray400),
        ],
      ).paddingAll(context, 16),
    );
  }

  Widget _buildStatBadge(BuildContext context, String value, String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: 16.radius,
        border: Border.all(color: AppTheme.gray200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          10.width,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.gray900,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.gray500,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ],
      ),
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
