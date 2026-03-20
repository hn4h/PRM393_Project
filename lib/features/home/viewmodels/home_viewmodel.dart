import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:prm_project/core/models/service.dart';
import 'package:prm_project/core/models/worker.dart';
import 'package:prm_project/features/home/repositories/home_repository.dart';

final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  return HomeRepository(Supabase.instance.client);
});

final activeServicesProvider = FutureProvider<List<Service>>((ref) async {
  final repo = ref.watch(homeRepositoryProvider);
  return repo.getActiveServices();
});

final topWorkersProvider = FutureProvider<List<Worker>>((ref) async {
  final repo = ref.watch(homeRepositoryProvider);
  return repo.getTopWorkers();
});

final searchQueryProvider = StateProvider<String>((ref) => '');

final searchedServicesProvider = FutureProvider<List<Service>>((ref) async {
  final query = ref.watch(searchQueryProvider).trim().toLowerCase();
  final services = await ref.watch(activeServicesProvider.future);

  if (query.isEmpty) return services;

  return services.where((service) {
    return service.name.toLowerCase().contains(query) ||
        service.description.toLowerCase().contains(query) ||
        service.categoryId.toLowerCase().contains(query);
  }).toList();
});

final searchedWorkersProvider = FutureProvider<List<Worker>>((ref) async {
  final query = ref.watch(searchQueryProvider).trim().toLowerCase();
  final workers = await ref.watch(topWorkersProvider.future);

  if (query.isEmpty) return workers;

  return workers.where((worker) {
    return worker.name.toLowerCase().contains(query) ||
        worker.description.toLowerCase().contains(query) ||
        worker.jobTitle.toLowerCase().contains(query) ||
        worker.location.toLowerCase().contains(query);
  }).toList();
});
