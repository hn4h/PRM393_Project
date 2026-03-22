import 'package:flutter/material.dart';
import 'package:prm_project/features/wk_chat/screens/wk_chat_inbox_screen.dart';
import 'package:prm_project/features/wk_home/screens/wk_home_screen.dart';
import 'package:prm_project/features/wk_notifications/services/wk_push_notification_service.dart';
import 'package:prm_project/features/wk_profile/screens/wk_profile_screen.dart';
import 'package:prm_project/features/wk_schedule/screens/wk_schedule_screen.dart';

/// Shell dành riêng cho worker.
/// Giữ BottomNavigationBar cố định và điều khiển tabs bằng IndexedStack.
class WkMainShell extends StatefulWidget {
  const WkMainShell({super.key});

  @override
  State<WkMainShell> createState() => _WkMainShellState();
}

class _WkMainShellState extends State<WkMainShell> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WkPushNotificationService.instance.start();
  }

  @override
  void dispose() {
    WkPushNotificationService.instance.stop();
    super.dispose();
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
        items: const [
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
            icon: _ChatIconWithBadge(),
            activeIcon: _ChatIconWithBadge(isActive: true),
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

  const _ChatIconWithBadge({this.isActive = false});

  @override
  Widget build(BuildContext context) {
    const unread = 0;

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
