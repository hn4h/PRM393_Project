// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking_history_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$filteredBookingsHash() => r'2d0729bac6c7f0b95963720b8fb7ea1e0206c448';

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

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FilteredBookingsRef = AutoDisposeProviderRef<List<Booking>>;
String _$bookingHistoryViewModelHash() =>
    r'a203176490cde4dcbeea39a1764163c82d4787a7';

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
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
