import 'package:empyreal_ai_community_builder_flutter/models/attendee.dart';
import 'package:empyreal_ai_community_builder_flutter/models/event.dart';
import 'package:empyreal_ai_community_builder_flutter/models/user.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: onBack,
        ),
        title: const Text('Attendees'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchHeader(context, isDark),
          Expanded(
            child: attendees.isEmpty
                ? _buildEmptyState(context)
                : _buildAttendeeList(context, isDark),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.person_add, color: Colors.white),
      ),
    );
  }

  Widget _buildSearchHeader(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        border: Border(bottom: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight)),
      ),
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: 'Search attendees...',
              prefixIcon: const Icon(Icons.search),
              fillColor: isDark ? AppColors.slate900 : AppColors.slate50,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${attendees.length} Members',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  _FilterChip(label: 'All', isActive: true),
                  const SizedBox(width: 8),
                  _FilterChip(label: 'Pending', isActive: false),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 64, color: AppColors.slate300),
          const SizedBox(height: 16),
          const Text('No attendees yet', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const Text('Start adding members to your community.', style: TextStyle(color: AppColors.slate500)),
        ],
      ),
    );
  }

  Widget _buildAttendeeList(BuildContext context, bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: attendees.length,
      itemBuilder: (context, index) {
        final attendee = attendees[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              backgroundColor: AppColors.primary.withOpacity(0.1),
              child: Text(
                attendee.name[0].toUpperCase(),
                style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
              ),
            ),
            title: Text(attendee.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(attendee.email, style: TextStyle(color: AppColors.slate500)),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Confirmed',
                style: TextStyle(color: AppColors.success, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isActive;

  const _FilterChip({required this.label, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isActive ? AppColors.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: isActive ? null : Border.all(color: AppColors.borderLight),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isActive ? Colors.white : AppColors.slate500,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
