import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/supabase_tables.dart';

/// Listens to realtime notifications for current worker and displays local push.
class WkPushNotificationService {
  WkPushNotificationService._();

  static final WkPushNotificationService instance =
      WkPushNotificationService._();

  final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();

  RealtimeChannel? _channel;
  bool _initialized = false;

  Future<void> start() async {
    if (kIsWeb) return;

    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    if (!_initialized) {
      await _initializeLocalNotifications();
      _initialized = true;
    }

    await stop();

    _channel = Supabase.instance.client
        .channel('worker-notifications-$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: SupabaseTables.workerNotifications,
          callback: (payload) async {
            final record = payload.newRecord;
            if (record['worker_id'] != userId) return;

            final title = (record['title'] as String?) ?? 'New notification';
            final body = (record['body'] as String?) ?? '';

            await _showLocalPush(
              id:
                  (record['id']?.toString().hashCode ??
                  DateTime.now().millisecondsSinceEpoch),
              title: title,
              body: body,
            );
          },
        )
        .subscribe();
  }

  Future<void> stop() async {
    if (_channel != null) {
      await Supabase.instance.client.removeChannel(_channel!);
      _channel = null;
    }
  }

  Future<void> _initializeLocalNotifications() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwin = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _local.initialize(
      const InitializationSettings(
        android: android,
        iOS: darwin,
        macOS: darwin,
      ),
    );
  }

  Future<void> _showLocalPush({
    required int id,
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'worker_notifications_channel',
      'Worker Notifications',
      channelDescription: 'Realtime notifications for worker events',
      importance: Importance.max,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    await _local.show(
      id,
      title,
      body,
      const NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
        macOS: iosDetails,
      ),
    );
  }
}
