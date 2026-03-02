import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:prm_project/core/models/booking.dart';
import 'package:prm_project/features/auth/screens/login_screen.dart';
import 'package:prm_project/features/discover/screens/service_discover_screen.dart';
import 'package:prm_project/features/home/screens/home_screen.dart';
import 'package:prm_project/features/home/widgets/header.dart';
import 'package:prm_project/features/profile/screens/profile_screen.dart';
import 'package:prm_project/features/settings/screens/settings_screen.dart';
import 'package:prm_project/features/service_detail/screens/service_detail_screen.dart';
import 'package:prm_project/features/booking/screens/booking_confirmed_screen.dart';
import 'package:prm_project/features/booking/screens/booking_flow_screen.dart';
import 'package:prm_project/features/booking/screens/booking_detail_view_screen.dart';
import 'package:prm_project/features/booking_history/screens/booking_history_screen.dart';
import 'package:prm_project/features/booking_history/screens/booking_detail_management_screen.dart';

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
      GoRoute(
        path: '/service-detail',
        name: 'service-detail',
        builder: (context, state) => const ServiceDetailScreen(),
      ),
      GoRoute(
        path: '/booking-flow',
        name: 'booking-flow',
        builder: (context, state) => const BookingFlowScreen(),
      ),
      GoRoute(
        path: '/booking-confirmed',
        name: 'booking-confirmed',
        builder: (context, state) => const BookingConfirmedScreen(),
      ),
      GoRoute(
        path: '/booking-detail-view',
        name: 'booking-detail-view',
        builder: (context, state) => const BookingDetailViewScreen(),
      ),
      GoRoute(
        path: '/booking-history',
        name: 'booking-history',
        builder: (context, state) => const BookingHistoryScreen(),
      ),
      GoRoute(
        path: '/booking-history-detail',
        name: 'booking-history-detail',
        builder: (context, state) {
          final booking = state.extra as Booking;
          return BookingDetailManagementScreen(booking: booking);
        },
      ),
    ],
  );
}
