import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:prm_project/core/models/booking.dart';
import 'package:prm_project/core/enums/booking_status.dart';

part 'booking_history_repository.g.dart';

@riverpod
BookingHistoryRepository bookingHistoryRepository(
  BookingHistoryRepositoryRef ref,
) => BookingHistoryRepository(Supabase.instance.client);

class BookingHistoryRepository {
  final SupabaseClient _client;

  const BookingHistoryRepository(this._client);

  // ─── Select query with joined profile + service data ───
  static const _selectWithJoins = '''
    *,
    worker_profile:profiles!bookings_worker_id_fkey(full_name, avatar_url),
    service:services!bookings_service_id_fkey(name, image_url)
  ''';

  /// Get all bookings for a customer, newest first.
  Future<List<Booking>> getCustomerBookings(String customerId) async {
    final response = await _client
        .from('bookings')
        .select(_selectWithJoins)
        .eq('customer_id', customerId)
        .order('created_at', ascending: false);
    return response.map(Booking.fromMap).toList();
  }

  /// Get a single booking by ID.
  Future<Booking> getBookingById(String bookingId) async {
    final response = await _client
        .from('bookings')
        .select(_selectWithJoins)
        .eq('id', bookingId)
        .single();
    return Booking.fromMap(response);
  }

  /// Update booking status.
  Future<void> updateBookingStatus(
    String bookingId,
    BookingStatus newStatus,
  ) async {
    await _client
        .from('bookings')
        .update({
          'status': newStatus.toDbValue(),
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', bookingId);
  }

  /// Cancel a booking (customer-side, only when pending).
  Future<void> cancelBooking(String bookingId) async {
    await updateBookingStatus(bookingId, BookingStatus.cancelled);
  }

  /// Mark booking as completed (customer confirms service is done).
  Future<void> completeBooking(String bookingId) async {
    await updateBookingStatus(bookingId, BookingStatus.completed);
  }
}
