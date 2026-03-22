import 'package:flutter/material.dart';
import 'package:prm_project/core/models/worker.dart';

class ScheduleLocationCard extends StatelessWidget {
  final Worker worker;
  final List<String> serviceNames;

  const ScheduleLocationCard({
    super.key,
    required this.worker,
    this.serviceNames = const [],
  });

  Widget _row(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.black45),
          const SizedBox(width: 10),
          SizedBox(
            width: 78,
            child: Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.black54),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
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
          'Work Details',
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
              _row(
                Icons.work_outline,
                'Service Area',
                worker.workingDays.isNotEmpty ? worker.workingDays : '-',
              ),
              const Divider(height: 1),
              _row(
                Icons.build_outlined,
                'Skills',
                worker.workingTime.isNotEmpty ? worker.workingTime : '-',
              ),
            ],
          ),
        ),
      ],
    );
  }
}
