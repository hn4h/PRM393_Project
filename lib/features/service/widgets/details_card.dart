import 'package:flutter/material.dart';
import 'package:prm_project/core/models/service.dart';

/* bảng chi tiết dịch vụ */
class DetailsCard extends StatelessWidget {
  final Service service;

  const DetailsCard({
    super.key,
    required this.service,
  });

  @override
  Widget build(BuildContext context) {
    final tagsText = service.serviceTags.isNotEmpty
        ? service.serviceTags.join(', ')
        : service.name;

    final durationText = _formatDuration(service.durationMinutes);

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
            tagsText,
          ),
          _buildDetailRow(Icons.timer_outlined, "Duration", durationText),
          _buildDetailRow(
            Icons.monetization_on_outlined,
            "Price",
            "\$${service.price.toStringAsFixed(2)}",
          ),
          _buildDetailRow(
            Icons.star_outline,
            "Rating",
            service.rating.toStringAsFixed(1),
            isRating: true,
          ),
          _buildDetailRow(
            Icons.people_outline,
            "Review Count",
            service.reviewCount.toString(),
          ),
          _buildDetailRow(
            Icons.local_fire_department_outlined,
            "Booking Count",
            service.bookingCount.toString(),
            isLast: true,
          ),
        ],
      ),
    );
  }

  String _formatDuration(int durationMinutes) {
    if (durationMinutes <= 0) return '-';

    final hours = durationMinutes ~/ 60;
    final minutes = durationMinutes % 60;

    if (hours > 0 && minutes > 0) {
      return '$hours hr $minutes min';
    }
    if (hours > 0) {
      return '$hours hr';
    }
    return '$minutes min';
  }

  Widget _buildHeader() {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          "Service Details",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 20, color: Colors.grey[400]),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
              const SizedBox(width: 12),
              if (isRating)
                const Icon(Icons.star, color: Colors.orange, size: 16),
              Flexible(
                child: Text(
                  value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
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
