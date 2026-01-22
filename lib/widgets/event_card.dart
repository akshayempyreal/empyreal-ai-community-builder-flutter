import 'package:flutter/material.dart';
import '../models/event.dart';
import '../core/theme/app_theme.dart';
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

class _EventCardState extends State<EventCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: 16.roundBorder.copyWith(
        side: const BorderSide(color: AppColors.gray200),
      ),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: 16.radius,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event Image or Placeholder
            if (widget.event.image != null && widget.event.image!.isNotEmpty)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.network(
                  widget.event.image!.fixImageUrl,
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 160,
                    width: double.infinity,
                    color: AppColors.indigo100,
                    child: const Icon(Icons.broken_image_outlined, color: AppColors.primaryIndigo, size: 48),
                  ),
                ),
              )
            else
              Container(
                height: 160,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.indigo100,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: const Icon(Icons.image_outlined, color: AppColors.primaryIndigo, size: 48),
              ),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    StatusBadge(status: widget.event.status),
                    Text(
                      widget.event.type.upper,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: AppColors.gray400,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
                12.height(context),

                Text(
                  widget.event.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.gray900,
                    letterSpacing: -0.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                4.height(context),

                Text(
                  widget.event.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.gray600,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                20.height(context),

                // Details Grid - Clean logistics hub
                Row(
                  children: [
                    _buildCompactInfo(Icons.calendar_today_rounded, _formatDate(widget.event.date)),
                    const Spacer(),
                    _buildCompactInfo(Icons.timer_rounded, '${widget.event.duration}h/day'),
                    const Spacer(),
                    _buildCompactInfo(Icons.group_rounded, '${widget.event.attendeeCount ?? 0} members'),
                  ],
                ),

                20.height(context),

                // Footer Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.gray50,
                        borderRadius: 8.radius,
                        border: Border.all(color: AppColors.gray200),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            widget.event.planningMode == 'automated' ? Icons.auto_awesome : Icons.edit_note,
                            size: 14,
                            color: AppColors.primaryIndigo,
                          ),
                          8.width,
                          Text(
                            widget.event.planningMode == 'automated' ? 'AI Planned' : 'Manual',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.gray700,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_rounded, size: 18, color: AppColors.gray400),
                  ],
                ),
              ],
            ).paddingAll(context, 20),
          ],
        ),
      ),

    );
  }

  Widget _buildCompactInfo(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.primaryIndigo),
        6.width,
        Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.gray600,
          ),
        ),
      ],
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${months[date.month - 1]} ${date.day}, ${date.year}';
    } catch (e) {
      return dateStr;
    }
  }
}
