import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:prm_project/core/models/booking.dart';

part 'booking_repository.g.dart';

@riverpod
BookingRepository bookingRepository(BookingRepositoryRef ref) =>
    BookingRepository();

class BookingRepository {
  final List<Booking> _allBookings = [];

  Future<List<Booking>> getAll() async {
    return _allBookings;
  }

  Future<void> add(Booking booking) async {
    _allBookings.add(booking);
  }
}
