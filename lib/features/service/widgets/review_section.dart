import 'package:flutter/material.dart';
import 'package:prm_project/core/utils/image_helper.dart';

import '../viewmodel/service_review_item.dart';

/* rv cua khach hang cuon ngang */
class ReviewSection extends StatelessWidget {
  const ReviewSection({super.key, required this.reviews});

  final List<ServiceReviewItem> reviews;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Reviews",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () {},
              child: const Text(
                "See All >",
                style: TextStyle(color: Color(0xFF008DDA)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        reviews.isEmpty
            ? _buildEmptyCard()
            : Column(
                children: reviews
                    .map(
                      (review) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildReviewCard(review),
                      ),
                    )
                    .toList(),
              ),
      ],
    );
  }

  Widget _buildEmptyCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Text(
        'No reviews yet',
        style: TextStyle(color: Colors.black54),
      ),
    );
  }

  Widget _buildReviewCard(ServiceReviewItem review) {
    final hasAvatar = review.customerAvatarUrl.isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: const Color(0xFFF0F0F0),
                child: ClipOval(
                  child: hasAvatar
                      ? ImageHelper.loadNetworkImage(
                          imageUrl: review.customerAvatarUrl,
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                          errorWidget:
                              const Icon(Icons.person, color: Colors.grey),
                        )
                      : const Icon(Icons.person, color: Colors.grey),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.customerName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      review.createdAt != null
                          ? _formatDate(review.createdAt!)
                          : '-',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.star, color: Colors.orange, size: 16),
              const SizedBox(width: 4),
              Text(
                review.rating.toStringAsFixed(1),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            review.comment.isNotEmpty ? review.comment : 'No comment',
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.black87, height: 1.4),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$day/$month/$year';
  }
}
