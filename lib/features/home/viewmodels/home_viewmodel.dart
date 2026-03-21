import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:prm_project/core/models/service.dart';
import 'package:prm_project/core/models/worker.dart';
import 'package:prm_project/features/home/repositories/home_repository.dart';

part 'home_viewmodel.g.dart';

@riverpod
Future<List<Service>> activeServices(ActiveServicesRef ref) async {
  final repo = ref.watch(homeRepositoryProvider);
  return repo.getActiveServices();
}

@riverpod
Future<List<Worker>> topWorkers(TopWorkersRef ref) async {
  final repo = ref.watch(homeRepositoryProvider);
  return repo.getTopWorkers();
}

@riverpod
class HomeSearchQuery extends _$HomeSearchQuery {
  @override
  String build() => '';

  void setQuery(String value) {
    state = value;
  }
}

@riverpod
Future<List<Service>> searchedServices(SearchedServicesRef ref) async {
  final query = ref.watch(homeSearchQueryProvider).trim().toLowerCase();
  final services = await ref.watch(activeServicesProvider.future);

  if (query.isEmpty) return services;

  return services.where((service) {
    return service.name.toLowerCase().contains(query);
  }).toList();
}

@riverpod
Future<List<Worker>> searchedWorkers(SearchedWorkersRef ref) async {
  final query = ref.watch(homeSearchQueryProvider).trim().toLowerCase();
  final workers = await ref.watch(topWorkersProvider.future);

  if (query.isEmpty) return workers;

  return workers.where((worker) {
    return worker.name.toLowerCase().contains(query);
  }).toList();
}
