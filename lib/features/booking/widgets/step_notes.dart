import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodel/booking_flow_viewmodel.dart';

class StepNotes extends ConsumerStatefulWidget {
  const StepNotes({super.key});

  @override
  ConsumerState<StepNotes> createState() => _StepNotesState();
}

class _StepNotesState extends ConsumerState<StepNotes> {
  bool _isAgreed = false;
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final booking = ref.read(bookingFlowViewModelProvider).booking;
    _notesController.text = booking.notes ?? '';
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final flowState = ref.watch(bookingFlowViewModelProvider);
    final booking = flowState.booking;
    final notifier = ref.read(bookingFlowViewModelProvider.notifier);

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

        TextFormField(
          controller: _notesController,
          maxLines: 6,
          onChanged: (val) {
            notifier.updateBooking(booking.copyWith(notes: val));
          },
          decoration: InputDecoration(
            hintText: "Enter your notes...",
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
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
        const SizedBox(height: 20),

        Row(
          children: [
            Checkbox(
              value: _isAgreed,
              activeColor: const Color(0xFF008DDA),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              onChanged: (v) {
                setState(() {
                  _isAgreed = v ?? false;
                });
              },
            ),
            const Expanded(
              child: Text(
                "I agree to the Terms of Service, Community Guidelines and Privacy Policy.",
                style: TextStyle(fontSize: 12, color: Colors.black87),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
