import 'package:flutter/material.dart';

import '../models/review_display_item.dart';
import 'review_card.dart';

class ReviewSection extends StatelessWidget {
  const ReviewSection({
    super.key,
    required this.title,
    required this.reviews,
    this.onSeeAll,
  });

  final String title;
  final List<ReviewDisplayItem> reviews;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: onSeeAll,
              child: const Text(
                'See All >',
                style: TextStyle(color: Color(0xFF008DDA)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (reviews.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            child: const Text(
              'No reviews yet',
              style: TextStyle(color: Colors.black54),
            ),
          )
        else
          SizedBox(
            height: 220,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: reviews.length,
              separatorBuilder: (_, __) => const SizedBox(width: 16),
              itemBuilder: (context, index) => ReviewCard(review: reviews[index]),
            ),
          ),
      ],
    );
  }
}
