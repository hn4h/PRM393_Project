import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:prm_project/core/models/service.dart';
import 'package:prm_project/features/home/repositories/home_repository.dart';

// ─── Provider for HomeRepository ─────────────────────────────────────────────
final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  return HomeRepository(Supabase.instance.client);
});

// ─── All active services (for home screen) ───────────────────────────────────
final activeServicesProvider = FutureProvider<List<Service>>((ref) async {
  final repo = ref.watch(homeRepositoryProvider);
  return repo.getActiveServices();
});

// ─── Selected category filter on home screen ─────────────────────────────────
final selectedCategoryProvider = StateProvider<String>((ref) => 'All');

// ─── Filtered services (based on selected category) ──────────────────────────
final filteredServicesProvider = FutureProvider<List<Service>>((ref) async {
  final category = ref.watch(selectedCategoryProvider);
  final repo = ref.watch(homeRepositoryProvider);
  if (category == 'All') {
    return repo.getActiveServices();
  }
  return repo.getServicesByCategory(category);
});
