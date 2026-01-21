import 'package:empyreal_ai_community_builder_flutter/models/agenda_item.dart';
import 'package:empyreal_ai_community_builder_flutter/models/event.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class EventAgendaScreen extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 800;

    return Scaffold(
      backgroundColor: AppColors.gray50,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: onBack,
        ),
        title: const Text('Event Agenda'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_calendar_outlined),
            tooltip: 'Edit agenda',
            onPressed: onEditAgenda,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: onEditAgenda,
        child: const Icon(Icons.auto_awesome),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final horizontalPadding = isWide ? 32.0 : 16.0;

                return SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    16,
                    horizontalPadding,
                    24,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDayTabs(context),
                      const SizedBox(height: 16),
                      _buildTimeline(context),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildDayTabs(BuildContext context) {
    // For now we assume a single-day event; tabs are static but styled
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Oct 24',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.info,
              ),
            ),
            Text(
              'Oct 25',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.gray400,
              ),
            ),
            Text(
              'Oct 26',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.gray400,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text(
              'DAY 1',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.info,
                letterSpacing: 1.2,
              ),
            ),
            Text(
              'DAY 2',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.gray400,
                letterSpacing: 1.2,
              ),
            ),
            Text(
              'DAY 3',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.gray400,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          height: 2,
          decoration: const BoxDecoration(
            color: AppColors.gray200,
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: 1 / 3,
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.info,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeline(BuildContext context) {
    // If there are no agenda items, show an empty state
    if (agendaItems.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 48.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.event_busy, size: 56, color: AppColors.gray300),
            const SizedBox(height: 16),
            const Text(
              'No agenda items yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.gray800,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Use AI planning or manual editor to build your schedule.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.gray500,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onEditAgenda,
              icon: const Icon(Icons.auto_awesome),
              label: const Text('Start planning with AI'),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Time range label for the first item
        if (agendaItems.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 56.0, bottom: 8.0),
            child: Text(
              '${agendaItems.first.startTime} - ${agendaItems.first.endTime}',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.gray700,
              ),
            ),
          ),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            final item = agendaItems[index];
            final isFirst = index == 0;
            final isLast = index == agendaItems.length - 1;

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTimelineRail(
                  context,
                  index: index,
                  isFirst: isFirst,
                  isLast: isLast,
                  type: item.type,
                ),
                const SizedBox(width: 12),
                Expanded(child: _buildAgendaCard(context, item)),
              ],
            );
          },
          separatorBuilder: (_, __) => const SizedBox(height: 20),
          itemCount: agendaItems.length,
        ),
      ],
    );
  }

  Widget _buildTimelineRail(
    BuildContext context, {
    required int index,
    required bool isFirst,
    required bool isLast,
    required String type,
  }) {
    final Color iconBg;
    final IconData icon;

    switch (type) {
      case 'break':
        iconBg = const Color(0xFFDCFCE7);
        icon = Icons.local_cafe;
        break;
      case 'activity':
        iconBg = const Color(0xFFE0F2FE);
        icon = Icons.group;
        break;
      case 'ceremony':
        iconBg = const Color(0xFFFEF3C7);
        icon = Icons.emoji_events;
        break;
      default:
        iconBg = const Color(0xFFE0E7FF);
        icon = Icons.auto_awesome;
    }

    return SizedBox(
      width: 40,
      child: Column(
        children: [
          if (!isFirst)
            Container(
              height: 24,
              width: 2,
              color: AppColors.gray200,
            ),
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: iconBg,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 18,
              color: AppColors.info,
            ),
          ),
          if (!isLast)
            Container(
              height: 48,
              width: 2,
              color: AppColors.gray200,
            ),
        ],
      ),
    );
  }

  Widget _buildAgendaCard(BuildContext context, AgendaItem item) {
    final isSession = item.type == 'session' || item.type == 'ceremony';
    final Color borderColor;

    switch (item.type) {
      case 'break':
        borderColor = const Color(0xFF22C55E);
        break;
      case 'activity':
        borderColor = const Color(0xFFF97316);
        break;
      default:
        borderColor = AppColors.info;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border(
          left: BorderSide(
            color: borderColor,
            width: 3,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.indigo100,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        item.type.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                          color: AppColors.primaryIndigo,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.auto_awesome,
                      size: 14,
                      color: AppColors.info,
                    ),
                    const SizedBox(width: 4),
                    const Flexible(
                      child: Text(
                        'Generated by AI',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AppColors.gray500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${item.startTime} - ${item.endTime}',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.gray600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            item.title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.gray900,
            ),
          ),
          if (isSession) ...[
            const SizedBox(height: 12),
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF4C1D95),
                      Color(0xFF7C3AED),
                    ],
                  ),
                ),
              ),
            ),
          ],
          if (item.description != null && item.description!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              item.description!,
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
                color: AppColors.gray600,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: onEditAgenda,
              icon: const Icon(Icons.edit, size: 16),
              label: const Text('Edit'),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                foregroundColor: AppColors.info,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 600;
    if (isWide) return const SizedBox.shrink();

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: AppColors.gray200),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildNavItem(Icons.home, 'Home', false),
              _buildNavItem(Icons.event_available, 'Agenda', true),
              _buildNavItem(Icons.people_alt, 'People', false),
              _buildNavItem(Icons.settings, 'Settings', false),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 22,
          color: isActive ? AppColors.info : AppColors.gray400,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            color: isActive ? AppColors.info : AppColors.gray400,
          ),
        ),
      ],
    );
  }
}

