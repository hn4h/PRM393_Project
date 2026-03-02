import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:prm_project/core/models/booking.dart';
import 'package:prm_project/core/models/worker.dart';
import 'package:prm_project/core/models/service.dart';
import '../widgets/booking_card.dart';
import '../widgets/booking_filter_bar.dart';

class BookingHistoryScreen extends StatelessWidget {
  const BookingHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Booking> mockBookings = [
      Booking(
        id: "1",
        worker: demoWorkers[0],
        services: [demoServices[0]],
        status: BookingStatus.inProgress,
        scheduledAt: DateTime.now(),
        duration: "2 Hours",
        totalPrice: 145.50,
      ),
      Booking(
        id: "2",
        worker: demoWorkers[1],
        services: [demoServices[1]],
        status: BookingStatus.upcoming,
        scheduledAt: DateTime.now().add(const Duration(days: 1)),
        duration: "1 Hour",
        totalPrice: 60.00,
      ),
      Booking(
        id: "3",
        worker: demoWorkers[0],
        services: [demoServices[0]],
        status: BookingStatus.completed,
        scheduledAt: DateTime.now().subtract(const Duration(days: 2)),
        duration: "3 Hours",
        totalPrice: 200.00,
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "My Booking",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.calendar_month_outlined,
              color: Colors.black,
            ),
            onPressed: () {
              // logic loc theo ngay (code sau)
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const BookingFilterBar(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: mockBookings.length,
              itemBuilder: (context, index) {
                return BookingCard(
                  booking: mockBookings[index],
                  onTap: () {
                    context.pushNamed(
                      'booking-history-detail',
                      extra: mockBookings[index],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
