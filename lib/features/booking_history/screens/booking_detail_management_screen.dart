import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:prm_project/core/models/booking.dart';
import 'package:prm_project/core/enums/booking_status.dart';
import '../viewmodel/booking_history_viewmodel.dart';

class BookingDetailManagementScreen extends ConsumerWidget {
  final Booking booking;

  const BookingDetailManagementScreen({super.key, required this.booking});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Booking Detail",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildWorkerHeader(),
                  const SizedBox(height: 24),
                  const Text(
                    "Service",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildServiceItem(
                    booking.serviceName ?? 'Service',
                    "\$${booking.totalPrice.toStringAsFixed(2)}",
                  ),
                  const Divider(height: 40),
                  const Text(
                    "Contact Information",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildContactBox(),
                  const SizedBox(height: 24),
                  const Text(
                    "Details",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildDetailBox(),
                ],
              ),
            ),
          ),
          _buildActionButton(context, ref),
        ],
      ),
    );
  }

  Widget _buildWorkerHeader() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundImage:
                booking.workerAvatar != null && booking.workerAvatar!.isNotEmpty
                ? NetworkImage(booking.workerAvatar!)
                : null,
            child: booking.workerAvatar == null || booking.workerAvatar!.isEmpty
                ? const Icon(Icons.person, size: 30)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking.workerName ?? 'Worker',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  booking.serviceName ?? 'Service',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.chat_bubble_outline,
              color: Color(0xFF008DDA),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceItem(String name, String price) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle_outline,
            color: Color(0xFF008DDA),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Text(price, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildContactBox() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildRow("Name", booking.contactName ?? 'N/A'),
          _buildRow("Phone", booking.contactPhone ?? 'N/A'),
          if (booking.address != null && booking.address!.isNotEmpty)
            _buildRow("Address", booking.address!, isMultiLine: true),
          if (booking.notes != null && booking.notes!.isNotEmpty)
            _buildRow("Notes", booking.notes!, isMultiLine: true),
        ],
      ),
    );
  }

  Widget _buildDetailBox() {
    final scheduled = booking.scheduledAt ?? DateTime.now();
    final serviceFee = booking.totalPrice * 0.05;
    final total = booking.totalPrice + serviceFee;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildRow(
            "Status",
            booking.statusText,
            valueColor: booking.statusColor,
          ),
          _buildRow("Date", DateFormat('EEE, d MMM yyyy').format(scheduled)),
          _buildRow("Time", DateFormat('hh:mm a').format(scheduled)),
          _buildRow("Duration", "${booking.durationMinutes} min"),
          _buildRow(
            "Payment Method",
            _formatPaymentMethod(booking.paymentMethod),
          ),
          const Divider(height: 24),
          _buildRow(
            "Service Price",
            "\$${booking.totalPrice.toStringAsFixed(2)}",
          ),
          _buildRow("Service Fee (5%)", "\$${serviceFee.toStringAsFixed(2)}"),
          const Divider(height: 24),
          _buildRow("Total", "\$${total.toStringAsFixed(2)}", isTotal: true),
        ],
      ),
    );
  }

  String _formatPaymentMethod(String method) {
    switch (method.toLowerCase()) {
      case 'credit card':
        return 'Credit Card';
      case 'paypal':
        return 'PayPal';
      case 'apple pay':
        return 'Apple Pay';
      case 'google pay':
        return 'Google Pay';
      case 'cash':
        return 'Cash';
      default:
        return method;
    }
  }

  Widget _buildRow(
    String label,
    String value, {
    bool isTotal = false,
    bool isMultiLine = false,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: isMultiLine
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: isTotal ? 16 : 14,
                color:
                    valueColor ??
                    (isTotal ? const Color(0xFF008DDA) : Colors.black),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, WidgetRef ref) {
    // No action for final states
    if (booking.status == BookingStatus.cancelled ||
        booking.status == BookingStatus.rejected ||
        booking.status == BookingStatus.accepted) {
      return const SizedBox.shrink();
    }

    String buttonText = "";
    Color buttonColor = const Color(0xFF008DDA);

    switch (booking.status) {
      case BookingStatus.pending:
        buttonText = "Cancel Booking";
        buttonColor = Colors.red.shade400;
        break;
      case BookingStatus.inProgress:
        buttonText = "Mark as Completed";
        buttonColor = Colors.green.shade600;
        break;
      case BookingStatus.completed:
        buttonText = "Add Review";
        buttonColor = const Color(0xFF008DDA);
        break;
      default:
        return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFF1F4F8))),
      ),
      child: ElevatedButton(
        onPressed: () => _handleAction(context, ref, booking.status),
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          minimumSize: const Size(double.infinity, 54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: Text(
          buttonText,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _handleAction(
    BuildContext context,
    WidgetRef ref,
    BookingStatus status,
  ) {
    switch (status) {
      case BookingStatus.pending:
        _showConfirmationDialog(
          context,
          ref,
          "Cancel Booking",
          "Are you sure you want to cancel this booking?",
          onConfirm: () async {
            await ref
                .read(bookingHistoryViewModelProvider.notifier)
                .cancelBooking(booking.id);
            if (context.mounted) {
              Navigator.pop(context); // Close dialog
              context.pop(); // Go back to booking history
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Booking cancelled successfully"),
                  backgroundColor: Colors.green,
                ),
              );
            }
          },
        );
        break;
      case BookingStatus.inProgress:
        _showConfirmationDialog(
          context,
          ref,
          "Complete Service",
          "Are you sure the service has been completed?",
          onConfirm: () async {
            await ref
                .read(bookingHistoryViewModelProvider.notifier)
                .completeBooking(booking.id);
            if (context.mounted) {
              Navigator.pop(context); // Close dialog
              context.pop(); // Go back to booking history
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Booking marked as completed!"),
                  backgroundColor: Colors.green,
                ),
              );
            }
          },
        );
        break;
      case BookingStatus.completed:
        // TODO: Navigate to review screen
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Review feature coming soon...")),
        );
        break;
      default:
        break;
    }
  }

  void _showConfirmationDialog(
    BuildContext context,
    WidgetRef ref,
    String title,
    String content, {
    required Future<void> Function() onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(content),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              await onConfirm();
            },
            child: Text(
              "Confirm",
              style: TextStyle(
                color: title.contains("Cancel")
                    ? Colors.red
                    : const Color(0xFF008DDA),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
