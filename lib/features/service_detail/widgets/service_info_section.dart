import 'package:flutter/material.dart';

/* tieu de dich vu + mo ta */
class ServiceInfoSection extends StatelessWidget {
  const ServiceInfoSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "About Plumbing Service service",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 10),
        RichText(
          text: TextSpan(
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
              height: 1.5,
            ),
            children: [
              const TextSpan(
                text:
                    "Reliable plumbing services for leaks and repairs. This service is available in your area. Please check the availability.... ",
              ),
              TextSpan(
                text: "Show more",
                style: const TextStyle(
                  color: Color(0xFF008DDA),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
