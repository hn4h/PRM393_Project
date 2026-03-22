import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:prm_project/core/models/service.dart';
import 'package:prm_project/core/models/worker.dart';
import 'package:prm_project/core/constants/supabase_tables.dart';
import 'package:prm_project/features/service/repository/service_stats_mapper.dart';
import 'package:prm_project/features/worker/repository/worker_stats_mapper.dart';

part 'home_repository.g.dart';

@riverpod
HomeRepository homeRepository(HomeRepositoryRef ref) =>
    HomeRepository(Supabase.instance.client);

class HomeRepository {
  final SupabaseClient _client;
  const HomeRepository(this._client);
  static const _workerServicesTable = 'worker_services';

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
    return ServiceStatsMapper.mapServicesWithStats(
      _client,
      (response as List).map((item) => item as Map<String, dynamic>).toList(),
    );
  }

  /// Fetch services filtered by category.
  Future<List<Service>> getServicesByCategory(String category) async {
    final response = await _client
        .from(SupabaseTables.services)
        .select()
        .eq('is_active', true)
        .eq('category', category)
        .order('created_at', ascending: false);
    return ServiceStatsMapper.mapServicesWithStats(
      _client,
      (response as List).map((item) => item as Map<String, dynamic>).toList(),
    );
  }

  Future<List<Worker>> getTopWorkers() async {
    final response = await _client
        .from(SupabaseTables.workers)
        .select(_workerSelect)
        .order('rating', ascending: false);

    return _buildWorkersFromRows(
      (response as List).map((item) => item as Map<String, dynamic>).toList(),
    );
  }

  Future<List<Worker>> getWorkersPage({
    int limit = 10,
    int offset = 0,
  }) async {
    final response = await _client
        .from(SupabaseTables.workers)
        .select(_workerSelect)
        .order('rating', ascending: false)
        .range(offset, offset + limit - 1);

    return _buildWorkersFromRows(
      (response as List).map((item) => item as Map<String, dynamic>).toList(),
    );
  }

  Future<List<Worker>> _buildWorkersFromRows(
    List<Map<String, dynamic>> workerRows,
  ) async {
    if (workerRows.isEmpty) return const [];

    final workerIds = workerRows
        .map((row) => row['profile_id'] as String?)
        .whereType<String>()
        .toSet()
        .toList();

    final serviceNamesByWorkerId = await _getServiceNamesByWorkerId(workerIds);

    final workers = workerRows
        .map((item) => _mapWorker(
              item,
              serviceNames: serviceNamesByWorkerId[
                      item['profile_id'] as String? ?? ''] ??
                  const [],
            ))
        .toList();

    return WorkerStatsMapper.applyRatings(_client, workers);
  }

  Future<Map<String, List<String>>> _getServiceNamesByWorkerId(
    List<String> workerIds,
  ) async {
    if (workerIds.isEmpty) return const {};

    final workerServicesResponse = await _client
        .from(_workerServicesTable)
        .select('worker_id, service_id')
        .inFilter('worker_id', workerIds);

    final workerServiceRows = (workerServicesResponse as List)
        .map((item) => item as Map<String, dynamic>)
        .toList();

    final serviceIds = workerServiceRows
        .map((row) => row['service_id'] as String?)
        .whereType<String>()
        .toSet()
        .toList();

    if (serviceIds.isEmpty) return const {};

    final servicesResponse = await _client
        .from(SupabaseTables.services)
        .select('id, name')
        .inFilter('id', serviceIds)
        .eq('is_active', true);

    final serviceNameById = {
      for (final service in servicesResponse as List)
        (service as Map<String, dynamic>)['id'] as String:
            (service)['name'] as String? ?? '',
    };

    final result = <String, List<String>>{};
    for (final row in workerServiceRows) {
      final workerId = row['worker_id'] as String?;
      final serviceId = row['service_id'] as String?;
      final serviceName = serviceId != null ? serviceNameById[serviceId] : null;

      if (workerId == null || serviceName == null || serviceName.trim().isEmpty) {
        continue;
      }

      result.putIfAbsent(workerId, () => []);
      if (!result[workerId]!.contains(serviceName)) {
        result[workerId]!.add(serviceName);
      }
    }

    return result;
  }

  Worker _mapWorker(
    Map<String, dynamic> map, {
    List<String> serviceNames = const [],
  }) {
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
      'service_ids': serviceNames,
      'profile': profile,
    });
  }
}
