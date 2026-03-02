import 'package:flutter/material.dart';

class StepSummary extends StatelessWidget {
  const StepSummary({super.key});

  @override
  Widget build(BuildContext context) {
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
          ),
          child: Column(
            children: [
              _buildSummaryRow(
                Icons.calendar_today,
                "Date",
                "Wed, 20 May 2025",
              ),
              _buildSummaryRow(Icons.access_time, "Time", "10:00 AM"),
              _buildSummaryRow(Icons.handyman_outlined, "Services", "Cleaning"),
              const Divider(),
              _buildSummaryRow(null, "Price", "\$142.00"),
              _buildSummaryRow(null, "Fee", "\$3.50"),
              const Divider(),
              _buildSummaryRow(null, "Total price", "\$145.50", isTotal: true),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const Text("Promo", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(
          decoration: InputDecoration(
            hintText: "Enter promo code",
            prefixIcon: const Icon(Icons.confirmation_number_outlined),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: Colors.grey),
            const SizedBox(width: 8),
          ],
          Text(label, style: const TextStyle(color: Colors.grey)),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: isTotal ? 16 : 14,
              color: isTotal ? const Color(0xFF008DDA) : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
