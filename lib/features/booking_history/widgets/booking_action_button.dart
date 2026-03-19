import 'package:flutter/material.dart';
import 'package:prm_project/core/enums/booking_status.dart';

class BookingActionButton extends StatelessWidget {
  final BookingStatus status;
  final VoidCallback? onPressed;

  const BookingActionButton({
    super.key,
    required this.status,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    if (status == BookingStatus.cancelled || status == BookingStatus.rejected) {
      return const SizedBox.shrink();
    }

    String buttonText = "";
    Color buttonColor = const Color(0xFF008DDA);

    switch (status) {
      case BookingStatus.pending:
        buttonText = "Cancel Booking";
        buttonColor = Colors.red.shade400;
        break;
      case BookingStatus.accepted:
        buttonText = "View Details";
        buttonColor = const Color(0xFF607D8B);
        break;
      case BookingStatus.inProgress:
        buttonText = "Mark as completed";
        buttonColor = Colors.black;
        break;
      case BookingStatus.completed:
        buttonText = "Add your Review";
        buttonColor = const Color(0xFF008DDA);
        break;
      default:
        buttonText = "Details";
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFF1F4F8))),
      ),
      child: ElevatedButton(
        onPressed: onPressed ?? () => _handleAction(context, status),
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          minimumSize: const Size(double.infinity, 54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: Text(
          buttonText,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _handleAction(BuildContext context, BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        _showConfirmationDialog(
          context,
          "Cancel Booking",
          "Are you sure you want to cancel this booking?",
        );
        break;
      case BookingStatus.inProgress:
        _showConfirmationDialog(
          context,
          "Complete Service",
          "Are you sure the service is finished?",
        );
        break;
      case BookingStatus.completed:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Opening Review screen...")),
        );
        break;
      default:
        break;
    }
  }

  void _showConfirmationDialog(
    BuildContext context,
    String title,
    String content,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text(
              "Confirm",
              style: TextStyle(color: Color(0xFF008DDA)),
            ),
          ),
        ],
      ),
    );
  }
}
