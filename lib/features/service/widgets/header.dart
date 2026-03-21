import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prm_project/core/models/service.dart';
import 'package:prm_project/core/utils/image_helper.dart';
import 'package:prm_project/features/service/viewmodel/service_favorites_provider.dart';

class Header extends ConsumerWidget {
  final Service service;

  const Header({super.key, required this.service});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cover =
        service.images.isNotEmpty ? service.images.first : service.image;
    final isFavorite = ref.watch(
      serviceFavoritesProvider.select((favorites) => favorites.contains(service.id)),
    );

    return Stack(
      children: [
        ImageHelper.loadNetworkImage(
          imageUrl: cover,
          height: 320,
          width: double.infinity,
          fit: BoxFit.cover,
          errorWidget: Container(
            height: 320,
            width: double.infinity,
            color: Colors.grey.shade200,
            alignment: Alignment.center,
            child: const Icon(Icons.broken_image, size: 40),
          ),
        ),
        Positioned(
          top: MediaQuery.of(context).padding.top + 10,
          left: 16,
          child: _buildCircleButton(
            icon: Icons.arrow_back,
            onTap: () => Navigator.pop(context),
          ),
        ),
        Positioned(
          top: MediaQuery.of(context).padding.top + 10,
          right: 16,
          child: _buildCircleButton(
            icon: isFavorite ? Icons.favorite : Icons.favorite_border,
            iconColor: isFavorite ? Colors.red : Colors.black,
            onTap: () =>
                ref.read(serviceFavoritesProvider.notifier).toggle(service.id),
          ),
        ),
      ],
    );
  }

  Widget _buildCircleButton({
    required IconData icon,
    required VoidCallback onTap,
    Color iconColor = Colors.black,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
    );
  }
}
