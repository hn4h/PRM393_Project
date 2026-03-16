import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:prm_project/core/models/booking.dart';
import 'package:prm_project/core/shell/main_shell.dart';
import 'package:prm_project/features/auth/screens/login_screen.dart';
import 'package:prm_project/features/auth/screens/register_screen.dart';
import 'package:prm_project/features/auth/screens/forgot_password_screen.dart';
import 'package:prm_project/features/discover/screens/service_discover_screen.dart';
import 'package:prm_project/features/settings/screens/settings_screen.dart';
import 'package:prm_project/features/worker/screens/worker_detail.dart';
import 'package:prm_project/features/service/screens/service_detail_screen.dart';
import 'package:prm_project/features/booking/screens/booking_confirmed_screen.dart';
import 'package:prm_project/features/booking/screens/booking_flow_screen.dart';
import 'package:prm_project/features/booking/screens/booking_detail_view_screen.dart';
import 'package:prm_project/features/booking_history/screens/booking_detail_management_screen.dart';
import 'package:prm_project/features/profile/screens/edit_profile_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/login',
    navigatorKey: _rootNavigatorKey,
    routes: [
      // Root redirect → shell (sau khi đăng nhập)
      GoRoute(path: '/', redirect: (_, __) => '/shell'),

      // ── Auth routes ─────────────────────────────────────────────────────
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (_, __) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        name: 'forgot-password',
        builder: (_, __) => const ForgotPasswordScreen(),
      ),

      // ── Main shell (Home + Bookings + Calendar + Chat + Profile tabs) ───
      GoRoute(
        path: '/shell',
        name: 'shell',
        builder: (_, __) => const MainShell(),
      ),

      // ── Settings (push lên trên shell) ──────────────────────────────────
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (_, __) => const SettingsScreen(),
      ),

      // ── Service ─────────────────────────────────────────────────────────
      GoRoute(
        path: '/service-discover',
        name: 'service-discover',
        builder: (_, __) => DiscoverScreen(),
      ),
      GoRoute(
        path: '/service-detail/:id',
        name: 'service-detail',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return ServiceDetailScreen(serviceId: id);
        },
      ),

      // ── Worker ───────────────────────────────────────────────────────────
      GoRoute(
        path: '/worker/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return WorkerDetailScreen(workerId: id);
        },
      ),

      // ── Booking flow ─────────────────────────────────────────────────────
      GoRoute(
        path: '/booking-flow',
        name: 'booking-flow',
        builder: (_, __) => const BookingFlowScreen(),
      ),
      GoRoute(
        path: '/booking-confirmed',
        name: 'booking-confirmed',
        builder: (_, __) => const BookingConfirmedScreen(),
      ),
      GoRoute(
        path: '/booking-detail-view',
        name: 'booking-detail-view',
        builder: (_, __) => const BookingDetailViewScreen(),
      ),

      // ── Booking history detail (push trên shell) ─────────────────────────
      GoRoute(
        path: '/booking-history-detail',
        name: 'booking-history-detail',
        builder: (context, state) {
          final booking = state.extra as Booking;
          return BookingDetailManagementScreen(booking: booking);
        },
      ),

      // ── Profile ──────────────────────────────────────────────────────────
      GoRoute(
        path: '/edit-profile',
        name: 'edit-profile',
        builder: (_, __) => const EditProfileScreen(),
      ),
    ],
  );
}
