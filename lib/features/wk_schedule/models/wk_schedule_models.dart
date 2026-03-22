import 'package:flutter/material.dart';

enum WkScheduleBookingStatus {
  pending,
  accepted,
  inProgress,
  completed,
  rejected,
  cancelled,
  unknown,
}

WkScheduleBookingStatus wkScheduleStatusFromDb(String? status) {
  switch (status) {
    case 'pending':
      return WkScheduleBookingStatus.pending;
    case 'accepted':
      return WkScheduleBookingStatus.accepted;
    case 'in_progress':
      return WkScheduleBookingStatus.inProgress;
    case 'completed':
      return WkScheduleBookingStatus.completed;
    case 'rejected':
      return WkScheduleBookingStatus.rejected;
    case 'cancelled':
      return WkScheduleBookingStatus.cancelled;
    default:
      return WkScheduleBookingStatus.unknown;
  }
}

String wkScheduleStatusLabel(WkScheduleBookingStatus status) {
  switch (status) {
    case WkScheduleBookingStatus.pending:
      return 'Pending';
    case WkScheduleBookingStatus.accepted:
      return 'Accepted';
    case WkScheduleBookingStatus.inProgress:
      return 'In Progress';
    case WkScheduleBookingStatus.completed:
      return 'Completed';
    case WkScheduleBookingStatus.rejected:
      return 'Rejected';
    case WkScheduleBookingStatus.cancelled:
      return 'Cancelled';
    case WkScheduleBookingStatus.unknown:
      return 'Unknown';
  }
}

Color wkScheduleStatusColor(WkScheduleBookingStatus status) {
  switch (status) {
    case WkScheduleBookingStatus.pending:
      return const Color(0xFFF9A825);
    case WkScheduleBookingStatus.accepted:
      return const Color(0xFF1E88E5);
    case WkScheduleBookingStatus.inProgress:
      return const Color(0xFFFB8C00);
    case WkScheduleBookingStatus.completed:
      return const Color(0xFF43A047);
    case WkScheduleBookingStatus.rejected:
      return const Color(0xFFE53935);
    case WkScheduleBookingStatus.cancelled:
      return const Color(0xFF8E8E8E);
    case WkScheduleBookingStatus.unknown:
      return const Color(0xFF9E9E9E);
  }
}

class WkScheduleBooking {
  final String id;
  final String serviceName;
  final DateTime scheduledAtUtc7;
  final int durationMinutes;
  final String customerName;
  final String address;
  final String notes;
  final double totalPriceUsd;
  final String? contactPhone;
  final WkScheduleBookingStatus status;

  const WkScheduleBooking({
    required this.id,
    required this.serviceName,
    required this.scheduledAtUtc7,
    required this.durationMinutes,
    required this.customerName,
    required this.address,
    required this.notes,
    required this.totalPriceUsd,
    required this.contactPhone,
    required this.status,
  });

  DateTime get endsAtUtc7 =>
      scheduledAtUtc7.add(Duration(minutes: durationMinutes));

  String get timeRangeLabel {
    final start = TimeOfDay.fromDateTime(scheduledAtUtc7);
    final end = TimeOfDay.fromDateTime(endsAtUtc7);
    final s =
        '${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')}';
    final e =
        '${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}';
    return '$s - $e';
  }

  bool isSameDate(DateTime dateUtc7) {
    return scheduledAtUtc7.year == dateUtc7.year &&
        scheduledAtUtc7.month == dateUtc7.month &&
        scheduledAtUtc7.day == dateUtc7.day;
  }
}

class WkBookingReview {
  final String id;
  final int rating;
  final String comment;
  final DateTime createdAtUtc7;

  const WkBookingReview({
    required this.id,
    required this.rating,
    required this.comment,
    required this.createdAtUtc7,
  });
}

enum WkBookingsFilter {
  all,
  pending,
  accepted,
  inProgress,
  completed,
  rejected,
  cancelled,
}

String wkBookingsFilterLabel(WkBookingsFilter filter) {
  switch (filter) {
    case WkBookingsFilter.all:
      return 'All';
    case WkBookingsFilter.pending:
      return 'Pending';
    case WkBookingsFilter.accepted:
      return 'Accepted';
    case WkBookingsFilter.inProgress:
      return 'In Progress';
    case WkBookingsFilter.completed:
      return 'Completed';
    case WkBookingsFilter.rejected:
      return 'Rejected';
    case WkBookingsFilter.cancelled:
      return 'Cancelled';
  }
}

class WkScheduleState {
  final DateTime focusedMonthUtc7;
  final DateTime selectedDateUtc7;
  final WkBookingsFilter activeFilter;
  final List<WkScheduleBooking> bookings;

  const WkScheduleState({
    required this.focusedMonthUtc7,
    required this.selectedDateUtc7,
    required this.activeFilter,
    required this.bookings,
  });

  WkScheduleState copyWith({
    DateTime? focusedMonthUtc7,
    DateTime? selectedDateUtc7,
    WkBookingsFilter? activeFilter,
    List<WkScheduleBooking>? bookings,
  }) {
    return WkScheduleState(
      focusedMonthUtc7: focusedMonthUtc7 ?? this.focusedMonthUtc7,
      selectedDateUtc7: selectedDateUtc7 ?? this.selectedDateUtc7,
      activeFilter: activeFilter ?? this.activeFilter,
      bookings: bookings ?? this.bookings,
    );
  }
}
