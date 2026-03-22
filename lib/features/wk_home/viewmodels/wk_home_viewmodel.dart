import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/wk_home_models.dart';
import '../repository/wk_home_repository.dart';

part 'wk_home_viewmodel.g.dart';

@riverpod
class WkHomeViewModel extends _$WkHomeViewModel {
  @override
  Future<WkHomeState> build() {
    return _load();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }

  Future<void> toggleAvailability(bool isOnline) async {
    final current = state.valueOrNull;
    if (current == null) return;

    state = AsyncData(
      current.copyWith(isOnline: isOnline, clearActionError: true),
    );

    try {
      await ref.read(wkHomeRepositoryProvider).setAvailability(isOnline);
    } catch (e) {
      state = AsyncData(
        current.copyWith(
          actionError: 'Unable to update your availability right now.',
        ),
      );
    }
  }

  Future<void> accept(String bookingId) async {
    await _runBookingAction(
      action: () => ref.read(wkHomeRepositoryProvider).acceptBooking(bookingId),
      errorText: 'Unable to accept this job right now.',
    );
  }

  Future<void> decline(String bookingId) async {
    await _runBookingAction(
      action: () =>
          ref.read(wkHomeRepositoryProvider).declineBooking(bookingId),
      errorText: 'Unable to decline this request right now.',
    );
  }

  Future<void> startJob(String bookingId) async {
    await _runBookingAction(
      action: () => ref.read(wkHomeRepositoryProvider).startBooking(bookingId),
      errorText: 'Unable to start this job.',
    );
  }

  Future<void> completeJob(String bookingId) async {
    await _runBookingAction(
      action: () =>
          ref.read(wkHomeRepositoryProvider).completeBooking(bookingId),
      errorText: 'Unable to complete this job.',
    );
  }

  Future<void> _runBookingAction({
    required Future<void> Function() action,
    required String errorText,
  }) async {
    final current = state.valueOrNull;
    if (current == null) return;

    state = AsyncData(current.copyWith(clearActionError: true));

    try {
      await action();
      state = await AsyncValue.guard(_load);
    } catch (e) {
      state = AsyncData(current.copyWith(actionError: errorText));
    }
  }

  Future<WkHomeState> _load() {
    return ref.read(wkHomeRepositoryProvider).fetchHomeState();
  }
}
