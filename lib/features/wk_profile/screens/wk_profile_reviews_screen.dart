import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prm_project/core/theme/app_colors.dart';
import 'package:prm_project/core/theme/app_text_styles.dart';
import 'package:prm_project/features/wk_schedule/repository/wk_schedule_repository.dart';
import 'package:prm_project/features/wk_schedule/screens/wk_booking_details_screen.dart';

import '../models/wk_profile_models.dart';
import '../viewmodels/wk_profile_viewmodel.dart';

class WkProfileReviewsScreen extends ConsumerWidget {
  const WkProfileReviewsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncData = ref.watch(wkProfileViewmodelProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('All Reviews')),
      body: asyncData.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _ErrorView(
          onRetry: () =>
              ref.read(wkProfileViewmodelProvider.notifier).refresh(),
        ),
        data: (data) {
          if (data.reviews.isEmpty) {
            return const _EmptyView();
          }

          return RefreshIndicator(
            onRefresh: () =>
                ref.read(wkProfileViewmodelProvider.notifier).refresh(),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: data.reviews.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final review = data.reviews[index];
                return _ReviewCard(
                  review: review,
                  onTap: () async {
                    final bookingId = review.bookingId;
                    if (bookingId == null || bookingId.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Booking details are unavailable.'),
                        ),
                      );
                      return;
                    }

                    final booking = await ref
                        .read(wkScheduleRepositoryProvider)
                        .fetchBookingById(bookingId);
                    if (!context.mounted) return;

                    if (booking == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Booking details are unavailable.'),
                        ),
                      );
                      return;
                    }

                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            WkBookingDetailsScreen(booking: booking),
                      ),
                    );
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

class _ReviewCard extends StatelessWidget {
  final WkReviewItem review;
  final VoidCallback onTap;

  const _ReviewCard({required this.review, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final divider = Theme.of(context).dividerColor;

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '${review.rating}/5',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.warning,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  _formatDate(review.createdAtUtc7),
                  style: AppTextStyles.caption.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 6),
                Icon(Icons.chevron_right, color: scheme.onSurfaceVariant),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              review.comment.isNotEmpty ? review.comment : 'No comment',
              style: AppTextStyles.body2.copyWith(color: scheme.onSurface),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime d) {
    final day = d.day.toString().padLeft(2, '0');
    final month = d.month.toString().padLeft(2, '0');
    return '$day/$month/${d.year}';
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Center(
      child: Text(
        'No reviews yet.',
        style: AppTextStyles.body2.copyWith(color: scheme.onSurfaceVariant),
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
          const Icon(Icons.error_outline, size: 42, color: AppColors.error),
          const SizedBox(height: 8),
          Text(
            'Unable to load reviews.',
            style: AppTextStyles.body2.copyWith(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 10),
          ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
