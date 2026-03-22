import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:prm_project/features/review/models/review_display_item.dart';
import 'package:prm_project/features/review/models/review_list_args.dart';
import 'package:prm_project/features/review/widgets/review_section.dart';

class ReviewsPreview extends StatelessWidget {
  const ReviewsPreview({super.key, required this.reviews});

  final List<ReviewDisplayItem> reviews;

  @override
  Widget build(BuildContext context) {
    return ReviewSection(
      title: 'Reviews',
      reviews: reviews,
      onSeeAll: () {
        context.pushNamed(
          'reviews',
          extra: ReviewListArgs(
            title: 'Worker Reviews',
            reviews: reviews,
          ),
        );
      },
    );
  }
}
