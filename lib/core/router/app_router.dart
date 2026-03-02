import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:prm_project/features/auth/screens/login_screen.dart';
import 'package:prm_project/features/discover/screens/service_discover_screen.dart';
import 'package:prm_project/features/home/screens/home_screen.dart';
import 'package:prm_project/features/home/widgets/header.dart';
import 'package:prm_project/features/profile/screens/profile_screen.dart';
import 'package:prm_project/features/settings/screens/settings_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/login',
    navigatorKey: _rootNavigatorKey,
    routes: [
      GoRoute(path: '/', redirect: (context, state) => '/profile'),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => HomeScreen(),
      ),
      GoRoute(
        path: '/service-discover',
        name: 'service-discover',
        builder: (context, state) => DiscoverScreen(),
      ),
    ],
  );
}
