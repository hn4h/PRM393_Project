import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:prm_project/features/notification/viewmodels/notification_viewmodel.dart';
import 'package:prm_project/features/notification/widgets/notification_card.dart';

class NotificationScreen extends ConsumerWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(notificationViewModelProvider);
    final vm = ref.read(notificationViewModelProvider.notifier);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Notifications',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: [
          if (state.unreadCount > 0)
            TextButton(
              onPressed: () => vm.markAllAsRead(),
              child: Text(
                'Read all',
                style: TextStyle(
                  color: colorScheme.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: _buildBody(context, state, vm, colorScheme),
    );
  }

  Widget _buildBody(
    BuildContext context,
    NotificationState state,
    NotificationViewModel vm,
    ColorScheme colorScheme,
  ) {
    // Loading state
    if (state.isLoading && state.items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    // Error state
    if (state.error != null && state.items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: colorScheme.error),
            const SizedBox(height: 12),
            Text(
              'Failed to load notifications',
              style: TextStyle(
                fontSize: 16,
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () => vm.refresh(),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    // Empty state
    if (state.items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.notifications_off_outlined,
              size: 64,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 16),
            Text(
              'No notifications yet',
              style: TextStyle(
                fontSize: 16,
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'You will see updates about your bookings here.',
              style: TextStyle(
                fontSize: 13,
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      );
    }

    // Notification list
    return RefreshIndicator(
      onRefresh: () => vm.refresh(),
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: state.items.length,
        itemBuilder: (context, index) {
          final notification = state.items[index];
          return NotificationCard(
            notification: notification,
            onTap: () {
              // Mark as read on tap
              if (!notification.isRead) {
                vm.markAsRead(notification.id);
              }
              // Navigate to booking detail if linked
              if (notification.bookingId != null) {
                context.push('/booking-detail-view');
              }
            },
          );
        },
      ),
    );
  }
}
