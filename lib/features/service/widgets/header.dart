import 'package:flutter/material.dart';

/* anh nen tren cung + appbar */
class Header extends StatelessWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // anh dich vu
        Image.network(
          'https://images.unsplash.com/photo-1584622650111-993a426fbf0a?q=80&w=1000',
          height: 320,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
        // nut back
        Positioned(
          top: MediaQuery.of(context).padding.top + 10,
          left: 16,
          child: _buildCircleButton(
            icon: Icons.arrow_back,
            onTap: () => Navigator.pop(context),
          ),
        ),
        // nut share
        Positioned(
          top: MediaQuery.of(context).padding.top + 10,
          right: 16,
          child: _buildCircleButton(icon: Icons.ios_share, onTap: () {}),
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