import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/supabase_tables.dart';
import '../models/cs_chat_models.dart';

final csChatRepositoryProvider = Provider<CsChatRepository>(
  (ref) => CsChatRepository(Supabase.instance.client),
);

class CsChatRepository {
  static const Duration _utcPlus7 = Duration(hours: 7);
  final SupabaseClient _client;

  const CsChatRepository(this._client);

  // ── Inbox ──────────────────────────────────────────────────────────────

  Future<List<CsChatConversationItem>> fetchInbox({String query = ''}) async {
    final customerId = _client.auth.currentUser?.id;
    if (customerId == null) throw Exception('You are not signed in.');

    final rows = await _client
        .from(SupabaseTables.chatConversations)
        .select(
          'id, booking_id, last_message_text, last_message_type, last_message_at, '
          'worker:profiles!chat_conversations_worker_id_fkey(id, full_name, avatar_url), '
          'booking:bookings!chat_conversations_booking_id_fkey(id, scheduled_at, status, service:services(name))',
        )
        .eq('customer_id', customerId)
        .order('last_message_at', ascending: false);

    final lowered = query.trim().toLowerCase();

    final mapped = rows
        .map((raw) {
          final worker = raw['worker'] as Map<String, dynamic>?;
          final booking = raw['booking'] as Map<String, dynamic>?;
          final service = booking?['service'] as Map<String, dynamic>?;

          final workerName =
              (worker?['full_name'] as String?)?.trim().isNotEmpty == true
              ? worker!['full_name'] as String
              : 'Worker';

          final lastType = (raw['last_message_type'] as String?) ?? 'text';
          final lastText = (raw['last_message_text'] as String?)?.trim() ?? '';
          final preview = lastType == 'image'
              ? '[Image]'
              : (lastType == 'system'
                    ? lastText
                    : (lastText.isEmpty ? 'No message yet' : lastText));

          final scheduledAt =
              DateTime.tryParse(
                booking?['scheduled_at']?.toString() ?? '',
              )?.toUtc().add(_utcPlus7) ??
              DateTime.now().toUtc().add(_utcPlus7);

          final serviceName = (service?['name'] as String?) ?? 'Service';
          final tagDate =
              '${scheduledAt.day.toString().padLeft(2, '0')}/${scheduledAt.month.toString().padLeft(2, '0')}';

          return CsChatConversationItem(
            conversationId: raw['id'] as String,
            bookingId:
                (raw['booking_id'] as String?) ??
                (booking?['id'] as String? ?? ''),
            workerName: workerName,
            workerAvatarUrl: worker?['avatar_url'] as String?,
            serviceTag: '$serviceName - $tagDate',
            lastMessagePreview: preview,
            lastMessageAtUtc7:
                DateTime.tryParse(
                  raw['last_message_at']?.toString() ?? '',
                )?.toUtc().add(_utcPlus7) ??
                scheduledAt,
            unreadCount: 0,
          );
        })
        .where((item) {
          if (lowered.isEmpty) return true;
          return item.workerName.toLowerCase().contains(lowered);
        })
        .toList(growable: false);

    if (mapped.isEmpty) return const [];

    // ── Unread count (messages from worker that customer hasn't read) ────
    final ids = mapped.map((e) => e.conversationId).toList(growable: false);
    final unreadRows = await _client
        .from(SupabaseTables.chatMessages)
        .select('conversation_id')
        .inFilter('conversation_id', ids)
        .neq('sender_role', 'customer')
        .eq('read_by_customer', false);

    final unreadMap = <String, int>{};
    for (final row in unreadRows) {
      final cid = row['conversation_id'] as String?;
      if (cid == null) continue;
      unreadMap[cid] = (unreadMap[cid] ?? 0) + 1;
    }

    return mapped
        .map(
          (item) => CsChatConversationItem(
            conversationId: item.conversationId,
            bookingId: item.bookingId,
            workerName: item.workerName,
            workerAvatarUrl: item.workerAvatarUrl,
            serviceTag: item.serviceTag,
            lastMessagePreview: item.lastMessagePreview,
            lastMessageAtUtc7: item.lastMessageAtUtc7,
            unreadCount: unreadMap[item.conversationId] ?? 0,
          ),
        )
        .toList(growable: false);
  }

  // ── Total unread (for badge) ───────────────────────────────────────────

  Future<int> totalUnreadCount() async {
    final customerId = _client.auth.currentUser?.id;
    if (customerId == null) return 0;

    final convRows = await _client
        .from(SupabaseTables.chatConversations)
        .select('id')
        .eq('customer_id', customerId);

    final convIds =
        convRows
            .map((r) => r['id'] as String?)
            .whereType<String>()
            .toList(growable: false);
    if (convIds.isEmpty) return 0;

    final unread = await _client
        .from(SupabaseTables.chatMessages)
        .select('id')
        .inFilter('conversation_id', convIds)
        .neq('sender_role', 'customer')
        .eq('read_by_customer', false);

    return unread.length;
  }

  // ── Booking context ────────────────────────────────────────────────────

