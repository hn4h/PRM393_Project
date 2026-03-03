import 'package:flutter/material.dart';
import 'worker.dart';
import 'service.dart';

enum BookingStatus { inProgress, upcoming, completed, cancelled }

class Booking {
  final String id;
  final Worker worker;
  final List<Service> services;
  final BookingStatus status;
  final DateTime scheduledAt;
  final String duration;
  final double totalPrice;

  Booking({
    required this.id,
    required this.worker,
    required this.services,
    required this.status,
    required this.scheduledAt,
    required this.duration,
    required this.totalPrice,
  });

  Color get statusColor {
    switch (status) {
      case BookingStatus.inProgress:
        return Colors.orange;
      case BookingStatus.upcoming:
        return const Color(0xFF008DDA);
      case BookingStatus.completed:
        return Colors.green;
      case BookingStatus.cancelled:
        return Colors.red;
    }
  }

  String get statusText {
    switch (status) {
      case BookingStatus.inProgress:
        return "In Progress";
      case BookingStatus.upcoming:
        return "Upcoming";
      case BookingStatus.completed:
        return "Completed";
      case BookingStatus.cancelled:
        return "Cancelled";
    }
  }

  Booking copyWith({
    String? id,
    Worker? worker,
    List<Service>? services,
    BookingStatus? status,
    DateTime? scheduledAt,
    String? duration,
    double? totalPrice,
  }) {
    return Booking(
      id: id ?? this.id,
      worker: worker ?? this.worker,
      services: services ?? this.services,
      status: status ?? this.status,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      duration: duration ?? this.duration,
      totalPrice: totalPrice ?? this.totalPrice,
    );
  }
}

//data mau
final List<Booking> demoBookingHistory = [
  Booking(
    id: 'BK001',
    worker: demoWorkers[0],
    services: [demoServices[0]],
    status: BookingStatus.inProgress,
    scheduledAt: DateTime.now(),
    duration: '1 Hour',
    totalPrice: 145.50,
  ),
  Booking(
    id: 'BK002',
    worker: demoWorkers[1],
    services: [demoServices[1]],
    status: BookingStatus.upcoming,
    scheduledAt: DateTime.now().add(const Duration(days: 1)),
    duration: '2 Hours',
    totalPrice: 80.0,
  ),
  Booking(
    id: 'BK003',
    worker: demoWorkers[0],
    services: [demoServices[0]],
    status: BookingStatus.completed,
    scheduledAt: DateTime.now().subtract(const Duration(days: 3)),
    duration: '1.5 Hours',
    totalPrice: 120.0,
  ),
];
