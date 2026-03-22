import 'package:flutter/material.dart';
import 'package:prm_project/core/theme/app_colors.dart';
import 'package:prm_project/core/theme/app_text_styles.dart';

import '../models/wk_schedule_models.dart';

class WkDayAgenda extends StatelessWidget {
  final DateTime selectedDateUtc7;
  final List<WkScheduleBooking> bookings;

  const WkDayAgenda({
    super.key,
    required this.selectedDateUtc7,
    required this.bookings,
  });

  @override
  Widget build(BuildContext context) {
    final dayBookings =
        bookings.where((b) => b.isSameDate(selectedDateUtc7)).toList()
          ..sort((a, b) => a.scheduledAtUtc7.compareTo(b.scheduledAtUtc7));
    final scheme = Theme.of(context).colorScheme;
    final divider = Theme.of(context).dividerColor;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Agenda - ${selectedDateUtc7.day}/${selectedDateUtc7.month}/${selectedDateUtc7.year}',
            style: AppTextStyles.headline3,
          ),
          const SizedBox(height: 10),
          if (dayBookings.isEmpty)
            Text(
              'No shifts on this day.',
              style: AppTextStyles.body2.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ...dayBookings.map(
            (booking) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: divider),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 4,
                    height: 48,
                    decoration: BoxDecoration(
                      color: wkScheduleStatusColor(booking.status),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          booking.timeRangeLabel,
                          style: AppTextStyles.label.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          booking.serviceName,
                          style: AppTextStyles.body1.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          booking.customerName,
                          style: AppTextStyles.body2.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  _StatusBadge(status: booking.status),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final WkScheduleBookingStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = wkScheduleStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        wkScheduleStatusLabel(status),
        style: AppTextStyles.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
