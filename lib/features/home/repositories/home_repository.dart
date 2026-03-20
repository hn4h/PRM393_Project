import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:prm_project/core/models/service.dart';
import 'package:prm_project/core/models/worker.dart';
import 'package:prm_project/core/constants/supabase_tables.dart';

class HomeRepository {
  final SupabaseClient _client;
  const HomeRepository(this._client);

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

  /// Fetch all active services from Supabase.
  Future<List<Service>> getActiveServices() async {
    final response = await _client
        .from(SupabaseTables.services)
        .select()
        .eq('is_active', true)
        .order('created_at', ascending: false);
    return (response as List).map((e) => Service.fromMap(e)).toList();
  }

  /// Fetch services filtered by category.
  Future<List<Service>> getServicesByCategory(String category) async {
    final response = await _client
        .from(SupabaseTables.services)
        .select()
        .eq('is_active', true)
        .eq('category', category)
        .order('created_at', ascending: false);
    return (response as List).map((e) => Service.fromMap(e)).toList();
  }

  Future<List<Worker>> getTopWorkers() async {
    final response = await _client
        .from(SupabaseTables.workers)
        .select(_workerSelect)
        .order('rating', ascending: false);

    return (response as List)
        .map((item) => _mapWorker(item as Map<String, dynamic>))
        .toList();
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
