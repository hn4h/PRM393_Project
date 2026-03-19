import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodel/booking_flow_viewmodel.dart';

class StepSchedule extends ConsumerWidget {
  const StepSchedule({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flowState = ref.watch(bookingFlowViewModelProvider);
    final booking = flowState.booking;
    final notifier = ref.read(bookingFlowViewModelProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCalendarHeader(),
        const SizedBox(height: 16),
        _buildCalendarGrid(booking, notifier),
        const SizedBox(height: 24),
        const Text(
          "Select a Time",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children:
              [
                "10:00 AM",
                "11:00 AM",
                "12:00 PM",
                "01:00 PM",
                "02:00 PM",
                "03:00 PM",
                "04:00 PM",
                "05:00 PM",
              ].map((timeStr) {
                final scheduled = booking.scheduledAt ?? DateTime.now();
                final isSelected = _isTimeSelected(
                  scheduled,
                  timeStr,
                );

                return GestureDetector(
                  onTap: () {
                    final newDateTime = _updateTime(
                      scheduled,
                      timeStr,
                    );
                    notifier.updateBooking(
                      booking.copyWith(scheduledAt: newDateTime),
                    );
                  },
                  child: _buildTimeChip(timeStr, isSelected: isSelected),
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildCalendarHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: const [
        Text("S", style: TextStyle(color: Colors.grey)),
        Text("M", style: TextStyle(color: Colors.grey)),
        Text("T", style: TextStyle(color: Colors.grey)),
        Text("W", style: TextStyle(color: Colors.grey)),
        Text("T", style: TextStyle(color: Colors.grey)),
        Text("F", style: TextStyle(color: Colors.grey)),
        Text("S", style: TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _buildCalendarGrid(dynamic booking, BookingFlowViewModel notifier) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
      ),
      itemCount: 31,
      itemBuilder: (context, index) {
        int day = index + 1;
        final scheduled = booking.scheduledAt ?? DateTime.now();
        bool isSelected = scheduled.day == day;
        bool isToday =
            DateTime.now().day == day &&
            DateTime.now().month == scheduled.month;

        return GestureDetector(
          onTap: () {
            final newDate = DateTime(
              scheduled.year,
              scheduled.month,
              day,
              scheduled.hour,
              scheduled.minute,
            );
            notifier.updateBooking(booking.copyWith(scheduledAt: newDate));
          },
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF008DDA)
                    : Colors.transparent,
                shape: BoxShape.circle,
                border: isToday
                    ? Border.all(color: const Color(0xFF008DDA))
                    : null,
              ),
              child: Text(
                "$day",
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : (isToday ? const Color(0xFF008DDA) : Colors.black),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTimeChip(String time, {bool isSelected = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected
            ? const Color(0xFF008DDA).withOpacity(0.1)
            : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? const Color(0xFF008DDA) : Colors.transparent,
        ),
      ),
      child: Text(
        time,
        style: TextStyle(
          color: isSelected ? const Color(0xFF008DDA) : Colors.black,
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

  DateTime _updateTime(DateTime current, String timeStr) {
    final hour = int.parse(timeStr.split(":")[0]);
    final isPM = timeStr.contains("PM");
    final convertedHour = (isPM && hour != 12)
        ? hour + 12
        : (isPM ? hour : (hour == 12 ? 0 : hour));
    return DateTime(current.year, current.month, current.day, convertedHour, 0);
  }
}
