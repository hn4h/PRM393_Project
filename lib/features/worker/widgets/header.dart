import 'package:flutter/material.dart';
import 'package:prm_project/core/models/worker.dart';

class Header extends StatelessWidget {
  final Worker worker;

  const Header({super.key, required this.worker});

  @override
  Widget build(BuildContext context) {
    final hasAvatar = worker.image.isNotEmpty;

    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 44,
            backgroundColor: Colors.grey.shade200,
            child: ClipOval(
              child: hasAvatar
                  ? Image.network(
                      worker.image,
                      width: 88,
                      height: 88,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.person,
                        color: Colors.grey,
                        size: 36,
                      ),
                    )
                  : const Icon(Icons.person, color: Colors.grey, size: 36),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  worker.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (worker.isVerified) ...[
                const SizedBox(width: 6),
                const Icon(Icons.verified, size: 18, color: Color(0xFF2F80ED)),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
