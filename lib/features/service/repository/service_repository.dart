import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:prm_project/core/models/service.dart';

part 'service_repository.g.dart';

@riverpod
ServiceRepository serviceRepository(ServiceRepositoryRef ref) =>
    ServiceRepository(Supabase.instance.client);

class ServiceRepository {
  final SupabaseClient _client;

  const ServiceRepository(this._client);

  /// Fetch all active services
  Future<List<Service>> getAll() async {
    final response = await _client
        .from('services')
        .select()
        .eq('is_active', true)
        .order('name');

    return response.map((map) => Service.fromMap(map)).toList();
  }

  /// Fetch a single service by ID
  Future<Service?> getById(String id) async {
    final response = await _client
        .from('services')
        .select()
        .eq('id', id)
        .maybeSingle();

    if (response == null) return null;
    return Service.fromMap(response);
  }

  /// Fetch services offered by a specific worker
  Future<List<Service>> getServicesByWorkerId(String workerId) async {
    final response = await _client
        .from('worker_services')
        .select('''
          services!worker_services_service_id_fkey(
            id,
            name,
            description,
            price,
            image_url,
            category,
            is_active,
            duration_minutes
          )
        ''')
        .eq('worker_id', workerId);

    return response
        .map((row) => row['services'] as Map<String, dynamic>)
        .where((s) => s['is_active'] == true)
        .map((map) => Service.fromMap(map))
        .toList();
  }
}
