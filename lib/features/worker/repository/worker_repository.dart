import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:prm_project/core/models/worker.dart';

part 'worker_repository.g.dart';

@riverpod
WorkerRepository workerRepository(WorkerRepositoryRef ref) => WorkerRepository();

class WorkerRepository {
  final List<Worker> _workers = demoWorkers; // mock DB

  Future<List<Worker>> getAll() async {
    return _workers;
  }

  Future<Worker?> getById(String id) async {
    try {
      return _workers.firstWhere((w) => w.id == id);
    } catch (_) {
      return null;
    }
  }
}