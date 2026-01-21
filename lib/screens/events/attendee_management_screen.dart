import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../../models/event.dart';
import '../../models/attendee.dart';
import '../../theme/app_theme.dart';

class AttendeeManagementScreen extends StatelessWidget {
  final Event event;
  final List<Attendee> attendees;
  final Function(Attendee) onAddAttendee;
  final VoidCallback onBack;
  final User user;

  const AttendeeManagementScreen({
    super.key,
    required this.event,
    required this.attendees,
    required this.onAddAttendee,
    required this.onBack,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: AppTheme.gray50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: onBack,
        ),
        title: const Text(
          'Attendee Management',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.ios_share_outlined),
            tooltip: 'Export / share',
            onPressed: () {},
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(isMobile),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: isMobile
          ? FloatingActionButton(
              onPressed: () {
                // Placeholder: in a real app you'd open a form / scanner.
                // onAddAttendee(...);
              },
              child: const Icon(Icons.person_add_alt_1),
            )
          : null,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, viewport) {
            final horizontalPadding = isMobile ? 16.0 : 32.0;
            final maxWidth = viewport.maxWidth >= 1100 ? 900.0 : 720.0;

            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                16,
                horizontalPadding,
                isMobile ? 80 : 32,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSearchAndFilters(context),
                      const SizedBox(height: 24),
                      _buildHeaderRow(context),
                      const SizedBox(height: 8),
                      _buildAttendeeList(context),
                      const SizedBox(height: 32),
                      _buildEndOfList(),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSearchAndFilters(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search field
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const TextField(
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.search, color: AppTheme.gray400),
              hintText: 'Search by name or email...',
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Filter chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildFilterChip('All', isSelected: true),
              const SizedBox(width: 12),
              _buildFilterChip('Checked-in'),
              const SizedBox(width: 12),
              _buildFilterChip('Registered'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, {bool isSelected = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected ? AppTheme.blue600 : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: isSelected ? null : Border.all(color: AppTheme.gray200),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: AppTheme.blue600.withOpacity(0.35),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: isSelected ? Colors.white : AppTheme.gray700,
        ),
      ),
    );
  }

  Widget _buildHeaderRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(
              '${attendees.length}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppTheme.gray900,
              ),
            ),
            const SizedBox(width: 6),
            const Text(
              'ATTENDEES',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.4,
                color: AppTheme.gray500,
              ),
            ),
          ],
        ),
        TextButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.download_rounded, size: 18),
          label: const Text('Export List'),
          style: TextButton.styleFrom(
            backgroundColor: AppTheme.indigo100,
            foregroundColor: AppTheme.blue600,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAttendeeList(BuildContext context) {
    if (attendees.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 32.0),
        child: Column(
          children: const [
            Icon(Icons.people_outline, size: 56, color: AppTheme.gray300),
            SizedBox(height: 12),
            Text(
              'No attendees yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.gray800,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: attendees.length,
      separatorBuilder: (_, __) => const Divider(height: 1, color: AppTheme.gray100),
      itemBuilder: (context, index) {
        final attendee = attendees[index];
        final isCheckedIn = attendee.status == 'confirmed' || attendee.status == 'checked-in';

        return Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppTheme.indigo100,
                child: Text(
                  attendee.name.isNotEmpty ? attendee.name[0].toUpperCase() : '?',
                  style: const TextStyle(
                    color: AppTheme.primaryIndigo,
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      attendee.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.gray900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      attendee.email,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.blue600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildStatusPill(isCheckedIn ? 'CHECKED-IN' : 'REGISTERED', isCheckedIn),
                  const SizedBox(height: 6),
                  const Text(
                    '2m ago',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppTheme.gray400,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusPill(String label, bool isCheckedIn) {
    final bgColor = isCheckedIn ? const Color(0xFFDCFCE7) : const Color(0xFFDBEAFE);
    final textColor = isCheckedIn ? const Color(0xFF16A34A) : const Color(0xFF1D4ED8);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildEndOfList() {
    return Column(
      children: const [
        SizedBox(height: 24),
        Icon(Icons.groups_rounded, size: 40, color: AppTheme.gray300),
        SizedBox(height: 8),
        Text(
          'End of list',
          style: TextStyle(
            fontSize: 14,
            color: AppTheme.gray400,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNav(bool isMobile) {
    if (!isMobile) return const SizedBox.shrink();

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppTheme.gray200)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildNavItem(Icons.event, 'Event', false),
              _buildNavItem(Icons.people_alt, 'Attendees', true),
              _buildNavItem(Icons.qr_code_scanner, 'Scanner', false),
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
          color: isActive ? AppTheme.blue600 : AppTheme.gray400,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            color: isActive ? AppTheme.blue600 : AppTheme.gray400,
          ),
        ),
      ],
    );
  }
}
