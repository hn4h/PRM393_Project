import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:prm_project/core/constants/supabase_tables.dart';
import 'package:prm_project/core/models/service.dart';
import 'package:prm_project/core/models/worker.dart';

import '../viewmodel/service_review_item.dart';

part 'service_repository.g.dart';

@riverpod
ServiceRepository serviceRepository(ServiceRepositoryRef ref) =>
    ServiceRepository(Supabase.instance.client);

class ServiceRepository {
  const ServiceRepository(this._client);

  final SupabaseClient _client;

  static const _workerSelect = '''
    profile_id,
    bio,
    service_area,
    years_experience,
    skills,
    is_available,
    rating,
    created_at,
    updated_at,
    profile:profiles!workers_profile_id_fkey(
      id,
      full_name,
      avatar_url,
      address
    )
  ''';

  Future<List<Service>> getAll() async {
    final response = await _client
        .from(SupabaseTables.services)
        .select()
        .eq('is_active', true)
        .order('created_at', ascending: false);

    return (response as List)
        .map((item) => Service.fromMap(item as Map<String, dynamic>))
        .toList();
  }

  Future<Service?> getById(String id) async {
    final response = await _client
        .from(SupabaseTables.services)
        .select()
        .eq('id', id)
        .maybeSingle();

    if (response == null) return null;
    return Service.fromMap(response);
  }

  Future<List<Worker>> getWorkersForService(String serviceId) async {
    final bookingsResponse = await _client
        .from(SupabaseTables.bookings)
        .select('worker_id')
        .eq('service_id', serviceId)
        .not('worker_id', 'is', null);

    final workerIds = (bookingsResponse as List)
        .map((item) => (item as Map<String, dynamic>)['worker_id'] as String?)
        .whereType<String>()
        .toSet()
        .toList();

    if (workerIds.isEmpty) return const [];

    final response = await _client
        .from(SupabaseTables.workers)
        .select(_workerSelect)
        .inFilter('profile_id', workerIds)
        .order('rating', ascending: false);

    return (response as List)
        .map((item) => _mapWorker(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<ServiceReviewItem>> getReviewsForService(String serviceId) async {
    final bookingsResponse = await _client
        .from(SupabaseTables.bookings)
        .select('id')
        .eq('service_id', serviceId);

    final bookingIds = (bookingsResponse as List)
        .map((item) => (item as Map<String, dynamic>)['id'] as String?)
        .whereType<String>()
        .toSet()
        .toList();

    if (bookingIds.isEmpty) return const [];

    final reviewsResponse = await _client
        .from(SupabaseTables.reviews)
        .select('id, customer_id, rating, comment, created_at')
        .inFilter('booking_id', bookingIds)
        .order('created_at', ascending: false)
        .limit(5);

    final reviewRows = (reviewsResponse as List)
        .map((item) => item as Map<String, dynamic>)
        .toList();

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
      final customerProfile =
          customerId != null ? profilesById[customerId] : null;
      return ServiceReviewItem.fromMap(row, customerProfile: customerProfile);
    }).toList();
  }

  Worker _mapWorker(Map<String, dynamic> map) {
    final profile = map['profile'] as Map<String, dynamic>? ?? const {};

    return Worker.fromMap({
      'id': map['profile_id'],
      'bio': map['bio'],
      'specialization': map['service_area'],
      'rating': map['rating'],
      'experience_years': map['years_experience'],
      'total_clients': 0,
      'is_verified': true,
      'working_days': map['service_area'] ?? '',
      'working_time': map['skills'] ?? '',
      'gallery_images': const <String>[],
      'service_ids': const <String>[],
      'profile': profile,
    });
  }
}
