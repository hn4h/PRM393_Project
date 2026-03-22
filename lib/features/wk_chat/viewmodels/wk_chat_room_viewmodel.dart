import 'dart:async';
import 'dart:typed_data';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/supabase_tables.dart';
import '../models/wk_chat_models.dart';
import '../repository/wk_chat_repository.dart';

part 'wk_chat_room_viewmodel.g.dart';

class WkChatRoomState {
  final WkChatBookingContext? context;
  final List<WkChatMessage> messages;

  const WkChatRoomState({
    required this.context,
    required this.messages,
  });

  WkChatRoomState copyWith({
    WkChatBookingContext? context,
    List<WkChatMessage>? messages,
  }) {
    return WkChatRoomState(
      context: context ?? this.context,
      messages: messages ?? this.messages,
    );
  }
}

@riverpod
class WkChatRoomViewmodel extends _$WkChatRoomViewmodel {
  late String _conversationId;
  RealtimeChannel? _messagesChannel;
  Timer? _reloadDebounce;

  Future<WkChatRoomState> _load() async {
    final repo = ref.read(wkChatRepositoryProvider);
    final ctx = await repo.fetchBookingContextByConversation(_conversationId);
    final messages = await repo.fetchMessages(_conversationId);
    await repo.markConversationReadByWorker(_conversationId);
    return WkChatRoomState(context: ctx, messages: messages);
  }

  void _subscribeRealtime() {
    _messagesChannel = Supabase.instance.client
        .channel('wk-chat-room-$_conversationId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: SupabaseTables.chatMessages,
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'conversation_id',
            value: _conversationId,
          ),
          callback: (_) {
            _scheduleRefresh();
          },
        )
        .subscribe();
  }

  void _scheduleRefresh() {
    _reloadDebounce?.cancel();
    _reloadDebounce = Timer(const Duration(milliseconds: 300), () async {
      state = await AsyncValue.guard(_load);
    });
  }

  @override
  Future<WkChatRoomState> build(String conversationId) async {
    _conversationId = conversationId;
    _subscribeRealtime();

    ref.onDispose(() async {
      _reloadDebounce?.cancel();
      if (_messagesChannel != null) {
        await Supabase.instance.client.removeChannel(_messagesChannel!);
      }
    });

    return _load();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }

  Future<void> sendTextMessage(String text, String bookingId) async {
    if (text.trim().isEmpty) return;

    try {
      final repo = ref.read(wkChatRepositoryProvider);
      await repo.sendTextMessage(
        conversationId: _conversationId,
        bookingId: bookingId,
        text: text,
      );
      await refresh();
    } catch (_) {
      rethrow;
    }
  }

  Future<void> sendImageMessage(
    Uint8List bytes,
    String extension,
    String bookingId,
  ) async {
    try {
      final repo = ref.read(wkChatRepositoryProvider);
      await repo.sendImageMessage(
        conversationId: _conversationId,
        bookingId: bookingId,
        bytes: bytes,
        extension: extension,
      );
      await refresh();
    } catch (_) {
      rethrow;
    }
  }
}
