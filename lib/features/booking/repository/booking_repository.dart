import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:prm_project/core/models/booking.dart';
import 'package:prm_project/core/enums/booking_status.dart';

part 'booking_repository.g.dart';

@riverpod
BookingRepository bookingRepository(BookingRepositoryRef ref) =>
    BookingRepository(Supabase.instance.client);

class BookingRepository {
  final SupabaseClient _client;

  const BookingRepository(this._client);

  // ─── Select query with joined profile + service data ───
  static const _selectWithJoins = '''
    *,
    worker_profile:profiles!bookings_worker_id_fkey(full_name, avatar_url),
    service:services!bookings_service_id_fkey(name, image_url)
  ''';

  /// Create a new booking (customer-side).
  Future<Booking> createBooking(Booking booking) async {
    final response = await _client
        .from('bookings')
        .insert(booking.toInsertMap())
        .select(_selectWithJoins)
        .single();
    return Booking.fromMap(response);
  }

  /// Get all bookings for a customer, newest first.
  Future<List<Booking>> getCustomerBookings(String customerId) async {
    final response = await _client
        .from('bookings')
        .select(_selectWithJoins)
        .eq('customer_id', customerId)
        .order('created_at', ascending: false);
    return response.map(Booking.fromMap).toList();
  }

  /// Get pending bookings for workers to accept/reject.
  Future<List<Booking>> getPendingBookings() async {
    final response = await _client
        .from('bookings')
        .select(_selectWithJoins)
        .eq('status', 'pending')
        .order('created_at', ascending: false);
    return response.map(Booking.fromMap).toList();
  }

  /// Get bookings assigned to a worker (accepted or in_progress).
  Future<List<Booking>> getWorkerAssignedBookings(String workerId) async {
    final response = await _client
        .from('bookings')
        .select(_selectWithJoins)
        .eq('worker_id', workerId)
        .inFilter('status', ['accepted', 'in_progress'])
        .order('scheduled_at', ascending: true);
    return response.map(Booking.fromMap).toList();
  }

  /// Get worker's booking history (completed/cancelled/rejected).
  Future<List<Booking>> getWorkerHistoryBookings(String workerId) async {
    final response = await _client
        .from('bookings')
        .select(_selectWithJoins)
        .eq('worker_id', workerId)
        .inFilter('status', ['completed', 'cancelled', 'rejected'])
        .order('updated_at', ascending: false);
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

  /// Update booking status (worker accept/reject, or complete).
  Future<void> updateBookingStatus(
      String bookingId, BookingStatus newStatus) async {
    await _client
        .from('bookings')
        .update({
          'status': newStatus.toDbValue(),
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', bookingId);
  }

  /// Cancel a booking (customer-side).
  Future<void> cancelBooking(String bookingId) async {
    await updateBookingStatus(bookingId, BookingStatus.cancelled);
  }

  /// Subscribe to Realtime changes on a specific booking.
  RealtimeChannel subscribeToBooking(
    String bookingId,
    void Function(Booking) onChange,
  ) {
    return _client
        .channel('booking:$bookingId')
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'bookings',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'id',
            value: bookingId,
          ),
          callback: (payload) {
            onChange(Booking.fromMap(payload.newRecord));
          },
        )
        .subscribe();
  }

  /// Subscribe to all pending bookings (for worker view).
  RealtimeChannel subscribeToPendingBookings(
    void Function() onNewBooking,
  ) {
    return _client
        .channel('pending_bookings')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'bookings',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'status',
            value: 'pending',
          ),
          callback: (_) => onNewBooking(),
        )
        .subscribe();
  }
}
