import 'package:flutter/material.dart';

enum CsChatMessageType { text, image, system }

CsChatMessageType csChatMessageTypeFromDb(String? raw) {
  switch (raw) {
    case 'image':
      return CsChatMessageType.image;
    case 'system':
      return CsChatMessageType.system;
    case 'text':
    default:
      return CsChatMessageType.text;
  }
}

class CsChatBookingContext {
  final String bookingId;
  final String serviceName;
  final String workerName;
  final String address;
  final DateTime scheduledAtUtc7;
  final String status;

  const CsChatBookingContext({
    required this.bookingId,
    required this.serviceName,
    required this.workerName,
    required this.address,
    required this.scheduledAtUtc7,
    required this.status,
  });

  bool get isClosed => status == 'completed' || status == 'cancelled';
}

class CsChatConversationItem {
  final String conversationId;
  final String bookingId;
  final String workerName;
  final String? workerAvatarUrl;
  final String serviceTag;
  final String lastMessagePreview;
  final DateTime lastMessageAtUtc7;
  final int unreadCount;

  const CsChatConversationItem({
    required this.conversationId,
    required this.bookingId,
    required this.workerName,
    required this.workerAvatarUrl,
    required this.serviceTag,
    required this.lastMessagePreview,
    required this.lastMessageAtUtc7,
    required this.unreadCount,
  });
}

class CsChatMessage {
  final String id;
  final String conversationId;
  final String senderId;
  final String senderRole;
  final CsChatMessageType type;
  final String text;
  final String? imageUrl;
  final DateTime createdAtUtc7;

  const CsChatMessage({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.senderRole,
    required this.type,
    required this.text,
    required this.imageUrl,
    required this.createdAtUtc7,
  });

  bool get isFromCustomer => senderRole == 'customer';
  bool get isSystem => type == CsChatMessageType.system;
}

String csChatRelativeDateLabel(DateTime valueUtc7) {
  final now = DateTime.now().toUtc().add(const Duration(hours: 7));
  final startOfToday = DateTime(now.year, now.month, now.day);
  final startOfDate = DateTime(valueUtc7.year, valueUtc7.month, valueUtc7.day);
  final diff = startOfDate.difference(startOfToday).inDays;

  if (diff == 0) return 'Today';
  if (diff == -1) return 'Yesterday';
  return '${valueUtc7.day.toString().padLeft(2, '0')}/${valueUtc7.month.toString().padLeft(2, '0')}/${valueUtc7.year}';
}

String csChatTimeLabel(DateTime valueUtc7) {
  final tod = TimeOfDay.fromDateTime(valueUtc7);
  final h = tod.hourOfPeriod == 0 ? 12 : tod.hourOfPeriod;
  final m = tod.minute.toString().padLeft(2, '0');
  final suffix = tod.period == DayPeriod.am ? 'AM' : 'PM';
  return '$h:$m $suffix';
}
