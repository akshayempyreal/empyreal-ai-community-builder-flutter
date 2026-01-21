import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../../models/event.dart';
import '../../theme/app_theme.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/event_card.dart';

class DashboardScreen extends StatelessWidget {
  final User user;
  final List<Event> events;
  final VoidCallback onCreateEvent;
  final Function(Event) onSelectEvent;
  final VoidCallback onLogout;

  const DashboardScreen({
    super.key,
    required this.user,
    required this.events,
    required this.onCreateEvent,
    required this.onSelectEvent,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final stats = _calculateStats();

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
            icon: Stack(
              children: [
                const Icon(Icons.notifications_outlined),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppTheme.red500,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
            onPressed: () {},
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: PopupMenuButton(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Check screen width from MediaQuery since constraints here are from the AppBar action slot
                  final isSmall = MediaQuery.of(context).size.width < 600;
                  if (isSmall) {
                    return CircleAvatar(
                      backgroundColor: AppTheme.indigo100,
                      child: Text(
                        user.name[0].toUpperCase(),
                        style: const TextStyle(color: AppTheme.primaryIndigo),
                      ),
                    );
                  }
                  return Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: AppTheme.indigo100,
                        child: Text(
                          user.name[0].toUpperCase(),
                          style: const TextStyle(color: AppTheme.primaryIndigo),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.name,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                          ),
                          Text(
                            user.email,
                            style: const TextStyle(fontSize: 12, color: AppTheme.gray500),
                          ),
                        ],
                      ),
                    ],
                  );
                }
              ),
              itemBuilder: (context) => [
                PopupMenuItem(
                  child: ListTile(
                    leading: const Icon(Icons.logout),
                    title: const Text('Logout'),
                    onTap: onLogout,
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
              'Welcome back, ${user.name.split(' ')[0]}! 👋',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppTheme.gray900,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            const Text(
              "Here's what's happening with your events",
              style: TextStyle(fontSize: 16, color: AppTheme.gray600),
            ),
            const SizedBox(height: 32),

            // Stats grid
            LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final crossAxisCount = width > 800 ? 4 : 2;
                // On mobile (2 cols), width is small, so we need more height (lower aspect ratio)
                // Width ~150px. Content ~120px. Ratio should be ~1.2. 1.0 is safer.
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
            ),
            const SizedBox(height: 32),

            // Create Event CTA
            LayoutBuilder(
              builder: (context, constraints) {
                final isSmall = constraints.maxWidth < 600;
                return Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.primaryIndigo, AppTheme.primaryPurple],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(24),
                  child: isSmall 
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
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
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
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
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: onCreateEvent,
                          icon: const Icon(Icons.add),
                          label: const Text('New Event'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppTheme.primaryIndigo,
                            minimumSize: const Size(double.infinity, 48), // Full width
                          ),
                        ),
                      ],
                    )
                  : Row(
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
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Use AI to plan your event in minutes',
                                style: TextStyle(fontSize: 14, color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton.icon(
                          onPressed: onCreateEvent,
                          icon: const Icon(Icons.add),
                          label: const Text('New Event'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppTheme.primaryIndigo,
                          ),
                        ),
                      ],
                    ),
                );
              }
            ),
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
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.filter_list, size: 16),
                  label: const Text('Filter'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Events grid
            if (events.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(48),
                  child: Center(
                    child: Column(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          size: 48,
                          color: AppTheme.gray400,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No events yet',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.gray900,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Create your first event to get started',
                          style: TextStyle(color: AppTheme.gray600),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: onCreateEvent,
                          icon: const Icon(Icons.add),
                          label: const Text('Create Event'),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              LayoutBuilder(
                builder: (context, constraints) {
                  final isMobile = constraints.maxWidth <= 700;
                  
                  if (isMobile) {
                    return Column(
                      children: events.map((event) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: EventCard(
                          event: event,
                          onTap: () => onSelectEvent(event),
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
                        onTap: () => onSelectEvent(events[index]),
                      );
                    },
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Map<String, int> _calculateStats() {
    return {
      'totalEvents': events.length,
      'activeEvents': events.where((e) => e.status == 'ongoing' || e.status == 'published').length,
      'totalAttendees': events.fold(0, (sum, e) => sum + (e.attendeeCount ?? 0)),
      'completedEvents': events.where((e) => e.status == 'completed').length,
    };
  }
}
