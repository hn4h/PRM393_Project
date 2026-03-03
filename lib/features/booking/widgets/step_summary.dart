import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../viewmodel/booking_flow_viewmodel.dart';

class StepSummary extends ConsumerWidget {
  const StepSummary({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flowState = ref.watch(bookingFlowViewModelProvider);
    final booking = flowState.booking;

    final dateStr = DateFormat('EEE, d MMM yyyy').format(booking.scheduledAt);
    final timeStr = DateFormat('hh:mm a').format(booking.scheduledAt);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Details",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const Text(
          "Please check your details before proceeding to payment.",
          style: TextStyle(color: Colors.grey, fontSize: 13),
        ),
        const SizedBox(height: 16),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            children: [
              _buildSummaryRow(Icons.calendar_today, "Date", dateStr),
              _buildSummaryRow(Icons.access_time, "Time", timeStr),
              _buildSummaryRow(
                Icons.handyman_outlined,
                "Package",
                booking.duration,
              ),
              _buildSummaryRow(
                Icons.payment,
                "Method",
                booking.duration.contains("Pay") ||
                        booking.duration.contains("Card")
                    ? booking.duration
                    : "Not selected",
              ),
              const Divider(height: 32),
              _buildSummaryRow(
                null,
                "Price",
                "\$${booking.totalPrice.toStringAsFixed(2)}",
              ),
              _buildSummaryRow(null, "Service Fee", "\$3.50"),
              const Divider(height: 32),
              _buildSummaryRow(
                null,
                "Total price",
                "\$${(booking.totalPrice + 3.50).toStringAsFixed(2)}",
                isTotal: true,
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),
        const Text("Promo", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(
          decoration: InputDecoration(
            hintText: "Enter promo code",
            hintStyle: const TextStyle(fontSize: 14, color: Colors.grey),
            prefixIcon: const Icon(
              Icons.confirmation_number_outlined,
              size: 20,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(
    IconData? icon,
    String label,
    String value, {
    bool isTotal = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: Colors.grey),
            const SizedBox(width: 8),
          ],
          Text(
            label,
            style: TextStyle(
              color: isTotal ? Colors.black : Colors.grey,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: isTotal ? 18 : 14,
              color: isTotal ? const Color(0xFF008DDA) : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
