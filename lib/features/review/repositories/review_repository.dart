import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:prm_project/core/constants/supabase_tables.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/review_display_item.dart';

part 'review_repository.g.dart';

class ReviewStats {
  const ReviewStats({
    required this.averageRating,
    required this.reviewCount,
  });

  final double averageRating;
  final int reviewCount;
}

@riverpod
ReviewRepository reviewRepository(ReviewRepositoryRef ref) =>
    ReviewRepository(Supabase.instance.client);

class ReviewRepository {
  const ReviewRepository(this._client);

  final SupabaseClient _client;

  Future<List<ReviewDisplayItem>> getLatestReviews({int limit = 10}) async {
    final reviewsResponse = await _client
        .from(SupabaseTables.reviews)
        .select('id, booking_id, customer_id, rating, comment, created_at')
        .order('created_at', ascending: false)
        .limit(limit);

    final reviewRows = (reviewsResponse as List)
        .map((item) => item as Map<String, dynamic>)
        .toList();

    return _buildReviewItems(reviewRows);
  }

  Future<List<ReviewDisplayItem>> getWorkerReviews(
    String workerId, {
    int limit = 10,
  }) async {
    final reviewsResponse = await _client
        .from(SupabaseTables.reviews)
        .select('id, booking_id, customer_id, rating, comment, created_at')
        .eq('worker_id', workerId)
        .order('created_at', ascending: false)
        .limit(limit);

    final reviewRows = (reviewsResponse as List)
        .map((item) => item as Map<String, dynamic>)
        .toList();

    return _buildReviewItems(reviewRows);
  }

  Future<List<ReviewDisplayItem>> getServiceReviews(
    String serviceId, {
    int limit = 10,
  }) async {
    final bookingIds = await _getBookingIdsForService(serviceId);
    if (bookingIds.isEmpty) return const [];

    final reviewsResponse = await _client
        .from(SupabaseTables.reviews)
        .select('id, booking_id, customer_id, rating, comment, created_at')
        .inFilter('booking_id', bookingIds)
        .order('created_at', ascending: false)
        .limit(limit);

    final reviewRows = (reviewsResponse as List)
        .map((item) => item as Map<String, dynamic>)
        .toList();

    return _buildReviewItems(reviewRows);
  }

  Future<ReviewStats> getServiceReviewStats(String serviceId) async {
    final bookingIds = await _getBookingIdsForService(serviceId);
    if (bookingIds.isEmpty) {
      return const ReviewStats(averageRating: 0, reviewCount: 0);
    }

    final reviewsResponse = await _client
        .from(SupabaseTables.reviews)
        .select('rating')
        .inFilter('booking_id', bookingIds);

    final ratings = (reviewsResponse as List)
        .map((item) => item as Map<String, dynamic>)
        .map((row) => (row['rating'] as num?)?.toDouble())
        .whereType<double>()
        .toList();

    if (ratings.isEmpty) {
      return const ReviewStats(averageRating: 0, reviewCount: 0);
    }

    final total = ratings.fold<double>(0, (sum, rating) => sum + rating);
    return ReviewStats(
      averageRating: total / ratings.length,
      reviewCount: ratings.length,
    );
  }

  Future<List<String>> _getBookingIdsForService(String serviceId) async {
    final bookingsResponse = await _client
        .from(SupabaseTables.bookings)
        .select('id')
        .eq('service_id', serviceId);

    return (bookingsResponse as List)
        .map((item) => (item as Map<String, dynamic>)['id'] as String?)
        .whereType<String>()
        .toSet()
        .toList();
  }

  Future<List<ReviewDisplayItem>> _buildReviewItems(
    List<Map<String, dynamic>> reviewRows,
  ) async {
    if (reviewRows.isEmpty) return const [];

    final customerIds = reviewRows
        .map((row) => row['customer_id'] as String?)
        .whereType<String>()
        .toSet()
        .toList();

    final bookingIds = reviewRows
        .map((row) => row['booking_id'] as String?)
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

    Map<String, String> serviceNameByBookingId = {};
    if (bookingIds.isNotEmpty) {
      final bookingsResponse = await _client
          .from(SupabaseTables.bookings)
          .select('id, service_id')
          .inFilter('id', bookingIds);

      final bookingRows = (bookingsResponse as List)
          .map((item) => item as Map<String, dynamic>)
          .toList();

      final serviceIds = bookingRows
          .map((row) => row['service_id'] as String?)
          .whereType<String>()
          .toSet()
          .toList();

      Map<String, String> serviceNameById = {};
      if (serviceIds.isNotEmpty) {
        final servicesResponse = await _client
            .from(SupabaseTables.services)
            .select('id, name')
            .inFilter('id', serviceIds);

        serviceNameById = {
          for (final service in servicesResponse as List)
            (service as Map<String, dynamic>)['id'] as String:
                (service)['name'] as String? ?? '',
        };
      }

      for (final booking in bookingRows) {
        final bookingId = booking['id'] as String?;
        final serviceId = booking['service_id'] as String?;
        if (bookingId == null || serviceId == null) continue;
        serviceNameByBookingId[bookingId] = serviceNameById[serviceId] ?? '';
      }
    }

    return reviewRows.map((row) {
      final customerId = row['customer_id'] as String?;
      final bookingId = row['booking_id'] as String?;
      final customerProfile =
          customerId != null ? profilesById[customerId] : null;
      return ReviewDisplayItem.fromMap(
        row,
        customerProfile: customerProfile,
        serviceName:
            bookingId != null ? serviceNameByBookingId[bookingId] ?? '' : '',
      );
    }).toList();
  }
}
