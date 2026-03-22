import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prm_project/core/enums/booking_status.dart';
import '../viewmodel/booking_history_viewmodel.dart';

class BookingFilterBar extends ConsumerWidget {
  const BookingFilterBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectedStatus = ref.watch(selectedStatusFilterProvider);
    final searchQuery = ref.watch(searchQueryProvider);

    // Status filter options: null means "All"
    final statusFilters = <BookingStatus?>[
      null, // All
      BookingStatus.pending,
      BookingStatus.accepted,
      BookingStatus.inProgress,
      BookingStatus.completed,
      BookingStatus.cancelled,
      BookingStatus.rejected,
    ];

    String getStatusLabel(BookingStatus? status) {
      if (status == null) return 'All';
      return status.label;
    }

    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: TextField(
            onChanged: (value) {
              ref.read(searchQueryProvider.notifier).state = value;
            },
            decoration: InputDecoration(
              hintText: "Search by service, worker, address...",
              hintStyle: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 14,
              ),
              prefixIcon: Icon(
                Icons.search,
                color: colorScheme.onSurfaceVariant,
                size: 20,
              ),
              suffixIcon: searchQuery.isNotEmpty
                  ? IconButton(
                      icon: Icon(
                        Icons.clear,
                        color: colorScheme.onSurfaceVariant,
                        size: 20,
                      ),
                      onPressed: () {
                        ref.read(searchQueryProvider.notifier).state = '';
                      },
                    )
                  : null,
              filled: true,
              fillColor: isDark
                  ? colorScheme.surfaceContainerHighest
                  : const Color(0xFFF1F4F8),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        // Status filter chips
        SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: statusFilters.length,
            itemBuilder: (context, index) {
              final status = statusFilters[index];
              final isSelected = selectedStatus == status;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () {
                    ref.read(selectedStatusFilterProvider.notifier).state =
                        status;
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF008DDA)
                          : colorScheme.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? Colors.transparent
                            : Theme.of(context).dividerColor,
                      ),
                    ),
                    child: Text(
                      getStatusLabel(status),
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : colorScheme.onSurface,
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
