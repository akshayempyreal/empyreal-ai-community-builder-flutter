import 'package:empyreal_ai_community_builder_flutter/core/theme/app_colors.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:empyreal_ai_community_builder_flutter/models/event_api_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/user.dart';
import '../../models/event.dart';
import '../../blocs/event_list/event_list_bloc.dart';
import '../../blocs/event_list/event_list_event.dart';
import '../../blocs/event_list/event_list_state.dart';
import '../../blocs/dashboard_stats/dashboard_stats_bloc.dart';
import '../../blocs/dashboard_stats/dashboard_stats_event.dart';
import '../../blocs/dashboard_stats/dashboard_stats_state.dart';
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
  EventOwnership _selectedOwnership = EventOwnership.other;
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;
  EventListBloc? _eventListBloc;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - 200) {
      // Load more when user is 200px from bottom
      _loadMoreEvents();
    }
  }

  void _loadMoreEvents() {
    if (!mounted || _eventListBloc == null) return;
    
    final state = _eventListBloc!.state;
    
    if (state is EventListSuccess && state.hasMore && !_isLoadingMore) {
      setState(() => _isLoadingMore = true);
      
      _eventListBloc!.add(FetchMoreEvents(
        request: EventListRequest(
          page: state.currentPage + 1,
          limit: 10,
          ownBy: _selectedOwnership,
          status: null, // Pass null to send empty string ""
        ),
        token: widget.token,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) {
            final bloc = EventListBloc(EventRepository(ApiClient()))
              ..add(FetchEventList(
                request: EventListRequest(
                  page: 1,
                  limit: 10,
                  ownBy: _selectedOwnership,
                  status: null, // Pass null to send empty string ""
                ),
                token: widget.token,
              ));
            // Store bloc reference for scroll listener
            _eventListBloc = bloc;
            return bloc;
          },
        ),
        BlocProvider(
          create: (context) => DashboardStatsBloc(EventRepository(ApiClient()))
            ..add(FetchDashboardStats(widget.token)),
        ),
      ],
      child: BlocConsumer<EventListBloc, EventListState>(
        listener: (context, state) {
          // Reset loading flag when new events are loaded
          if (state is EventListSuccess && _isLoadingMore) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) setState(() => _isLoadingMore = false);
            });
          }
        },
        builder: (context, eventState) {
          List<Event> events = [];
          bool isEventsLoading = eventState is EventListLoading;

          if (eventState is EventListSuccess) {
            // Use accumulated events from all pages
            events = eventState.allEvents.map((e) => Event.fromEventData(e)).toList();
            // Reset loading flag when state updates
            if (_isLoadingMore) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) setState(() => _isLoadingMore = false);
              });
            }
          }

          final theme = Theme.of(context);
          final isDark = theme.brightness == Brightness.dark;

          return Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            appBar: AppBar(
              backgroundColor: theme.appBarTheme.backgroundColor,
              elevation: 0,
              title: Row(
                children: [
                  // App Logo
                  Container(
                    height: 38,
                    width: 38,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        'assets/images/logo.png',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [AppColors.primaryIndigo, AppColors.primaryPurple],
                              ),
                            ),
                            child: const Center(
                              child: Text(
                                'E',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'EvoMeet',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : AppColors.gray900,
                      letterSpacing: -0.5,
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
              controller: _scrollController,
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
                  BlocBuilder<DashboardStatsBloc, DashboardStatsState>(
                    builder: (context, statsState) {
                      if (statsState is DashboardStatsLoaded) {
                        return _buildStatsGrid(statsState.stats);
                      } else if (statsState is DashboardStatsError) {
                        return Center(child: Text('Error loading stats: ${statsState.error}'));
                      }
                      return const Center(child: CircularProgressIndicator());
                    },
                  ),
                  const SizedBox(height: 32),

                  // Create Event CTA
                  _buildCreateEventCTA(),
                  const SizedBox(height: 32),

                  // Events list header
                  _buildOwnershipToggle(context),
                  const SizedBox(height: 16),

                  if (eventState is EventListFailure)
                    Center(child: Text('Error: ${eventState.error}', style: const TextStyle(color: Colors.red)))
                  else if (isEventsLoading && events.isEmpty)
                    const Center(child: CircularProgressIndicator())
                  else if (events.isEmpty)
                    _buildEmptyState()
                  else
                    _buildEventsList(events, eventState),
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
          onBackgroundImageError: widget.user.profilePic != null && widget.user.profilePic!.isNotEmpty
              ? (exception, stackTrace) {
                  debugPrint('Error loading profile image: $exception');
                }
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

  Widget _buildStatsGrid(DashboardCountsData stats) {
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
              value: stats.totalEvents.toString(),
              icon: Icons.calendar_today,
              iconColor: AppColors.slate600,
              subtitle: 'All time',
            ),
            StatCard(
              title: 'Active Events',
              value: stats.activeEvents.toString(),
              icon: Icons.access_time,
              iconColor: AppColors.success,
              subtitle: 'Ongoing',
            ),
            StatCard(
              title: 'My Events',
              value: stats.myEvents.toString(),
              icon: Icons.person_outline,
              iconColor: AppColors.primaryIndigo,
              subtitle: 'Created by you',
            ),
            StatCard(
              title: 'Completed',
              value: stats.totalCompletedEvents.toString(),
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

  Widget _buildOwnershipToggle(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      height: 40,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildToggleItem(context, 'Others Event', EventOwnership.other),
          _buildToggleItem(context, 'Own Events', EventOwnership.me),
        ],
      ),
    );
  }

  Widget _buildToggleItem(BuildContext context, String title, EventOwnership ownership) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isSelected = _selectedOwnership == ownership;

    return GestureDetector(
      onTap: () {
        if (!isSelected) {
          setState(() {
            _selectedOwnership = ownership;
            _isLoadingMore = false; // Reset loading state when changing filter
          });
          final bloc = context.read<EventListBloc>();
          _eventListBloc = bloc; // Update stored reference
          bloc.add(FetchEventList(
                request: EventListRequest(
                  page: 1,
                  limit: 10,
                  ownBy: ownership,
                  status: null, // Pass null to send empty string ""
                ),
                token: widget.token,
              ));
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: colorScheme.primary.withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Text(
          title,
          style: theme.textTheme.bodySmall?.copyWith(
            color: isSelected ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
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

  Widget _buildEventsList(List<Event> events, EventListState state) {
    final hasMore = state is EventListSuccess && state.hasMore;
    final isLoadingMore = _isLoadingMore || (state is EventListLoading && events.isNotEmpty);
    
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: events.length + (hasMore || isLoadingMore ? 1 : 0),
      separatorBuilder: (context, index) {
        if (index >= events.length) return const SizedBox.shrink();
        return const SizedBox(height: 16);
      },
      itemBuilder: (context, index) {
        // Show loading indicator at the end if there are more pages
        if (index == events.length) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: isLoadingMore
                  ? const CircularProgressIndicator()
                  : const SizedBox.shrink(),
            ),
          );
        }
        
        return EventCard(
          event: events[index],
          onTap: () => widget.onSelectEvent(events[index]),
        );
      },
    );
  }
}
