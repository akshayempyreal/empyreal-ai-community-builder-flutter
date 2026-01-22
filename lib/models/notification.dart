class NotificationModel {
  final String id;
  final String title;
  final String message;
  final String createdAt;
  final bool isRead;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.createdAt,
    this.isRead = false,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      createdAt: json['createdAt'] ?? '',
      isRead: json['isRead'] ?? false,
    );
  }

  NotificationModel copyWith({
    String? id,
    String? title,
    String? message,
    String? createdAt,
    bool? isRead,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
    );
  }
}

class PaginationModel {
  final int total;
  final int page;
  final int limit;
  final int pages;

  PaginationModel({
    required this.total,
    required this.page,
    required this.limit,
    required this.pages,
  });

  factory PaginationModel.fromJson(Map<String, dynamic> json) {
    return PaginationModel(
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 10,
      pages: json['pages'] ?? 0,
    );
  }
}

class NotificationResponse {
  final bool status;
  final String message;
  final List<NotificationModel> notifications;
  final PaginationModel pagination;

  NotificationResponse({
    required this.status,
    required this.message,
    required this.notifications,
    required this.pagination,
  });

  factory NotificationResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    final List<dynamic> list = data['notifications'] ?? [];
    
    return NotificationResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      notifications: list.map((e) => NotificationModel.fromJson(e)).toList(),
      pagination: PaginationModel.fromJson(data['pagination'] ?? {}),
    );
  }
}
class UnreadCountResponse {
  final bool status;
  final String message;
  final int unreadCount;

  UnreadCountResponse({
    required this.status,
    required this.message,
    required this.unreadCount,
  });

  factory UnreadCountResponse.fromJson(Map<String, dynamic> json) {
    return UnreadCountResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      unreadCount: json['data']?['unreadCount'] ?? 0,
    );
  }
}
