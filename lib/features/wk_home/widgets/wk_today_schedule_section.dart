import 'package:flutter/material.dart';
import 'package:prm_project/core/theme/app_colors.dart';
import 'package:prm_project/core/theme/app_text_styles.dart';

import '../models/wk_home_models.dart';

class WkTodayScheduleSection extends StatelessWidget {
  final List<WkBookingCardData> jobs;
  final Future<void> Function(String bookingId) onStartJob;
  final Future<void> Function(String bookingId) onCompleteJob;
  final void Function(WkBookingCardData booking) onOpenChat;

  const WkTodayScheduleSection({
    super.key,
    required this.jobs,
    required this.onStartJob,
    required this.onCompleteJob,
    required this.onOpenChat,
  });

  @override
  Widget build(BuildContext context) {
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
          Text('Today\'s schedule', style: AppTextStyles.headline3),
          const SizedBox(height: 10),
          if (jobs.isEmpty)
            Text(
              'No jobs scheduled for today.',
              style: AppTextStyles.body2.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ...jobs.map(
            (job) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _JobCard(
                data: job,
                onStartJob: () => onStartJob(job.id),
                onCompleteJob: () => onCompleteJob(job.id),
                onOpenChat: () => onOpenChat(job),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _JobCard extends StatelessWidget {
  final WkBookingCardData data;
  final VoidCallback onStartJob;
  final VoidCallback onCompleteJob;
  final VoidCallback onOpenChat;

  const _JobCard({
    required this.data,
    required this.onStartJob,
    required this.onCompleteJob,
    required this.onOpenChat,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = data.status == WkJobStatus.completed;
    final scheme = Theme.of(context).colorScheme;
    final divider = Theme.of(context).dividerColor;

    return Opacity(
      opacity: isCompleted ? 0.72 : 1,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: divider),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${data.serviceName} | ${data.timeRangeLabel}',
                    style: AppTextStyles.label.copyWith(
                      fontWeight: FontWeight.w700,
                      color: scheme.onSurface,
                    ),
                  ),
                ),
                _StatusChip(status: data.status),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${data.customerName} • ${data.address}',
              style: AppTextStyles.body2.copyWith(
                color: scheme.onSurfaceVariant,
              ),
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
            Row(children: _actionButtons()),
          ],
        ),
      ),
    );
  }

  List<Widget> _actionButtons() {
    if (data.status == WkJobStatus.upcoming) {
      return [
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(42),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: onStartJob,
            child: const Text('Start job'),
          ),
        ),
        const SizedBox(width: 8),
        IconButton.filledTonal(
          onPressed: onOpenChat,
          icon: const Icon(Icons.chat_bubble_outline),
          tooltip: 'Open chat',
        ),
      ];
    }

    if (data.status == WkJobStatus.inProgress) {
      return [
        Expanded(
          child: Container(
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Text(
              'Waiting for customer to confirm completion.',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.warning,
                fontWeight: FontWeight.w700,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ];
    }

    return [
      Expanded(
        child: Container(
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_circle,
                size: 18,
                color: AppColors.success,
              ),
              const SizedBox(width: 6),
              Text(
                'Completed',
                style: AppTextStyles.label.copyWith(color: AppColors.success),
              ),
            ],
          ),
        ),
      ),
    ];
  }
}

class _StatusChip extends StatelessWidget {
  final WkJobStatus status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    late final Color background;
    late final Color text;
    late final String label;

    switch (status) {
      case WkJobStatus.upcoming:
        background = AppColors.primary.withValues(alpha: 0.12);
        text = AppColors.primary;
        label = 'Upcoming';
        break;
      case WkJobStatus.inProgress:
        background = AppColors.warning.withValues(alpha: 0.15);
        text = AppColors.warning;
        label = 'In progress';
        break;
      case WkJobStatus.completed:
        background = AppColors.success.withValues(alpha: 0.15);
        text = AppColors.success;
        label = 'Done';
        break;
      default:
        background = Theme.of(
          context,
        ).colorScheme.surface.withValues(alpha: 0.7);
        text = Theme.of(context).colorScheme.onSurfaceVariant;
        label = 'Other';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          color: text,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
