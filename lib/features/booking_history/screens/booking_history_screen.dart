import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:prm_project/features/booking/viewmodel/booking_list_viewmodel.dart';
import '../widgets/booking_card.dart';
import '../widgets/booking_filter_bar.dart';

class BookingHistoryScreen extends ConsumerWidget {
  const BookingHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final asyncState = ref.watch(bookingListViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "My Booking",
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(
              Icons.calendar_month_outlined,
              color: colorScheme.onSurface,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          const BookingFilterBar(),
          Expanded(
            child: asyncState.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error: $err')),
              data: (state) {
                final bookings = state.bookings;
                if (bookings.isEmpty) {
                  return const Center(
                    child: Text(
                      'No bookings yet',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () => ref
                      .read(bookingListViewModelProvider.notifier)
                      .refresh(),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    itemCount: bookings.length,
                    itemBuilder: (context, index) {
                      return BookingCard(
                        booking: bookings[index],
                        onTap: () {
                          context.pushNamed(
                            'booking-history-detail',
                            extra: bookings[index],
                          );
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
