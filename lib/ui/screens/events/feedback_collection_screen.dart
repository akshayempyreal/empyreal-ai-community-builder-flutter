import 'package:empyreal_ai_community_builder_flutter/models/event.dart';
import 'package:empyreal_ai_community_builder_flutter/models/event_api_models.dart';
import 'package:empyreal_ai_community_builder_flutter/repositories/event_repository.dart';
import 'package:empyreal_ai_community_builder_flutter/services/api_client.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/animation/app_animations.dart';
import 'package:intl/intl.dart';

class FeedbackCollectionScreen extends StatefulWidget {
  final Event event;
  final String token;
  final VoidCallback onBack;

  const FeedbackCollectionScreen({
    super.key,
    required this.event,
    required this.token,
    required this.onBack,
  });

  @override
  State<FeedbackCollectionScreen> createState() => _FeedbackCollectionScreenState();
}

class _FeedbackCollectionScreenState extends State<FeedbackCollectionScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  List<MemberData> _feedbackList = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppAnimations.normal,
    )..forward();
    _fetchFeedback();
  }

  Future<void> _fetchFeedback() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final repository = EventRepository(ApiClient());
      final response = await repository.getMemberList(widget.event.id, widget.token, limit: 100);
      
      if (response.status && response.data != null) {
        setState(() {
          // Filter members who actually left feedback
          _feedbackList = response.data!.members
              .where((m) => m.feedback.trim().isNotEmpty)
              .toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = response.message;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBack,
        ),
        title: const Text('Event Reviews'),
        elevation: 0,
      ),
      body: SafeArea(
        child: _isLoading 
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? _buildErrorState()
                : _feedbackList.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _fetchFeedback,
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildStatBanner(context),
                              const SizedBox(height: 32),
                              Text(
                                'Community Feedback',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 16),
                              ...List.generate(_feedbackList.length, (index) {
                                return AppAnimations.staggeredEntrance(
                                  _buildMemberFeedbackCard(context, _feedbackList[index], isDark),
                                  index + 1,
                                  _controller,
                                );
                              }),
                            ],
                          ),
                        ),
                      ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.rate_review_outlined, size: 64, color: AppColors.slate300),
          const SizedBox(height: 16),
          const Text(
            'No feedback yet',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Attendees haven\'t shared their thoughts yet.',
            style: TextStyle(color: AppColors.slate500),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(_error!, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _fetchFeedback,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBanner(BuildContext context) {
    return AppAnimations.staggeredEntrance(
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            )
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _StatItem(
              label: 'Total Reviews', 
              value: _feedbackList.length.toString(), 
              icon: Icons.forum_rounded
            ),
            Container(width: 1, height: 40, color: Colors.white.withOpacity(0.2)),
            const _StatItem(
              label: 'Avg Mood', 
              value: 'Positive', 
              icon: Icons.sentiment_satisfied_alt_rounded
            ),
          ],
        ),
      ),
      0,
      _controller,
    );
  }

  Widget _buildMemberFeedbackCard(BuildContext context, MemberData member, bool isDark) {
    final theme = Theme.of(context);
    final user = member.userId;
    
    String formattedDate = '';
    try {
      final date = DateTime.parse(member.updatedAt).toLocal();
      formattedDate = DateFormat('MMM dd, yyyy').format(date);
    } catch (_) {}

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: Text(
                    user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                    style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name, 
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
                      ),
                      if (formattedDate.isNotEmpty)
                        Text(
                          formattedDate, 
                          style: TextStyle(color: AppColors.slate500, fontSize: 12)
                        ),
                    ],
                  ),
                ),
                Icon(Icons.format_quote_rounded, color: AppColors.primary.withOpacity(0.2), size: 32),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              member.feedback,
              style: theme.textTheme.bodyMedium?.copyWith(
                height: 1.5,
                color: isDark ? Colors.white.withOpacity(0.9) : AppColors.slate800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatItem({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 20),
        const SizedBox(height: 4),
        Text(
          value, 
          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)
        ),
        Text(
          label, 
          style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 11, fontWeight: FontWeight.w500)
        ),
      ],
    );
  }
}
