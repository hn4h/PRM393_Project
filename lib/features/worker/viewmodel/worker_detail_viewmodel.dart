import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:prm_project/core/models/service.dart';
import 'package:prm_project/core/models/worker.dart';
import 'package:prm_project/features/review/models/review_display_item.dart';
import 'package:prm_project/features/review/repositories/review_repository.dart';
import 'package:prm_project/features/worker/repository/worker_repository.dart';

part 'worker_detail_viewmodel.g.dart';

class WorkerDetailState {
  final bool isLoading;
  final Worker? worker;
  final List<ReviewDisplayItem> reviews;
  final List<Service> services;
  final String? error;

  WorkerDetailState({
    this.isLoading = false,
    this.worker,
    this.reviews = const [],
    this.services = const [],
    this.error,
  });

  WorkerDetailState copyWith({
    bool? isLoading,
    Worker? worker,
    List<ReviewDisplayItem>? reviews,
    List<Service>? services,
    String? error,
  }) {
    return WorkerDetailState(
      isLoading: isLoading ?? this.isLoading,
      worker: worker ?? this.worker,
      reviews: reviews ?? this.reviews,
      services: services ?? this.services,
      error: error,
    );
  }
}

@riverpod
class WorkerDetailViewModel extends _$WorkerDetailViewModel {
  @override
  WorkerDetailState build(String workerId) {
    // state initial
    state = WorkerDetailState(isLoading: true);

    // kick off async load
    _load(workerId);

    return state;
  }

  Future<void> _load(String workerId) async {
    try {
      final repo = ref.read(workerRepositoryProvider);
      final worker = await repo.getById(workerId);

      if (worker == null) {
        state = WorkerDetailState(
          isLoading: false,
          worker: null,
          reviews: const [],
          services: const [],
          error: "Worker not found",
        );
        return;
      }

      final reviews = await ref
          .read(reviewRepositoryProvider)
          .getWorkerReviews(workerId, limit: 10);
      final services = await repo.getServices(workerId);

      state = WorkerDetailState(
        isLoading: false,
        worker: worker,
        reviews: reviews,
        services: services,
        error: null,
      );
    } catch (e) {
      state = WorkerDetailState(
        isLoading: false,
        worker: null,
        reviews: const [],
        services: const [],
        error: e.toString(),
      );
    }
  }
}
