import 'package:flutter/material.dart';
import '../enums/booking_status.dart';

/// Booking model matching the Supabase `bookings` table schema.
class Booking {
  final String id;
  final String customerId;
  final String? workerId;
  final String? serviceId;
  final BookingStatus status;
  final DateTime? scheduledAt;
  final String? address;
  final String? notes;
  final double totalPrice;
  final String paymentMethod;
  final String? contactName;
  final String? contactPhone;
  final int durationMinutes;
  final DateTime createdAt;
  final DateTime updatedAt;

  // ── Joined data (populated by SELECT with joins) ──
  final String? workerName;
  final String? workerAvatar;
  final String? serviceName;
  final String? serviceImage;

  const Booking({
    required this.id,
    required this.customerId,
    this.workerId,
    this.serviceId,
    required this.status,
    this.scheduledAt,
    this.address,
    this.notes,
    required this.totalPrice,
    this.paymentMethod = 'cash',
    this.contactName,
    this.contactPhone,
    this.durationMinutes = 60,
    required this.createdAt,
    required this.updatedAt,
    // joined
    this.workerName,
    this.workerAvatar,
    this.serviceName,
    this.serviceImage,
  });

  /// Parse from Supabase response (snake_case).
  factory Booking.fromMap(Map<String, dynamic> map) {
    // Handle joined worker profile data
    final workerProfile = map['worker_profile'] as Map<String, dynamic>?;
    // Handle joined service data
    final serviceData = map['service'] as Map<String, dynamic>?;

    return Booking(
      id: map['id'] as String,
      customerId: map['customer_id'] as String,
      workerId: map['worker_id'] as String?,
      serviceId: map['service_id'] as String?,
      status: BookingStatus.fromString(map['status'] as String? ?? 'pending'),
      // Database time is already in GMT+7 - load as-is
      scheduledAt: map['scheduled_at'] != null
          ? DateTime.parse(map['scheduled_at'] as String)
          : null,
      address: map['address'] as String?,
      notes: map['notes'] as String?,
      totalPrice: (map['total_price'] as num?)?.toDouble() ?? 0.0,
      paymentMethod: map['payment_method'] as String? ?? '',
      contactName: map['contact_name'] as String?,
      contactPhone: map['contact_phone'] as String?,
      durationMinutes: map['duration_minutes'] as int? ?? 60,
      createdAt: DateTime.parse(
        map['created_at'] as String? ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        map['updated_at'] as String? ?? DateTime.now().toIso8601String(),
      ),
      // joined
      workerName: workerProfile?['full_name'] as String?,
      workerAvatar: workerProfile?['avatar_url'] as String?,
      serviceName: serviceData?['name'] as String?,
      serviceImage: serviceData?['image_url'] as String?,
    );
  }

  /// Map for INSERT (exclude auto-generated fields).
  /// Database time is already in GMT+7 - save as-is
  Map<String, dynamic> toInsertMap() => {
    'customer_id': customerId,
    if (workerId != null) 'worker_id': workerId,
    if (serviceId != null) 'service_id': serviceId,
    'status': status.toDbValue(),
    if (scheduledAt != null) 'scheduled_at': scheduledAt!.toIso8601String(),
    if (address != null) 'address': address,
    if (notes != null) 'notes': notes,
    'total_price': totalPrice,
    'payment_method': paymentMethod,
    if (contactName != null) 'contact_name': contactName,
    if (contactPhone != null) 'contact_phone': contactPhone,
    'duration_minutes': durationMinutes,
  };

  Booking copyWith({
    String? id,
    String? customerId,
    String? workerId,
    String? serviceId,
    BookingStatus? status,
    DateTime? scheduledAt,
    String? address,
    String? notes,
    double? totalPrice,
    String? paymentMethod,
    String? contactName,
    String? contactPhone,
    int? durationMinutes,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? workerName,
    String? workerAvatar,
    String? serviceName,
    String? serviceImage,
  }) {
    return Booking(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      workerId: workerId ?? this.workerId,
      serviceId: serviceId ?? this.serviceId,
      status: status ?? this.status,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      address: address ?? this.address,
      notes: notes ?? this.notes,
      totalPrice: totalPrice ?? this.totalPrice,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      contactName: contactName ?? this.contactName,
      contactPhone: contactPhone ?? this.contactPhone,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      workerName: workerName ?? this.workerName,
      workerAvatar: workerAvatar ?? this.workerAvatar,
      serviceName: serviceName ?? this.serviceName,
      serviceImage: serviceImage ?? this.serviceImage,
    );
  }

  /// Status color for UI badges.
  Color get statusColor {
    switch (status) {
      case BookingStatus.pending:
        return Colors.amber;
      case BookingStatus.accepted:
        return const Color(0xFF008DDA);
      case BookingStatus.inProgress:
        return Colors.orange;
      case BookingStatus.completed:
        return Colors.green;
      case BookingStatus.cancelled:
        return Colors.red;
      case BookingStatus.rejected:
        return Colors.grey;
    }
  }

  /// Human-readable status text.
  String get statusText => status.label;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Booking && other.id == id);

  @override
  int get hashCode => id.hashCode;
}
