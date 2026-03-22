import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../viewmodel/booking_flow_viewmodel.dart';
import '../utils/booking_validators.dart';

class StepSchedule extends ConsumerStatefulWidget {
  const StepSchedule({super.key});

  @override
  ConsumerState<StepSchedule> createState() => _StepScheduleState();
}

class _StepScheduleState extends ConsumerState<StepSchedule> {
  late DateTime _displayedMonth;

  @override
  void initState() {
    super.initState();
    final booking = ref.read(bookingFlowViewModelProvider).booking;
    _displayedMonth = booking.scheduledAt ?? DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final flowState = ref.watch(bookingFlowViewModelProvider);
    final booking = flowState.booking;
    final notifier = ref.read(bookingFlowViewModelProvider.notifier);
    final selectedDate = booking.scheduledAt ?? DateTime.now();
    final colorScheme = Theme.of(context).colorScheme;

    // Check if there's a validation error
    final validationError = BookingValidators.validateScheduledTime(
      booking.scheduledAt,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Select a Date",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        _buildMonthHeader(colorScheme),
        const SizedBox(height: 12),
        _buildWeekdayHeader(colorScheme),
        const SizedBox(height: 8),
        _buildCalendarGrid(selectedDate, notifier, booking, colorScheme),
        const SizedBox(height: 24),
        Text(
          "Select a Time",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children:
              [
                "09:00 AM",
                "10:00 AM",
                "11:00 AM",
                "12:00 PM",
                "01:00 PM",
                "02:00 PM",
                "03:00 PM",
                "04:00 PM",
                "05:00 PM",
              ].map((timeStr) {
                final isSelected = _isTimeSelected(selectedDate, timeStr);
                final isPastTime = _isPastTime(selectedDate, timeStr);

                return GestureDetector(
                  onTap: isPastTime
                      ? null
                      : () {
                          final newDateTime = _updateTime(
                            selectedDate,
                            timeStr,
                          );
                          notifier.updateBooking(
                            booking.copyWith(scheduledAt: newDateTime),
                          );
                        },
                  child: _buildTimeChip(
                    timeStr,
                    isSelected: isSelected,
                    isDisabled: isPastTime,
                    colorScheme: colorScheme,
                  ),
                );
              }).toList(),
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

  Widget _buildMonthHeader(ColorScheme colorScheme) {
    final monthYear = DateFormat('MMMM yyyy').format(_displayedMonth);
    final now = DateTime.now();
    final canGoPrevious =
        _displayedMonth.year > now.year ||
        (_displayedMonth.year == now.year && _displayedMonth.month > now.month);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: Icon(Icons.chevron_left, color: colorScheme.onSurface),
          onPressed: canGoPrevious
              ? () {
                  setState(() {
                    _displayedMonth = DateTime(
                      _displayedMonth.year,
                      _displayedMonth.month - 1,
                    );
                  });
                }
              : null,
        ),
        Text(
          monthYear,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        IconButton(
          icon: Icon(Icons.chevron_right, color: colorScheme.onSurface),
          onPressed: () {
            setState(() {
              _displayedMonth = DateTime(
                _displayedMonth.year,
                _displayedMonth.month + 1,
              );
            });
          },
        ),
      ],
    );
  }

  Widget _buildWeekdayHeader(ColorScheme colorScheme) {
    const weekdays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: weekdays
          .map(
            (day) => SizedBox(
              width: 40,
              child: Center(
                child: Text(
                  day,
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildCalendarGrid(
    DateTime selectedDate,
    BookingFlowViewModel notifier,
    dynamic booking,
    ColorScheme colorScheme,
  ) {
    final firstDayOfMonth = DateTime(
      _displayedMonth.year,
      _displayedMonth.month,
      1,
    );
    final lastDayOfMonth = DateTime(
      _displayedMonth.year,
      _displayedMonth.month + 1,
      0,
    );
    final daysInMonth = lastDayOfMonth.day;
    final firstWeekday = firstDayOfMonth.weekday % 7; // Sunday = 0
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Calculate total cells needed (leading empty + days)
    final totalCells = firstWeekday + daysInMonth;
    final rows = (totalCells / 7).ceil();

    return Column(
      children: List.generate(rows, (rowIndex) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(7, (colIndex) {
            final cellIndex = rowIndex * 7 + colIndex;
            final dayNumber = cellIndex - firstWeekday + 1;

            if (dayNumber < 1 || dayNumber > daysInMonth) {
              return const SizedBox(width: 40, height: 40);
            }

            final cellDate = DateTime(
              _displayedMonth.year,
              _displayedMonth.month,
              dayNumber,
            );
            final isSelected =
                selectedDate.year == cellDate.year &&
                selectedDate.month == cellDate.month &&
                selectedDate.day == cellDate.day;
            final isToday =
                today.year == cellDate.year &&
                today.month == cellDate.month &&
                today.day == cellDate.day;
            final isPast = cellDate.isBefore(today);

            return GestureDetector(
              onTap: isPast
                  ? null
                  : () {
                      final newDate = DateTime(
                        cellDate.year,
                        cellDate.month,
                        cellDate.day,
                        selectedDate.hour,
                        selectedDate.minute,
                      );
                      notifier.updateBooking(
                        booking.copyWith(scheduledAt: newDate),
                      );
                    },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF008DDA)
                      : Colors.transparent,
                  shape: BoxShape.circle,
                  border: isToday && !isSelected
                      ? Border.all(color: const Color(0xFF008DDA), width: 2)
                      : null,
                ),
                child: Center(
                  child: Text(
                    '$dayNumber',
                    style: TextStyle(
                      color: isPast
                          ? colorScheme.onSurfaceVariant.withOpacity(0.4)
                          : isSelected
                          ? Colors.white
                          : isToday
                          ? const Color(0xFF008DDA)
                          : colorScheme.onSurface,
                      fontWeight: isSelected || isToday
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            );
          }),
        );
      }),
    );
  }

  Widget _buildTimeChip(
    String time, {
    required bool isSelected,
    required bool isDisabled,
    required ColorScheme colorScheme,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected
            ? const Color(0xFF008DDA).withOpacity(0.1)
            : isDisabled
            ? colorScheme.surfaceContainerHighest
            : colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected
              ? const Color(0xFF008DDA)
              : isDisabled
              ? Colors.transparent
              : colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Text(
        time,
        style: TextStyle(
          color: isSelected
              ? const Color(0xFF008DDA)
              : isDisabled
              ? colorScheme.onSurfaceVariant.withOpacity(0.5)
              : colorScheme.onSurface,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
        ),
      ),
    );
  }

  bool _isTimeSelected(DateTime current, String timeStr) {
    final hour = int.parse(timeStr.split(":")[0]);
    final isPM = timeStr.contains("PM");
    final convertedHour = (isPM && hour != 12)
        ? hour + 12
        : (isPM ? hour : (hour == 12 ? 0 : hour));
    return current.hour == convertedHour;
  }

  /// Check if a time is in the past
  /// Returns true if the selected date is today and the time has already passed
  bool _isPastTime(DateTime selected, String timeStr) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selectedDateOnly = DateTime(
      selected.year,
      selected.month,
      selected.day,
    );

    // Only past times are counted if selected date is today
    if (!selectedDateOnly.isAtSameMomentAs(today)) {
      return false;
    }

    final hour = int.parse(timeStr.split(":")[0]);
    final isPM = timeStr.contains("PM");
    final convertedHour = (isPM && hour != 12)
        ? hour + 12
        : (isPM ? hour : (hour == 12 ? 0 : hour));

    final timeDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      convertedHour,
      0,
    );
    return timeDateTime.isBefore(now);
  }

  DateTime _updateTime(DateTime current, String timeStr) {
    final hour = int.parse(timeStr.split(":")[0]);
    final isPM = timeStr.contains("PM");
    final convertedHour = (isPM && hour != 12)
        ? hour + 12
        : (isPM ? hour : (hour == 12 ? 0 : hour));
    return DateTime(current.year, current.month, current.day, convertedHour, 0);
  }
}
