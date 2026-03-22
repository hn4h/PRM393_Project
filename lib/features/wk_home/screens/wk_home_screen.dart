import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:prm_project/core/theme/app_colors.dart';
import 'package:prm_project/core/theme/app_text_styles.dart';
import 'package:prm_project/features/wk_chat/repository/wk_chat_repository.dart';
import 'package:prm_project/features/wk_chat/screens/wk_chat_room_screen.dart';

import '../models/wk_home_models.dart';
import '../viewmodels/wk_home_viewmodel.dart';
import '../widgets/wk_bottom_navigation.dart';
import '../widgets/wk_header_section.dart';
import '../widgets/wk_pending_requests_section.dart';
import '../widgets/wk_quick_stats_section.dart';
import '../widgets/wk_today_schedule_section.dart';
import '../../wk_notifications/viewmodels/wk_notifications_viewmodel.dart';

class WkHomeScreen extends ConsumerStatefulWidget {
  final bool embeddedInShell;

  const WkHomeScreen({super.key, this.embeddedInShell = false});

  @override
  ConsumerState<WkHomeScreen> createState() => _WkHomeScreenState();
}

class _WkHomeScreenState extends ConsumerState<WkHomeScreen> {
  int _bottomIndex = 0;

  @override
  Widget build(BuildContext context) {
    final stateAsync = ref.watch(wkHomeViewModelProvider);
    final notificationsAsync = ref.watch(wkNotificationsViewmodelProvider);
    final unreadCount = notificationsAsync.valueOrNull?.unreadCount ?? 0;

    ref.listen(wkHomeViewModelProvider, (_, next) {
      final msg = next.valueOrNull?.actionError;
      if (msg != null && context.mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(msg)));
      }
    });

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: stateAsync.when(
          loading: _LoadingView.new,
          error: (error, _) => _ErrorView(
            message: 'Unable to load Worker Home data.',
            onRetry: () => ref.read(wkHomeViewModelProvider.notifier).refresh(),
          ),
          data: (state) => RefreshIndicator(
            onRefresh: () =>
                ref.read(wkHomeViewModelProvider.notifier).refresh(),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
              children: [
                WkHeaderSection(
                  workerName: state.workerName,
                  avatarUrl: state.avatarUrl,
                  isOnline: state.isOnline,
                  unreadNotifications: unreadCount,
                  onTapAvatar: () => context.push('/edit-profile'),
                  onTapNotifications: () => context.push('/wk-notifications'),
                  onToggleAvailability: (value) {
                    ref
                        .read(wkHomeViewModelProvider.notifier)
                        .toggleAvailability(value);
                  },
                ),
                const SizedBox(height: 16),
                WkQuickStatsSection(stats: state.stats),
                const SizedBox(height: 16),
                WkPendingRequestsSection(
                  requests: state.pendingRequests,
                  onAccept: (id) =>
                      ref.read(wkHomeViewModelProvider.notifier).accept(id),
                  onDecline: (id) =>
                      ref.read(wkHomeViewModelProvider.notifier).decline(id),
                ),
                const SizedBox(height: 16),
                WkTodayScheduleSection(
                  jobs: state.todaySchedule,
                  onStartJob: (id) =>
                      ref.read(wkHomeViewModelProvider.notifier).startJob(id),
                  onCompleteJob: (id) => ref
                      .read(wkHomeViewModelProvider.notifier)
                      .completeJob(id),
                  onOpenChat: _openChat,
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: widget.embeddedInShell
          ? null
          : WkBottomNavigation(
              currentIndex: _bottomIndex,
              unreadMessages: stateAsync.valueOrNull?.unreadMessages ?? 0,
              onTap: _onBottomTap,
            ),
    );
  }

  Future<void> _openChat(WkBookingCardData booking) async {
    try {
      final conversationId = await ref
          .read(wkChatRepositoryProvider)
          .getOrCreateConversationForBooking(booking.id);

      if (!mounted) return;

      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => WkChatRoomScreen(conversationId: conversationId),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
    }
  }

  void _onBottomTap(int index) {
    setState(() => _bottomIndex = index);

    if (index == 3) {
      context.push('/edit-profile');
      return;
    }

    if (index == 0) return;

    final label = switch (index) {
      1 => 'Schedule',
      2 => 'Messages',
      _ => 'Other screen',
    };

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$label will be wired in the next step.')),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.body1.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
