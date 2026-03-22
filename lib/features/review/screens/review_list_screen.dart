import 'package:flutter/material.dart';

import '../models/review_list_args.dart';
import '../widgets/review_card.dart';
import '../widgets/review_summary.dart';

class ReviewListScreen extends StatelessWidget {
  const ReviewListScreen({
    super.key,
    required this.args,
  });

  final ReviewListArgs args;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(args.title),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ReviewSummary(reviews: args.reviews),
              const SizedBox(height: 24),
              Text(
                'Reviews (${args.reviews.length})',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              if (args.reviews.isEmpty)
                const Text(
                  'No reviews yet',
                  style: TextStyle(color: Colors.black54),
                )
              else
                Column(
                  children: args.reviews
                      .map(
                        (review) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: ReviewCard(
                            review: review,
                            width: double.infinity,
                          ),
                        ),
                      )
                      .toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
