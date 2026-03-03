import 'package:flutter/material.dart';

/* ttin tho */
class StepWorkerInfo extends StatelessWidget {
  const StepWorkerInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CircleAvatar(
              radius: 35,
              backgroundImage: NetworkImage(
                'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?q=80&w=200',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Do Duc Anh",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "He is a highly experienced home cleaner with over 5 years in the industry...",
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: const [
                      Icon(Icons.star, color: Colors.orange, size: 16),
                      Text(
                        " 4.9 (142)",
                        style: TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 16),
                      Icon(
                        Icons.monetization_on_outlined,
                        color: Color(0xFF008DDA),
                        size: 16,
                      ),
                      Text(
                        " \$40 / hour",
                        style: TextStyle(
                          color: Color(0xFF008DDA),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Divider(thickness: 1, color: Colors.grey.shade200),
        const SizedBox(height: 10),
      ],
    );
  }
}
