import 'package:flutter/material.dart';
import 'package:prm_project/core/theme/app_colors.dart';
import 'package:prm_project/core/theme/app_text_styles.dart';

import '../models/wk_schedule_models.dart';

class WkMonthCalendar extends StatelessWidget {
  final DateTime focusedMonthUtc7;
  final DateTime selectedDateUtc7;
  final List<WkScheduleBooking> bookings;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;
  final ValueChanged<DateTime> onSelectDate;

  const WkMonthCalendar({
    super.key,
    required this.focusedMonthUtc7,
    required this.selectedDateUtc7,
    required this.bookings,
    required this.onPreviousMonth,
    required this.onNextMonth,
    required this.onSelectDate,
  });

  @override
  Widget build(BuildContext context) {
    final monthLabel = _monthLabel(focusedMonthUtc7);
    final days = _buildCalendarCells(focusedMonthUtc7);
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
          Row(
            children: [
              IconButton(
                onPressed: onPreviousMonth,
                icon: const Icon(Icons.chevron_left),
                tooltip: 'Previous month',
              ),
              Expanded(
                child: Text(
                  monthLabel,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.headline3,
                ),
              ),
              IconButton(
                onPressed: onNextMonth,
                icon: const Icon(Icons.chevron_right),
                tooltip: 'Next month',
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: const [
              _WeekdayCell(label: 'Mon'),
              _WeekdayCell(label: 'Tue'),
              _WeekdayCell(label: 'Wed'),
              _WeekdayCell(label: 'Thu'),
              _WeekdayCell(label: 'Fri'),
              _WeekdayCell(label: 'Sat'),
              _WeekdayCell(label: 'Sun'),
            ],
          ),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: days.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 0.95,
            ),
            itemBuilder: (context, index) {
              final day = days[index];
              if (day == null) return const SizedBox.shrink();

              final selected = _isSameDate(day, selectedDateUtc7);
              final inFocusedMonth = day.month == focusedMonthUtc7.month;
              final dailyCount = _bookingsInDate(day).length;

              Color? markerColor;
              if (dailyCount > 0) {
                markerColor = dailyCount >= 4
                    ? AppColors.warning
                    : AppColors.success;
              }

              return InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () => onSelectDate(day),
                child: Container(
                  margin: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.primary.withValues(alpha: 0.12)
                        : null,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${day.day}',
                        style: AppTextStyles.body2.copyWith(
                          color: inFocusedMonth
                              ? scheme.onSurface
                              : scheme.onSurfaceVariant,
                          fontWeight: selected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (markerColor != null)
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: markerColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  List<WkScheduleBooking> _bookingsInDate(DateTime date) {
    return bookings.where((b) => b.isSameDate(date)).toList(growable: false);
  }

  String _monthLabel(DateTime date) {
    const monthNames = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${monthNames[date.month - 1]} ${date.year}';
  }

  List<DateTime?> _buildCalendarCells(DateTime month) {
    final firstDay = DateTime(month.year, month.month, 1);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;

    final firstWeekday = firstDay.weekday;
    final leadingEmpty = firstWeekday - DateTime.monday;

    final cells = <DateTime?>[];
    for (int i = 0; i < leadingEmpty; i++) {
      cells.add(null);
    }

    for (int day = 1; day <= daysInMonth; day++) {
      cells.add(DateTime(month.year, month.month, day));
    }

    while (cells.length % 7 != 0) {
      cells.add(null);
    }

    return cells;
  }

  bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

class _WeekdayCell extends StatelessWidget {
  final String label;

  const _WeekdayCell({required this.label});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Expanded(
      child: Center(
        child: Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: scheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
