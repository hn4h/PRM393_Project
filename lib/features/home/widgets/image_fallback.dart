import 'package:flutter/material.dart';

class ImageFallback extends StatelessWidget {
  const ImageFallback({
    super.key,
    this.height,
    this.width,
    this.icon = Icons.image_not_supported_outlined,
    this.label = 'Image unavailable',
  });

  final double? height;
  final double? width;
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: height,
      width: width,
      color: colorScheme.surfaceContainerHighest,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: colorScheme.onSurfaceVariant, size: 32),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
