import 'package:prm_project/core/constants/supabase_tables.dart';
import 'package:prm_project/core/models/service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ServiceStatsMapper {
  const ServiceStatsMapper._();

  static Future<List<Service>> mapServicesWithStats(
    SupabaseClient client,
    List<Map<String, dynamic>> serviceRows,
  ) async {
    if (serviceRows.isEmpty) return const [];

    final services = serviceRows.map(Service.fromMap).toList();
    final serviceIds = services.map((service) => service.id).toList();

    final statsResponse = await client
        .from(SupabaseTables.serviceStatsView)
        .select('service_id, booking_count, review_count, average_rating')
        .inFilter('service_id', serviceIds);

    final statsByServiceId = {
      for (final row in statsResponse as List)
        (row as Map<String, dynamic>)['service_id'] as String: row,
    };

    return services.map((service) {
      final stats = statsByServiceId[service.id];

      return service.copyWith(
        rating: (stats?['average_rating'] as num?)?.toDouble() ?? 0,
        reviewCount: (stats?['review_count'] as num?)?.toInt() ?? 0,
        bookingCount: (stats?['booking_count'] as num?)?.toInt() ?? 0,
      );
    }).toList();
  }
}
