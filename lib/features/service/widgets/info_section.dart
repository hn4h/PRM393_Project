import 'package:flutter/material.dart';
import 'package:prm_project/core/models/service.dart';

class InfoSection extends StatefulWidget {
  final Service service;

  const InfoSection({super.key, required this.service});

  @override
  State<InfoSection> createState() => _InfoSectionState();
}

class _InfoSectionState extends State<InfoSection> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    final description = widget.service.description;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "About ${widget.service.name}",
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          description,
          maxLines: expanded ? null : 3,
          overflow: expanded ? TextOverflow.visible : TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 14, color: Colors.grey, height: 1.5),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: () => setState(() => expanded = !expanded),
          child: Text(
            expanded ? "Show less" : "Show more",
            style: const TextStyle(
              color: Color(0xFF008DDA),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}