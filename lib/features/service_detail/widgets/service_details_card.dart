import 'package:flutter/material.dart';

/* bang chi tiet dich vu */
class ServiceDetailsCard extends StatelessWidget {
  const ServiceDetailsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildHeader(),
          _buildDetailRow(
            Icons.cleaning_services,
            "Service",
            "Cleaning, Repair",
          ),
          _buildDetailRow(Icons.timer_outlined, "Duration", "2 hours"),
          _buildDetailRow(Icons.monetization_on_outlined, "Price", "\$40.00"),
          _buildDetailRow(Icons.star_outline, "Rating", "4.6", isRating: true),
          _buildDetailRow(Icons.people_outline, "Rating Count", "110"),
          _buildDetailRow(Icons.list_alt, "Category", "Plumbing", isLast: true),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Service Details",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          GestureDetector(
            onTap: () {},
            child: const Text(
              "See All >",
              style: TextStyle(color: Color(0xFF008DDA), fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    IconData icon,
    String label,
    String value, {
    bool isRating = false,
    bool isLast = false,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(icon, size: 20, color: Colors.grey[400]),
              const SizedBox(width: 12),
              Text(label, style: const TextStyle(color: Colors.grey)),
              const Spacer(),
              if (isRating)
                const Icon(Icons.star, color: Colors.orange, size: 16),
              Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            color: Colors.grey[100],
            indent: 16,
            endIndent: 16,
          ),
      ],
    );
  }
}
