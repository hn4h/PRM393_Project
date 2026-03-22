import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodel/booking_flow_viewmodel.dart';
import '../utils/booking_validators.dart';

class StepPayment extends ConsumerWidget {
  const StepPayment({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flowState = ref.watch(bookingFlowViewModelProvider);
    final booking = flowState.booking;
    final notifier = ref.read(bookingFlowViewModelProvider.notifier);
    final colorScheme = Theme.of(context).colorScheme;

    final selectedMethod = booking.paymentMethod;
    final validationError = BookingValidators.validatePaymentMethod(
      selectedMethod,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Payment Method *",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        Text(
          "Choose a payment method",
          style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 13),
        ),
        const SizedBox(height: 16),

        _buildPaymentOption(
          context,
          title: "Credit Card",
          subtitle: "Secure and fast payment",
          icon: Icons.credit_card,
          isSelected: selectedMethod == "Credit Card",
          onTap: () => notifier.setPaymentMethod("Credit Card"),
          colorScheme: colorScheme,
        ),

        _buildPaymentOption(
          context,
          title: "PayPal",
          subtitle: "Secure and fast payment",
          icon: Icons.account_balance_wallet_outlined,
          isSelected: selectedMethod == "PayPal",
          onTap: () => notifier.setPaymentMethod("PayPal"),
          colorScheme: colorScheme,
        ),

        _buildPaymentOption(
          context,
          title: "Apple Pay",
          subtitle: "Secure and fast payment",
          icon: Icons.apple,
          isSelected: selectedMethod == "Apple Pay",
          onTap: () => notifier.setPaymentMethod("Apple Pay"),
          colorScheme: colorScheme,
        ),

        _buildPaymentOption(
          context,
          title: "Google Pay",
          subtitle: "Secure and fast payment",
          icon: Icons.payment,
          isSelected: selectedMethod == "Google Pay",
          onTap: () => notifier.setPaymentMethod("Google Pay"),
          colorScheme: colorScheme,
        ),

        if (validationError != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.error_outline, color: colorScheme.error, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    validationError,
                    style: TextStyle(color: colorScheme.error, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
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
    required ColorScheme colorScheme,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected
                ? const Color(0xFF008DDA)
                : colorScheme.outline.withOpacity(0.2),
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
                : colorScheme.surfaceContainerLow,
            child: Icon(
              icon,
              color: isSelected
                  ? const Color(0xFF008DDA)
                  : colorScheme.onSurfaceVariant,
            ),
          ),
          title: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isSelected
                  ? const Color(0xFF008DDA)
                  : colorScheme.onSurface,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
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
