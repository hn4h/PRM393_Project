import 'package:flutter/material.dart';
import 'package:prm_project/core/models/worker.dart';

class Stats extends StatelessWidget {
  final Worker worker;

  const Stats({super.key, required this.worker});

  Widget _item(IconData icon, String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF2F80ED).withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: const Color(0xFF2F80ED)),
            const SizedBox(height: 6),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final expText = '${worker.experienceYears} yrs';
    final clientsText = worker.clients.toString();
    final ratingText = worker.rating.toStringAsFixed(1);

    return Row(
      children: [
        _item(Icons.timer_outlined, expText, 'Experience'),
        const SizedBox(width: 10),
        _item(Icons.people_outline, clientsText, 'Clients'),
        const SizedBox(width: 10),
        _item(Icons.star_border, ratingText, 'Rating'),
      ],
    );
  }
}