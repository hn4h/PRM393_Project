import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/supabase_tables.dart';

part 'worker_repository.g.dart';

@riverpod
WorkerRepository workerRepository(WorkerRepositoryRef ref) {
  return WorkerRepository(Supabase.instance.client);
}

class WorkerRepository {
  final SupabaseClient _client;

  const WorkerRepository(this._client);

  /// Lấy thông tin worker theo profile_id — có thể null nếu chưa tồn tại
  Future<Map<String, dynamic>?> getWorkerInfo(String profileId) async {
    return await _client
        .from(SupabaseTables.workers)
        .select('profile_id, bio, service_area, years_experience, skills')
        .eq('profile_id', profileId)
        .maybeSingle();
  }

  /// Tạo mới hoặc cập nhật worker record (upsert)
  Future<void> upsertWorkerInfo(String profileId, Map<String, dynamic> data) async {
    await _client.from(SupabaseTables.workers).upsert(
      {'profile_id': profileId, ...data},
      onConflict: 'profile_id',
    );
  }
}
