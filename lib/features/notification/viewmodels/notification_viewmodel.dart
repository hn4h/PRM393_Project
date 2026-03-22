import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:prm_project/core/providers/user_profile_provider.dart';
import 'package:prm_project/features/notification/models/notification_model.dart';
import 'package:prm_project/features/notification/repository/notification_repository.dart';

// ─── State class ────────────────────────────────────────────────────────────

class NotificationState {
  final List<NotificationModel> items;
  final bool isLoading;
  final String? error;
  final int unreadCount;

  const NotificationState({
    this.items = const [],
    this.isLoading = false,
    this.error,
    this.unreadCount = 0,
  });

  NotificationState copyWith({
    List<NotificationModel>? items,
    bool? isLoading,
    String? error,
    int? unreadCount,
  }) {
    return NotificationState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}

// ─── Notification ViewModel ─────────────────────────────────────────────────

class NotificationViewModel extends StateNotifier<NotificationState> {
  final NotificationRepository _repository;
  final String _userId;
  final String _role; // 'customer' or 'worker'
  RealtimeChannel? _realtimeChannel;

  NotificationViewModel({
    required NotificationRepository repository,
    required String userId,
    required String role,
  }) : _repository = repository,
       _userId = userId,
       _role = role,
       super(const NotificationState(isLoading: true)) {
    _init();
  }

  Future<void> _init() async {
    await refresh();
    _subscribeRealtime();
  }

  /// Re-fetch notifications from Supabase.
  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final List<NotificationModel> items;
      final int unread;

      if (_role == 'worker') {
        items = await _repository.getWorkerNotifications(_userId);
        unread = await _repository.getWorkerUnreadCount(_userId);
      } else {
        items = await _repository.getCustomerNotifications(_userId);
        unread = await _repository.getCustomerUnreadCount(_userId);
      }

      state = NotificationState(items: items, unreadCount: unread);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Mark a single notification as read (optimistic update).
  Future<void> markAsRead(String notificationId) async {
    // Optimistic update
    final updatedItems = state.items.map((n) {
      if (n.id == notificationId && !n.isRead) {
        return n.copyWith(isRead: true);
      }
      return n;
    }).toList();

    final newUnread = updatedItems.where((n) => !n.isRead).length;
    state = state.copyWith(items: updatedItems, unreadCount: newUnread);

    try {
      if (_role == 'worker') {
        await _repository.markWorkerNotificationRead(notificationId);
      } else {
        await _repository.markCustomerNotificationRead(notificationId);
      }
    } catch (_) {
      // Rollback on failure
      await refresh();
    }
  }

  /// Mark all notifications as read.
  Future<void> markAllAsRead() async {
    final updatedItems = state.items
        .map((n) => n.isRead ? n : n.copyWith(isRead: true))
        .toList();
    state = state.copyWith(items: updatedItems, unreadCount: 0);

    try {
      if (_role == 'worker') {
        await _repository.markAllWorkerNotificationsRead(_userId);
      } else {
        await _repository.markAllCustomerNotificationsRead(_userId);
      }
    } catch (_) {
      await refresh();
    }
  }

  /// Subscribe to Realtime inserts.
  void _subscribeRealtime() {
    if (_role == 'worker') {
      _realtimeChannel = _repository.subscribeToWorkerNotifications(
        _userId,
        () => refresh(),
      );
    } else {
      _realtimeChannel = _repository.subscribeToCustomerNotifications(
        _userId,
        () => refresh(),
      );
    }
  }

  @override
  void dispose() {
    _realtimeChannel?.unsubscribe();
    super.dispose();
  }
}

// ─── Providers ──────────────────────────────────────────────────────────────

final notificationViewModelProvider =
    StateNotifierProvider<NotificationViewModel, NotificationState>((ref) {
      final client = Supabase.instance.client;
      final user = client.auth.currentUser;

      if (user == null) {
        return NotificationViewModel(
          repository: NotificationRepository(client),
          userId: '',
          role: 'customer',
        );
      }

      // Attempt to get role from profile provider (sync access).
      final profileAsync = ref.watch(userProfileProvider);
      final role = profileAsync.valueOrNull?.role ?? 'customer';

      return NotificationViewModel(
        repository: NotificationRepository(client),
        userId: user.id,
        role: role,
      );
    });

/// Convenience provider: unread count for the notification badge.
final unreadNotificationCountProvider = Provider<int>((ref) {
  return ref.watch(notificationViewModelProvider).unreadCount;
});
