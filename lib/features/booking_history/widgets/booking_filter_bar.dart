import 'package:flutter/material.dart';

class BookingFilterBar extends StatefulWidget {
  const BookingFilterBar({super.key});

  @override
  State<BookingFilterBar> createState() => _BookingFilterBarState();
}

class _BookingFilterBarState extends State<BookingFilterBar> {
  int selectedIndex = 0;
  final List<String> categories = [
    "All",
    "Plumbing",
    "Electrical",
    "Cleaning",
    "Repair",
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Thanh tìm kiếm
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: TextField(
            decoration: InputDecoration(
              hintText: "Search in services, workers, etc.",
              hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
              prefixIcon: const Icon(
                Icons.search,
                color: Colors.grey,
                size: 20,
              ),
              filled: true,
              fillColor: const Color(0xFFF1F4F8),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              bool isSelected = selectedIndex == index;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => setState(() => selectedIndex = index),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF008DDA)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? Colors.transparent
                            : Colors.grey.shade200,
                      ),
                    ),
                    child: Text(
                      categories[index],
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
