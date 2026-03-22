import 'package:flutter/material.dart';

enum WkJobStatus {
  pending,
  upcoming,
  inProgress,
  completed,
  rejected,
  cancelled,
  unknown,
}

WkJobStatus wkJobStatusFromDb(String? status) {
  switch (status) {
    case 'pending':
      return WkJobStatus.pending;
    case 'accepted':
      return WkJobStatus.upcoming;
    case 'in_progress':
      return WkJobStatus.inProgress;
    case 'completed':
      return WkJobStatus.completed;
    case 'rejected':
      return WkJobStatus.rejected;
    case 'cancelled':
      return WkJobStatus.cancelled;
    default:
      return WkJobStatus.unknown;
  }
}

class WkBookingCardData {
  static const Duration _utcPlus7 = Duration(hours: 7);

  final String id;
  final String serviceName;
  final DateTime scheduledAt;
  final int durationMinutes;
  final String customerName;
  final String address;
  final String notes;
  final double totalPrice;
  final String? contactPhone;
  final WkJobStatus status;

  const WkBookingCardData({
    required this.id,
    required this.serviceName,
    required this.scheduledAt,
    required this.durationMinutes,
    required this.customerName,
    required this.address,
    required this.notes,
    required this.totalPrice,
    required this.contactPhone,
    required this.status,
  });

  DateTime get endsAt => scheduledAt.add(Duration(minutes: durationMinutes));

  String get timeRangeLabel {
    final start = TimeOfDay.fromDateTime(scheduledAt);
    final end = TimeOfDay.fromDateTime(endsAt);
    return '${_formatTime(start)} - ${_formatTime(end)}';
  }

  String get dayLabel {
    final now = DateTime.now().toUtc().add(_utcPlus7);
    final startOfToday = DateTime(now.year, now.month, now.day);
    final startOfBooking = DateTime(
      scheduledAt.year,
      scheduledAt.month,
      scheduledAt.day,
    );

    final diff = startOfBooking.difference(startOfToday).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Tomorrow';
    if (diff == -1) return 'Yesterday';

    return '${scheduledAt.day.toString().padLeft(2, '0')}/${scheduledAt.month.toString().padLeft(2, '0')}/${scheduledAt.year}';
  }

  String _formatTime(TimeOfDay t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

class WkQuickStats {
  final int pendingRequests;
  final int todayJobs;
  final double expectedIncome;

  const WkQuickStats({
    required this.pendingRequests,
    required this.todayJobs,
    required this.expectedIncome,
  });
}

class WkHomeState {
  final String workerName;
  final String? avatarUrl;
  final bool isOnline;
  final int unreadMessages;
  final WkQuickStats stats;
  final List<WkBookingCardData> pendingRequests;
  final List<WkBookingCardData> todaySchedule;
  final String? actionError;

  const WkHomeState({
    required this.workerName,
    required this.avatarUrl,
    required this.isOnline,
    required this.unreadMessages,
    required this.stats,
    required this.pendingRequests,
    required this.todaySchedule,
    this.actionError,
  });

  WkHomeState copyWith({
    String? workerName,
    String? avatarUrl,
    bool? isOnline,
    int? unreadMessages,
    WkQuickStats? stats,
    List<WkBookingCardData>? pendingRequests,
    List<WkBookingCardData>? todaySchedule,
    String? actionError,
    bool clearActionError = false,
  }) {
    return WkHomeState(
      workerName: workerName ?? this.workerName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isOnline: isOnline ?? this.isOnline,
      unreadMessages: unreadMessages ?? this.unreadMessages,
      stats: stats ?? this.stats,
      pendingRequests: pendingRequests ?? this.pendingRequests,
      todaySchedule: todaySchedule ?? this.todaySchedule,
      actionError: clearActionError ? null : actionError ?? this.actionError,
    );
  }
}
