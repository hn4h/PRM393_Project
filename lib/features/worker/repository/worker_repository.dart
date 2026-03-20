import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:prm_project/core/constants/supabase_tables.dart';
import 'package:prm_project/core/models/worker.dart';

import '../viewmodel/worker_review_item.dart';

part 'worker_repository.g.dart';

@riverpod
WorkerRepository workerRepository(WorkerRepositoryRef ref) =>
    WorkerRepository(Supabase.instance.client);

class WorkerRepository {
  const WorkerRepository(this._client);

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

  static const _reviewSelect = '''
    id,
    customer_id,
    rating,
    comment,
    created_at
  ''';

  Future<List<Worker>> getAll() async {
    final response = await _client
        .from(SupabaseTables.workers)
        .select(_workerSelect)
        .order('rating', ascending: false);

    return (response as List)
        .map((item) => _mapWorker(item as Map<String, dynamic>))
        .toList();
  }

  Future<Worker?> getById(String profileId) async {
    final response = await _client
        .from(SupabaseTables.workers)
        .select(_workerSelect)
        .eq('profile_id', profileId)
        .maybeSingle();

    if (response == null) return null;
    return _mapWorker(response);
  }

  Future<List<WorkerReviewItem>> getReviews(String workerId) async {
    final response = await _client
        .from(SupabaseTables.reviews)
        .select(_reviewSelect)
        .eq('worker_id', workerId)
        .order('created_at', ascending: false)
        .limit(3);

    final rows = (response as List)
        .map((item) => item as Map<String, dynamic>)
        .toList();

    final customerIds = rows
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

    return rows.map((row) {
      final customerId = row['customer_id'] as String?;
      final customerProfile =
          customerId != null ? profilesById[customerId] : null;
      return WorkerReviewItem.fromMap(row, customerProfile: customerProfile);
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
