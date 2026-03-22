import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../viewmodel/booking_flow_viewmodel.dart';

class StepSummary extends ConsumerWidget {
  const StepSummary({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flowState = ref.watch(bookingFlowViewModelProvider);
    final booking = flowState.booking;
    final selectedService = flowState.selectedService;
    final selectedWorker = flowState.selectedWorker;
    final colorScheme = Theme.of(context).colorScheme;

    final scheduled = booking.scheduledAt ?? DateTime.now();
    final dateStr = DateFormat('EEE, d MMM yyyy').format(scheduled);
    final timeStr = DateFormat('hh:mm a').format(scheduled);

    // Calculate prices
    final servicePrice = booking.totalPrice;
    final serviceFee = servicePrice * 0.05; // 5% service fee
    final totalPrice = servicePrice + serviceFee;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Details",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        Text(
          "Please check your details before proceeding to payment.",
          style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 13),
        ),
        const SizedBox(height: 16),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
          ),
          child: Column(
            children: [
              // Service info
              if (selectedService != null)
                _buildSummaryRow(
                  Icons.cleaning_services_outlined,
                  "Service",
                  selectedService.name,
                  colorScheme: colorScheme,
                ),
              // Worker info
              if (selectedWorker != null)
                _buildSummaryRow(
                  Icons.person_outline,
                  "Worker",
                  selectedWorker.name,
                  colorScheme: colorScheme,
                ),
              _buildSummaryRow(
                Icons.calendar_today,
                "Date",
                dateStr,
                colorScheme: colorScheme,
              ),
              _buildSummaryRow(
                Icons.access_time,
                "Time",
                timeStr,
                colorScheme: colorScheme,
              ),
              _buildSummaryRow(
                Icons.handyman_outlined,
                "Duration",
                "${booking.durationMinutes} min",
                colorScheme: colorScheme,
              ),
              if (booking.address != null && booking.address!.isNotEmpty)
                _buildSummaryRow(
                  Icons.location_on_outlined,
                  "Address",
                  booking.address!,
                  colorScheme: colorScheme,
                ),
              _buildSummaryRow(
                Icons.payment,
                "Method",
                _formatPaymentMethod(booking.paymentMethod),
                colorScheme: colorScheme,
              ),
              Divider(height: 32, color: colorScheme.outline.withOpacity(0.2)),
              _buildSummaryRow(
                null,
                "Service Price",
                "\$${servicePrice.toStringAsFixed(2)}",
                colorScheme: colorScheme,
              ),
              _buildSummaryRow(
                null,
                "Service Fee (5%)",
                "\$${serviceFee.toStringAsFixed(2)}",
                colorScheme: colorScheme,
              ),
              Divider(height: 32, color: colorScheme.outline.withOpacity(0.2)),
              _buildSummaryRow(
                null,
                "Total price",
                "\$${totalPrice.toStringAsFixed(2)}",
                isTotal: true,
                colorScheme: colorScheme,
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),
        Text(
          "Promo",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          decoration: InputDecoration(
            hintText: "Enter promo code...",
            hintStyle: TextStyle(
              fontSize: 14,
              color: colorScheme.onSurfaceVariant.withOpacity(0.5),
            ),
            prefixIcon: Icon(
              Icons.confirmation_number_outlined,
              size: 20,
              color: colorScheme.onSurfaceVariant,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: colorScheme.outline.withOpacity(0.2),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: colorScheme.outline.withOpacity(0.2),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: const Color(0xFF008DDA), width: 2),
            ),
          ),
        ),
      ],
    );
  }

  String _formatPaymentMethod(String method) {
    switch (method.toLowerCase()) {
      case 'cash':
        return 'Cash';
      case 'card':
        return 'Credit/Debit Card';
      case 'wallet':
        return 'Digital Wallet';
      default:
        return method;
    }
  }

  Widget _buildSummaryRow(
    IconData? icon,
    String label,
    String value, {
    bool isTotal = false,
    required ColorScheme colorScheme,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: colorScheme.onSurfaceVariant),
            const SizedBox(width: 8),
          ],
          Text(
            label,
            style: TextStyle(
              color: isTotal
                  ? colorScheme.onSurface
                  : colorScheme.onSurfaceVariant,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: isTotal ? 18 : 14,
                color: isTotal
                    ? const Color(0xFF008DDA)
                    : colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
