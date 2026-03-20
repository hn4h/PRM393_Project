import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:prm_project/core/models/worker.dart';

part 'worker_repository.g.dart';

@riverpod
WorkerRepository workerRepository(WorkerRepositoryRef ref) =>
    WorkerRepository(Supabase.instance.client);

class WorkerRepository {
  final SupabaseClient _client;

  const WorkerRepository(this._client);

  /// Fetch all workers with profile data
  Future<List<Worker>> getAll() async {
    // First get all available workers
    final workersResponse = await _client
        .from('workers')
        .select()
        .eq('is_available', true);

    final List<Worker> workers = [];
    for (final workerMap in workersResponse) {
      final profileId = workerMap['profile_id'] as String?;
      if (profileId == null) continue;

      // Fetch profile data separately
      final profileResponse = await _client
          .from('profiles')
          .select()
          .eq('id', profileId)
          .maybeSingle();

      workers.add(_mapWorker(workerMap, profileResponse));
    }
    return workers;
  }

  /// Fetch a single worker by profile_id
  Future<Worker?> getById(String id) async {
    final workerResponse = await _client
        .from('workers')
        .select()
        .eq('profile_id', id)
        .maybeSingle();

    if (workerResponse == null) return null;

    // Fetch profile data separately
    final profileResponse = await _client
        .from('profiles')
        .select()
        .eq('id', id)
        .maybeSingle();

    return _mapWorker(workerResponse, profileResponse);
  }

  /// Fetch workers who provide a specific service
  Future<List<Worker>> getWorkersByServiceId(String serviceId) async {
    // Get worker IDs from worker_services
    final wsResponse = await _client
        .from('worker_services')
        .select('worker_id')
        .eq('service_id', serviceId);

    final List<Worker> workers = [];
    for (final row in wsResponse) {
      final workerId = row['worker_id'] as String?;
      if (workerId == null) continue;

      final worker = await getById(workerId);
      if (worker != null) {
        workers.add(worker);
      }
    }
    return workers;
  }

  /// Fetch service IDs for a worker
  Future<List<String>> getWorkerServiceIds(String workerId) async {
    final response = await _client
        .from('worker_services')
        .select('service_id')
        .eq('worker_id', workerId);

    return response.map((row) => row['service_id'] as String).toList();
  }

  Worker _mapWorker(Map<String, dynamic> workerMap, Map<String, dynamic>? profile) {
    // Get worker name from profile
    String workerName = profile?['full_name'] as String? ?? 'Worker';

    // Get avatar URL from profile
    String avatarUrl = profile?['avatar_url'] as String? ?? '';

    // Get location from profile address or worker service_area
    String location = profile?['address'] as String? ?? 
                      workerMap['service_area'] as String? ?? '';

    return Worker(
      id: workerMap['profile_id'] as String? ?? '',
      name: workerName,
      jobTitle: workerMap['skills'] as String? ?? '',
      description: workerMap['bio'] as String? ?? '',
      rating: (workerMap['rating'] as num?)?.toDouble() ?? 0.0,
      image: avatarUrl,
      experienceYears: workerMap['years_experience'] as int? ?? 0,
      clients: 0,
      isVerified: true,
      galleryImages: const [],
      serviceIds: const [],
      workingDays: 'Mon - Fri',
      workingTime: '9:00 AM - 5:00 PM',
      location: location,
    );
  }
}
