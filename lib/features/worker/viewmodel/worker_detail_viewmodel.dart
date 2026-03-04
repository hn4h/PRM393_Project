import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:prm_project/core/models/worker.dart';
import 'package:prm_project/features/worker/repository/worker_repository.dart';

part 'worker_detail_viewmodel.g.dart';

class WorkerDetailState {
  final bool isLoading;
  final Worker? worker;
  final String? error;

  WorkerDetailState({this.isLoading = false, this.worker, this.error});

  WorkerDetailState copyWith({bool? isLoading, Worker? worker, String? error}) {
    return WorkerDetailState(
      isLoading: isLoading ?? this.isLoading,
      worker: worker ?? this.worker,
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
      final w = await repo.getById(workerId);

      if (w == null) {
        state = WorkerDetailState(
          isLoading: false,
          worker: null,
          error: "Worker not found",
        );
        return;
      }

      state = WorkerDetailState(isLoading: false, worker: w, error: null);
    } catch (e) {
      state = WorkerDetailState(
        isLoading: false,
        worker: null,
        error: e.toString(),
      );
    }
  }
}
