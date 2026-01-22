import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform;
import '../../project_helpers.dart';
import 'dart:math' as math;
import '../../models/user.dart';
import '../../models/event.dart';
import '../../models/agenda_item.dart';
import '../../models/attendee.dart';
import '../../widgets/status_badge.dart';
import '../../repositories/event_repository.dart';
import '../../services/api_client.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../blocs/events/event_actions_bloc.dart';
import '../../blocs/events/event_actions_event.dart';
import '../../blocs/events/event_actions_state.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../repositories/event_repository.dart';
import '../../services/api_client.dart';

class EventDetailsScreen extends StatefulWidget {
  final Event event;
  final List<AgendaItem> agendaItems;
  final List<Attendee> attendees;
  final Function(String) onNavigate;
  final VoidCallback onBack;
  final User user;
  final String token;

  const EventDetailsScreen({
    super.key,
    required this.event,
    required this.agendaItems,
    required this.attendees,
    required this.onNavigate,
    required this.onBack,
    required this.user,
    required this.token,
  });

  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  late Event _currentEvent;
  bool _isLoading = false;
  bool? _previousJoinState; // Store previous join state before optimistic update

  @override
  void initState() {
    super.initState();
    _currentEvent = widget.event;
  }

  bool get _isOwner => widget.user.id == _currentEvent.createdBy;

  /// Check if the event has ended by comparing end date with current time
  bool _isEventEnded() {
    try {
      if (_currentEvent.endDate == null || _currentEvent.endDate!.isEmpty) {
        // If no end date, check start date + duration
        final startDate = DateTime.parse(_currentEvent.date);
        final endDateTime = startDate.add(Duration(hours: _currentEvent.duration));
        return DateTime.now().isAfter(endDateTime);
      } else {
        // Use end date if available
        final endDate = DateTime.parse(_currentEvent.endDate!);
        return DateTime.now().isAfter(endDate);
      }
    } catch (e) {
      // If parsing fails, assume event is not ended
      return false;
    }
  }

  /// Get the current status of the event based on time (upcoming, ongoing, past)
  String _getEventStatus() {
    try {
      final now = DateTime.now();
      final startDate = DateTime.parse(_currentEvent.date).toLocal();
      
      // Determine end date
      DateTime endDate;
      if (_currentEvent.endDate != null && _currentEvent.endDate!.isNotEmpty) {
        endDate = DateTime.parse(_currentEvent.endDate!).toLocal();
      } else {
        // If no end date, calculate from start date + duration
        endDate = startDate.add(Duration(hours: _currentEvent.duration));
      }
      
      // Compare current time with event dates
      if (now.isBefore(startDate)) {
        return 'upcoming';
      } else if (now.isAfter(endDate)) {
        return 'past';
      } else {
        // Event is currently happening
        return 'ongoing';
      }
    } catch (e) {
      // If parsing fails, return the stored status
      return _currentEvent.status;
    }
  }

  Future<void> _showDeleteDialog(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Event'),
        content: Text(
          'Are you sure you want to delete "${_currentEvent.name}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      setState(() => _isLoading = true);
      // Use the context from the BlocConsumer builder which has access to BlocProvider
      context.read<EventActionsBloc>().add(
        DeleteEvent(eventId: _currentEvent.id, token: widget.token),
      );
    }
  }

