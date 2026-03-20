import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:prm_project/core/models/booking.dart';
import 'package:prm_project/core/enums/booking_status.dart';
import '../repository/booking_repository.dart';

/// State for the booking list (customer booking history).
class BookingListState {
  final List<Booking> bookings;
  final bool isLoading;
  final String? error;

  const BookingListState({
    this.bookings = const [],
    this.isLoading = false,
    this.error,
  });

  BookingListState copyWith({
    List<Booking>? bookings,
    bool? isLoading,
    String? error,
  }) {
    return BookingListState(
      bookings: bookings ?? this.bookings,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  /// Filter bookings by status.
  List<Booking> filterByStatus(BookingStatus? status) {
    if (status == null) return bookings;
    return bookings.where((b) => b.status == status).toList();
  }

  /// Get active bookings (pending, accepted, in-progress).
  List<Booking> get activeBookings => bookings
      .where((b) =>
          b.status == BookingStatus.pending ||
          b.status == BookingStatus.accepted ||
          b.status == BookingStatus.inProgress)
      .toList();

  /// Get past bookings (completed, cancelled, rejected).
  List<Booking> get pastBookings => bookings
      .where((b) =>
          b.status == BookingStatus.completed ||
          b.status == BookingStatus.cancelled ||
          b.status == BookingStatus.rejected)
      .toList();
}

/// ViewModel for customer booking list / history.
class BookingListViewModel extends AsyncNotifier<BookingListState> {
  @override
  Future<BookingListState> build() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      return const BookingListState();
    }

    final repo = ref.read(bookingRepositoryProvider);
    final bookings = await repo.getCustomerBookings(user.id);
    return BookingListState(bookings: bookings);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return const BookingListState();
      final repo = ref.read(bookingRepositoryProvider);
      final bookings = await repo.getCustomerBookings(user.id);
      return BookingListState(bookings: bookings);
    });
  }

  /// Cancel a booking and refresh the list.
  Future<void> cancelBooking(String bookingId) async {
    final repo = ref.read(bookingRepositoryProvider);
    await repo.cancelBooking(bookingId);
    await refresh();
  }
}

final bookingListViewModelProvider =
    AsyncNotifierProvider<BookingListViewModel, BookingListState>(() {
  return BookingListViewModel();
});
