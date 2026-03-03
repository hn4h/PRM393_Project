import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodel/booking_flow_viewmodel.dart';

class StepPayment extends ConsumerWidget {
  const StepPayment({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flowState = ref.watch(bookingFlowViewModelProvider);
    final booking = flowState.booking;
    final notifier = ref.read(bookingFlowViewModelProvider.notifier);

    // dung bien tam sau them 'paymentMethod' vao Booking
    final selectedMethod = booking.duration;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Payment Method",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const Text(
          "Choose a payment method",
          style: TextStyle(color: Colors.grey, fontSize: 13),
        ),
        const SizedBox(height: 16),

        _buildPaymentOption(
          context,
          title: "Credit Card",
          subtitle: "Secure and fast payment",
          icon: Icons.credit_card,
          isSelected: selectedMethod == "Credit Card",
          onTap: () =>
              notifier.updateBooking(booking.copyWith(duration: "Credit Card")),
        ),

        _buildPaymentOption(
          context,
          title: "PayPal",
          subtitle: "Secure and fast payment",
          icon: Icons.account_balance_wallet_outlined,
          isSelected: selectedMethod == "PayPal",
          onTap: () =>
              notifier.updateBooking(booking.copyWith(duration: "PayPal")),
        ),

        _buildPaymentOption(
          context,
          title: "Apple Pay",
          subtitle: "Secure and fast payment",
          icon: Icons.apple,
          isSelected: selectedMethod == "Apple Pay",
          onTap: () =>
              notifier.updateBooking(booking.copyWith(duration: "Apple Pay")),
        ),

        _buildPaymentOption(
          context,
          title: "Google Pay",
          subtitle: "Secure and fast payment",
          icon: Icons.payment,
          isSelected: selectedMethod == "Google Pay",
          onTap: () =>
              notifier.updateBooking(booking.copyWith(duration: "Google Pay")),
        ),
      ],
    );
  }

  Widget _buildPaymentOption(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? const Color(0xFF008DDA) : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(16),
          color: isSelected
              ? const Color(0xFF008DDA).withOpacity(0.05)
              : Colors.transparent,
        ),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: isSelected
                ? const Color(0xFF008DDA).withOpacity(0.1)
                : Colors.grey[100],
            child: Icon(
              icon,
              color: isSelected ? const Color(0xFF008DDA) : Colors.black,
            ),
          ),
          title: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isSelected ? const Color(0xFF008DDA) : Colors.black,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          trailing: Radio<String>(
            value: title,
            groupValue: isSelected ? title : "",
            activeColor: const Color(0xFF008DDA),
            onChanged: (v) => onTap(),
          ),
        ),
      ),
    );
  }
}
