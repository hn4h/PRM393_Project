import 'package:flutter/material.dart';

import '../models/review_display_item.dart';

class ReviewSummary extends StatelessWidget {
  const ReviewSummary({
    super.key,
    required this.reviews,
  });

  final List<ReviewDisplayItem> reviews;

  @override
  Widget build(BuildContext context) {
    if (reviews.isEmpty) {
      return const SizedBox.shrink();
    }

    final average = reviews
            .map((review) => review.rating)
            .fold<double>(0, (sum, rating) => sum + rating) /
        reviews.length;
    final distribution = _buildDistribution();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              average.toStringAsFixed(1),
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: List.generate(
                5,
                (index) => Icon(
                  index < average.round()
                      ? Icons.star
                      : Icons.star_half_outlined,
                  color: Colors.orange,
                  size: 18,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Based on ${reviews.length} reviews',
              style: const TextStyle(color: Colors.black54),
            ),
          ],
        ),
        const SizedBox(width: 24),
        Expanded(
          child: Column(
            children: List.generate(5, (index) {
              final star = index + 1;
              final count = distribution[star] ?? 0;
              final ratio = reviews.isEmpty ? 0.0 : count / reviews.length;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    SizedBox(width: 12, child: Text('$star')),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          value: ratio,
                          minHeight: 6,
                          backgroundColor: const Color(0xFFEAEAEA),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Colors.orange,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).reversed.toList(),
          ),
        ),
      ],
    );
  }

  Map<int, int> _buildDistribution() {
    final result = <int, int>{for (var i = 1; i <= 5; i++) i: 0};
    for (final review in reviews) {
      final bucket = review.rating.round().clamp(1, 5);
      result[bucket] = (result[bucket] ?? 0) + 1;
    }
    return result;
  }
}
