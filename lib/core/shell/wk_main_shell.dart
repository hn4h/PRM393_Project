import 'dart:async';

import 'package:flutter/material.dart';
import 'package:prm_project/features/wk_chat/screens/wk_chat_inbox_screen.dart';
import 'package:prm_project/features/wk_home/screens/wk_home_screen.dart';
import 'package:prm_project/features/wk_notifications/services/wk_push_notification_service.dart';
import 'package:prm_project/features/wk_profile/screens/wk_profile_screen.dart';
import 'package:prm_project/features/wk_schedule/screens/wk_schedule_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../constants/supabase_tables.dart';

/// Shell dành riêng cho worker.
/// Giữ BottomNavigationBar cố định và điều khiển tabs bằng IndexedStack.
class WkMainShell extends StatefulWidget {
  const WkMainShell({super.key});

  @override
  State<WkMainShell> createState() => _WkMainShellState();
}

class _WkMainShellState extends State<WkMainShell> {
  int _currentIndex = 0;
  int _chatUnreadCount = 0;
  RealtimeChannel? _chatMessagesChannel;
  RealtimeChannel? _chatConversationsChannel;
  Timer? _chatUnreadDebounce;

  @override
  void initState() {
    super.initState();
    WkPushNotificationService.instance.start();
    _loadChatUnreadCount();
    _subscribeChatUnreadRealtime();
  }

  @override
  void dispose() {
    _chatUnreadDebounce?.cancel();
    if (_chatMessagesChannel != null) {
      Supabase.instance.client.removeChannel(_chatMessagesChannel!);
    }
    if (_chatConversationsChannel != null) {
      Supabase.instance.client.removeChannel(_chatConversationsChannel!);
    }
    WkPushNotificationService.instance.stop();
    super.dispose();
  }

  void _subscribeChatUnreadRealtime() {
    final workerId = Supabase.instance.client.auth.currentUser?.id;
    if (workerId == null) return;

    _chatConversationsChannel = Supabase.instance.client
        .channel('wk-shell-chat-conv-$workerId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: SupabaseTables.chatConversations,
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'worker_id',
            value: workerId,
          ),
          callback: (_) => _scheduleUnreadReload(),
        )
        .subscribe();

    _chatMessagesChannel = Supabase.instance.client
        .channel('wk-shell-chat-msg-$workerId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: SupabaseTables.chatMessages,
          callback: (_) => _scheduleUnreadReload(),
        )
        .subscribe();
  }

  void _scheduleUnreadReload() {
    _chatUnreadDebounce?.cancel();
    _chatUnreadDebounce = Timer(const Duration(milliseconds: 300), () {
      _loadChatUnreadCount();
    });
  }

  Future<void> _loadChatUnreadCount() async {
    final workerId = Supabase.instance.client.auth.currentUser?.id;
    if (workerId == null) {
      if (!mounted) return;
      setState(() => _chatUnreadCount = 0);
      return;
    }

    try {
      final conversations = await Supabase.instance.client
          .from(SupabaseTables.chatConversations)
          .select('id')
          .eq('worker_id', workerId);

      final conversationIds = conversations
          .map((e) => (e['id'] as String?) ?? '')
          .where((id) => id.isNotEmpty)
          .toList(growable: false);

      if (conversationIds.isEmpty) {
        if (!mounted) return;
        setState(() => _chatUnreadCount = 0);
        return;
      }

      final unreadRows = await Supabase.instance.client
          .from(SupabaseTables.chatMessages)
          .select('conversation_id')
          .inFilter('conversation_id', conversationIds)
          .eq('sender_role', 'customer')
          .eq('read_by_worker', false);

      final unreadConversationIds = unreadRows
          .map((e) => (e['conversation_id'] as String?) ?? '')
          .where((id) => id.isNotEmpty)
          .toSet();

      if (!mounted) return;
      setState(() => _chatUnreadCount = unreadConversationIds.length);
    } catch (_) {
      // Keep the last count if reload fails.
    }
  }

  static const List<Widget> _tabs = [
    WkHomeScreen(embeddedInShell: true),
    WkScheduleScreen(),
    WkChatInboxScreen(),
    WkProfileScreen(),
  ];

  void _onTabTapped(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _tabs),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurfaceVariant,
        backgroundColor: colorScheme.surface,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedFontSize: 12,
        unselectedFontSize: 11,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_outlined),
            activeIcon: Icon(Icons.calendar_month),
            label: 'Schedule',
          ),
          BottomNavigationBarItem(
            icon: _ChatIconWithBadge(unread: _chatUnreadCount),
            activeIcon: _ChatIconWithBadge(
              isActive: true,
              unread: _chatUnreadCount,
            ),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class _ChatIconWithBadge extends StatelessWidget {
  final bool isActive;
  final int unread;

  const _ChatIconWithBadge({this.isActive = false, this.unread = 0});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(isActive ? Icons.chat_bubble : Icons.chat_bubble_outline),
        if (unread > 0)
          Positioned(
            right: -8,
            top: -5,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: const BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.all(Radius.circular(999)),
              ),
              child: Text(
                unread > 99 ? '99+' : '$unread',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
