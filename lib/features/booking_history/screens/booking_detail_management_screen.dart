import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:prm_project/core/enums/booking_status.dart';
import 'package:prm_project/core/models/booking.dart';
import 'package:prm_project/features/cs_chat/repository/cs_chat_repository.dart';
import 'package:prm_project/features/cs_chat/screens/cs_chat_room_screen.dart';
import '../widgets/booking_action_button.dart';

class BookingDetailManagementScreen extends StatelessWidget {
  final Booking booking;

  const BookingDetailManagementScreen({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
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
                  _buildWorkerHeader(context),
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
                    "Details",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildDetailBox(),
                ],
              ),
            ),
          ),
          BookingActionButton(status: booking.status),
        ],
      ),
    );
  }

  Widget _buildWorkerHeader(BuildContext context) {
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
            onPressed:
                (booking.status == BookingStatus.accepted ||
                    booking.status == BookingStatus.inProgress)
                ? () => _openChatRoom(context)
                : null,
            icon: Icon(
              Icons.chat_bubble_outline,
              color:
                  (booking.status == BookingStatus.accepted ||
                      booking.status == BookingStatus.inProgress)
                  ? const Color(0xFF008DDA)
                  : Colors.grey.shade400,
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
          Text(name, style: const TextStyle(fontWeight: FontWeight.w500)),
          const Spacer(),
          Text(price, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildDetailBox() {
    final scheduled = booking.scheduledAt ?? DateTime.now();
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
          if (booking.address != null)
            _buildRow("Address", booking.address!, isMultiLine: true),
          const Divider(height: 24),
          _buildRow(
            "Total price",
            "\$${booking.totalPrice.toStringAsFixed(2)}",
            isTotal: true,
          ),
        ],
      ),
    );
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

  Future<void> _openChatRoom(BuildContext context) async {
    try {
      final repo = CsChatRepository(Supabase.instance.client);
      final conversationId = await repo.getConversationIdForBooking(booking.id);
      if (conversationId == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Chat is not available for this booking yet.'),
            ),
          );
        }
        return;
      }
      if (context.mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => CsChatRoomScreen(conversationId: conversationId),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Unable to open chat: $e')));
      }
    }
  }
}