  Future<CsChatBookingContext> fetchBookingContextByConversation(
    String conversationId,
  ) async {
    final customerId = _client.auth.currentUser?.id;
    if (customerId == null) throw Exception('You are not signed in.');

    final raw = await _client
        .from(SupabaseTables.chatConversations)
        .select(
          'worker:profiles!chat_conversations_worker_id_fkey(id, full_name), '
          'booking:bookings!chat_conversations_booking_id_fkey(id, status, scheduled_at, address, service:services(name))',
        )
        .eq('id', conversationId)
        .eq('customer_id', customerId)
        .maybeSingle();

    final booking = raw?['booking'] as Map<String, dynamic>?;
    final worker = raw?['worker'] as Map<String, dynamic>?;
    if (booking == null) throw Exception('Booking context not found.');

    final service = booking['service'] as Map<String, dynamic>?;
    final scheduledAt =
        DateTime.tryParse(
          booking['scheduled_at']?.toString() ?? '',
        )?.toUtc().add(_utcPlus7) ??
        DateTime.now().toUtc().add(_utcPlus7);

    return CsChatBookingContext(
      bookingId: booking['id'] as String,
      serviceName: (service?['name'] as String?) ?? 'Service',
      workerName:
          (worker?['full_name'] as String?)?.trim().isNotEmpty == true
          ? worker!['full_name'] as String
          : 'Worker',
      address: (booking['address'] as String?)?.trim() ?? 'No address provided',
      scheduledAtUtc7: scheduledAt,
      status: (booking['status'] as String?) ?? 'unknown',
    );
  }

  // ── Get conversation id by booking ─────────────────────────────────────

  Future<String?> getConversationIdForBooking(String bookingId) async {
    final row = await _client
        .from(SupabaseTables.chatConversations)
        .select('id')
        .eq('booking_id', bookingId)
        .maybeSingle();
    return row?['id'] as String?;
  }

  // ── Messages ───────────────────────────────────────────────────────────

  Future<List<CsChatMessage>> fetchMessages(String conversationId) async {
    final customerId = _client.auth.currentUser?.id;
    if (customerId == null) throw Exception('You are not signed in.');

    final rows = await _client
        .from(SupabaseTables.chatMessages)
        .select(
          'id, conversation_id, sender_id, sender_role, message_type, text, image_url, created_at',
        )
        .eq('conversation_id', conversationId)
        .order('created_at', ascending: true);

    return rows
        .map((raw) {
          final created =
              DateTime.tryParse(raw['created_at']?.toString() ?? '')?.toUtc() ??
              DateTime.now().toUtc();
          return CsChatMessage(
            id: raw['id'] as String,
            conversationId: raw['conversation_id'] as String,
            senderId: (raw['sender_id'] as String?) ?? '',
            senderRole: (raw['sender_role'] as String?) ?? 'worker',
            type: csChatMessageTypeFromDb(raw['message_type'] as String?),
            text: (raw['text'] as String?) ?? '',
            imageUrl: raw['image_url'] as String?,
            createdAtUtc7: created.add(_utcPlus7),
          );
        })
        .toList(growable: false);
  }

  // ── Mark read ──────────────────────────────────────────────────────────

  Future<void> markConversationReadByCustomer(String conversationId) async {
    await _client
        .from(SupabaseTables.chatMessages)
        .update({'read_by_customer': true})
        .eq('conversation_id', conversationId)
        .neq('sender_role', 'customer')
        .eq('read_by_customer', false);
  }

  // ── Send text ──────────────────────────────────────────────────────────

  Future<void> sendTextMessage({
    required String conversationId,
    required String bookingId,
    required String text,
  }) async {
    final customerId = _client.auth.currentUser?.id;
    if (customerId == null) throw Exception('You are not signed in.');

    await _client.from(SupabaseTables.chatMessages).insert({
      'conversation_id': conversationId,
      'booking_id': bookingId,
      'sender_id': customerId,
      'sender_role': 'customer',
      'message_type': 'text',
      'text': text.trim(),
      'created_at': DateTime.now().toUtc().toIso8601String(),
      'read_by_worker': false,
      'read_by_customer': true,
    });

    await _touchConversation(
      conversationId: conversationId,
      type: 'text',
      preview: text.trim(),
    );
  }

  // ── Send image ─────────────────────────────────────────────────────────

  Future<void> sendImageMessage({
    required String conversationId,
    required String bookingId,
    required Uint8List bytes,
    required String extension,
  }) async {
    final customerId = _client.auth.currentUser?.id;
    if (customerId == null) throw Exception('You are not signed in.');

    final filePath =
        'customer/$customerId/$conversationId/${DateTime.now().millisecondsSinceEpoch}.$extension';

    await _client.storage
        .from(SupabaseBuckets.chatImages)
        .uploadBinary(
          filePath,
          bytes,
          fileOptions: const FileOptions(upsert: false),
        );

    final publicUrl = _client.storage
        .from(SupabaseBuckets.chatImages)
        .getPublicUrl(filePath);

    await _client.from(SupabaseTables.chatMessages).insert({
      'conversation_id': conversationId,
      'booking_id': bookingId,
      'sender_id': customerId,
      'sender_role': 'customer',
      'message_type': 'image',
      'text': '',
      'image_url': publicUrl,
      'created_at': DateTime.now().toUtc().toIso8601String(),
      'read_by_worker': false,
      'read_by_customer': true,
    });

    await _touchConversation(
      conversationId: conversationId,
      type: 'image',
      preview: '[Image]',
    );
  }

  // ── Private helpers ────────────────────────────────────────────────────

  Future<void> _touchConversation({
    required String conversationId,
    required String type,
    required String preview,
  }) async {
    await _client
        .from(SupabaseTables.chatConversations)
        .update({
          'last_message_type': type,
          'last_message_text': preview,
          'last_message_at': DateTime.now().toUtc().toIso8601String(),
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('id', conversationId);
  }
}
