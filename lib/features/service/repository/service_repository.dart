import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:prm_project/core/models/service.dart';

part 'service_repository.g.dart';

@riverpod
ServiceRepository serviceRepository(ServiceRepositoryRef ref) =>
    ServiceRepository();

class ServiceRepository {
  final List<Service> _services = demoServices; // mock DB

  Future<List<Service>> getAll() async => _services;

  Future<Service?> getById(String id) async {
    try {
      return _services.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }
}