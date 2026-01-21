import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/user.dart';
import '../../models/event.dart';
import '../../models/event_api_models.dart';
import '../../theme/app_theme.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/event_card.dart';
import '../../blocs/event_list/event_list_bloc.dart';
import '../../blocs/event_list/event_list_event.dart';
import '../../blocs/event_list/event_list_state.dart';
import '../../repositories/event_repository.dart';
import '../../services/api_client.dart';
import '../../project_helpers.dart';

class DashboardScreen extends StatefulWidget {
  final User user;
  final String token;
  final VoidCallback onCreateEvent;
  final Function(Event) onSelectEvent;
  final VoidCallback onLogout;
  final VoidCallback onNavigateToProfile;

  const DashboardScreen({
    super.key,
    required this.user,
    required this.token,
    required this.onCreateEvent,
    required this.onSelectEvent,
    required this.onLogout,
    required this.onNavigateToProfile,
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
          request: EventListRequest(page: 1, limit: 10, ownBy: 'all', status: 'upcoming'),
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

          return Scaffold(
            backgroundColor: AppTheme.gray50,
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              title: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppTheme.primaryIndigo, AppTheme.primaryPurple],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.calendar_today, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Text('AI Event Builder'),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () {
                    context.read<EventListBloc>().add(FetchEventList(
                      request: EventListRequest(page: 1, limit: 10, ownBy: 'all', status: 'upcoming'),
                      token: widget.token,
                    ));
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: PopupMenuButton(
                    child: avatarWidget(),
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        onTap: widget.onNavigateToProfile,
                        child: const ListTile(
                          leading: Icon(Icons.person_outline),
                          title: Text('Profile'),
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
            body: RefreshIndicator(
              onRefresh: () async {
                context.read<EventListBloc>().add(FetchEventList(
                  request: EventListRequest(page: 1, limit: 10, ownBy: 'all', status: 'upcoming'),
                  token: widget.token,
                ));
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back, ${widget.user.name.split(' ')[0]}! 👋',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.gray900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Here's what's happening with your events",
                      style: TextStyle(fontSize: 16, color: AppTheme.gray600),
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
                        const Text(
                          'Your Events',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.gray900,
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
            ),
          );
        },
      ),
    );
  }

  Widget avatarWidget() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmall = MediaQuery.of(context).size.width < 600;
        
        Widget avatar = CircleAvatar(
          backgroundColor: AppTheme.indigo100,
          backgroundImage: widget.user.profilePic != null && widget.user.profilePic!.isNotEmpty
              ? NetworkImage(widget.user.profilePic!.fixImageUrl)
              : null,
          child: widget.user.profilePic == null || widget.user.profilePic!.isEmpty
              ? Text(
                  widget.user.name.firstChar.upper,
                  style: const TextStyle(color: AppTheme.primaryIndigo),
                )
              : null,
        );

        if (isSmall) return avatar;

        return Row(
          children: [
            avatar,
            const SizedBox(width: 8),
            Text(
              widget.user.name,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
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
              iconColor: AppTheme.gray600,
              subtitle: 'All time',
            ),
            StatCard(
              title: 'Active Events',
              value: stats['activeEvents'].toString(),
              icon: Icons.access_time,
              iconColor: AppTheme.green600,
              subtitle: 'Ongoing',
            ),
            StatCard(
              title: 'Total Attendees',
              value: stats['totalAttendees'].toString(),
              icon: Icons.people,
              iconColor: AppTheme.gray600,
              subtitle: 'Registered',
            ),
            StatCard(
              title: 'Completed',
              value: stats['completedEvents'].toString(),
              icon: Icons.bar_chart,
              iconColor: AppTheme.primaryPurple,
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
          colors: [AppTheme.primaryIndigo, AppTheme.primaryPurple],
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
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              SizedBox(height: 4),
              Text(
                'Use AI to plan your event',
                style: TextStyle(fontSize: 14, color: Colors.white70),
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
        foregroundColor: AppTheme.primaryIndigo,
        minimumSize: const Size(140, 48),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Center(
          child: Column(
            children: [
              const Icon(Icons.calendar_today, size: 48, color: AppTheme.gray400),
              const SizedBox(height: 16),
              const Text(
                'No events yet',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.gray900),
              ),
              const SizedBox(height: 8),
              const Text('Create your first event to get started', style: TextStyle(color: AppTheme.gray600)),
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth <= 700;
        
        if (isMobile) {
          return Column(
            children: events.map((event) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: EventCard(
                event: event,
                onTap: () => widget.onSelectEvent(event),
              ),
            )).toList(),
          );
        }

        final crossAxisCount = constraints.maxWidth > 1200 ? 3 : 2;
        
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 0.85,
          ),
          itemCount: events.length,
          itemBuilder: (context, index) {
            return EventCard(
              event: events[index],
              onTap: () => widget.onSelectEvent(events[index]),
            );
          },
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
