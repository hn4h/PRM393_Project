import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prm_project/core/theme/app_colors.dart';
import 'package:prm_project/core/theme/app_text_styles.dart';
import 'package:prm_project/features/wk_schedule/repository/wk_schedule_repository.dart';
import 'package:prm_project/features/wk_schedule/screens/wk_booking_details_screen.dart';

import '../viewmodels/wk_notifications_viewmodel.dart';
import '../widgets/wk_notification_item.dart';

class WkNotificationsScreen extends ConsumerWidget {
  const WkNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncState = ref.watch(wkNotificationsViewmodelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          TextButton(
            onPressed: () => ref
                .read(wkNotificationsViewmodelProvider.notifier)
                .markAllRead(),
            child: const Text('Mark all read'),
          ),
        ],
      ),
      body: asyncState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _ErrorView(
          onRetry: () =>
              ref.read(wkNotificationsViewmodelProvider.notifier).refresh(),
        ),
        data: (state) {
          if (state.notifications.isEmpty) {
            return const _EmptyView();
          }

          return RefreshIndicator(
            onRefresh: () =>
                ref.read(wkNotificationsViewmodelProvider.notifier).refresh(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.notifications.length,
              itemBuilder: (context, index) {
                final item = state.notifications[index];
                return WkNotificationCard(
                  item: item,
                  onTap: () async {
                    if (!item.isRead) {
                      await ref
                          .read(wkNotificationsViewmodelProvider.notifier)
                          .markRead(item.id);
                    }

                    if (item.bookingId == null || item.bookingId!.isEmpty)
                      return;

                    final booking = await ref
                        .read(wkScheduleRepositoryProvider)
                        .fetchBookingById(item.bookingId!);

                    if (!context.mounted) return;

                    if (booking == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Booking details are unavailable.'),
                        ),
                      );
                      return;
                    }

                    final changed = await Navigator.of(context).push<bool>(
                      MaterialPageRoute(
                        builder: (_) =>
                            WkBookingDetailsScreen(booking: booking),
                      ),
                    );

                    if (changed == true) {
                      await ref
                          .read(wkNotificationsViewmodelProvider.notifier)
                          .refresh();
                    }
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.notifications_none,
            size: 44,
            color: scheme.onSurfaceVariant,
          ),
          const SizedBox(height: 8),
          Text(
            'No notifications yet',
            style: AppTextStyles.body2.copyWith(color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final VoidCallback onRetry;

  const _ErrorView({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 40, color: AppColors.error),
          const SizedBox(height: 8),
          Text(
            'Unable to load notifications.',
            style: AppTextStyles.body2.copyWith(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 10),
          ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
