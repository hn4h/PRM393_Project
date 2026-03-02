import 'package:flutter/material.dart';

class StepSchedule extends StatelessWidget {
  const StepSchedule({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCalendarHeader(),
        const SizedBox(height: 16),
        _buildCalendarGrid(),
        const SizedBox(height: 24),
        const Text(
          "Select a Time",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _buildTimeChip("10:00 AM", isSelected: true),
            _buildTimeChip("11:00 AM"),
            _buildTimeChip("12:00 PM"),
            _buildTimeChip("1:00 PM"),
            _buildTimeChip("2:00 PM"),
            _buildTimeChip("3:00 PM"),
            _buildTimeChip("4:00 PM"),
            _buildTimeChip("5:00 PM"),
          ],
        ),
      ],
    );
  }

  Widget _buildCalendarHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: const [
        Text("S"),
        Text("M"),
        Text("T"),
        Text("W"),
        Text("T"),
        Text("F"),
        Text("S"),
      ],
    );
  }

  Widget _buildCalendarGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
      ),
      itemCount: 31,
      itemBuilder: (context, index) {
        int day = index + 1;
        bool isSelected = day == 13;
        bool isToday = day == 2;
        return Center(
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF008DDA) : Colors.transparent,
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
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
