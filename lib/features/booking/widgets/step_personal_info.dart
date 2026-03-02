import 'package:flutter/material.dart';

class StepPersonalInfo extends StatelessWidget {
  const StepPersonalInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Confirm your booking",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const Text(
          "Please provide any additional information or notes for your booking.",
          style: TextStyle(color: Colors.grey, fontSize: 13),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(child: _buildTextField("First Name", "Duc")),
            const SizedBox(width: 16),
            Expanded(child: _buildTextField("Last Name", "Anh")),
          ],
        ),
        _buildTextField("Email", "anhddhe181409@gmail.com"),
        _buildTextField("Phone Number", "0123456442"),
        _buildTextField(
          "Full Address",
          "Hoa Lac, Ha Noi",
          icon: Icons.location_on,
        ),
        const SizedBox(height: 10),
        const Text(
          "Package Type",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _buildPackageChip("Standard", isSelected: true),
            const SizedBox(width: 12),
            _buildPackageChip("Premium"),
          ],
        ),
      ],
    );
  }

  Widget _buildTextField(String label, String hint, {IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 6),
          TextField(
            decoration: InputDecoration(
              hintText: hint,
              prefixIcon: icon != null ? Icon(icon, size: 20) : null,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPackageChip(String label, {bool isSelected = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected
            ? const Color(0xFF008DDA).withOpacity(0.1)
            : Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? const Color(0xFF008DDA) : Colors.transparent,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? const Color(0xFF008DDA) : Colors.black,
        ),
      ),
    );
  }
}
