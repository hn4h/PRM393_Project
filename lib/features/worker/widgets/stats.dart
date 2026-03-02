import 'package:flutter/material.dart';

class Stats extends StatelessWidget {
  const Stats({super.key});

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
            Icon(icon, size: 18, color: Color(0xFF2F80ED)),
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
    return Row(
      children: [
        _item(Icons.timer_outlined, '6 yrs', 'Experience'),
        const SizedBox(width: 10),
        _item(Icons.people_outline, '1000', 'Clients'),
        const SizedBox(width: 10),
        _item(Icons.star_border, '4.9', 'Rating'),
      ],
    );
  }
}