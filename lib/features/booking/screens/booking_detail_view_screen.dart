import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../viewmodel/booking_flow_viewmodel.dart';

class BookingDetailViewScreen extends ConsumerWidget {
  const BookingDetailViewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flowState = ref.watch(bookingFlowViewModelProvider);
    final booking = flowState.booking;

    final scheduled = booking.scheduledAt ?? DateTime.now();
    final dateStr = DateFormat('EEEE, d MMMM yyyy').format(scheduled);
    final timeStr = DateFormat('hh:mm a').format(scheduled);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          "Booking Detail",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatusBanner(),
                const SizedBox(height: 24),

                _buildSectionTitle("Service Information"),
                _buildInfoCard([
                  _buildDetailRow(
                    "Service",
                    booking.serviceName ?? "Home Cleaning",
                  ),
                  _buildDetailRow(
                    "Package",
                    "${booking.durationMinutes} min",
                  ),
                  _buildDetailRow(
                    "Provider",
                    booking.workerName ?? 'Worker',
                    isLink: true,
                  ),
                ]),

                const SizedBox(height: 24),
                _buildSectionTitle("Schedule"),
                _buildInfoCard([
                  _buildDetailRow("Date", dateStr),
                  _buildDetailRow("Time", timeStr),
                  _buildDetailRow("Duration", "${booking.durationMinutes} min"),
                ]),

                const SizedBox(height: 24),
                _buildSectionTitle("Address & Contact"),
                _buildInfoCard([
                  _buildDetailRow("Customer", "Anh Duc"),
                  _buildDetailRow("Phone", "0123456422"),
                  _buildDetailRow(
                    "Address",
                    "Hoa Lac, Ha Noi",
                    isMultiLine: true,
                  ),
                ]),

                const SizedBox(height: 24),
                _buildSectionTitle("Payment Summary"),
                _buildInfoCard([
                  _buildDetailRow(
                    "Subtotal",
                    "\$${booking.totalPrice.toStringAsFixed(2)}",
                  ),
                  _buildDetailRow("Service Fee", "\$3.50"),
                  const Divider(),
                  _buildDetailRow(
                    "Total Amount",
                    "\$${(booking.totalPrice + 3.5).toStringAsFixed(2)}",
                    isBold: true,
                    color: const Color(0xFF008DDA),
                  ),
                  _buildDetailRow("Method", "Credit Card (**** 1234)"),
                ]),
                const SizedBox(height: 120),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: _buildBottomAction(context),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: const [
          Icon(Icons.check_circle, color: Color(0xFF008DDA)),
          SizedBox(width: 12),
          Text(
            "Your booking is scheduled",
            style: TextStyle(
              color: Color(0xFF008DDA),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value, {
    bool isLink = false,
    bool isBold = false,
    Color? color,
    bool isMultiLine = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: isMultiLine
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontWeight: isBold || isLink
                    ? FontWeight.bold
                    : FontWeight.normal,
                fontSize: 14,
                color: isLink
                    ? const Color(0xFF008DDA)
                    : (color ?? Colors.black),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomAction(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: ElevatedButton(
          onPressed: () => context.goNamed('home'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            minimumSize: const Size(double.infinity, 54),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            "Return to Home",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
