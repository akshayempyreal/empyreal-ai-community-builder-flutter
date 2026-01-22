import 'package:flutter/material.dart';
import '../models/event.dart';
import '../core/theme/app_theme.dart';
import '../core/animation/app_animations.dart';
import 'status_badge.dart';
import '../project_helpers.dart';


class EventCard extends StatefulWidget {
  final Event event;
  final VoidCallback onTap;

  const EventCard({
    super.key,
    required this.event,
    required this.onTap,
  });

  @override
  State<EventCard> createState() => _EventCardState();
}

class _EventCardState extends State<EventCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppAnimations.fast,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _controller.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _controller.reverse();
      },
      child: AnimatedContainer(
        duration: AppAnimations.fast,
        curve: Curves.easeInOut,
        transform: Matrix4.identity()..scale(_scaleAnimation.value),
        child: Card(
          elevation: _isHovered ? 4 : 0,
          shadowColor: colorScheme.primary.withOpacity(0.15),
          clipBehavior: Clip.antiAlias,
          shape: 16.roundBorder.copyWith(
            side: BorderSide(
              color: _isHovered 
                  ? colorScheme.primary.withOpacity(0.3)
                  : (isDark ? colorScheme.outline.withOpacity(0.2) : AppColors.gray200),
              width: _isHovered ? 1.5 : 1.0,
            ),
          ),
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Adjust image height based on available space
            final imageHeight = constraints.maxHeight > 0 
                ? (constraints.maxHeight * 0.4).clamp(100.0, 160.0) 
                : 140.0;

            return SizedBox(
              height: constraints.maxHeight > 0 ? constraints.maxHeight : null,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max, // Fill available space in grid
                children: [
                // Event Image or Placeholder
                SizedBox(
                  height: imageHeight,
                  width: double.infinity,
                  child: _buildImage(imageHeight),
                ),

                // Content Area
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                      // Header: Status and Type
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          StatusBadge(status: widget.event.status),
                          Flexible(
                            child: Text(
                              widget.event.type.upper,
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                color: theme.hintColor,
                                letterSpacing: 1.2,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Event Name
                      Text(
                        widget.event.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),

                      // Description
                      Text(
                        widget.event.description,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      const SizedBox(height: 16),

                      // Details Wrap - Replaces Row to prevent horizontal overflow
                      Wrap(
                        spacing: 12,
                        runSpacing: 8,
                        children: [
                          _buildCompactInfo(context, Icons.calendar_today_rounded, _formatDateRange(widget.event.date, widget.event.endDate)),
                          _buildCompactInfo(context, Icons.timer_rounded, '${widget.event.duration}h/day'),
                          _buildCompactInfo(context, Icons.group_rounded, '${widget.event.attendeeCount ?? 0} members'),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Footer Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: isDark ? colorScheme.surfaceVariant : AppColors.gray50,
                                borderRadius: 8.radius,
                                border: Border.all(
                                  color: isDark ? colorScheme.outline.withOpacity(0.2) : AppColors.gray200,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    widget.event.planningMode == 'automated' ? Icons.auto_awesome : Icons.edit_note,
                                    size: 14,
                                    color: colorScheme.primary,
                                  ),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: Text(
                                      widget.event.planningMode == 'automated' ? 'AI Planned' : 'Manual',
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Icon(Icons.arrow_forward_rounded, size: 18, color: theme.hintColor),
                        ],
                      ),
                    ],
                    ),
                  ),
                ),
                ],
              ),
            );
          },
        ),
          ),
        ),
      ),
    );
  }

  Widget _buildImage(double height) {
    if (widget.event.image != null && widget.event.image!.isNotEmpty) {
      return Image.network(
        widget.event.image!.fixImageUrl,
        height: height,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(height, Icons.broken_image_outlined),
      );
    }
    return _buildPlaceholder(height, Icons.image_outlined);
  }

  Widget _buildPlaceholder(double height, IconData icon) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      height: height,
      width: double.infinity,
      color: colorScheme.primaryContainer.withOpacity(0.3),
      child: Icon(icon, color: colorScheme.primary, size: 48),
    );
  }

  Widget _buildCompactInfo(BuildContext context, IconData icon, String text) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: theme.colorScheme.primary),
          const SizedBox(width: 6),
          Text(
            text,
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateRange(String startStr, String? endStr) {
    try {
      final start = DateTime.parse(startStr);
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      
      String startFmt = '${months[start.month - 1]} ${start.day}';
      
      if (endStr != null && endStr.isNotEmpty) {
        final end = DateTime.parse(endStr);
        if (start.month == end.month && start.year == end.year) {
          if (start.day == end.day) return startFmt;
          return '${months[start.month - 1]} ${start.day}-${end.day}';
        }
        return '$startFmt - ${months[end.month - 1]} ${end.day}';
      }
      return startFmt;
    } catch (e) {
      return startStr;
    }
  }
}
