import 'package:flutter/material.dart';
import 'package:prm_project/core/theme/app_colors.dart';
import 'package:prm_project/core/theme/app_text_styles.dart';

import '../models/wk_schedule_models.dart';

class WkBookingsList extends StatelessWidget {
  final List<WkScheduleBooking> bookings;
  final WkBookingsFilter activeFilter;
  final ValueChanged<WkBookingsFilter> onFilterChanged;
  final ValueChanged<WkScheduleBooking> onOpenBooking;

  const WkBookingsList({
    super.key,
    required this.bookings,
    required this.activeFilter,
    required this.onFilterChanged,
    required this.onOpenBooking,
  });

  @override
  Widget build(BuildContext context) {
    final filtered = _filter(bookings, activeFilter)
      ..sort((a, b) => b.scheduledAtUtc7.compareTo(a.scheduledAtUtc7));
    final scheme = Theme.of(context).colorScheme;
    final divider = Theme.of(context).dividerColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withValues(alpha: 0.1),
                AppColors.primary.withValues(alpha: 0.02),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.22),
            ),
          ),
          child: Row(
            children: [
              const Icon(Icons.work_history_outlined, color: AppColors.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Job Inbox',
                  style: AppTextStyles.body1.copyWith(
                    fontWeight: FontWeight.w700,
                    color: scheme.onSurface,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${filtered.length}',
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 42,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: WkBookingsFilter.values
                .map(
                  (filter) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      selected: activeFilter == filter,
                      showCheckmark: false,
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (activeFilter == filter)
                            const Padding(
                              padding: EdgeInsets.only(right: 4),
                              child: Icon(
                                Icons.circle,
                                size: 7,
                                color: AppColors.primary,
                              ),
                            ),
                          Text(wkBookingsFilterLabel(filter)),
                        ],
                      ),
                      onSelected: (_) => onFilterChanged(filter),
                      backgroundColor: scheme.surface,
                      selectedColor: AppColors.primary.withValues(alpha: 0.15),
                      side: BorderSide(
                        color: activeFilter == filter
                            ? AppColors.primary
                            : divider,
                      ),
                      labelStyle: AppTextStyles.caption.copyWith(
                        color: activeFilter == filter
                            ? AppColors.primary
                            : scheme.onSurfaceVariant,
                        fontWeight: activeFilter == filter
                            ? FontWeight.bold
                            : FontWeight.w500,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                )
                .toList(growable: false),
          ),
        ),
        const SizedBox(height: 12),
        if (filtered.isEmpty)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: scheme.surface,
              border: Border.all(color: divider),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              'No bookings in this status.',
              style: AppTextStyles.body2.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
        ...filtered.map(
          (booking) => InkWell(
            onTap: () => onOpenBooking(booking),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: scheme.surface,
                border: Border.all(color: divider),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 10,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                    decoration: BoxDecoration(
                      color: wkScheduleStatusColor(
                        booking.status,
                      ).withValues(alpha: 0.08),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            booking.serviceName,
                            style: AppTextStyles.label.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        _StatusChip(status: booking.status),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.access_time,
                              size: 15,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              booking.timeRangeLabel,
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Icon(
                              Icons.calendar_today,
                              size: 14,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _scheduleDateLabel(booking.scheduledAtUtc7),
                              style: AppTextStyles.caption.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                            const Spacer(),
                            Icon(
                              Icons.chevron_right,
                              color: scheme.onSurfaceVariant,
                              size: 18,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          booking.customerName,
                          style: AppTextStyles.body1.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          booking.address,
                          style: AppTextStyles.body2.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                        if (booking.notes.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: scheme.surface.withValues(alpha: 0.8),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              booking.notes,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.caption.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Icon(
                              Icons.attach_money,
                              size: 16,
                              color: AppColors.success,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              _formatUsd(booking.totalPriceUsd),
                              style: AppTextStyles.label.copyWith(
                                color: AppColors.success,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const Spacer(),
                            if (booking.contactPhone != null &&
                                booking.contactPhone!.trim().isNotEmpty)
                              Text(
                                booking.contactPhone!,
                                style: AppTextStyles.caption.copyWith(
                                  color: scheme.onSurfaceVariant,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<WkScheduleBooking> _filter(
    List<WkScheduleBooking> source,
    WkBookingsFilter filter,
  ) {
    if (filter == WkBookingsFilter.all)
      return List<WkScheduleBooking>.from(source);

    return source
        .where((item) {
          return switch (filter) {
            WkBookingsFilter.pending =>
              item.status == WkScheduleBookingStatus.pending,
            WkBookingsFilter.accepted =>
              item.status == WkScheduleBookingStatus.accepted,
            WkBookingsFilter.inProgress =>
              item.status == WkScheduleBookingStatus.inProgress,
            WkBookingsFilter.completed =>
              item.status == WkScheduleBookingStatus.completed,
            WkBookingsFilter.rejected =>
              item.status == WkScheduleBookingStatus.rejected,
            WkBookingsFilter.cancelled =>
              item.status == WkScheduleBookingStatus.cancelled,
            WkBookingsFilter.all => true,
          };
        })
        .toList(growable: false);
  }

  String _scheduleDateLabel(DateTime date) {
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    final y = date.year;
    return '$d/$m/$y';
  }

  String _formatUsd(double value) {
    final fixed = value.toStringAsFixed(2);
    final parts = fixed.split('.');
    final whole = parts[0];
    final decimal = parts[1];
    final withCommas = whole.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (_) => ',',
    );
    return '\$$withCommas.$decimal';
  }
}

class _StatusChip extends StatelessWidget {
  final WkScheduleBookingStatus status;

  const _StatusChip({required this.status});

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
