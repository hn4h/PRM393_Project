import 'package:flutter/material.dart';

/* thong tin tho */
class StepWorkerInfo extends StatelessWidget {
  const StepWorkerInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
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
                  const Text(
                    "He is a highly experienced home cleaner with over ...",
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
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
                      Text(
                        "\$40 / hour",
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
        const Divider(thickness: 3, color: Colors.black),
      ],
    );
  }
}
