import 'package:empyreal_ai_community_builder_flutter/models/event.dart';
import 'package:empyreal_ai_community_builder_flutter/models/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/animation/app_animations.dart';
import '../../../blocs/attendee/attendee_bloc.dart';
import '../../../blocs/attendee/attendee_event.dart';
import '../../../blocs/attendee/attendee_state.dart';
import '../../../models/event_api_models.dart';

class AttendeeManagementScreen extends StatefulWidget {
  final Event event;
  final VoidCallback onBack;
  final User user;
  final String token;

  const AttendeeManagementScreen({
    super.key,
    required this.event,
    required this.onBack,
    required this.user,
    required this.token,
  });

  @override
  State<AttendeeManagementScreen> createState() => _AttendeeManagementScreenState();
}

class _AttendeeManagementScreenState extends State<AttendeeManagementScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppAnimations.normal,
    )..forward();
    
    // Fetch attendees when screen loads
    context.read<AttendeeBloc>().add(
      FetchAttendeeList(
        eventId: widget.event.id,
        token: widget.token,
      ),
    );
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
        title: const Text('Attendees'),
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.download_outlined),
        //     onPressed: () {},
        //   ),
        // ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchHeader(context, isDark),
            Expanded(
              child: BlocBuilder<AttendeeBloc, AttendeeState>(
                builder: (context, state) {
                  if (state is AttendeeLoading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (state is AttendeeFailure) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, size: 64, color: AppColors.error),
                          const SizedBox(height: 16),
                          Text(
                            'Failed to load attendees',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            state.error,
                            style: TextStyle(color: AppColors.slate500),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: () {
                              context.read<AttendeeBloc>().add(
                                FetchAttendeeList(
                                  eventId: widget.event.id,
                                  token: widget.token,
                                ),
                              );
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  } else if (state is AttendeeSuccess) {
                    final members = state.response.data?.members ?? [];
                    final filteredMembers = _filterMembers(members, _searchQuery);
                    
                    if (filteredMembers.isEmpty) {
                      return _buildEmptyState(context);
                    }
                    
                    return _buildAttendeeList(context, isDark, filteredMembers, state.response.data?.total ?? 0);
                  }
                  return _buildEmptyState(context);
                },
              ),
            ),
          ],
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {},
      //   backgroundColor: AppColors.primary,
      //   child: const Icon(Icons.person_add, color: Colors.white),
      // ),
    );
  }

  List<MemberData> _filterMembers(List<MemberData> members, String query) {
    if (query.isEmpty) return members;
    final lowerQuery = query.toLowerCase();
    return members.where((member) {
      final name = member.userId.name.toLowerCase();
      final email = member.userId.email?.toLowerCase() ?? '';
      final mobileNo = member.userId.mobileNo.toLowerCase();
      return name.contains(lowerQuery) || 
             email.contains(lowerQuery) || 
             mobileNo.contains(lowerQuery);
    }).toList();
  }

  Widget _buildSearchHeader(BuildContext context, bool isDark) {
    return BlocBuilder<AttendeeBloc, AttendeeState>(
      builder: (context, state) {
        final totalMembers = state is AttendeeSuccess 
            ? (state.response.data?.total ?? 0)
            : 0;
            
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
                  filled: true,
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$totalMembers Members',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        );
      },
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

  Widget _buildAttendeeList(BuildContext context, bool isDark, List<MemberData> members, int totalMembers) {
    return ListView.builder(
      padding: const EdgeInsets.all(24) + const EdgeInsets.only(bottom: 80),
      itemCount: members.length,
      itemBuilder: (context, index) {
        final member = members[index];
        final user = member.userId;
        final displayName = user.name.isNotEmpty ? user.name : 'Unknown';
        final displayEmail = user.email ?? user.mobileNo;
        final initials = displayName.isNotEmpty 
            ? displayName[0].toUpperCase() 
            : '?';
        
        return AppAnimations.staggeredEntrance(
          Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: user.profilePic != null && user.profilePic!.isNotEmpty
                  ? CircleAvatar(
                      backgroundImage: NetworkImage(user.profilePic!),
                      onBackgroundImageError: (_, __) {},
                    )
                  : CircleAvatar(
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      child: Text(
                        initials,
                        style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                      ),
                    ),
              title: Text(displayName, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (user.email != null && user.email!.isNotEmpty)
                    Text(user.email!, style: TextStyle(color: AppColors.slate500)),
                  Text(user.mobileNo, style: TextStyle(color: AppColors.slate500, fontSize: 12)),
                  if (member.feedback.trim().isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.format_quote_rounded, size: 14, color: AppColors.primary.withOpacity(0.5)),
                              const SizedBox(width: 4),
                              const Text('Feedback', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            member.feedback,
                            style: const TextStyle(
                              fontSize: 13,
                              fontStyle: FontStyle.italic,
                              color: AppColors.slate700,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Member',
                  style: TextStyle(color: AppColors.success, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          index,
          _controller,
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
