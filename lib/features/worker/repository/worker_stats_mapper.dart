import 'package:prm_project/core/constants/supabase_tables.dart';
import 'package:prm_project/core/models/worker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class WorkerStatsMapper {
  const WorkerStatsMapper._();

  static Future<List<Worker>> applyRatings(
    SupabaseClient client,
    List<Worker> workers,
  ) async {
    if (workers.isEmpty) return const [];

    final workerIds = workers
        .map((worker) => worker.id)
        .where((id) => id.trim().isNotEmpty)
        .toSet()
        .toList();

    if (workerIds.isEmpty) return workers;

    final reviewsResponse = await client
        .from(SupabaseTables.reviews)
        .select('worker_id, rating')
        .inFilter('worker_id', workerIds);

    final totalsByWorkerId = <String, double>{};
    final countsByWorkerId = <String, int>{};

    for (final item in reviewsResponse as List) {
      final row = item as Map<String, dynamic>;
      final workerId = row['worker_id'] as String?;
      final rating = (row['rating'] as num?)?.toDouble();

      if (workerId == null || rating == null) continue;

      totalsByWorkerId[workerId] = (totalsByWorkerId[workerId] ?? 0) + rating;
      countsByWorkerId[workerId] = (countsByWorkerId[workerId] ?? 0) + 1;
    }

    final mapped = workers.map((worker) {
      final count = countsByWorkerId[worker.id] ?? 0;
      if (count == 0) return worker;

      final average = (totalsByWorkerId[worker.id] ?? 0) / count;
      return Worker(
        id: worker.id,
        name: worker.name,
        jobTitle: worker.jobTitle,
        description: worker.description,
        rating: average,
        image: worker.image,
        experienceYears: worker.experienceYears,
        clients: worker.clients,
        isVerified: worker.isVerified,
        galleryImages: worker.galleryImages,
        serviceIds: worker.serviceIds,
        workingDays: worker.workingDays,
        workingTime: worker.workingTime,
        location: worker.location,
      );
    }).toList();

    mapped.sort((a, b) => b.rating.compareTo(a.rating));
    return mapped;
  }
}
