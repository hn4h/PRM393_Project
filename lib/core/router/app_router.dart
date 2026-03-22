import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:prm_project/core/constants/supabase_tables.dart';
import 'package:prm_project/core/models/booking.dart';
import 'package:prm_project/core/shell/main_shell.dart';
import 'package:prm_project/core/shell/wk_main_shell.dart';
import 'package:prm_project/features/auth/screens/login_screen.dart';
import 'package:prm_project/features/auth/screens/register_screen.dart';
import 'package:prm_project/features/auth/screens/forgot_password_screen.dart';
import 'package:prm_project/features/auth/screens/complete_profile_screen.dart';
import 'package:prm_project/features/auth/screens/otp_verify_screen.dart';
import 'package:prm_project/features/discover/screens/service_discover_screen.dart';
import 'package:prm_project/features/settings/screens/settings_screen.dart';
import 'package:prm_project/features/worker/screens/worker_detail.dart';
import 'package:prm_project/features/service/screens/service_detail_screen.dart';
import 'package:prm_project/features/review/models/review_list_args.dart';
import 'package:prm_project/features/review/screens/review_list_screen.dart';
import 'package:prm_project/features/booking/screens/booking_confirmed_screen.dart';
import 'package:prm_project/features/booking/screens/booking_flow_screen.dart';
import 'package:prm_project/features/booking/screens/booking_detail_view_screen.dart';
import 'package:prm_project/features/booking_history/screens/booking_detail_management_screen.dart';
import 'package:prm_project/features/upcoming_services/screens/upcoming_services_screen.dart';
import 'package:prm_project/features/profile/screens/edit_profile_screen.dart';
import 'package:prm_project/features/settings/screens/change_password_screen.dart';
import 'package:prm_project/features/cs_chat/screens/cs_chat_room_screen.dart';
import 'package:prm_project/features/wk_notifications/screens/wk_notifications_screen.dart';
import 'package:prm_project/features/wk_profile/screens/wk_profile_reviews_screen.dart';
import 'package:prm_project/features/wk_profile/screens/wk_profile_services_screen.dart';
import 'package:prm_project/features/wk_schedule/models/wk_schedule_models.dart';
import 'package:prm_project/features/wk_schedule/screens/wk_schedule_screen.dart';
import 'package:prm_project/features/notification/screens/notification_screen.dart';
import 'package:prm_project/features/ai_support/screens/ai_support_screen.dart';

