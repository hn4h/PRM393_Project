import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:prm_project/core/models/worker.dart';
import 'package:prm_project/features/worker/repository/worker_repository.dart';

import 'worker_review_item.dart';

part 'worker_detail_viewmodel.g.dart';

class WorkerDetailState {
  final bool isLoading;
  final Worker? worker;
  final List<WorkerReviewItem> reviews;
  final String? error;

  WorkerDetailState({
    this.isLoading = false,
    this.worker,
    this.reviews = const [],
    this.error,
  });

  WorkerDetailState copyWith({
    bool? isLoading,
    Worker? worker,
    List<WorkerReviewItem>? reviews,
    String? error,
  }) {
    return WorkerDetailState(
      isLoading: isLoading ?? this.isLoading,
      worker: worker ?? this.worker,
      reviews: reviews ?? this.reviews,
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
          error: "Worker not found",
        );
        return;
      }

      final reviews = await repo.getReviews(workerId);

      state = WorkerDetailState(
        isLoading: false,
        worker: worker,
        reviews: reviews,
        error: null,
      );
    } catch (e) {
      state = WorkerDetailState(
        isLoading: false,
        worker: null,
        reviews: const [],
        error: e.toString(),
      );
    }
  }
}
