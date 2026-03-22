import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:prm_project/core/constants/supabase_tables.dart';
import 'package:prm_project/core/theme/app_colors.dart';
import 'package:prm_project/core/theme/app_text_styles.dart';
import 'package:prm_project/features/booking_history/screens/booking_history_screen.dart';
import 'package:prm_project/features/cs_chat/repository/cs_chat_repository.dart';
import 'package:prm_project/features/cs_chat/screens/cs_chat_inbox_screen.dart';
import 'package:prm_project/features/home/screens/home_screen.dart';
import 'package:prm_project/features/profile/screens/profile_screen.dart';

/// Placeholder cho tab Calendar (chưa implement)
class _CalendarTab extends StatelessWidget {
  const _CalendarTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Calendar')),
      body: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.calendar_today_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Your Bookings Calendar',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8),
            Text(
              'Schedule view coming soon',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shell chính của app — giữ BottomNavigationBar và quản lý tabs bằng IndexedStack.
/// IndexedStack giữ nguyên state của mỗi tab khi switch, tránh rebuild không cần thiết.
class MainShell extends ConsumerStatefulWidget {
  const MainShell({Key? key}) : super(key: key);

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  int _currentIndex = 0;
  int _chatUnreadCount = 0;
  RealtimeChannel? _badgeChannel;

  /// Các tab screens — giữ thứ tự khớp với BottomNavigationBar items
  List<Widget> get _screens => [
    const HomeScreen(),
    const BookingHistoryScreen(),
    const _CalendarTab(),
    const CsChatInboxScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _loadUnreadCount();
    _subscribeBadge();
  }

  @override
  void dispose() {
    if (_badgeChannel != null) {
      Supabase.instance.client.removeChannel(_badgeChannel!);
    }
    super.dispose();
  }

  Future<void> _loadUnreadCount() async {
    try {
      final count = await ref.read(csChatRepositoryProvider).totalUnreadCount();
      if (!mounted) return;
      setState(() => _chatUnreadCount = count);
    } catch (_) {
      // silently ignore
    }
  }

  void _subscribeBadge() {
    final customerId = Supabase.instance.client.auth.currentUser?.id;
    if (customerId == null) return;

    _badgeChannel = Supabase.instance.client
        .channel('cs-chat-badge-$customerId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: SupabaseTables.chatConversations,
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'customer_id',
            value: customerId,
          ),
          callback: (_) {
            if (!mounted) return;
            _loadUnreadCount();
          },
        )
        .subscribe();
  }

  void _onTabTapped(int index) {
    setState(() => _currentIndex = index);
    // Refresh badge when switching away from chat tab
    if (index != 3) {
      _loadUnreadCount();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedFontSize: 12,
        unselectedFontSize: 11,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            activeIcon: Icon(Icons.receipt_long),
            label: 'Bookings',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            activeIcon: Icon(Icons.calendar_today),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            icon: _chatUnreadCount > 0
                ? Badge(
                    label: Text(
                      _chatUnreadCount > 99 ? '99+' : '$_chatUnreadCount',
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                    ),
                    backgroundColor: AppColors.error,
                    child: const Icon(Icons.chat_bubble_outline),
                  )
                : const Icon(Icons.chat_bubble_outline),
            activeIcon: _chatUnreadCount > 0
                ? Badge(
                    label: Text(
                      _chatUnreadCount > 99 ? '99+' : '$_chatUnreadCount',
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                    ),
                    backgroundColor: AppColors.error,
                    child: const Icon(Icons.chat_bubble),
                  )
                : const Icon(Icons.chat_bubble),
            label: 'Chat',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
