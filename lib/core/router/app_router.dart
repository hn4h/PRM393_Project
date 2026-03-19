import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:prm_project/core/models/booking.dart';
import 'package:prm_project/core/shell/main_shell.dart';
import 'package:prm_project/features/auth/screens/login_screen.dart';
import 'package:prm_project/features/auth/screens/register_screen.dart';
import 'package:prm_project/features/auth/screens/forgot_password_screen.dart';
import 'package:prm_project/features/auth/screens/complete_profile_screen.dart';
import 'package:prm_project/features/auth/screens/otp_verify_screen.dart';
import 'package:prm_project/features/discover/screens/service_discover_screen.dart';
import 'package:prm_project/features/settings/screens/settings_screen.dart';
import 'package:prm_project/features/worker/screens/worker_detail.dart';
import 'package:prm_project/features/service/screens/service_detail_screen.dart';
import 'package:prm_project/features/booking/screens/booking_confirmed_screen.dart';
import 'package:prm_project/features/booking/screens/booking_flow_screen.dart';
import 'package:prm_project/features/booking/screens/booking_detail_view_screen.dart';
import 'package:prm_project/features/booking_history/screens/booking_detail_management_screen.dart';
import 'package:prm_project/features/profile/screens/edit_profile_screen.dart';
import 'package:prm_project/features/settings/screens/change_password_screen.dart';

// ── Routes that don't require authentication ──────────────────────────────────
const _publicRoutes = [
  '/login',
  '/register',
  '/forgot-password',
  '/complete-profile',
  '/otp-verify',
];

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);

class AppRouter {
  /// Refresh notifier that triggers GoRouter redirect when auth state changes.
  static final _authRefresh = GoRouterRefreshStream(
    Supabase.instance.client.auth.onAuthStateChange,
  );

  static final GoRouter router = GoRouter(
    initialLocation: '/login',
    navigatorKey: _rootNavigatorKey,
    refreshListenable: _authRefresh,
    redirect: (context, state) {
      final session = Supabase.instance.client.auth.currentSession;
      final user = Supabase.instance.client.auth.currentUser;
      final isLoggedIn = session != null;
      final loc = state.matchedLocation;
      final isOnPublicRoute = _publicRoutes.contains(loc);

      // ── Logged-in but email NOT confirmed → must complete registration ──
      if (isLoggedIn && user != null) {
        final confirmedAt = user.emailConfirmedAt;
        final isConfirmed = confirmedAt != null && confirmedAt.isNotEmpty;

        if (!isConfirmed) {
          // Allow staying on complete-profile or otp-verify
          if (loc == '/complete-profile' || loc == '/otp-verify') {
            return null;
          }
          return '/complete-profile';
        }

        // Confirmed + on public route → go to shell
        if (isOnPublicRoute) return '/shell';
      }

      // Unauthenticated user on a protected page → go to login
      if (!isLoggedIn && !isOnPublicRoute) return '/login';

      // No redirect needed
      return null;
    },
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

      // ── Registration flow (complete profile → OTP) ─────────────────────
      GoRoute(
        path: '/complete-profile',
        name: 'complete-profile',
        builder: (_, state) {
          final email = state.extra as String? ??
              Supabase.instance.client.auth.currentUser?.email ??
              '';
          return CompleteProfileScreen(email: email);
        },
      ),
      GoRoute(
        path: '/otp-verify',
        name: 'otp-verify',
        builder: (_, state) {
          final data = state.extra as Map<String, String>;
          return OtpVerifyScreen(
            email: data['email']!,
            phone: data['phone']!,
            address: data['address']!,
          );
        },
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

      // ── Change Password ─────────────────────────────────────────────────
      GoRoute(
        path: '/change-password',
        name: 'change-password',
        builder: (_, __) => const ChangePasswordScreen(),
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

// ── GoRouterRefreshStream ─────────────────────────────────────────────────────
/// Converts a [Stream] into a [ChangeNotifier] so GoRouter re-evaluates its
/// `redirect` callback whenever the stream emits a new value.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners(); // trigger initial evaluation
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
