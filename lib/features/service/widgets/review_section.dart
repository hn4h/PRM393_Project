import 'package:flutter/material.dart';
import 'package:prm_project/features/review/models/review_display_item.dart';
import 'package:prm_project/features/review/widgets/review_section.dart'
    as review_feature;

/* rv cua khach hang cuon ngang */
class ReviewSection extends StatelessWidget {
  const ReviewSection({
    super.key,
    required this.reviews,
    this.onSeeAll,
  });

  final List<ReviewDisplayItem> reviews;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    return review_feature.ReviewSection(
      title: 'Reviews',
      reviews: reviews,
      onSeeAll: onSeeAll,
    );
  }
}
