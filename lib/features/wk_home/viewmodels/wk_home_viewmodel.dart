import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/supabase_tables.dart';

import '../models/wk_home_models.dart';
import '../repository/wk_home_repository.dart';

part 'wk_home_viewmodel.g.dart';

@riverpod
class WkHomeViewModel extends _$WkHomeViewModel {
  RealtimeChannel? _bookingsChannel;
  Timer? _reloadDebounce;

  @override
  Future<WkHomeState> build() {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId != null) {
      _subscribeBookingChanges(userId);
    }

    ref.onDispose(() async {
      _reloadDebounce?.cancel();
      if (_bookingsChannel != null) {
        await Supabase.instance.client.removeChannel(_bookingsChannel!);
      }
    });

    return _load();
  }

  void _subscribeBookingChanges(String userId) {
    _bookingsChannel = Supabase.instance.client
        .channel('wk-home-bookings-$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: SupabaseTables.bookings,
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'worker_id',
            value: userId,
          ),
          callback: (_) => _scheduleInvalidate(),
        )
        .subscribe();
  }

  void _scheduleInvalidate() {
    _reloadDebounce?.cancel();
    _reloadDebounce = Timer(const Duration(milliseconds: 300), () {
      ref.invalidate(wkHomeViewModelProvider);
    });
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
      useExceptionMessage: true,
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
    bool useExceptionMessage = false,
  }) async {
    final current = state.valueOrNull;
    if (current == null) return;

    state = AsyncData(current.copyWith(clearActionError: true));

    try {
      await action();
      state = await AsyncValue.guard(_load);
    } catch (e) {
      final raw = e.toString();
      final friendly = raw.startsWith('Exception: ')
          ? raw.substring('Exception: '.length)
          : raw;
      state = AsyncData(current.copyWith(actionError: errorText));
      if (useExceptionMessage && friendly.trim().isNotEmpty) {
        state = AsyncData(current.copyWith(actionError: friendly.trim()));
      }
    }
  }

  Future<WkHomeState> _load() {
    return ref.read(wkHomeRepositoryProvider).fetchHomeState();
  }
}
