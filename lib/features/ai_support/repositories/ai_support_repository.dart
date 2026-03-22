import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/supabase_tables.dart';
import '../models/ai_support_models.dart';

final aiSupportRepositoryProvider = Provider<AiSupportRepository>(
  (ref) => AiSupportRepository(Supabase.instance.client),
);

class AiSupportRepository {
  final SupabaseClient _client;

  const AiSupportRepository(this._client);

  // ── Get or create conversation ──────────────────────────────────────────

  Future<String> getOrCreateConversation() async {
    final customerId = _client.auth.currentUser?.id;
    if (customerId == null) throw Exception('You are not signed in.');

    // Try to find existing conversation
    final existing = await _client
        .from(SupabaseTables.aiSupportConversations)
        .select('id')
        .eq('customer_id', customerId)
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();

    if (existing != null) return existing['id'] as String;

    // Create new conversation
    final created = await _client
        .from(SupabaseTables.aiSupportConversations)
        .insert({'customer_id': customerId})
        .select('id')
        .single();

    return created['id'] as String;
  }

  // ── Fetch messages ──────────────────────────────────────────────────────

  Future<List<AiSupportMessage>> fetchMessages(String conversationId) async {
    final rows = await _client
        .from(SupabaseTables.aiSupportMessages)
        .select('id, conversation_id, role, content, sources, created_at')
        .eq('conversation_id', conversationId)
        .order('created_at', ascending: true);

    return rows
        .map((raw) => AiSupportMessage.fromJson(raw))
        .toList(growable: false);
  }

  // ── Send question to Edge Function ──────────────────────────────────────

  Future<Map<String, dynamic>> sendQuestion({
    required String conversationId,
    required String question,
  }) async {
    final response = await _client.functions.invoke(
      'ai-support-chat',
      body: {'question': question.trim(), 'conversation_id': conversationId},
    );

    if (response.status != 200) {
      final errorBody = response.data;
      final errorMsg = errorBody is Map
          ? (errorBody['error'] ?? 'Unknown error')
          : 'Request failed with status ${response.status}';
      throw Exception(errorMsg);
    }

    final data = response.data;
    if (data is Map<String, dynamic>) return data;
    if (data is String) return jsonDecode(data) as Map<String, dynamic>;
    return {'answer': '', 'sources': []};
  }
}
