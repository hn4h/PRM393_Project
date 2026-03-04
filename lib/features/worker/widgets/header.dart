import 'package:flutter/material.dart';
import 'package:prm_project/core/models/worker.dart';

class Header extends StatelessWidget {
  final Worker worker;

  const Header({super.key, required this.worker});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 44,
            backgroundImage: NetworkImage(worker.image),
            backgroundColor: Colors.grey.shade200,
            onBackgroundImageError: (_, __) {},
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                worker.name,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              if (worker.isVerified) ...[
                const SizedBox(width: 6),
                const Icon(Icons.verified, size: 18, color: Color(0xFF2F80ED)),
              ],
            ],
          ),
          const SizedBox(height: 4),
          Text(
            worker.jobTitle,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2F80ED),
            ),
          ),
        ],
      ),
    );
  }
}