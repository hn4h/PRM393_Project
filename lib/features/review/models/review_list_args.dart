import 'review_display_item.dart';

class ReviewListArgs {
  const ReviewListArgs({
    required this.title,
    required this.reviews,
  });

  final String title;
  final List<ReviewDisplayItem> reviews;
}
