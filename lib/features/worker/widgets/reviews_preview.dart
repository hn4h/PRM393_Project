import 'package:flutter/material.dart';

import '../viewmodel/worker_review_item.dart';

class ReviewsPreview extends StatelessWidget {
  const ReviewsPreview({super.key, required this.reviews});

  final List<WorkerReviewItem> reviews;

  @override
  Widget build(BuildContext context) {
    if (reviews.isEmpty) {
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
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFEAEAEA)),
            ),
            child: const Text(
              'No reviews yet',
              style: TextStyle(color: Colors.black54),
            ),
          ),
        ],
      );
    }

    final firstReview = reviews.first;
    final hasAvatar = firstReview.customerAvatarUrl.isNotEmpty;

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
            children: [
              CircleAvatar(
                radius: 18,
                child: ClipOval(
                  child: hasAvatar
                      ? Image.network(
                          firstReview.customerAvatarUrl,
                          width: 36,
                          height: 36,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.person, size: 18),
                        )
                      : const Icon(Icons.person, size: 18),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  firstReview.comment.isNotEmpty
                      ? firstReview.comment
                      : 'No comment',
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.black54),
                ),
              ),
              const Icon(Icons.star, size: 18),
              const SizedBox(width: 2),
              Text(firstReview.rating.toStringAsFixed(1)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          firstReview.customerName,
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
