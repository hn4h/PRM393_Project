import 'package:flutter/material.dart';
import 'package:prm_project/core/models/booking.dart';

class BookingActionButton extends StatelessWidget {
  final BookingStatus status;

  const BookingActionButton({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    // neu status la cancelled, khong hien thi nut bam hdong
    if (status == BookingStatus.cancelled) {
      return const SizedBox.shrink();
    }

    String buttonText = "";
    Color buttonColor = const Color(0xFF008DDA);

    switch (status) {
      case BookingStatus.inProgress:
        buttonText = "Mark as completed";
        buttonColor = Colors.black;
        break;
      case BookingStatus.upcoming:
        buttonText = "Update booking";
        buttonColor = const Color(0xFF607D8B);
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
        onPressed: () {
          _handleAction(context, status);
        },
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

  // ham xu ly logic khi bam nut dua tren trang thai
  void _handleAction(BuildContext context, BookingStatus status) {
    switch (status) {
      case BookingStatus.inProgress:
        // logic khi hoan tat dvu
        _showConfirmationDialog(
          context,
          "Complete Service",
          "Are you sure the service is finished?",
        );
        break;
      case BookingStatus.upcoming:
        // logic khi muon thay doi lich/update
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Redirecting to reschedule...")),
        );
        break;
      case BookingStatus.completed:
        // logic danh gia
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Opening Review screen...")),
        );
        break;
      default:
        break;
    }
  }

  // popup xac nhan hoan thanh
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
              // logic cap nhat status
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
