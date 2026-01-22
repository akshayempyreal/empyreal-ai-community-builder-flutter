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
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

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

  @override
  void initState() {
    super.initState();
    _currentEvent = widget.event;
  }

  bool get _isOwner => widget.user.id == _currentEvent.createdBy;

  Future<void> _showEditDialog() async {
    final nameController = TextEditingController(text: _currentEvent.name);

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
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
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, nameController.text),
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

    return Scaffold(
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
              onPressed: _isLoading ? null : _showEditDialog,
              tooltip: 'Edit Event',
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
                                      StatusBadge(status: _currentEvent.status),
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
                              Icons.calendar_today_rounded,
                              'Schedule',
                              _formatDateRange(_currentEvent.date, _currentEvent.endDate),
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
                            subtitle: '${widget.attendees.length} registered',
                            icon: Icons.people,
                            iconColor: Colors.green,
                            onTap: () => widget.onNavigate('attendees'),
                          ),
                          _buildActionCard(
                            context,
                            title: 'Feedback',
                            subtitle: 'Collect responses',
                            icon: Icons.feedback,
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
                    maxLines: 1,
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

  Future<void> _openLocationInMaps(BuildContext context) async {
    // Check if event has coordinates
    if (event.latitude == null || event.longitude == null) {
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
                '&destination=${event.latitude},${event.longitude}'
                '&travelmode=driving';
          } else {
            // Just destination - Google Maps will prompt for user location or use browser location
            mapsUrl = 'https://www.google.com/maps/dir/?api=1'
                '&destination=${event.latitude},${event.longitude}'
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
            'google.navigation:q=${event.latitude},${event.longitude}',
          ));

          // Try comgooglemaps:// with directions
          urisToTry.add(Uri.parse(
            'comgooglemaps://?saddr=${userPosition.latitude},${userPosition.longitude}&daddr=${event.latitude},${event.longitude}&directionsmode=driving',
          ));
        }

        // Try geo: scheme (works with any map app)
        urisToTry.add(Uri.parse(
          'geo:${event.latitude},${event.longitude}?q=${event.latitude},${event.longitude}(${Uri.encodeComponent(event.name)})',
        ));

        // Try comgooglemaps:// without directions
        urisToTry.add(Uri.parse(
          'comgooglemaps://?q=${event.latitude},${event.longitude}',
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
            'http://maps.apple.com/?saddr=${userPosition.latitude},${userPosition.longitude}&daddr=${event.latitude},${event.longitude}&dirflg=d',
          ));
        } else {
          urisToTry.add(Uri.parse(
            'http://maps.apple.com/?q=${event.latitude},${event.longitude}',
          ));
        }

        // Fallback to Google Maps on iOS
        urisToTry.add(Uri.parse(
          'comgooglemaps://?q=${event.latitude},${event.longitude}',
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
                '&destination=${event.latitude},${event.longitude}'
                '&travelmode=driving';
          } else {
            mapsUrl = 'https://www.google.com/maps/dir/?api=1'
                '&destination=${event.latitude},${event.longitude}'
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
