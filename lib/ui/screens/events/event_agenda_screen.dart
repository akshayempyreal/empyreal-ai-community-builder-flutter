import 'package:empyreal_ai_community_builder_flutter/models/agenda_item.dart';
import 'package:empyreal_ai_community_builder_flutter/models/event.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/buttons/primary_button.dart';
import '../../../core/animation/app_animations.dart';

class EventAgendaScreen extends StatefulWidget {
  final Event event;
  final List<AgendaItem> agendaItems;
  final VoidCallback onBack;
  final VoidCallback onEditAgenda;

  const EventAgendaScreen({
    super.key,
    required this.event,
    required this.agendaItems,
    required this.onBack,
    required this.onEditAgenda,
  });

  @override
  State<EventAgendaScreen> createState() => _EventAgendaScreenState();
}

class _EventAgendaScreenState extends State<EventAgendaScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppAnimations.normal,
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBack,
        ),
        title: const Text('Event Agenda'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: widget.onEditAgenda,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, isDark),
            Expanded(
              child: _buildAgendaContent(context, isDark),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        border: Border(bottom: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.calendar_today, color: AppColors.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.event.name,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  widget.event.agenda != null && widget.event.agenda!.isNotEmpty
                      ? 'Agenda available'
                      : '${widget.agendaItems.length} items scheduled',
                  style: const TextStyle(color: AppColors.slate500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.event_note, size: 80, color: AppColors.slate300),
            const SizedBox(height: 24),
            Text(
              'Your agenda is empty',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'Let AI help you build a professional schedule for your community in seconds.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.slate500),
            ),
            const SizedBox(height: 32),
            PrimaryButton(
              text: 'Plan with AI',
              icon: Icons.auto_awesome,
              width: 200,
              onPressed: widget.onEditAgenda,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAgendaContent(BuildContext context, bool isDark) {
    // If event has agenda text, display it; otherwise show agenda items
    if (widget.event.agenda != null && widget.event.agenda!.isNotEmpty) {
      return _buildAgendaText(context, isDark);
    } else if (widget.agendaItems.isEmpty) {
      return _buildEmptyState(context, isDark);
    } else {
      return _buildAgendaList(context, isDark);
    }
  }

  Widget _buildAgendaText(BuildContext context, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.description, color: AppColors.primary, size: 24),
                  const SizedBox(width: 12),
                  Text(
                    'Event Agenda',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 24),
              // Display agenda text with basic formatting
              _buildFormattedAgendaText(widget.event.agenda!),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormattedAgendaText(String agendaText) {
    // Simple text formatting - can be enhanced with markdown package if needed
    final lines = agendaText.split('\n');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lines.map((line) {
        if (line.trim().isEmpty) {
          return const SizedBox(height: 12);
        }
        
        // Check if line is a heading (starts with # or **)
        final isHeading = line.trim().startsWith('#') || 
                         (line.trim().startsWith('**') && line.trim().endsWith('**'));
        final isBold = line.trim().startsWith('**') && line.trim().endsWith('**');
        
        // Remove markdown syntax for display
        String displayText = line;
        if (displayText.startsWith('#')) {
          displayText = displayText.replaceFirst(RegExp(r'^#+\s*'), '');
        }
        if (displayText.startsWith('**') && displayText.endsWith('**')) {
          displayText = displayText.substring(2, displayText.length - 2);
        }
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            displayText,
            style: TextStyle(
              fontSize: isHeading ? 18 : 16,
              fontWeight: isHeading || isBold ? FontWeight.bold : FontWeight.normal,
              height: 1.6,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAgendaList(BuildContext context, bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32) + const EdgeInsets.only(bottom: 80),
      itemCount: widget.agendaItems.length,
      itemBuilder: (context, index) {
        final item = widget.agendaItems[index];
        return AppAnimations.staggeredEntrance(
          _AgendaTimelineItem(
            item: item,
            isFirst: index == 0,
            isLast: index == widget.agendaItems.length - 1,
          ),
          index,
          _controller,
        );
      },
    );
  }
}

class _AgendaTimelineItem extends StatelessWidget {
  final AgendaItem item;
  final bool isFirst;
  final bool isLast;

  const _AgendaTimelineItem({
    required this.item,
    required this.isFirst,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final Color itemColor;
    switch(item.type.toLowerCase()) {
      case 'break': itemColor = AppColors.success; break;
      case 'session': itemColor = AppColors.primary; break;
      case 'activity': itemColor = AppColors.secondary; break;
      default: itemColor = AppColors.primary;
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTimeline(context, itemColor),
          const SizedBox(width: 20),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 24),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isDark ? AppColors.borderDark.withOpacity(0.5) : AppColors.borderLight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${item.startTime} - ${item.endTime}',
                        style: TextStyle(
                          color: itemColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: itemColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          item.type.toUpperCase(),
                          style: TextStyle(color: itemColor, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    item.title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  if (item.description != null && item.description!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      item.description!,
                      style: const TextStyle(color: AppColors.slate500, fontSize: 14, height: 1.4),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline(BuildContext context, Color color) {
    return Column(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2),
          ),
        ),
        if (!isLast)
          Expanded(
            child: Container(
              width: 2,
              color: AppColors.slate200.withOpacity(0.5),
            ),
          ),
      ],
    );
  }
}
