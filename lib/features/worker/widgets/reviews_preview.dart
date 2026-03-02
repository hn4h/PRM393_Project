import 'package:flutter/material.dart';

class ReviewsPreview extends StatelessWidget {
  const ReviewsPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Reviews',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
            ),
            const Spacer(),
            TextButton(
              onPressed: () {},
              child: const Text('See all'),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFEAEAEA)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              CircleAvatar(radius: 18),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  "Sophia did an amazing job cleaning my apartment. Very professional and friendly!",
                  style: TextStyle(color: Colors.black54),
                ),
              ),
              Icon(Icons.star, size: 18),
              SizedBox(width: 2),
              Text("5"),
            ],
          ),
        ),
      ],
    );
  }
}