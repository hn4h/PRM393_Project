import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:prm_project/core/models/review.dart';

part 'review_repository.g.dart';

@riverpod
ReviewRepository reviewRepository(ReviewRepositoryRef ref) =>
    ReviewRepository(Supabase.instance.client);

class ReviewRepository {
  final SupabaseClient _client;

  const ReviewRepository(this._client);

  static const _selectWithProfile = '''
    *,
    profile:profiles!reviews_user_id_fkey(full_name, avatar_url)
  ''';

  /// Create a review for a completed booking.
  Future<Review> createReview({
    required String bookingId,
    required String serviceId,
    required String workerId,
    required String userId,
    required double rating,
    required String comment,
  }) async {
    final response = await _client
        .from('reviews')
        .insert({
          'booking_id': bookingId,
          'service_id': serviceId,
          'worker_id': workerId,
          'user_id': userId,
          'rating': rating,
          'comment': comment,
        })
        .select(_selectWithProfile)
        .single();
    return Review.fromMap(response);
  }

  /// Get all reviews for a worker, newest first.
  Future<List<Review>> getWorkerReviews(String workerId) async {
    final response = await _client
        .from('reviews')
        .select(_selectWithProfile)
        .eq('worker_id', workerId)
        .order('created_at', ascending: false);
    return response.map(Review.fromMap).toList();
  }

  /// Get all reviews for a service.
  Future<List<Review>> getServiceReviews(String serviceId) async {
    final response = await _client
        .from('reviews')
        .select(_selectWithProfile)
        .eq('service_id', serviceId)
        .order('created_at', ascending: false);
    return response.map(Review.fromMap).toList();
  }

  /// Check if a review exists for a booking.
  Future<bool> hasReview(String bookingId) async {
    final response = await _client
        .from('reviews')
        .select('id')
        .eq('booking_id', bookingId)
        .limit(1);
    return response.isNotEmpty;
  }

  /// Get the review for a specific booking.
  Future<Review?> getBookingReview(String bookingId) async {
    final response = await _client
        .from('reviews')
        .select(_selectWithProfile)
        .eq('booking_id', bookingId)
        .limit(1);
    if (response.isEmpty) return null;
    return Review.fromMap(response.first);
  }
}
