import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:prm_project/core/constants/supabase_tables.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:prm_project/core/models/review.dart';

part 'review_repository.g.dart';

@riverpod
ReviewRepository reviewRepository(ReviewRepositoryRef ref) =>
    ReviewRepository(Supabase.instance.client);

class ReviewRepository {
  final SupabaseClient _client;

  const ReviewRepository(this._client);

  /// Create a review for a completed booking.
  Future<Review> createReview({
    required String bookingId,
    required String workerId,
    required String customerId,
    required double rating,
    required String comment,
  }) async {
    final response = await _client
        .from(SupabaseTables.reviews)
        .insert({
          'booking_id': bookingId,
          'worker_id': workerId,
          'customer_id': customerId,
          'rating': rating,
          'comment': comment,
        })
        .select()
        .single();
    return _hydrateReview(response);
  }

  /// Get all reviews for a worker, newest first.
  Future<List<Review>> getWorkerReviews(String workerId) async {
    final response = await _client
        .from(SupabaseTables.reviews)
        .select()
        .eq('worker_id', workerId)
        .order('created_at', ascending: false);

    return _hydrateReviews(
      (response as List).map((item) => item as Map<String, dynamic>).toList(),
    );
  }

  /// Get all reviews for a service.
  Future<List<Review>> getServiceReviews(String serviceId) async {
    final bookingsResponse = await _client
        .from(SupabaseTables.bookings)
        .select('id')
        .eq('service_id', serviceId);

    final bookingIds = (bookingsResponse as List)
        .map((item) => (item as Map<String, dynamic>)['id'] as String?)
        .whereType<String>()
        .toList();

    if (bookingIds.isEmpty) return const [];

    final response = await _client
        .from(SupabaseTables.reviews)
        .select()
        .inFilter('booking_id', bookingIds)
        .order('created_at', ascending: false);

    return _hydrateReviews(
      (response as List).map((item) => item as Map<String, dynamic>).toList(),
    );
  }

  /// Check if a review exists for a booking.
  Future<bool> hasReview(String bookingId) async {
    final response = await _client
        .from(SupabaseTables.reviews)
        .select('id')
        .eq('booking_id', bookingId)
        .limit(1);
    return response.isNotEmpty;
  }

  /// Get the review for a specific booking.
  Future<Review?> getBookingReview(String bookingId) async {
    final response = await _client
        .from(SupabaseTables.reviews)
        .select()
        .eq('booking_id', bookingId)
        .limit(1);
    if (response.isEmpty) return null;
    return _hydrateReview(response.first as Map<String, dynamic>);
  }

  Future<List<Review>> _hydrateReviews(
    List<Map<String, dynamic>> reviewRows,
  ) async {
    if (reviewRows.isEmpty) return const [];

    final customerIds = reviewRows
        .map((row) => row['customer_id'] as String?)
        .whereType<String>()
        .toSet()
        .toList();

    Map<String, Map<String, dynamic>> profilesById = {};
    if (customerIds.isNotEmpty) {
      final profilesResponse = await _client
          .from(SupabaseTables.profiles)
          .select('id, full_name, avatar_url')
          .inFilter('id', customerIds);

      profilesById = {
        for (final profile in profilesResponse as List)
          (profile as Map<String, dynamic>)['id'] as String: profile,
      };
    }

    return reviewRows.map((row) {
      final customerId = row['customer_id'] as String?;
      return Review.fromMap({
        ...row,
        'profile': customerId != null ? profilesById[customerId] : null,
      });
    }).toList();
  }

  Future<Review> _hydrateReview(Map<String, dynamic> reviewRow) async {
    final reviews = await _hydrateReviews([reviewRow]);
    return reviews.first;
  }
}
