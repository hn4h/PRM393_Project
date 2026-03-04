import 'package:flutter/material.dart';
import 'package:prm_project/core/models/worker.dart';

class About extends StatefulWidget {
  final Worker worker;

  const About({super.key, required this.worker});

  @override
  State<About> createState() => _AboutState();
}

class _AboutState extends State<About> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    final description = widget.worker.description;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'About',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 6),
        Text(
          description.isNotEmpty ? description : '-',
          maxLines: expanded ? 99 : 2,
          overflow: expanded ? TextOverflow.visible : TextOverflow.ellipsis,
          style: const TextStyle(color: Colors.black54, height: 1.35),
        ),
        if (description.length > 60) ...[
          const SizedBox(height: 4),
          GestureDetector(
            onTap: () => setState(() => expanded = !expanded),
            child: Text(
              expanded ? 'Show less' : 'Show more',
              style: const TextStyle(
                color: Color(0xFF2F80ED),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
