import 'package:empyreal_ai_community_builder_flutter/core/theme/app_colors.dart';
import 'package:empyreal_ai_community_builder_flutter/models/event_api_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/user.dart';
import '../../models/event.dart';
import '../../blocs/event_list/event_list_bloc.dart';
import '../../blocs/event_list/event_list_event.dart';
import '../../blocs/event_list/event_list_state.dart';
import '../../repositories/event_repository.dart';
import '../../services/api_client.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/event_card.dart';
import '../../project_helpers.dart';

import '../../core/enums/event_enums.dart';

class DashboardScreen extends StatefulWidget {
  final User user;
  final String token;
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
    required this.token,
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

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => EventListBloc(EventRepository(ApiClient()))
        ..add(FetchEventList(
          request: EventListRequest(
            page: 1, 
            limit: 10, 
            ownBy: EventOwnership.all, 
            status: EventStatus.upcoming,
          ),
          token: widget.token,
        )),
      child: BlocBuilder<EventListBloc, EventListState>(
        builder: (context, state) {
          List<Event> events = [];
          bool isLoading = state is EventListLoading;

          if (state is EventListSuccess) {
            events = state.response.data?.events.map((e) => Event.fromEventData(e)).toList() ?? [];
          }

          final stats = _calculateStats(events);

          final theme = Theme.of(context);
          final isDark = theme.brightness == Brightness.dark;

          return Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            appBar: AppBar(
              backgroundColor: theme.appBarTheme.backgroundColor,
              elevation: 0,
              title: Row(
                children: [
                  // App Logo Placeholder
                  Container(
                    height: 36,
                    width: 36,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primaryIndigo, AppColors.primaryPurple],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryIndigo.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        )
                      ],
                    ),
                    child: const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'AI Event Builder',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: Stack(
                    children: [
                      Icon(Icons.notifications_outlined, color: theme.iconTheme.color),
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: PopupMenuButton(
                    child: _buildUserAvatar(),
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        onTap: widget.onNavigateToProfile,
                        child: const ListTile(
                          leading: Icon(Icons.person_outline),
                          title: Text('Profile'),
                        ),
                      ),
                      PopupMenuItem(
                        onTap: widget.onNavigateToSettings,
                        child: const ListTile(
                          leading: Icon(Icons.settings_outlined),
                          title: Text('Settings'),
                        ),
                      ),
                      PopupMenuItem(
                        onTap: widget.onLogout,
                        child: const ListTile(
                          leading: Icon(Icons.logout),
                          title: Text('Logout'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome section
                  Text(
                    'Welcome back, ${widget.user.name.split(' ')[0]}! 👋',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Here's what's happening with your events",
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.hintColor,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Stats grid
                  _buildStatsGrid(stats),
                  const SizedBox(height: 32),

                  // Create Event CTA
                  _buildCreateEventCTA(),
                  const SizedBox(height: 32),

                  // Events list header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Your Events',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (isLoading)
                        const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                    ],
                  ),
                  const SizedBox(height: 16),

                  if (state is EventListFailure)
                    Center(child: Text('Error: ${state.error}', style: const TextStyle(color: Colors.red)))
                  else if (isLoading && events.isEmpty)
                    const Center(child: CircularProgressIndicator())
                  else if (events.isEmpty)
                    _buildEmptyState()
                  else
                    _buildEventsList(events),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildUserAvatar() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmall = MediaQuery.of(context).size.width < 600;

        Widget avatar = CircleAvatar(
          backgroundColor: AppColors.indigo100,
          backgroundImage: widget.user.profilePic != null && widget.user.profilePic!.isNotEmpty
              ? NetworkImage(widget.user.profilePic!.fixImageUrl)
              : null,
          child: widget.user.profilePic == null || widget.user.profilePic!.isEmpty
              ? Text(
                  widget.user.name.firstChar.upper,
                  style: const TextStyle(color: AppColors.primaryIndigo),
                )
              : null,
        );

        if (isSmall) return avatar;

        return Row(
          children: [
            avatar,
            const SizedBox(width: 8),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.user.name,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ],
        );
      }
    );
  }

  Widget _buildStatsGrid(Map<String, int> stats) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final crossAxisCount = width > 800 ? 4 : 2;
        final aspectRatio = width > 800 ? 1.5 : (width > 600 ? 1.3 : 1.0);

        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: aspectRatio,
          children: [
            StatCard(
              title: 'Total Events',
              value: stats['totalEvents'].toString(),
              icon: Icons.calendar_today,
              iconColor: AppColors.slate600,
              subtitle: 'All time',
            ),
            StatCard(
              title: 'Active Events',
              value: stats['activeEvents'].toString(),
              icon: Icons.access_time,
              iconColor: AppColors.success,
              subtitle: 'Ongoing',
            ),
            StatCard(
              title: 'Total Attendees',
              value: stats['totalAttendees'].toString(),
              icon: Icons.people,
              iconColor: AppColors.slate600,
              subtitle: 'Registered',
            ),
            StatCard(
              title: 'Completed',
              value: stats['completedEvents'].toString(),
              icon: Icons.bar_chart,
              iconColor: AppColors.secondary,
              subtitle: 'Events',
            ),
          ],
        );
      },
    );
  }

  Widget _buildCreateEventCTA() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryIndigo, AppColors.primaryPurple],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(24),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isSmall = constraints.maxWidth < 600;
          return isSmall
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _ctaHeader(),
                const SizedBox(height: 24),
                _ctaButton(),
              ],
            )
          : Row(
              children: [
                Expanded(flex: 3, child: _ctaHeader()),
                const SizedBox(width: 16),
                _ctaButton(),
              ],
            );
        },
      ),
    );
  }

  Widget _ctaHeader() {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.auto_awesome, color: Colors.white),
        ),
        const SizedBox(width: 16),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Create Your Next Event',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 4),
              Text(
                'Use AI to plan your event',
                style: const TextStyle(fontSize: 14, color: Colors.white70),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _ctaButton() {
    return ElevatedButton.icon(
      onPressed: widget.onCreateEvent,
      icon: const Icon(Icons.add),
      label: const Text('New Event'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.primaryIndigo,
        minimumSize: const Size(140, 48),
      ),
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.calendar_today, size: 48, color: theme.hintColor.withOpacity(0.5)),
              const SizedBox(height: 16),
              Text(
                'No events yet',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                'Create your first event to get started', 
                style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: widget.onCreateEvent,
                icon: const Icon(Icons.add),
                label: const Text('Create Event'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEventsList(List<Event> events) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: events.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        return EventCard(
          event: events[index],
          onTap: () => widget.onSelectEvent(events[index]),
        );
      },
    );
  }

  Map<String, int> _calculateStats(List<Event> events) {
    return {
      'totalEvents': events.length,
      'activeEvents': events.where((e) => e.status == 'ongoing' || e.status == 'published').length,
      'totalAttendees': events.fold(0, (sum, e) => sum + (e.attendeeCount ?? 0)),
      'completedEvents': events.where((e) => e.status == 'completed').length,
    };
  }
}
