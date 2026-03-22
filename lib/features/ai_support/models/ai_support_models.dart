import 'package:flutter/material.dart';

// ── Message model ──────────────────────────────────────────────────────────────

class AiSupportMessage {
  final String id;
  final String conversationId;
  final String role; // 'user' | 'assistant' | 'system'
  final String content;
  final List<AiSupportSource> sources;
  final DateTime createdAtUtc7;

  const AiSupportMessage({
    required this.id,
    required this.conversationId,
    required this.role,
    required this.content,
    required this.sources,
    required this.createdAtUtc7,
  });

  bool get isUser => role == 'user';
  bool get isAssistant => role == 'assistant';
  bool get isSystem => role == 'system';

  factory AiSupportMessage.fromJson(Map<String, dynamic> json) {
    final created =
        DateTime.tryParse(json['created_at']?.toString() ?? '')?.toUtc() ??
        DateTime.now().toUtc();

    final rawSources = json['sources'];
    List<AiSupportSource> parsedSources = [];
    if (rawSources is List) {
      parsedSources = rawSources
          .whereType<Map<String, dynamic>>()
          .map(AiSupportSource.fromJson)
          .toList(growable: false);
    }

    return AiSupportMessage(
      id: json['id'] as String,
      conversationId: json['conversation_id'] as String,
      role: (json['role'] as String?) ?? 'user',
      content: (json['content'] as String?) ?? '',
      sources: parsedSources,
      createdAtUtc7: created.add(const Duration(hours: 7)),
    );
  }
}

// ── Source reference ────────────────────────────────────────────────────────────

class AiSupportSource {
  final String id;
  final String title;
  final String category;

  const AiSupportSource({
    required this.id,
    required this.title,
    required this.category,
  });

  factory AiSupportSource.fromJson(Map<String, dynamic> json) {
    return AiSupportSource(
      id: (json['id'] as String?) ?? '',
      title: (json['title'] as String?) ?? '',
      category: (json['category'] as String?) ?? '',
    );
  }
}

// ── Time helpers (reuse logic from cs_chat_models.dart) ────────────────────────

String aiSupportRelativeDateLabel(DateTime valueUtc7) {
  final now = DateTime.now().toUtc().add(const Duration(hours: 7));
  final startOfToday = DateTime(now.year, now.month, now.day);
  final startOfDate = DateTime(valueUtc7.year, valueUtc7.month, valueUtc7.day);
  final diff = startOfDate.difference(startOfToday).inDays;

  if (diff == 0) return 'Today';
  if (diff == -1) return 'Yesterday';
  return '${valueUtc7.day.toString().padLeft(2, '0')}/${valueUtc7.month.toString().padLeft(2, '0')}/${valueUtc7.year}';
}

String aiSupportTimeLabel(DateTime valueUtc7) {
  final tod = TimeOfDay.fromDateTime(valueUtc7);
  final h = tod.hourOfPeriod == 0 ? 12 : tod.hourOfPeriod;
  final m = tod.minute.toString().padLeft(2, '0');
  final suffix = tod.period == DayPeriod.am ? 'AM' : 'PM';
  return '$h:$m $suffix';
}
