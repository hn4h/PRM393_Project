import 'package:flutter/material.dart';

enum WkNotificationType { newJob, jobCancelled, jobUpdated, payout, system }

WkNotificationType wkNotificationTypeFromDb(String? raw) {
  switch (raw) {
    case 'new_job':
      return WkNotificationType.newJob;
    case 'job_cancelled':
      return WkNotificationType.jobCancelled;
    case 'job_updated':
      return WkNotificationType.jobUpdated;
    case 'payout':
      return WkNotificationType.payout;
    default:
      return WkNotificationType.system;
  }
}

class WkNotificationItem {
  final String id;
  final WkNotificationType type;
  final String title;
  final String body;
  final bool isRead;
  final DateTime createdAt;
  final String? bookingId;

  const WkNotificationItem({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.isRead,
    required this.createdAt,
    this.bookingId,
  });
}

IconData wkNotificationIcon(WkNotificationType type) {
  switch (type) {
    case WkNotificationType.newJob:
      return Icons.handyman_outlined;
    case WkNotificationType.jobCancelled:
      return Icons.cancel_outlined;
    case WkNotificationType.jobUpdated:
      return Icons.update_outlined;
    case WkNotificationType.payout:
      return Icons.account_balance_wallet_outlined;
    case WkNotificationType.system:
      return Icons.notifications_outlined;
  }
}

Color wkNotificationColor(WkNotificationType type) {
  switch (type) {
    case WkNotificationType.newJob:
      return const Color(0xFF1E88E5);
    case WkNotificationType.jobCancelled:
      return const Color(0xFFE53935);
    case WkNotificationType.jobUpdated:
      return const Color(0xFFFFA000);
    case WkNotificationType.payout:
      return const Color(0xFF43A047);
    case WkNotificationType.system:
      return const Color(0xFF546E7A);
  }
}

class WkNotificationsState {
  final List<WkNotificationItem> notifications;

  const WkNotificationsState({required this.notifications});

  int get unreadCount => notifications.where((n) => !n.isRead).length;

  WkNotificationsState copyWith({List<WkNotificationItem>? notifications}) {
    return WkNotificationsState(
      notifications: notifications ?? this.notifications,
    );
  }
}
