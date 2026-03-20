// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking_history_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$bookingHistoryViewModelHash() =>
    r'b8c9d0e1f2a3b4c5d6e7f8a9b0c1d2e3f4a5b6c7';

/// See also [BookingHistoryViewModel].
@ProviderFor(BookingHistoryViewModel)
final bookingHistoryViewModelProvider =
    AutoDisposeAsyncNotifierProvider<
      BookingHistoryViewModel,
      BookingHistoryState
    >.internal(
      BookingHistoryViewModel.new,
      name: r'bookingHistoryViewModelProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$bookingHistoryViewModelHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$BookingHistoryViewModel =
    AutoDisposeAsyncNotifier<BookingHistoryState>;

String _$filteredBookingsHash() => r'c9d0e1f2a3b4c5d6e7f8a9b0c1d2e3f4a5b6c7d8';

/// Filtered bookings (applies status filter and search)
///
/// Copied from [filteredBookings].
@ProviderFor(filteredBookings)
final filteredBookingsProvider = AutoDisposeProvider<List<Booking>>.internal(
  filteredBookings,
  name: r'filteredBookingsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$filteredBookingsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef FilteredBookingsRef = AutoDisposeProviderRef<List<Booking>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
