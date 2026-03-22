import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:prm_project/core/models/booking.dart';
import 'package:prm_project/core/enums/booking_status.dart';
import '../../booking_history/repository/booking_history_repository.dart';

part 'upcoming_services_viewmodel.g.dart';

class UpcomingServicesState {
  final List<Booking> bookings;
  final bool isLoading;
  final String? error;

  const UpcomingServicesState({
    this.bookings = const [],
    this.isLoading = false,
    this.error,
  });

  UpcomingServicesState copyWith({
    List<Booking>? bookings,
    bool? isLoading,
    String? error,
  }) {
    return UpcomingServicesState(
      bookings: bookings ?? this.bookings,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

@riverpod
class UpcomingServicesViewModel extends _$UpcomingServicesViewModel {
  @override
  Future<UpcomingServicesState> build() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      return const UpcomingServicesState();
    }

    final repo = ref.read(bookingHistoryRepositoryProvider);
    final allBookings = await repo.getCustomerBookings(user.id);

    // Filter accepted and in_progress bookings, sorted by scheduled date
    final upcomingBookings =
        allBookings
            .where(
              (b) =>
                  b.status == BookingStatus.accepted ||
                  b.status == BookingStatus.inProgress,
            )
            .toList()
          ..sort((a, b) {
            final aDate = a.scheduledAt ?? DateTime.now();
            final bDate = b.scheduledAt ?? DateTime.now();
            return aDate.compareTo(bDate);
          });

    return UpcomingServicesState(bookings: upcomingBookings);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return const UpcomingServicesState();
      final repo = ref.read(bookingHistoryRepositoryProvider);
      final allBookings = await repo.getCustomerBookings(user.id);

      final upcomingBookings =
          allBookings
              .where(
                (b) =>
                    b.status == BookingStatus.accepted ||
                    b.status == BookingStatus.inProgress,
              )
              .toList()
            ..sort((a, b) {
              final aDate = a.scheduledAt ?? DateTime.now();
              final bDate = b.scheduledAt ?? DateTime.now();
              return aDate.compareTo(bDate);
            });

      return UpcomingServicesState(bookings: upcomingBookings);
    });
  }
}
