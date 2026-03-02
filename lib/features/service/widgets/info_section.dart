import 'package:flutter/material.dart';

class InfoSection extends StatefulWidget {
  const InfoSection({super.key});

  @override
  State<InfoSection> createState() => _InfoSectionState();
}

class _InfoSectionState extends State<InfoSection> {
  bool expanded = false;

  final String description =
      "Reliable plumbing services for leaks and repairs. "
      "This service is available in your area. Please check the availability "
      "before booking. Our professional plumbers ensure high quality service "
      "with guaranteed customer satisfaction and fast response time.";

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "About Plumbing Service",
          style: TextStyle(
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
          onTap: () {
            setState(() {
              expanded = !expanded;
            });
          },
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
