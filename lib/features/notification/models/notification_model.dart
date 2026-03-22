import 'package:flutter/foundation.dart';

/// Notification type enum matching DB 'type' column values.
/// DB stores: booking_accepted, booking_rejected, booking_in_progress,
///            booking_completed, booking_cancelled, new_booking, system, etc.
enum NotificationType {
  bookingAccepted,
  bookingRejected,
  bookingInProgress,
  bookingCompleted,
  bookingCancelled,
  newBooking,
  system,
  promotion;

  static NotificationType fromString(String value) {
    return switch (value) {
      'booking_accepted' => NotificationType.bookingAccepted,
      'booking_rejected' => NotificationType.bookingRejected,
      'booking_in_progress' => NotificationType.bookingInProgress,
      'booking_completed' => NotificationType.bookingCompleted,
      'booking_cancelled' => NotificationType.bookingCancelled,
      'new_booking' => NotificationType.newBooking,
      'promotion' => NotificationType.promotion,
      _ => NotificationType.system,
    };
  }

  /// Whether this type is booking-related.
  bool get isBookingRelated => switch (this) {
    bookingAccepted ||
    bookingRejected ||
    bookingInProgress ||
    bookingCompleted ||
    bookingCancelled ||
    newBooking => true,
    _ => false,
  };
}

@immutable
class NotificationModel {
  final String id;
  final String userId; // customer_id or worker_id
  final String? bookingId;
  final NotificationType type;
  final String title;
  final String body;
  final bool isRead;
  final DateTime createdAt;

  const NotificationModel({
    required this.id,
    required this.userId,
    this.bookingId,
    required this.type,
    required this.title,
    required this.body,
    this.isRead = false,
    required this.createdAt,
  });

  /// Parse from Supabase response.
  /// [userIdColumn] is 'customer_id' or 'worker_id'.
  factory NotificationModel.fromMap(
    Map<String, dynamic> map, {
    required String userIdColumn,
  }) {
    return NotificationModel(
      id: map['id'] as String,
      userId: map[userIdColumn] as String,
      bookingId: map['booking_id'] as String?,
      type: NotificationType.fromString(map['type'] as String? ?? 'system'),
      title: map['title'] as String,
      body: map['body'] as String,
      isRead: map['is_read'] as bool? ?? false,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  NotificationModel copyWith({bool? isRead}) {
    return NotificationModel(
      id: id,
      userId: userId,
      bookingId: bookingId,
      type: type,
      title: title,
      body: body,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is NotificationModel && other.id == id);

  @override
  int get hashCode => id.hashCode;
}
