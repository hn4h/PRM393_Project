import 'package:flutter/material.dart';
import 'package:prm_project/core/models/worker.dart';

class ScheduleLocationCard extends StatelessWidget {
  final Worker worker;

  /// Nếu bạn có map serviceIds -> names, truyền list này vào
  final List<String>? serviceNames;

  const ScheduleLocationCard({
    super.key,
    required this.worker,
    this.serviceNames,
  });

  Widget _row(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.black45),
          const SizedBox(width: 10),
          Expanded(
            child: Text(label, style: const TextStyle(color: Colors.black54)),
          ),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final servicesText = (serviceNames != null && serviceNames!.isNotEmpty)
        ? serviceNames!.join(', ')
        : (worker.serviceIds.isNotEmpty ? worker.serviceIds.join(', ') : '-');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Schedule & Location',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFEAEAEA)),
          ),
          child: Column(
            children: [
              _row(Icons.calendar_month_outlined, 'Date',
                  worker.workingDays.isNotEmpty ? worker.workingDays : '-'),
              const Divider(height: 1),
              _row(Icons.access_time, 'Time',
                  worker.workingTime.isNotEmpty ? worker.workingTime : '-'),
              const Divider(height: 1),
              _row(Icons.cleaning_services_outlined, 'Services', servicesText),
              const Divider(height: 1),
              _row(Icons.location_on_outlined, 'Location',
                  worker.location.isNotEmpty ? worker.location : '-'),
            ],
          ),
        ),
      ],
    );
  }
}