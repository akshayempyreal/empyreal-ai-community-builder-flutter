import 'package:empyreal_ai_community_builder_flutter/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import '../../models/notification.dart';
import '../../repositories/auth_repository.dart';
import '../../services/api_client.dart';
import '../../project_helpers.dart';

class NotificationScreen extends StatefulWidget {
  final String token;
  final VoidCallback onBack;

  const NotificationScreen({
    super.key,
    required this.token,
    required this.onBack,
  });

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final AuthRepository _authRepository = AuthRepository(ApiClient());
  List<NotificationModel> _notifications = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await _authRepository.getNotifications(widget.token);
      if (mounted) {
        setState(() {
          _notifications = response.notifications;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _markAsRead(String id) async {
    try {
      await _authRepository.markNotificationAsRead(widget.token, id: id);
      if (mounted) {
        setState(() {
          _notifications = _notifications.map((n) {
            if (n.id == id) return n.copyWith(isRead: true);
            return n;
          }).toList();
        });
      }
    } catch (e) {
      debugPrint('Error marking as read: $e');
    }
  }

  Future<void> _markAllAsRead() async {
    try {
      await _authRepository.markNotificationAsRead(widget.token, readAll: true);
      if (mounted) {
        setState(() {
          _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
        });
      }
    } catch (e) {
      debugPrint('Error marking all as read: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const Icon(Icons.arrow_back_ios_new, color: AppColors.gray900, size: 20)
            .paddingAll(context, 8)
            .onClick(widget.onBack),
        title: const Text(
          'Notifications',
          style: TextStyle(color: AppColors.gray900, fontWeight: FontWeight.bold),
        ),
        actions: [
          if (_notifications.any((n) => !n.isRead))
            TextButton(
              onPressed: _markAllAsRead,
              child: const Text('Mark all as read'),
            ),
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.primaryIndigo),
            onPressed: _fetchNotifications,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: 16),
            Text(_error!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchNotifications,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_none, size: 64, color: AppColors.gray300),
            const SizedBox(height: 16),
            const Text(
              'No notifications yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.gray900,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'We\'ll notify you when something important happens',
              style: TextStyle(color: AppColors.gray600),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _notifications.length,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemBuilder: (context, index) {
        final notification = _notifications[index];
        return AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: notification.isRead ? 0.6 : 1.0,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: notification.isRead 
                  ? AppColors.gray100
                  : AppColors.indigo100,
              child: Icon(
                Icons.notifications, 
                color: notification.isRead ? AppColors.gray400 : AppColors.primaryIndigo,
                size: 20,
              ),
            ),
            title: Text(
              notification.title,
              style: TextStyle(
                fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
                color: AppColors.gray900,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.message,
                  style: const TextStyle(color: AppColors.gray600),
                ),
                const SizedBox(height: 4),
                Text(
                  notification.createdAt,
                  style: const TextStyle(fontSize: 12, color: AppColors.gray400),
                ),
              ],
            ),
            isThreeLine: true,
            onTap: () {
              if (!notification.isRead) {
                _markAsRead(notification.id);
              }
            },
          ),
        );
      },
    );
  }
}
