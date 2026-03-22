import 'package:flutter/material.dart';
import 'package:prm_project/core/theme/app_colors.dart';
import 'package:prm_project/core/theme/app_text_styles.dart';

import '../models/wk_home_models.dart';

class WkPendingRequestsSection extends StatelessWidget {
  final List<WkBookingCardData> requests;
  final Future<void> Function(String bookingId) onAccept;
  final Future<void> Function(String bookingId) onDecline;

  const WkPendingRequestsSection({
    super.key,
    required this.requests,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    final hasRequest = requests.isNotEmpty;
    final scheme = Theme.of(context).colorScheme;
    final divider = Theme.of(context).dividerColor;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: hasRequest
            ? AppColors.error.withValues(alpha: 0.05)
            : scheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasRequest ? AppColors.error.withValues(alpha: 0.35) : divider,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('New requests', style: AppTextStyles.headline3),
              const SizedBox(width: 8),
              if (hasRequest)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '${requests.length}',
                    style: AppTextStyles.caption.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          if (!hasRequest)
            Text(
              'No new requests yet.',
              style: AppTextStyles.body2.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          if (hasRequest)
            ...requests.map(
              (booking) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _PendingBookingCard(
                  data: booking,
                  onAccept: () => onAccept(booking.id),
                  onDecline: () => onDecline(booking.id),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _PendingBookingCard extends StatelessWidget {
  final WkBookingCardData data;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const _PendingBookingCard({
    required this.data,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final divider = Theme.of(context).dividerColor;

    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: divider),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${data.serviceName} | ${data.timeRangeLabel}, ${data.dayLabel}',
            style: AppTextStyles.label.copyWith(
              color: scheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${data.customerName} • ${data.address}',
            style: AppTextStyles.body2.copyWith(color: scheme.onSurfaceVariant),
          ),
          if (data.notes.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              data.notes,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.caption.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(42),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: onAccept,
                  child: const Text('Accept'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: BorderSide(
                      color: AppColors.error.withValues(alpha: 0.5),
                    ),
                    minimumSize: const Size.fromHeight(42),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: onDecline,
                  child: const Text('Decline'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
