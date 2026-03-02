import 'package:flutter/material.dart';

/* rv cua khach hang cuon ngang */
class ReviewSection extends StatelessWidget {
  const ReviewSection({super.key});

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
        // danh sach rv
        _buildReviewCard(),
      ],
    );
  }

  Widget _buildReviewCard() {
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
              const CircleAvatar(
                radius: 20,
                backgroundColor: Color(0xFFF0F0F0),
                child: Icon(Icons.person, color: Colors.grey),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "TuAnh",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "1 year ago",
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
              const Spacer(),
              const Icon(Icons.star, color: Colors.orange, size: 16),
              const SizedBox(width: 4),
              const Text("5", style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            "Dich vu tot, sua nhanh nhen!",
            style: TextStyle(color: Colors.black87, height: 1.4),
          ),
        ],
      ),
    );
  }
}