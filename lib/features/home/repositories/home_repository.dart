import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:prm_project/core/models/service.dart';

class HomeRepository {
  final SupabaseClient _client;
  const HomeRepository(this._client);

  /// Fetch all active services from Supabase.
  Future<List<Service>> getActiveServices() async {
    final response = await _client
        .from('services')
        .select()
        .eq('is_active', true)
        .order('created_at', ascending: false);
    return (response as List).map((e) => Service.fromMap(e)).toList();
  }

  /// Fetch services filtered by category.
  Future<List<Service>> getServicesByCategory(String category) async {
    final response = await _client
        .from('services')
        .select()
        .eq('is_active', true)
        .eq('category', category)
        .order('created_at', ascending: false);
    return (response as List).map((e) => Service.fromMap(e)).toList();
  }
}
