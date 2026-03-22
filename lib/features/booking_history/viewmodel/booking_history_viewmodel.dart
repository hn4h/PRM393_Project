import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prm_project/core/models/booking.dart';
import 'package:prm_project/core/enums/booking_status.dart';
import '../repository/booking_history_repository.dart';

part 'booking_history_viewmodel.g.dart';

// ════════════════════════════════════════════════════════════════════════════
// FILTER PROVIDERS
// ════════════════════════════════════════════════════════════════════════════

/// Selected status filter (null = All)
final selectedStatusFilterProvider = StateProvider<BookingStatus?>(
  (ref) => null,
);

/// Search query
final searchQueryProvider = StateProvider<String>((ref) => '');

// ════════════════════════════════════════════════════════════════════════════
// STATE
// ════════════════════════════════════════════════════════════════════════════

class BookingHistoryState {
  final List<Booking> bookings;
  final bool isLoading;
  final String? error;

  const BookingHistoryState({
    this.bookings = const [],
    this.isLoading = false,
    this.error,
  });

  BookingHistoryState copyWith({
    List<Booking>? bookings,
    bool? isLoading,
    String? error,
  }) {
    return BookingHistoryState(
      bookings: bookings ?? this.bookings,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// VIEWMODEL
// ════════════════════════════════════════════════════════════════════════════

@riverpod
class BookingHistoryViewModel extends _$BookingHistoryViewModel {
  @override
  Future<BookingHistoryState> build() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      return const BookingHistoryState();
    }

    final repo = ref.read(bookingHistoryRepositoryProvider);
    final bookings = await repo.getCustomerBookings(user.id);
    return BookingHistoryState(bookings: bookings);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return const BookingHistoryState();
      final repo = ref.read(bookingHistoryRepositoryProvider);
      final bookings = await repo.getCustomerBookings(user.id);
      return BookingHistoryState(bookings: bookings);
    });
  }

  /// Cancel a booking (only when pending).
  Future<void> cancelBooking(String bookingId) async {
    final repo = ref.read(bookingHistoryRepositoryProvider);
    await repo.cancelBooking(bookingId);
    await refresh();
  }

  /// Complete a booking (only when in_progress).
  Future<void> completeBooking(String bookingId) async {
    final repo = ref.read(bookingHistoryRepositoryProvider);
    await repo.completeBooking(bookingId);
    await refresh();
  }
}

// ════════════════════════════════════════════════════════════════════════════
// FILTERED BOOKINGS PROVIDER
// ════════════════════════════════════════════════════════════════════════════

/// Filtered bookings (applies status filter and search)
@riverpod
List<Booking> filteredBookings(FilteredBookingsRef ref) {
  final asyncState = ref.watch(bookingHistoryViewModelProvider);
  final statusFilter = ref.watch(selectedStatusFilterProvider);
  final searchQuery = ref.watch(searchQueryProvider).toLowerCase();

  return asyncState.when(
    data: (state) {
      var bookings = state.bookings;

      // Apply status filter
      if (statusFilter != null) {
        bookings = bookings.where((b) => b.status == statusFilter).toList();
      }

      // Apply search filter
      if (searchQuery.isNotEmpty) {
        bookings = bookings.where((b) {
          final workerName = (b.workerName ?? '').toLowerCase();
          final serviceName = (b.serviceName ?? '').toLowerCase();
          final address = (b.address ?? '').toLowerCase();
          final contactName = (b.contactName ?? '').toLowerCase();
          return workerName.contains(searchQuery) ||
              serviceName.contains(searchQuery) ||
              address.contains(searchQuery) ||
              contactName.contains(searchQuery);
        }).toList();
      }

      return bookings;
    },
    loading: () => [],
    error: (_, __) => [],
  );
}
