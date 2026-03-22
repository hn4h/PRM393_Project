import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/supabase_tables.dart';
import '../models/wk_notification_models.dart';
import '../repository/wk_notification_repository.dart';

part 'wk_notifications_viewmodel.g.dart';

@riverpod
class WkNotificationsViewmodel extends _$WkNotificationsViewmodel {
  RealtimeChannel? _notificationChannel;
  Timer? _reloadDebounce;

  @override
  Future<WkNotificationsState> build() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId != null) {
      _subscribeRealtime(userId);
    }

    ref.onDispose(() async {
      _reloadDebounce?.cancel();
      if (_notificationChannel != null) {
        await Supabase.instance.client.removeChannel(_notificationChannel!);
      }
    });

    return _load();
  }

  void _subscribeRealtime(String userId) {
    _notificationChannel = Supabase.instance.client
        .channel('wk-notifications-$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: SupabaseTables.workerNotifications,
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'worker_id',
            value: userId,
          ),
          callback: (_) {
            _scheduleRefresh();
          },
        )
        .subscribe();
  }

  void _scheduleRefresh() {
    _reloadDebounce?.cancel();
    _reloadDebounce = Timer(const Duration(milliseconds: 300), () async {
      state = await AsyncValue.guard(_load);
    });
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }

  Future<void> markAllRead() async {
    final current = state.valueOrNull;
    if (current == null) return;

    await ref.read(wkNotificationRepositoryProvider).markAllAsRead();
    state = await AsyncValue.guard(_load);
  }

  Future<void> markRead(String notificationId) async {
    final current = state.valueOrNull;
    if (current == null) return;

    await ref.read(wkNotificationRepositoryProvider).markAsRead(notificationId);
    state = AsyncData(
      current.copyWith(
        notifications: current.notifications
            .map(
              (item) => item.id == notificationId
                  ? WkNotificationItem(
                      id: item.id,
                      type: item.type,
                      title: item.title,
                      body: item.body,
                      isRead: true,
                      createdAt: item.createdAt,
                      bookingId: item.bookingId,
                    )
                  : item,
            )
            .toList(growable: false),
      ),
    );
  }

  Future<WkNotificationsState> _load() async {
    final notifications = await ref
        .read(wkNotificationRepositoryProvider)
        .fetchNotifications();
    return WkNotificationsState(notifications: notifications);
  }
}
