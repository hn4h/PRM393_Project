import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/models/booking.dart';
import '../viewmodel/booking_flow_viewmodel.dart';

class BookingConfirmedScreen extends ConsumerWidget {
  const BookingConfirmedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flowState = ref.watch(bookingFlowViewModelProvider);
    final booking = flowState.booking;

    final scheduled = booking.scheduledAt ?? DateTime.now();
    final formattedDateTime = DateFormat('EEEE, hh:mm a').format(scheduled);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.goNamed('home'),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle_outline,
              size: 100,
              color: Colors.green,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text(
                  "Booking Confirmed ",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                Icon(Icons.check_circle, color: Colors.green),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              "Your booking is confirmed with ${booking.workerName ?? 'your provider'}.\nPlease find the details below.",
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),

            _buildInfoCard(booking, formattedDateTime),

            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                context.pushNamed('booking-detail-view');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF008DDA),
                minimumSize: const Size(double.infinity, 54),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                "View My Bookings",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(Booking booking, String dateTime) {
    final servicePrice = booking.totalPrice;
    final serviceFee = servicePrice * 0.05;
    final totalPaid = servicePrice + serviceFee;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: [
          _buildRow(
            Icons.person,
            "Professional",
            booking.workerName ?? 'Worker',
            isBlue: true,
          ),
          const Divider(),
          _buildRow(Icons.calendar_today, "Date Time", dateTime),
          const Divider(),
          _buildRow(
            Icons.cleaning_services,
            "Services",
            booking.serviceName ?? "Service",
          ),
          const Divider(),
          _buildRow(
            Icons.monetization_on,
            "Total Paid",
            "\$${totalPaid.toStringAsFixed(2)}",
          ),
        ],
      ),
    );
  }

  Widget _buildRow(
    IconData icon,
    String label,
    String value, {
    bool isBlue = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(color: Colors.grey)),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isBlue ? const Color(0xFF008DDA) : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