// ── Routes that don't require authentication ──────────────────────────────────
const _publicRoutes = [
  '/login',
  '/register',
  '/forgot-password',
  '/complete-profile',
  '/otp-verify',
  '/change-password',
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
    redirect: (context, state) async {
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

        // Confirmed + on public route → go to shell (but not /change-password if forced)
        if (isOnPublicRoute && loc != '/change-password') return '/shell';
      }
      // final isOnPublicRoute = _publicRoutes.contains(state.matchedLocation);

      // Unauthenticated user on a protected page → go to login
      if (!isLoggedIn && !isOnPublicRoute) return '/login';

      if (!isLoggedIn) return null;

      final isWorker = await _isCurrentUserWorker();
      final isOnDefaultShell = state.matchedLocation == '/shell';
      final isOnWorkerShell = state.matchedLocation == '/wk-shell';

      // Authenticated user on a public page → go to role-based shell
      if (isOnPublicRoute) return isWorker ? '/wk-shell' : '/shell';

      // Prevent opening wrong shell for current role
      if (isWorker && isOnDefaultShell) return '/wk-shell';
      if (!isWorker && isOnWorkerShell) return '/shell';

      // No redirect needed
      return null;
    },
    routes: [
      // Root redirect → role-based shell (sau khi đăng nhập)
      GoRoute(
        path: '/',
        redirect: (_, __) async {
          final session = Supabase.instance.client.auth.currentSession;
          if (session == null) return '/login';

          final isWorker = await _isCurrentUserWorker();
          return isWorker ? '/wk-shell' : '/shell';
        },
      ),

      // ── Notifications ─────────────────────────────────────────────────────
      GoRoute(
        path: '/notifications',
        name: 'notifications',
        builder: (_, __) => const NotificationScreen(),
      ),

      // ── Customer Chat Room (push on top of shell) ─────────────────────────
      GoRoute(
        path: '/cs-chat-room/:conversationId',
        name: 'cs-chat-room',
        builder: (context, state) {
          final id = state.pathParameters['conversationId']!;
          return CsChatRoomScreen(conversationId: id);
        },
      ),

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
          final email =
              state.extra as String? ??
              Supabase.instance.client.auth.currentUser?.email ??
              '';
          return CompleteProfileScreen(email: email);
        },
      ),
      GoRoute(
        path: '/otp-verify',
        name: 'otp-verify',
        redirect: (context, state) {
          // If extra data is missing (e.g. deep link, browser refresh),
          // redirect back to complete-profile to re-collect data.
          if (state.extra == null || state.extra is! Map<String, String>) {
            return '/complete-profile';
          }
          return null;
        },
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
      GoRoute(
        path: '/wk-shell',
        name: 'wk-shell',
        builder: (_, __) => const WkMainShell(),
      ),
      GoRoute(
        path: '/wk-schedule',
        name: 'wk-schedule',
        builder: (_, state) {
          final tab = state.uri.queryParameters['tab'];
          final status = state.uri.queryParameters['status'];

          final initialTab = tab == 'bookings' ? 1 : 0;
          final initialFilter = _bookingsFilterFromQuery(status);

          return WkScheduleScreen(
            initialTabIndex: initialTab,
            initialFilter: initialFilter,
          );
        },
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
        builder: (_, state) {
          final forceMode = state.extra as bool? ?? true;
          return ChangePasswordScreen(forceMode: forceMode);
        },
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
      GoRoute(
        path: '/reviews',
        name: 'reviews',
        builder: (_, state) {
          final args = state.extra as ReviewListArgs;
          return ReviewListScreen(args: args);
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
        builder: (_, state) {
          final extra = state.extra as Map<String, String?>?;
          return BookingFlowScreen(
            serviceId: extra?['serviceId'],
            workerId: extra?['workerId'],
          );
        },
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

      // ── Upcoming Services Calendar (push lên trên shell) ────────────────
      GoRoute(
        path: '/upcoming-services',
        name: 'upcoming-services',
        builder: (_, __) => const UpcomingServicesScreen(),
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
      GoRoute(
        path: '/wk-notifications',
        name: 'wk-notifications',
        builder: (_, __) => const WkNotificationsScreen(),
      ),
      GoRoute(
        path: '/wk-profile-reviews',
        name: 'wk-profile-reviews',
        builder: (_, __) => const WkProfileReviewsScreen(),
      ),
      GoRoute(
        path: '/wk-profile-services',
        name: 'wk-profile-services',
        builder: (_, __) => const WkProfileServicesScreen(),
      ),

      // ── AI Support ──────────────────────────────────────────────────────────
      GoRoute(
        path: '/ai-support',
        name: 'ai-support',
        builder: (_, __) => const AiSupportScreen(),
      ),
    ],
  );

  static Future<bool> _isCurrentUserWorker() async {
    final client = Supabase.instance.client;
    final user = client.auth.currentUser;
    if (user == null) return false;

    try {
      final profile = await client
          .from(SupabaseTables.profiles)
          .select('role')
          .eq('id', user.id)
          .maybeSingle();

      return profile?['role'] == 'worker';
    } catch (_) {
      return false;
    }
  }

  static WkBookingsFilter? _bookingsFilterFromQuery(String? value) {
    switch (value) {
      case 'pending':
        return WkBookingsFilter.pending;
      case 'accepted':
        return WkBookingsFilter.accepted;
      case 'in_progress':
        return WkBookingsFilter.inProgress;
      case 'completed':
        return WkBookingsFilter.completed;
      case 'rejected':
        return WkBookingsFilter.rejected;
      case 'cancelled':
        return WkBookingsFilter.cancelled;
      default:
        return null;
    }
  }
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
