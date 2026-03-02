import 'package:flutter/material.dart';

class StepNotes extends StatelessWidget {
  const StepNotes({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Note for professional",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const Text(
          "You can add a note to the professional here",
          style: TextStyle(color: Colors.grey, fontSize: 13),
        ),
        const SizedBox(height: 16),
        TextField(
          maxLines: 6,
          decoration: InputDecoration(
            hintText: "Write your note here",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Checkbox(value: false, onChanged: (v) {}),
            const Expanded(
              child: Text(
                "I agree to the Terms of Service, Community Guidelines and Privacy Policy.",
                style: TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
