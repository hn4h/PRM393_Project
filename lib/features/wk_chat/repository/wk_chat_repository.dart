import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/supabase_tables.dart';
import '../models/wk_chat_models.dart';

final wkChatRepositoryProvider = Provider<WkChatRepository>(
  (ref) => WkChatRepository(Supabase.instance.client),
);

class WkChatRepository {
  static const Duration _utcPlus7 = Duration(hours: 7);
  final SupabaseClient _client;

  const WkChatRepository(this._client);

  Future<List<WkChatConversationItem>> fetchInbox({String query = ''}) async {
    final workerId = _client.auth.currentUser?.id;
    if (workerId == null) {
      throw Exception('You are not signed in.');
    }

    await _cleanupExpiredMessages(workerId);

    final rows = await _client
        .from(SupabaseTables.chatConversations)
        .select(
          'id, booking_id, last_message_text, last_message_type, last_message_at, '
          'customer:profiles!chat_conversations_customer_id_fkey(id, full_name, avatar_url), '
          'booking:bookings!chat_conversations_booking_id_fkey(id, scheduled_at, status, contact_name, service:services(name))',
        )
        .eq('worker_id', workerId)
        .order('last_message_at', ascending: false);

    final lowered = query.trim().toLowerCase();

    final mapped = rows
        .map((raw) {
          final customer = raw['customer'] as Map<String, dynamic>?;
          final booking = raw['booking'] as Map<String, dynamic>?;
          final service = booking?['service'] as Map<String, dynamic>?;

          final customerName =
              (customer?['full_name'] as String?)?.trim().isNotEmpty == true
              ? (customer!['full_name'] as String)
              : ((booking?['contact_name'] as String?)?.trim().isNotEmpty ==
                        true
                    ? booking!['contact_name'] as String
                    : 'Customer');

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

          return WkChatConversationItem(
            conversationId: raw['id'] as String,
            bookingId:
                (raw['booking_id'] as String?) ??
                (booking?['id'] as String? ?? ''),
            customerName: customerName,
            customerAvatarUrl: customer?['avatar_url'] as String?,
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
          return item.customerName.toLowerCase().contains(lowered);
        })
        .toList(growable: false);

    if (mapped.isEmpty) return const [];

    final ids = mapped.map((e) => e.conversationId).toList(growable: false);
    final unreadRows = await _client
        .from(SupabaseTables.chatMessages)
        .select('conversation_id')
        .inFilter('conversation_id', ids)
        .eq('sender_role', 'customer')
        .eq('read_by_worker', false)
        .gte(
          'created_at',
          DateTime.now()
              .toUtc()
              .subtract(const Duration(days: 7))
              .toIso8601String(),
        );

    final unreadMap = <String, int>{};
    for (final row in unreadRows) {
      final cid = row['conversation_id'] as String?;
      if (cid == null) continue;
      unreadMap[cid] = (unreadMap[cid] ?? 0) + 1;
    }

    return mapped
        .map(
          (item) => WkChatConversationItem(
            conversationId: item.conversationId,
            bookingId: item.bookingId,
            customerName: item.customerName,
            customerAvatarUrl: item.customerAvatarUrl,
            serviceTag: item.serviceTag,
            lastMessagePreview: item.lastMessagePreview,
            lastMessageAtUtc7: item.lastMessageAtUtc7,
            unreadCount: unreadMap[item.conversationId] ?? 0,
          ),
        )
        .toList(growable: false);
  }

  Future<WkChatBookingContext> fetchBookingContextByConversation(
    String conversationId,
  ) async {
    final workerId = _client.auth.currentUser?.id;
    if (workerId == null) {
      throw Exception('You are not signed in.');
    }

    final raw = await _client
        .from(SupabaseTables.chatConversations)
        .select(
          'booking:bookings!chat_conversations_booking_id_fkey(id, status, scheduled_at, address, contact_name, service:services(name))',
        )
        .eq('id', conversationId)
        .eq('worker_id', workerId)
        .maybeSingle();

    final booking = raw?['booking'] as Map<String, dynamic>?;
    if (booking == null) {
      throw Exception('Booking context not found.');
    }

    final service = booking['service'] as Map<String, dynamic>?;
    final scheduledAt =
        DateTime.tryParse(
          booking['scheduled_at']?.toString() ?? '',
        )?.toUtc().add(_utcPlus7) ??
        DateTime.now().toUtc().add(_utcPlus7);

    return WkChatBookingContext(
      bookingId: booking['id'] as String,
      serviceName: (service?['name'] as String?) ?? 'Service',
      customerName:
          (booking['contact_name'] as String?)?.trim().isNotEmpty == true
          ? booking['contact_name'] as String
          : 'Customer',
      address: (booking['address'] as String?)?.trim() ?? 'No address provided',
      scheduledAtUtc7: scheduledAt,
      status: (booking['status'] as String?) ?? 'unknown',
    );
  }

  Future<String> getOrCreateConversationForBooking(String bookingId) async {
    final workerId = _client.auth.currentUser?.id;
    if (workerId == null) {
      throw Exception('You are not signed in.');
    }

    final booking = await _client
        .from(SupabaseTables.bookings)
        .select('id, worker_id, customer_id, status')
        .eq('id', bookingId)
        .eq('worker_id', workerId)
        .maybeSingle();

    if (booking == null) {
      throw Exception('Booking not found.');
    }

    final status = (booking['status'] as String?) ?? 'unknown';
    if (status == 'pending') {
      throw Exception('Chat opens after you accept the booking.');
    }

    final existing = await _client
        .from(SupabaseTables.chatConversations)
        .select('id')
        .eq('booking_id', bookingId)
        .maybeSingle();

    if (existing != null) return existing['id'] as String;

    if (status != 'accepted' && status != 'in_progress') {
      throw Exception('Conversation is not available for this booking.');
    }

    final inserted = await _client
        .from(SupabaseTables.chatConversations)
        .insert({
          'booking_id': bookingId,
          'worker_id': workerId,
          'customer_id': booking['customer_id'] as String,
          'last_message_type': 'system',
          'last_message_text': 'Conversation started',
          'last_message_at': DateTime.now().toUtc().toIso8601String(),
          'created_at': DateTime.now().toUtc().toIso8601String(),
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        })
        .select('id')
        .single();

    final conversationId = inserted['id'] as String;

    await _insertSystemMessage(
      conversationId: conversationId,
      bookingId: bookingId,
      text: 'Conversation started',
    );

    return conversationId;
  }

  Future<List<WkChatMessage>> fetchMessages(String conversationId) async {
    final workerId = _client.auth.currentUser?.id;
    if (workerId == null) {
      throw Exception('You are not signed in.');
    }

    await _cleanupExpiredMessages(workerId);

    final rows = await _client
        .from(SupabaseTables.chatMessages)
        .select(
          'id, conversation_id, sender_id, sender_role, message_type, text, image_url, created_at',
        )
        .eq('conversation_id', conversationId)
        .gte(
          'created_at',
          DateTime.now()
              .toUtc()
              .subtract(const Duration(days: 7))
              .toIso8601String(),
        )
        .order('created_at', ascending: true);

    return rows
        .map((raw) {
          final created =
              DateTime.tryParse(raw['created_at']?.toString() ?? '')?.toUtc() ??
              DateTime.now().toUtc();
          return WkChatMessage(
            id: raw['id'] as String,
            conversationId: raw['conversation_id'] as String,
            senderId: (raw['sender_id'] as String?) ?? '',
            senderRole: (raw['sender_role'] as String?) ?? 'customer',
            type: wkChatMessageTypeFromDb(raw['message_type'] as String?),
            text: (raw['text'] as String?) ?? '',
            imageUrl: raw['image_url'] as String?,
            createdAtUtc7: created.add(_utcPlus7),
          );
        })
        .toList(growable: false);
  }

  Future<void> markConversationReadByWorker(String conversationId) async {
    await _client
        .from(SupabaseTables.chatMessages)
        .update({'read_by_worker': true})
        .eq('conversation_id', conversationId)
        .eq('sender_role', 'customer')
        .eq('read_by_worker', false);
  }

  Future<void> sendTextMessage({
    required String conversationId,
    required String bookingId,
    required String text,
  }) async {
    final workerId = _client.auth.currentUser?.id;
    if (workerId == null) {
      throw Exception('You are not signed in.');
    }

    await _client.from(SupabaseTables.chatMessages).insert({
      'conversation_id': conversationId,
      'booking_id': bookingId,
      'sender_id': workerId,
      'sender_role': 'worker',
      'message_type': 'text',
      'text': text.trim(),
      'created_at': DateTime.now().toUtc().toIso8601String(),
      'read_by_worker': true,
      'read_by_customer': false,
    });

    await _touchConversation(
      conversationId: conversationId,
      type: 'text',
      preview: text.trim(),
    );
  }

  Future<void> sendImageMessage({
    required String conversationId,
    required String bookingId,
    required Uint8List bytes,
    required String extension,
  }) async {
    final workerId = _client.auth.currentUser?.id;
    if (workerId == null) {
      throw Exception('You are not signed in.');
    }

    final filePath =
        'worker/$workerId/$conversationId/${DateTime.now().millisecondsSinceEpoch}.$extension';

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
      'sender_id': workerId,
      'sender_role': 'worker',
      'message_type': 'image',
      'text': '',
      'image_url': publicUrl,
      'created_at': DateTime.now().toUtc().toIso8601String(),
      'read_by_worker': true,
      'read_by_customer': false,
    });

    await _touchConversation(
      conversationId: conversationId,
      type: 'image',
      preview: '[Image]',
    );
  }

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

  Future<void> _insertSystemMessage({
    required String conversationId,
    required String bookingId,
    required String text,
  }) async {
    await _client.from(SupabaseTables.chatMessages).insert({
      'conversation_id': conversationId,
      'booking_id': bookingId,
      'sender_id': null,
      'sender_role': 'system',
      'message_type': 'system',
      'text': text,
      'created_at': DateTime.now().toUtc().toIso8601String(),
      'read_by_worker': true,
      'read_by_customer': true,
    });
  }

  Future<void> _cleanupExpiredMessages(String workerId) async {
    final cutoff = DateTime.now().toUtc().subtract(const Duration(days: 7));

    final conversationRows = await _client
        .from(SupabaseTables.chatConversations)
        .select('id')
        .eq('worker_id', workerId);

    final conversationIds = conversationRows
        .map((row) => row['id'] as String?)
        .whereType<String>()
        .toList(growable: false);

    if (conversationIds.isEmpty) return;

    await _client
        .from(SupabaseTables.chatMessages)
        .delete()
        .inFilter('conversation_id', conversationIds)
        .lt('created_at', cutoff.toIso8601String());
  }
}