  Future<void> _showEditDialog(BuildContext context) async {
    final nameController = TextEditingController(text: _currentEvent.name);

    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Edit Event Name'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Event Name',
            hintText: 'Enter new event name',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, nameController.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty && result != _currentEvent.name) {
      _updateEventName(result);
    }
  }

  Future<void> _updateEventName(String newName) async {
    setState(() => _isLoading = true);
    try {
      final repository = EventRepository(ApiClient());
      final response = await repository.updateEvent(_currentEvent.id, newName, widget.token);

      if (response.status && response.data != null) {
        setState(() {
          _currentEvent = Event.fromEventData(response.data!);
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Event updated successfully')),
          );
        }
      } else {
        throw Exception(response.message);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update event: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final horizontalPadding = context.isMobile ? 16.0 : context.width < 900 ? 24.0 : 32.0;

    return BlocProvider(
      create: (context) => EventActionsBloc(EventRepository(ApiClient())),
      child: BlocConsumer<EventActionsBloc, EventActionsState>(
        listener: (context, state) {
          if (state is DeleteEventSuccess) {
            if (mounted) {
              setState(() => _isLoading = false);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 2),
                ),
              );
              // Navigate back to dashboard after successful deletion
              widget.onBack();
            }
          } else if (state is EventActionFailure) {
            if (mounted) {
              setState(() => _isLoading = false);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.error),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 3),
                ),
              );
            }
          } else if (state is EventJoinLeaveSuccess) {
            // Use stored previous join status to determine the action taken
            // This was set before the optimistic update in the button handler
            final wasJoined = _previousJoinState ?? _currentEvent.isJoined;
            
            // Update event with response data, preserving existing data if server doesn't provide it
            if (state.response.data != null) {
              setState(() {
                final serverData = state.response.data!;
                // Store the optimistic count before server update
                final optimisticCount = _currentEvent.attendeeCount ?? 0;
                
                // Merge server response with existing event data
                // Preserve existing data when server returns 0, null, or empty values for non-join-related fields
                // Only update join status and attendee count from server response
                _currentEvent = Event(
                  id: _currentEvent.id, // Always preserve existing ID
                  name: (serverData.name.isNotEmpty && serverData.name != _currentEvent.name) ? serverData.name : _currentEvent.name,
                  description: (serverData.description.isNotEmpty && serverData.description != _currentEvent.description) ? serverData.description : _currentEvent.description,
                  location: (serverData.location.isNotEmpty && serverData.location != _currentEvent.location) ? serverData.location : _currentEvent.location,
                  type: (serverData.eventType.isNotEmpty && serverData.eventType != _currentEvent.type) ? serverData.eventType : _currentEvent.type,
                  date: (serverData.startDate.isNotEmpty && serverData.startDate != _currentEvent.date) ? serverData.startDate : _currentEvent.date,
                  endDate: (serverData.endDate.isNotEmpty && serverData.endDate != _currentEvent.endDate) ? serverData.endDate : _currentEvent.endDate,
                  // Preserve duration if server returns 0 or same value
                  duration: (serverData.hoursInDay > 0 && serverData.hoursInDay != _currentEvent.duration) ? serverData.hoursInDay : _currentEvent.duration,
                  // Preserve audience size if server returns 0 or same value
                  audienceSize: (serverData.expectedAudienceSize > 0 && serverData.expectedAudienceSize != _currentEvent.audienceSize) ? serverData.expectedAudienceSize : _currentEvent.audienceSize,
                  // Always preserve planning mode
                  planningMode: _currentEvent.planningMode,
                  // Always preserve status
                  status: _currentEvent.status,
                  // Always preserve timestamps
                  createdAt: _currentEvent.createdAt,
                  createdBy: _currentEvent.createdBy,
                  // Update attendee count from server
                  // If server returns 0 but we had a positive optimistic count, use server value (it's source of truth)
                  // But if server returns a valid positive value, use that
                  attendeeCount: serverData.membersCount >= 0 ? serverData.membersCount : optimisticCount,
                  // Preserve coordinates if server doesn't provide them
                  latitude: serverData.coordinates?.coordinates[1] ?? _currentEvent.latitude,
                  longitude: serverData.coordinates?.coordinates[0] ?? _currentEvent.longitude,
                  // Preserve image if server doesn't provide one
                  image: serverData.attachments.isNotEmpty ? serverData.attachments.first : _currentEvent.image,
                  // Always update join status from server
                  isJoined: serverData.isMember,
                );
              });
            } else {
              // If no server data, keep the optimistic update that was already done in button handler
              // No need to update again here
            }
            
            // Show success message from API response
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.response.message.isNotEmpty
                      ? state.response.message
                      : (_currentEvent.isJoined 
                          ? 'You have joined this event successfully!' 
                          : 'You have left this event'),
                ),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 2),
              ),
            );
            
            // Clear the stored previous state
            _previousJoinState = null;
          } else if (state is EventActionFailure) {
            // Revert optimistic update on failure - restore previous state
            setState(() {
              final previousIsJoined = !_currentEvent.isJoined;
              final previousCount = _currentEvent.attendeeCount ?? 0;
              _currentEvent = Event(
                id: _currentEvent.id,
                name: _currentEvent.name,
                description: _currentEvent.description,
                location: _currentEvent.location,
                type: _currentEvent.type,
                date: _currentEvent.date,
                endDate: _currentEvent.endDate,
                duration: _currentEvent.duration,
                audienceSize: _currentEvent.audienceSize,
                planningMode: _currentEvent.planningMode,
                status: _currentEvent.status,
                createdAt: _currentEvent.createdAt,
                createdBy: _currentEvent.createdBy,
                attendeeCount: previousIsJoined ? previousCount + 1 : (previousCount > 0 ? previousCount - 1 : 0),
                latitude: _currentEvent.latitude,
                longitude: _currentEvent.longitude,
                image: _currentEvent.image,
                isJoined: previousIsJoined,
              );
            });
            
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            bottomNavigationBar: _buildJoinLeaveBar(context, state),
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBack,
        ),
        title: const Text('Event Details'),
        actions: [
          if (_isOwner)
            IconButton(
              icon: _isLoading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.edit_outlined),
              onPressed: _isLoading ? null : () => _showEditDialog(context),
              tooltip: 'Edit Event',
            ),
          if (_isOwner)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: _isLoading ? null : () => _showDeleteDialog(context),
              tooltip: 'Delete Event',
            ),
          const SizedBox(width: 8),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              backgroundColor: colorScheme.primary.withOpacity(0.1),
              child: Text(
                widget.user.name[0].toUpperCase(),
                style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, viewport) {
            final contentMaxWidth = 1100.0;
            final imageHeight = context.isMobile ? 260.0 : 450.0;

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Cinematic Hero Image Header
                  Stack(
                    children: [
                      if (_currentEvent.image != null && _currentEvent.image!.isNotEmpty)
                        Image.network(
                          _currentEvent.image!.fixImageUrl,
                          height: imageHeight,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            height: imageHeight,
                            width: double.infinity,
                            color: colorScheme.primary.withOpacity(0.05),
                            child: Icon(Icons.image_not_supported_outlined,
                                color: colorScheme.primary, size: 48),
                          ),
                        )
                      else
                        Container(
                          height: 180,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [colorScheme.primary.withOpacity(0.1), colorScheme.secondary.withOpacity(0.1)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                        ),
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
                              elevation: 4,
                              shadowColor: Colors.black.withOpacity(0.1),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      StatusBadge(status: _getEventStatus()),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: colorScheme.primary.withOpacity(0.1),
                                          borderRadius: 20.radius,
                                        ),
                                        child: Text(
                                          _getDaysLeft(_currentEvent.date).toUpperCase(),
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w900,
                                            color: colorScheme.primary,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    _currentEvent.name,
                                    style: theme.textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: -1,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    _currentEvent.description,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
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
                        child: Column(
                          children: [
                            _buildLogisticsItem(
                              context,
                              Icons.play_arrow_rounded,
                              'Start',
                              _formatDateTime(_currentEvent.date),
                            ),
                            const Divider(height: 1),
                            _buildLogisticsItem(
                              context,
                              Icons.stop_rounded,
                              'End',
                              _currentEvent.endDate != null && _currentEvent.endDate!.isNotEmpty
                                  ? _formatDateTime(_currentEvent.endDate!)
                                  : 'N/A',
                            ),
                            const Divider(height: 1),
                            _buildLogisticsItem(
                              context,
                              Icons.location_on_rounded,
                              'Location',
                              _currentEvent.location,
                              isClickable: true,
                              onTap: () => _openLocationInMaps(context),
                            ),
                            const Divider(height: 1),
                            _buildLogisticsItem(
                              context,
                              Icons.category_rounded,
                              'Type',
                              _currentEvent.type,
                            ),
                            const Divider(height: 1),
                            _buildLogisticsItem(
                              context,
                              Icons.timer_rounded,
                              'Typical Duration',
                              '${_currentEvent.duration} hours per session',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Stats Row
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildStatBadge(
                              context,
                              _currentEvent.audienceSize?.toString() ?? '0',
                              'Capacity',
                              Icons.group_rounded,
                              colorScheme.primary,
                            ),
                            const SizedBox(width: 12),
                            _buildStatBadge(
                              context,
                              _currentEvent.attendeeCount?.toString() ?? '0',
                              'Registered',
                              Icons.person_add_rounded,
                              Colors.green,
                            ),
                            const SizedBox(width: 12),
                            _buildStatBadge(
                              context,
                              _currentEvent.planningMode == 'automated' ? 'AI' : 'Manual',
                              'Mode',
                              _currentEvent.planningMode == 'automated' ? Icons.auto_awesome : Icons.edit_note_rounded,
                              colorScheme.secondary,
                            ),
                          ],
                        ),
                      ).paddingHorizontal(context, 4),
                      const SizedBox(height: 24),

                    // Action cards Grid
                    LayoutBuilder(builder: (context, constraints) {
                      final effectiveWidth = (constraints.maxWidth).clamp(0.0, double.infinity);
                      final computedCount = math.max(1, (effectiveWidth / 320).floor());
                      final crossAxisCount = context.isMobile ? 1 : computedCount.clamp(1, 4);

                      return GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: crossAxisCount,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: context.isMobile ? 2.5 : 1.5,
                        children: [
                          _buildActionCard(
                            context,
                            title: 'Agenda',
                            subtitle: '${widget.agendaItems.length} items',
                            icon: Icons.list_alt,
                            iconColor: colorScheme.primary,
                            onTap: () => widget.onNavigate('agenda-view'),
                          ),
                          _buildActionCard(
                            context,
                            title: 'Attendees',
                            subtitle: '${_currentEvent.attendeeCount ?? 0} registered',
                            icon: Icons.people,
                            iconColor: Colors.green,
                            onTap: () => widget.onNavigate('attendees'),
                          ),
                          _buildActionCard(
                            context,
                            title: 'Feedback',
                            subtitle: 'Reviews',
                            icon: Icons.feedback_outlined,
                            iconColor: colorScheme.secondary,
                            onTap: () => widget.onNavigate('feedback-collection'),
                          ),
                        ],
                      );
                    }),
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
        },
      ),
    );
  }

  Widget _buildJoinLeaveBar(BuildContext context, EventActionsState state) {
    if (_isOwner) return const SizedBox.shrink();

    // Check if event has ended
    final isEventEnded = _isEventEnded();
    if (isEventEnded) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final isJoined = _currentEvent.isJoined;
    final isLoading = state is EventActionLoading;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: ElevatedButton(
          onPressed: isLoading
              ? null
              : () {
                  // Store previous state BEFORE optimistic update for success message
                  _previousJoinState = _currentEvent.isJoined;
                  
                  // Optimistically update UI immediately for better UX
                  final previousIsJoined = _currentEvent.isJoined;
                  final previousCount = _currentEvent.attendeeCount ?? 0;
                  
                  setState(() {
                    final newIsJoined = !_currentEvent.isJoined;
                    _currentEvent = Event(
                      id: _currentEvent.id,
                      name: _currentEvent.name,
                      description: _currentEvent.description,
                      location: _currentEvent.location,
                      type: _currentEvent.type,
                      date: _currentEvent.date,
                      endDate: _currentEvent.endDate,
                      duration: _currentEvent.duration,
                      audienceSize: _currentEvent.audienceSize,
                      planningMode: _currentEvent.planningMode,
                      status: _currentEvent.status,
                      createdAt: _currentEvent.createdAt,
                      createdBy: _currentEvent.createdBy,
                      attendeeCount: newIsJoined ? previousCount + 1 : (previousCount >= 1 ? previousCount - 1 : 0),
                      latitude: _currentEvent.latitude,
                      longitude: _currentEvent.longitude,
                      image: _currentEvent.image,
                      isJoined: newIsJoined,
                    );
                  });
                  
                  // Trigger the API call - listener will update with server response
                  context.read<EventActionsBloc>().add(
                        ToggleJoinLeave(eventId: _currentEvent.id, token: widget.token),
                      );
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: isJoined ? Colors.red.withOpacity(0.1) : theme.primaryColor,
            foregroundColor: isJoined ? Colors.red : Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            elevation: isJoined ? 0 : 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isJoined ? Icons.event_busy : Icons.event_available,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isJoined ? 'Leave This Event' : 'Join This Event',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.05),
                borderRadius: 12.radius,
              ),
              child: Icon(icon, size: 20, color: colorScheme.primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.hintColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    value,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (isClickable)
              Icon(Icons.chevron_right_rounded, color: theme.hintColor),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBadge(BuildContext context, String value, String label, IconData icon, Color color) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: 16.radius,
        border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(color: theme.hintColor),
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
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: 16.radius,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: 12.radius,
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
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

  String _formatTime(String dateStr) {
    try {
      final date = DateTime.parse(dateStr).toLocal();
      final hour = date.hour;
      final minute = date.minute;
      final period = hour >= 12 ? 'PM' : 'AM';
      final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
      return '${displayHour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
    } catch (e) {
      return '';
    }
  }

  String _formatDateTime(String dateStr) {
    try {
      final dateTime = DateTime.parse(dateStr).toLocal();
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      
      final date = '${days[dateTime.weekday - 1]}, ${months[dateTime.month - 1]} ${dateTime.day}, ${dateTime.year}';
      final time = _formatTime(dateStr);
      
      return '$date at $time';
    } catch (e) {
      return 'N/A';
    }
  }

  String _formatDateTimeRange(String startStr, String? endStr) {
    try {
      final start = DateTime.parse(startStr).toLocal();
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      
      String startFmt = '${months[start.month - 1]} ${start.day}, ${start.year}';
      String startTime = _formatTime(startStr);
      
      if (endStr != null && endStr.isNotEmpty) {
        final end = DateTime.parse(endStr).toLocal();
        String endTime = _formatTime(endStr);
        
        if (start.month == end.month && start.year == end.year) {
          if (start.day == end.day) {
            return '$startFmt\n$startTime - $endTime';
          }
          String endFmt = '${months[end.month - 1]} ${end.day}, ${start.year}';
          return '$startFmt - $endFmt\n$startTime - $endTime';
        }
        String endFmt = '${months[end.month - 1]} ${end.day}, ${end.year}';
        return '$startFmt - $endFmt\n$startTime - $endTime';
      }
      return '$startFmt\n$startTime';
    } catch (e) {
      return startStr;
    }
  }

  Future<void> _openLocationInMaps(BuildContext context) async {
    // Check if event has coordinates
    if (widget.event.latitude == null || widget.event.longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location coordinates not available'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      Position? userPosition;

      // Try to get user's current location
      if (kIsWeb) {
        // Web: Use browser geolocation API
        try {
          userPosition = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
          );
        } catch (e) {
          debugPrint('Error getting user location on web: $e');
          // Continue without user location - Google Maps will use browser location
        }
      } else {
        // Mobile: Use permission handler and geolocator
        final permissionStatus = await Permission.location.request();

        if (permissionStatus.isGranted) {
          try {
            // Check if location services are enabled
            bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
            if (serviceEnabled) {
              userPosition = await Geolocator.getCurrentPosition(
                desiredAccuracy: LocationAccuracy.high,
              );
            }
          } catch (e) {
            debugPrint('Error getting user location: $e');
            // Continue without user location - Google Maps will use device location
          }
        }
      }

      bool launched = false;

      // Web: Directly use web URL (no native apps available)
      if (kIsWeb) {
        try {
          String mapsUrl;
          if (userPosition != null) {
            // Include user location for directions
            mapsUrl = 'https://www.google.com/maps/dir/?api=1'
                '&origin=${userPosition.latitude},${userPosition.longitude}'
                '&destination=${widget.event.latitude},${widget.event.longitude}'
                '&travelmode=driving';
          } else {
            // Just destination - Google Maps will prompt for user location or use browser location
            mapsUrl = 'https://www.google.com/maps/dir/?api=1'
                '&destination=${widget.event.latitude},${widget.event.longitude}'
                '&travelmode=driving';
          }

          final uri = Uri.parse(mapsUrl);
          // On web, use platformDefault which opens in new tab (more reliable than externalApplication)
          // externalApplication might be blocked by browser pop-up blockers
          await launchUrl(uri, mode: LaunchMode.platformDefault);
          launched = true;
        } catch (e) {
          debugPrint('Failed to launch web maps: $e');
          // Show error message on web if launch fails
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Could not open Google Maps. Please check your browser settings.'),
                backgroundColor: Colors.red,
                action: SnackBarAction(
                  label: 'Retry',
                  textColor: Colors.white,
                  onPressed: () => _openLocationInMaps(context),
                ),
              ),
            );
          }
        }
      }

      // Try different URL schemes based on platform (skip if web, already handled)
      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
        // Android: Try multiple schemes with error handling
        List<Uri> urisToTry = [];

        if (userPosition != null) {
          // Try google.navigation: for turn-by-turn navigation
          urisToTry.add(Uri.parse(
            'google.navigation:q=${widget.event.latitude},${widget.event.longitude}',
          ));

          // Try comgooglemaps:// with directions
          urisToTry.add(Uri.parse(
            'comgooglemaps://?saddr=${userPosition.latitude},${userPosition.longitude}&daddr=${widget.event.latitude},${widget.event.longitude}&directionsmode=driving',
          ));
        }

        // Try geo: scheme (works with any map app)
        urisToTry.add(Uri.parse(
          'geo:${widget.event.latitude},${widget.event.longitude}?q=${widget.event.latitude},${widget.event.longitude}(${Uri.encodeComponent(widget.event.name)})',
        ));

        // Try comgooglemaps:// without directions
        urisToTry.add(Uri.parse(
          'comgooglemaps://?q=${widget.event.latitude},${widget.event.longitude}',
        ));

        // Try each URI
        for (final uri in urisToTry) {
          try {
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
              launched = true;
              break;
            }
          } catch (e) {
            debugPrint('Failed to launch $uri: $e');
            continue;
          }
        }
      } else if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
        // iOS: Try Apple Maps first, then Google Maps
        List<Uri> urisToTry = [];

        if (userPosition != null) {
          urisToTry.add(Uri.parse(
            'http://maps.apple.com/?saddr=${userPosition.latitude},${userPosition.longitude}&daddr=${widget.event.latitude},${widget.event.longitude}&dirflg=d',
          ));
        } else {
          urisToTry.add(Uri.parse(
            'http://maps.apple.com/?q=${widget.event.latitude},${widget.event.longitude}',
          ));
        }

        // Fallback to Google Maps on iOS
        urisToTry.add(Uri.parse(
          'comgooglemaps://?q=${widget.event.latitude},${widget.event.longitude}',
        ));

        for (final uri in urisToTry) {
          try {
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
              launched = true;
              break;
            }
          } catch (e) {
            debugPrint('Failed to launch $uri: $e');
            continue;
          }
        }
      }

      // Fallback to web URL for all platforms (always works)
      if (!launched) {
        try {
          String mapsUrl;
          if (userPosition != null) {
            mapsUrl = 'https://www.google.com/maps/dir/?api=1'
                '&origin=${userPosition.latitude},${userPosition.longitude}'
                '&destination=${widget.event.latitude},${widget.event.longitude}'
                '&travelmode=driving';
          } else {
            mapsUrl = 'https://www.google.com/maps/dir/?api=1'
                '&destination=${widget.event.latitude},${widget.event.longitude}'
                '&travelmode=driving';
          }

          final uri = Uri.parse(mapsUrl);
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          launched = true;
        } catch (e) {
          debugPrint('Failed to launch web maps: $e');
        }
      }

      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open maps application. Please install Google Maps.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error opening maps: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening maps: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
