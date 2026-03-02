import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:prm_project/core/models/booking.dart';
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
                  _buildWorkerHeader(),
                  const SizedBox(height: 24),
                  const Text(
                    "Services",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  ...booking.services
                      .map(
                        (service) => _buildServiceItem(
                          service.name,
                          "\$${service.price.toStringAsFixed(2)}",
                        ),
                      )
                      .toList(),

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
            backgroundImage: NetworkImage(booking.worker.image),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking.worker.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  booking.worker.description
                      .split('.')
                      .first, // Lấy câu đầu của mô tả
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
          Text(name, style: const TextStyle(fontWeight: FontWeight.w500)),
          const Spacer(),
          Text(price, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildDetailBox() {
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
          _buildRow(
            "Date",
            DateFormat('EEE, d MMM yyyy').format(booking.scheduledAt),
          ),
          _buildRow("Time", DateFormat('hh:mm a').format(booking.scheduledAt)),
          _buildRow("Duration", booking.duration),
          _buildRow("Address", "Hanoi, Vietnam", isMultiLine: true),
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
}
