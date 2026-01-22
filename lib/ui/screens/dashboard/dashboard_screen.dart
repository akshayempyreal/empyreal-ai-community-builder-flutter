import 'package:empyreal_ai_community_builder_flutter/models/event.dart';
import 'package:empyreal_ai_community_builder_flutter/models/user.dart';
import 'package:empyreal_ai_community_builder_flutter/project_helpers.dart';
import 'package:empyreal_ai_community_builder_flutter/widgets/event_card.dart';
import 'package:empyreal_ai_community_builder_flutter/widgets/stat_card.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/animation/app_animations.dart';
import '../../../core/animation/dashboard_entry_animation.dart';

class DashboardScreen extends StatefulWidget {
  final User user;
  final List<Event> events;
  final VoidCallback onCreateEvent;
  final Function(Event) onSelectEvent;
  final VoidCallback onLogout;
  final VoidCallback onNavigateToProfile;
  final VoidCallback onNavigateToSettings;
  final VoidCallback onNavigateToNotifications;
  final int unreadCount;

  const DashboardScreen({
    super.key,
    required this.user,
    required this.events,
    required this.onCreateEvent,
    required this.onSelectEvent,
    required this.onLogout,
    required this.onNavigateToProfile,
    required this.onNavigateToSettings,
    required this.onNavigateToNotifications,
    required this.unreadCount,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppAnimations.slow,
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stats = _calculateStats();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: DashboardEntryAnimation(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 120.0,
              floating: true,
              pinned: true,
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  context.tr('common.app_name'),
                  style: TextStyle(
                    color: isDark ? AppColors.slate50 : AppColors.slate900,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDark 
                        ? [AppColors.slate900, AppColors.slate800] 
                        : [AppColors.slate50, Colors.white],
                    ),
                  ),
                ),
              ),
              actions: [
                IconButton(
                  icon: Stack(
                    children: [
                      const Icon(Icons.notifications_outlined),
                      if (widget.unreadCount > 0)
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: AppColors.error,
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 14,
                              minHeight: 14,
                            ),
                            child: Text(
                              widget.unreadCount > 9 ? '9+' : widget.unreadCount.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                  onPressed: widget.onNavigateToNotifications,
                ),
                PopupMenuButton<int>(
                  offset: const Offset(0, 48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      backgroundImage: widget.user.profilePic != null && widget.user.profilePic!.isNotEmpty
                          ? NetworkImage(widget.user.profilePic!.fixImageUrl)
                          : null,
                      onBackgroundImageError: widget.user.profilePic != null && widget.user.profilePic!.isNotEmpty
                          ? (exception, stackTrace) {
                              debugPrint('Error loading profile image: $exception');
                            }
                          : null,
                      child: widget.user.profilePic == null || widget.user.profilePic!.isEmpty
                          ? Text(
                              widget.user.name[0].toUpperCase(),
                              style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                            )
                          : null,
                    ),
                  ),
                  itemBuilder: (context) => <PopupMenuEntry<int>>[
                    PopupMenuItem<int>(
                      onTap: widget.onNavigateToProfile,
                      child: ListTile(
                        leading: const Icon(Icons.person_outline),
                        title: Text(context.tr('common.profile')),
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                      ),
                    ),
                    PopupMenuItem<int>(
                      onTap: widget.onNavigateToSettings,
                      child: ListTile(
                        leading: const Icon(Icons.settings_outlined),
                        title: Text(context.tr('common.settings')),
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                      ),
                    ),
                    const PopupMenuDivider(),
                    PopupMenuItem<int>(
                      onTap: widget.onLogout,
                      child: ListTile(
                        leading: const Icon(Icons.logout, color: AppColors.error),
                        title: Text(
                          context.tr('common.logout'),
                          style: const TextStyle(color: AppColors.error),
                        ),
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FadeTransition(
                      opacity: _controller,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.tr('dashboard.welcome', arguments: {'name': widget.user.name.split(' ')[0]}),
                            style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            context.tr('dashboard.summary'),
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
  
                    // Stats row
                    _buildStatsGrid(context, stats),
                    const SizedBox(height: 32),
  
                    // Create Event Banner
                    AppAnimations.staggeredEntrance(
                      _buildCreateBanner(context),
                      2,
                      _controller,
                    ),
                    const SizedBox(height: 40),
  
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          context.tr('dashboard.your_events'),
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        TextButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.filter_list, size: 18),
                          label: const Text('Filter'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
  
                    _buildEventsList(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context, Map<String, int> stats) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 800 ? 4 : 2;
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: constraints.maxWidth > 600 ? 1.5 : 1.1,
          children: [
            AppAnimations.staggeredEntrance(
              StatCard(
                title: "All Events",
                value: stats['totalEvents'].toString(),
                icon: Icons.calendar_today,
                iconColor: AppColors.primary,
                subtitle: context.tr('dashboard.total_events_subtitle'),
              ),
              0,
              _controller,
            ),
            AppAnimations.staggeredEntrance(
              StatCard(
                title: "Ongoing Events",
                value: stats['activeEvents'].toString(),
                icon: Icons.bolt,
                iconColor: AppColors.success,
                subtitle: context.tr('dashboard.active_events_subtitle'),
              ),
              1,
              _controller,
            ),
            AppAnimations.staggeredEntrance(
              StatCard(
                title: "All Attendees",
                value: stats['totalAttendees'].toString(),
                icon: Icons.people_outline,
                iconColor: AppColors.secondary,
                subtitle: context.tr('dashboard.total_attendees_subtitle'),
              ),
              2,
              _controller,
            ),
            AppAnimations.staggeredEntrance(
              StatCard(
                title: "Past Events",
                value: stats['completedEvents'].toString(),
                icon: Icons.check_circle_outline,
                iconColor: AppColors.info,
                subtitle: context.tr('dashboard.completed_events_subtitle'),
              ),
              3,
              _controller,
            ),
          ],
        );
      },
    );
  }

  Widget _buildCreateBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
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
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr('dashboard.create_event_title'),
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  context.tr('dashboard.create_event_desc'),
                  style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: widget.onCreateEvent,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: Text(context.tr('dashboard.new_event'), style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          const Icon(Icons.auto_awesome, size: 80, color: Colors.white24),
        ],
      ),
    );
  }

  Widget _buildEventsList(BuildContext context) {
    if (widget.events.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 60),
          child: Column(
            children: [
              Icon(Icons.event_note_outlined, size: 64, color: AppColors.slate300),
              const SizedBox(height: 16),
              Text('No events found', style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 1200 ? 3 : (constraints.maxWidth > 700 ? 2 : 1);
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 0.9,
          ),
          itemCount: widget.events.length,
          itemBuilder: (context, index) {
            return AppAnimations.staggeredEntrance(
              EventCard(
                event: widget.events[index],
                onTap: () => widget.onSelectEvent(widget.events[index]),
              ),
              index + 4,
              _controller,
            );
          },
        );
      },
    );
  }

  Map<String, int> _calculateStats() {
    return {
      'totalEvents': widget.events.length,
      'activeEvents': widget.events.where((e) => e.status == 'ongoing' || e.status == 'published').length,
      'totalAttendees': widget.events.fold(0, (sum, e) => sum + (e.attendeeCount ?? 0)),
      'completedEvents': widget.events.where((e) => e.status == 'completed').length,
    };
  }
}
