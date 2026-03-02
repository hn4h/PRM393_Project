import 'package:flutter/material.dart';

class ScheduleLocationCard extends StatelessWidget {
  const ScheduleLocationCard({super.key});

  Widget _row(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.black45),
          const SizedBox(width: 10),
          Expanded(
            child: Text(label,
                style: const TextStyle(color: Colors.black54)),
          ),
          Text(value,
              style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Schedule & Location',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 10),
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFEAEAEA)),
          ),
          child: Column(
            children: [
              _row(Icons.calendar_month_outlined, 'Date', 'Mon - Fri'),
              const Divider(height: 1),
              _row(Icons.access_time, 'Time', '10:00 AM - 6:00 PM'),
              const Divider(height: 1),
              _row(Icons.cleaning_services_outlined, 'Services',
                  'Cleaning, Repair'),
              const Divider(height: 1),
              _row(Icons.location_on_outlined, 'Location',
                  'Kabul, Afghanistan'),
            ],
          ),
        ),
      ],
    );
  }
}