import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/wk_notification_models.dart';
import '../repository/wk_notification_repository.dart';

part 'wk_notifications_viewmodel.g.dart';

@riverpod
class WkNotificationsViewmodel extends _$WkNotificationsViewmodel {
  @override
  Future<WkNotificationsState> build() async {
    return _load();
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
