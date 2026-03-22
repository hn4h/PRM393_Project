import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/supabase_tables.dart';

import '../models/wk_schedule_models.dart';
import '../repository/wk_schedule_repository.dart';

part 'wk_schedule_viewmodel.g.dart';

@riverpod
class WkScheduleViewModel extends _$WkScheduleViewModel {
  static const Duration _utcPlus7 = Duration(hours: 7);
  RealtimeChannel? _bookingsChannel;
  Timer? _reloadDebounce;

  @override
  Future<WkScheduleState> build() async {
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

    return _loadInitial();
  }

  void _subscribeBookingChanges(String userId) {
    _bookingsChannel = Supabase.instance.client
        .channel('wk-schedule-bookings-$userId')
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
      ref.invalidate(wkScheduleViewModelProvider);
    });
  }

  Future<void> refresh() async {
    final current = state.valueOrNull;
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final bookings = await ref
          .read(wkScheduleRepositoryProvider)
          .fetchWorkerBookings();
      if (current == null) return _createInitialState(bookings);
      return current.copyWith(bookings: bookings);
    });
  }

  Future<void> acceptBooking(String bookingId) async {
    await _updateBookingStatus(bookingId: bookingId, status: 'accepted');
  }

  Future<void> rejectBooking(String bookingId) async {
    await _updateBookingStatus(bookingId: bookingId, status: 'rejected');
  }

  Future<void> startBooking(String bookingId) async {
    await _updateBookingStatus(bookingId: bookingId, status: 'in_progress');
  }

  void selectDate(DateTime dateUtc7) {
    final current = state.valueOrNull;
    if (current == null) return;

    state = AsyncData(
      current.copyWith(
        selectedDateUtc7: DateTime(dateUtc7.year, dateUtc7.month, dateUtc7.day),
        focusedMonthUtc7: DateTime(dateUtc7.year, dateUtc7.month, 1),
      ),
    );
  }

  void previousMonth() {
    final current = state.valueOrNull;
    if (current == null) return;

    final prev = DateTime(
      current.focusedMonthUtc7.year,
      current.focusedMonthUtc7.month - 1,
      1,
    );
    final selected = _keepSelectedInMonth(current.selectedDateUtc7, prev);

    state = AsyncData(
      current.copyWith(focusedMonthUtc7: prev, selectedDateUtc7: selected),
    );
  }

  void nextMonth() {
    final current = state.valueOrNull;
    if (current == null) return;

    final next = DateTime(
      current.focusedMonthUtc7.year,
      current.focusedMonthUtc7.month + 1,
      1,
    );
    final selected = _keepSelectedInMonth(current.selectedDateUtc7, next);

    state = AsyncData(
      current.copyWith(focusedMonthUtc7: next, selectedDateUtc7: selected),
    );
  }

  void setFilter(WkBookingsFilter filter) {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(current.copyWith(activeFilter: filter));
  }

  DateTime _keepSelectedInMonth(DateTime selected, DateTime targetMonth) {
    final maxDays = DateTime(targetMonth.year, targetMonth.month + 1, 0).day;
    final day = selected.day > maxDays ? maxDays : selected.day;
    return DateTime(targetMonth.year, targetMonth.month, day);
  }

  Future<WkScheduleState> _loadInitial() async {
    final bookings = await ref
        .read(wkScheduleRepositoryProvider)
        .fetchWorkerBookings();
    return _createInitialState(bookings);
  }

  WkScheduleState _createInitialState(List<WkScheduleBooking> bookings) {
    final nowUtc7 = DateTime.now().toUtc().add(_utcPlus7);
    final today = DateTime(nowUtc7.year, nowUtc7.month, nowUtc7.day);

    return WkScheduleState(
      focusedMonthUtc7: DateTime(today.year, today.month, 1),
      selectedDateUtc7: today,
      activeFilter: WkBookingsFilter.all,
      bookings: bookings,
    );
  }

  Future<void> _updateBookingStatus({
    required String bookingId,
    required String status,
  }) async {
    final current = state.valueOrNull;
    if (current == null) return;

    await ref
        .read(wkScheduleRepositoryProvider)
        .updateBookingStatus(bookingId: bookingId, status: status);

    final latest = await ref
        .read(wkScheduleRepositoryProvider)
        .fetchWorkerBookings();
    state = AsyncData(current.copyWith(bookings: latest));
  }
}
