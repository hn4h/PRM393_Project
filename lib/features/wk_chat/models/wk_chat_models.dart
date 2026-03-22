import 'package:flutter/material.dart';

enum WkChatMessageType { text, image, system }

WkChatMessageType wkChatMessageTypeFromDb(String? raw) {
  switch (raw) {
    case 'image':
      return WkChatMessageType.image;
    case 'system':
      return WkChatMessageType.system;
    case 'text':
    default:
      return WkChatMessageType.text;
  }
}

class WkChatBookingContext {
  final String bookingId;
  final String serviceName;
  final String customerName;
  final String? customerAvatarUrl;
  final String address;
  final DateTime scheduledAtUtc7;
  final String status;

  const WkChatBookingContext({
    required this.bookingId,
    required this.serviceName,
    required this.customerName,
    required this.customerAvatarUrl,
    required this.address,
    required this.scheduledAtUtc7,
    required this.status,
  });

  bool get isClosed => status == 'completed' || status == 'cancelled';
}

class WkChatConversationItem {
  final String conversationId;
  final String bookingId;
  final String customerName;
  final String? customerAvatarUrl;
  final String serviceTag;
  final String lastMessagePreview;
  final DateTime lastMessageAtUtc7;
  final int unreadCount;

  const WkChatConversationItem({
    required this.conversationId,
    required this.bookingId,
    required this.customerName,
    required this.customerAvatarUrl,
    required this.serviceTag,
    required this.lastMessagePreview,
    required this.lastMessageAtUtc7,
    required this.unreadCount,
  });
}

class WkChatMessage {
  final String id;
  final String conversationId;
  final String senderId;
  final String senderRole;
  final WkChatMessageType type;
  final String text;
  final String? imageUrl;
  final DateTime createdAtUtc7;

  const WkChatMessage({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.senderRole,
    required this.type,
    required this.text,
    required this.imageUrl,
    required this.createdAtUtc7,
  });

  bool get isFromWorker => senderRole == 'worker';
  bool get isSystem => type == WkChatMessageType.system;
}

String wkChatRelativeDateLabel(DateTime valueUtc7) {
  final now = DateTime.now().toUtc().add(const Duration(hours: 7));
  final startOfToday = DateTime(now.year, now.month, now.day);
  final startOfDate = DateTime(valueUtc7.year, valueUtc7.month, valueUtc7.day);
  final diff = startOfDate.difference(startOfToday).inDays;

  if (diff == 0) return 'Today';
  if (diff == -1) return 'Yesterday';
  return '${valueUtc7.day.toString().padLeft(2, '0')}/${valueUtc7.month.toString().padLeft(2, '0')}/${valueUtc7.year}';
}

String wkChatTimeLabel(DateTime valueUtc7) {
  final tod = TimeOfDay.fromDateTime(valueUtc7);
  final h = tod.hourOfPeriod == 0 ? 12 : tod.hourOfPeriod;
  final m = tod.minute.toString().padLeft(2, '0');
  final suffix = tod.period == DayPeriod.am ? 'AM' : 'PM';
  return '$h:$m $suffix';
}
