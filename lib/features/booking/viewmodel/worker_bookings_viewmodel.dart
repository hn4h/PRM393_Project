import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:prm_project/core/models/booking.dart';
import 'package:prm_project/core/enums/booking_status.dart';
import '../repository/booking_repository.dart';

/// State for worker-side booking management.
class WorkerBookingsState {
  final List<Booking> pendingBookings;
  final List<Booking> activeBookings;
  final List<Booking> historyBookings;
  final bool isLoading;
  final String? error;

  const WorkerBookingsState({
    this.pendingBookings = const [],
    this.activeBookings = const [],
    this.historyBookings = const [],
    this.isLoading = false,
    this.error,
  });

  WorkerBookingsState copyWith({
    List<Booking>? pendingBookings,
    List<Booking>? activeBookings,
    List<Booking>? historyBookings,
    bool? isLoading,
    String? error,
  }) {
    return WorkerBookingsState(
      pendingBookings: pendingBookings ?? this.pendingBookings,
      activeBookings: activeBookings ?? this.activeBookings,
      historyBookings: historyBookings ?? this.historyBookings,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// ViewModel for worker booking management.
class WorkerBookingsViewModel extends AsyncNotifier<WorkerBookingsState> {
  @override
  Future<WorkerBookingsState> build() async {
    return _fetchAll();
  }

  Future<WorkerBookingsState> _fetchAll() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return const WorkerBookingsState();

    final repo = ref.read(bookingRepositoryProvider);

    final pending = await repo.getPendingBookings();
    final active = await repo.getWorkerAssignedBookings(user.id);
    final history = await repo.getWorkerHistoryBookings(user.id);

    return WorkerBookingsState(
      pendingBookings: pending,
      activeBookings: active,
      historyBookings: history,
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetchAll);
  }

  /// Accept a pending booking.
  Future<void> acceptBooking(String bookingId) async {
    final repo = ref.read(bookingRepositoryProvider);
    await repo.updateBookingStatus(bookingId, BookingStatus.accepted);
    await refresh();
  }

  /// Reject a pending booking.
  Future<void> rejectBooking(String bookingId) async {
    final repo = ref.read(bookingRepositoryProvider);
    await repo.updateBookingStatus(bookingId, BookingStatus.rejected);
    await refresh();
  }

  /// Start working on a booking (accepted → in_progress).
  Future<void> startBooking(String bookingId) async {
    final repo = ref.read(bookingRepositoryProvider);
    await repo.updateBookingStatus(bookingId, BookingStatus.inProgress);
    await refresh();
  }

  /// Complete a booking.
  Future<void> completeBooking(String bookingId) async {
    final repo = ref.read(bookingRepositoryProvider);
    await repo.updateBookingStatus(bookingId, BookingStatus.completed);
    await refresh();
  }
}

final workerBookingsViewModelProvider =
    AsyncNotifierProvider<WorkerBookingsViewModel, WorkerBookingsState>(() {
  return WorkerBookingsViewModel();
});
