import 'package:flutter/material.dart';
import 'package:prm_project/core/models/service.dart';
import 'package:prm_project/core/utils/image_helper.dart';

class Header extends StatelessWidget {
  final Service service;

  const Header({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    final cover =
        service.images.isNotEmpty ? service.images.first : service.image;

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
      ],
    );
  }

  Widget _buildCircleButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.black, size: 20),
      ),
    );
  }
}
