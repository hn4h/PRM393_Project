import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/supabase_tables.dart';
import '../models/wk_notification_models.dart';

part 'wk_notification_repository.g.dart';

@riverpod
WkNotificationRepository wkNotificationRepository(
  WkNotificationRepositoryRef ref,
) {
  return WkNotificationRepository(Supabase.instance.client);
}

class WkNotificationRepository {
  static const Duration _utcPlus7 = Duration(hours: 7);

  final SupabaseClient _client;

  const WkNotificationRepository(this._client);

  Future<List<WkNotificationItem>> fetchNotifications() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('You are not signed in.');
    }

    final rows = await _client
        .from(SupabaseTables.workerNotifications)
        .select('id, type, title, body, is_read, created_at, booking_id')
        .eq('worker_id', userId)
        .order('created_at', ascending: false);

    return rows.map((raw) => _toItem(raw)).toList(growable: false);
  }

  Future<void> markAllAsRead() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('You are not signed in.');
    }

    await _client
        .from(SupabaseTables.workerNotifications)
        .update({'is_read': true})
        .eq('worker_id', userId)
        .eq('is_read', false);
  }

  Future<void> markAsRead(String notificationId) async {
    await _client
        .from(SupabaseTables.workerNotifications)
        .update({'is_read': true})
        .eq('id', notificationId);
  }

  WkNotificationItem _toItem(Map<String, dynamic> raw) {
    final createdUtc =
        DateTime.tryParse(raw['created_at']?.toString() ?? '')?.toUtc() ??
        DateTime.now().toUtc();

    return WkNotificationItem(
      id: raw['id'] as String,
      type: wkNotificationTypeFromDb(raw['type'] as String?),
      title: (raw['title'] as String?) ?? 'Notification',
      body: (raw['body'] as String?) ?? '',
      isRead: raw['is_read'] as bool? ?? false,
      createdAt: createdUtc.add(_utcPlus7),
      bookingId: raw['booking_id'] as String?,
    );
  }
}
