import 'package:flutter/material.dart';

class About extends StatefulWidget {
  const About({super.key});

  @override
  State<About> createState() => _AboutState();
}

class _AboutState extends State<About> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    const description =
        "James Anderson is a highly experienced home cleaner with over 10 years in the industry. He is recognized for his meticulous attention to detail and friendly service.";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'About',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 6),
        Text(
          description,
          maxLines: expanded ? 99 : 2,
          overflow:
              expanded ? TextOverflow.visible : TextOverflow.ellipsis,
          style: const TextStyle(color: Colors.black54, height: 1.35),
        ),
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
    );
  }
}