import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:prm_project/core/constants/supabase_tables.dart';
import 'package:prm_project/features/notification/models/notification_model.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepository(Supabase.instance.client);
});

class NotificationRepository {
  final SupabaseClient _client;

  const NotificationRepository(this._client);

  // ─── Customer notifications ─────────────────────────────────────────

  /// Fetch all notifications for a customer, newest first.
  Future<List<NotificationModel>> getCustomerNotifications(
    String customerId,
  ) async {
    final response = await _client
        .from(SupabaseTables.customerNotifications)
        .select()
        .eq('customer_id', customerId)
        .order('created_at', ascending: false);

    return response
        .map((m) =>
            NotificationModel.fromMap(m, userIdColumn: 'customer_id'))
        .toList();
  }

  /// Count unread notifications for a customer.
  Future<int> getCustomerUnreadCount(String customerId) async {
    final response = await _client
        .from(SupabaseTables.customerNotifications)
        .select('id')
        .eq('customer_id', customerId)
        .eq('is_read', false);

    return (response as List).length;
  }

  /// Mark a single customer notification as read.
  Future<void> markCustomerNotificationRead(String notificationId) async {
    await _client
        .from(SupabaseTables.customerNotifications)
        .update({'is_read': true})
        .eq('id', notificationId);
  }

  /// Mark all customer notifications as read.
  Future<void> markAllCustomerNotificationsRead(String customerId) async {
    await _client
        .from(SupabaseTables.customerNotifications)
        .update({'is_read': true})
        .eq('customer_id', customerId)
        .eq('is_read', false);
  }

  // ─── Worker notifications ───────────────────────────────────────────

  /// Fetch all notifications for a worker, newest first.
  Future<List<NotificationModel>> getWorkerNotifications(
    String workerId,
  ) async {
    final response = await _client
        .from(SupabaseTables.workerNotifications)
        .select()
        .eq('worker_id', workerId)
        .order('created_at', ascending: false);

    return response
        .map(
            (m) => NotificationModel.fromMap(m, userIdColumn: 'worker_id'))
        .toList();
  }

  /// Count unread notifications for a worker.
  Future<int> getWorkerUnreadCount(String workerId) async {
    final response = await _client
        .from(SupabaseTables.workerNotifications)
        .select('id')
        .eq('worker_id', workerId)
        .eq('is_read', false);

    return (response as List).length;
  }

  /// Mark a single worker notification as read.
  Future<void> markWorkerNotificationRead(String notificationId) async {
    await _client
        .from(SupabaseTables.workerNotifications)
        .update({'is_read': true})
        .eq('id', notificationId);
  }

  /// Mark all worker notifications as read.
  Future<void> markAllWorkerNotificationsRead(String workerId) async {
    await _client
        .from(SupabaseTables.workerNotifications)
        .update({'is_read': true})
        .eq('worker_id', workerId)
        .eq('is_read', false);
  }

  // ─── Realtime: subscribe to new notifications ───────────────────────

  /// Subscribe to new customer notifications via Realtime.
  RealtimeChannel subscribeToCustomerNotifications(
    String customerId,
    void Function() onNewNotification,
  ) {
    return _client
        .channel('customer_notif:$customerId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: SupabaseTables.customerNotifications,
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'customer_id',
            value: customerId,
          ),
          callback: (_) => onNewNotification(),
        )
        .subscribe();
  }

  /// Subscribe to new worker notifications via Realtime.
  RealtimeChannel subscribeToWorkerNotifications(
    String workerId,
    void Function() onNewNotification,
  ) {
    return _client
        .channel('worker_notif:$workerId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: SupabaseTables.workerNotifications,
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'worker_id',
            value: workerId,
          ),
          callback: (_) => onNewNotification(),
        )
        .subscribe();
  }
}
