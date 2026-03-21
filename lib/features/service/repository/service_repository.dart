import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:prm_project/core/constants/supabase_tables.dart';
import 'package:prm_project/core/models/service.dart';
import 'package:prm_project/core/models/worker.dart';

import 'service_stats_mapper.dart';

part 'service_repository.g.dart';

@riverpod
ServiceRepository serviceRepository(ServiceRepositoryRef ref) =>
    ServiceRepository(Supabase.instance.client);

class ServiceRepository {
  const ServiceRepository(this._client);

  final SupabaseClient _client;
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

  Future<List<Service>> getAll() async {
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

  Future<Service?> getById(String id) async {
    final response = await _client
        .from(SupabaseTables.services)
        .select()
        .eq('id', id)
        .maybeSingle();

    if (response == null) return null;
    final services = await ServiceStatsMapper.mapServicesWithStats(_client, [
      response,
    ]);
    return services.first;
  }

  Future<List<Worker>> getWorkersForService(String serviceId) async {
    final workerServicesResponse = await _client
        .from(_workerServicesTable)
        .select('worker_id')
        .eq('service_id', serviceId)
        .not('worker_id', 'is', null);

    final workerIds = (workerServicesResponse as List)
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

  Future<List<Service>> getServicesByWorkerId(String workerId) async {
    final workerServicesResponse = await _client
        .from(_workerServicesTable)
        .select('service_id')
        .eq('worker_id', workerId);

    final serviceIds = (workerServicesResponse as List)
        .map((item) => (item as Map<String, dynamic>)['service_id'] as String?)
        .whereType<String>()
        .toSet()
        .toList();

    if (serviceIds.isEmpty) return const [];

    final servicesResponse = await _client
        .from(SupabaseTables.services)
        .select()
        .inFilter('id', serviceIds)
        .eq('is_active', true)
        .order('name', ascending: true);

    final services = await ServiceStatsMapper.mapServicesWithStats(
      _client,
      (servicesResponse as List)
          .map((item) => item as Map<String, dynamic>)
          .toList(),
    );

    return services.where((service) => service.name.trim().isNotEmpty).toList();
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
