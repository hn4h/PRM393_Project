import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:prm_project/core/theme/app_colors.dart';
import 'package:prm_project/core/theme/app_text_styles.dart';

import '../models/wk_schedule_models.dart';
import '../repository/wk_schedule_repository.dart';
import '../viewmodels/wk_schedule_viewmodel.dart';

class WkBookingDetailsScreen extends ConsumerStatefulWidget {
  final WkScheduleBooking booking;

  const WkBookingDetailsScreen({super.key, required this.booking});

  @override
  ConsumerState<WkBookingDetailsScreen> createState() =>
      _WkBookingDetailsScreenState();
}

class _WkBookingDetailsScreenState
    extends ConsumerState<WkBookingDetailsScreen> {
  bool _isSubmitting = false;
  Future<List<WkBookingReview>>? _reviewsFuture;

  @override
  void initState() {
    super.initState();
    if (widget.booking.status == WkScheduleBookingStatus.completed) {
      _reviewsFuture = ref
          .read(wkScheduleRepositoryProvider)
          .fetchReviewsByBookingId(widget.booking.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final booking = widget.booking;
    final status = booking.status;
    final statusColor = wkScheduleStatusColor(status);
    final scheme = Theme.of(context).colorScheme;
    final divider = Theme.of(context).dividerColor;
    final isPending = status == WkScheduleBookingStatus.pending;
    final isAccepted = status == WkScheduleBookingStatus.accepted;
    final isInProgress = status == WkScheduleBookingStatus.inProgress;
    final isCompleted = status == WkScheduleBookingStatus.completed;

    return Scaffold(
      appBar: AppBar(title: const Text('Booking Details')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  statusColor.withValues(alpha: 0.14),
                  statusColor.withValues(alpha: 0.06),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: statusColor.withValues(alpha: 0.35)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        booking.serviceName,
                        style: AppTextStyles.headline3,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        wkScheduleStatusLabel(status),
                        style: AppTextStyles.caption.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _MetaTag(
                      icon: Icons.badge_outlined,
                      text:
                          'ID: ${booking.id.substring(0, booking.id.length > 8 ? 8 : booking.id.length)}',
                    ),
                    _MetaTag(
                      icon: Icons.timer_outlined,
                      text: '${booking.durationMinutes} mins',
                    ),
                    _MetaTag(
                      icon: Icons.attach_money,
                      text: _formatUsd(booking.totalPriceUsd),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _SectionCard(
            title: 'Schedule',
            icon: Icons.event_note_outlined,
            children: [
              _InfoRow(
                icon: Icons.access_time,
                title: 'Time',
                value: booking.timeRangeLabel,
              ),
              _InfoRow(
                icon: Icons.calendar_today,
                title: 'Date',
                value: _formatDate(booking.scheduledAtUtc7),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _SectionCard(
            title: 'Customer',
            icon: Icons.person_outline,
            children: [
              _InfoRow(
                icon: Icons.person_outline,
                title: 'Name',
                value: booking.customerName,
              ),
              _InfoRow(
                icon: Icons.location_on_outlined,
                title: 'Address',
                value: booking.address,
              ),
              _InfoRow(
                icon: Icons.phone_outlined,
                title: 'Phone',
                value:
                    (booking.contactPhone != null &&
                        booking.contactPhone!.trim().isNotEmpty)
                    ? booking.contactPhone!
                    : 'No phone provided',
              ),
            ],
          ),
          const SizedBox(height: 12),
          _SectionCard(
            title: 'Notes',
            icon: Icons.sticky_note_2_outlined,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: scheme.surface.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: divider),
                ),
                child: Text(
                  booking.notes.isNotEmpty
                      ? booking.notes
                      : 'No additional notes from customer.',
                  style: AppTextStyles.body2.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          if (isCompleted) ...[
            const SizedBox(height: 12),
            _SectionCard(
              title: 'Reviews',
              icon: Icons.reviews_outlined,
              children: [
                FutureBuilder<List<WkBookingReview>>(
                  future: _reviewsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    if (snapshot.hasError) {
                      return Text(
                        'Unable to load reviews.',
                        style: AppTextStyles.body2.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      );
                    }

                    final reviews = snapshot.data ?? const <WkBookingReview>[];
                    if (reviews.isEmpty) {
                      return Text(
                        'No reviews for this booking.',
                        style: AppTextStyles.body2.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      );
                    }

                    return Column(
                      children: reviews
                          .map(
                            (review) => Container(
                              width: double.infinity,
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: scheme.surface.withValues(alpha: 0.8),
                                borderRadius: BorderRadius.circular(10),
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
                                          color: AppColors.warning.withValues(
                                            alpha: 0.14,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            999,
                                          ),
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
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    review.comment.isNotEmpty
                                        ? review.comment
                                        : 'No comment',
                                    style: AppTextStyles.body2.copyWith(
                                      color: scheme.onSurface,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                          .toList(growable: false),
                    );
                  },
                ),
              ],
            ),
          ],
          const SizedBox(height: 90),
        ],
      ),
      bottomNavigationBar: (isPending || isAccepted || isInProgress)
          ? SafeArea(
              top: false,
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                decoration: BoxDecoration(
                  color: scheme.surface,
                  border: Border(top: BorderSide(color: divider)),
                ),
                child: isInProgress
                    ? Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 11,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Waiting for customer to confirm completion.',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.body2.copyWith(
                            color: AppColors.warning,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      )
                    : isPending
                    ? Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _isSubmitting ? null : _accept,
                              icon: const Icon(Icons.check_circle_outline),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.success,
                                foregroundColor: Colors.white,
                                minimumSize: const Size.fromHeight(46),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              label: _isSubmitting
                                  ? const SizedBox(
                                      height: 18,
                                      width: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text('Accept'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _isSubmitting ? null : _reject,
                              icon: const Icon(Icons.close),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.error,
                                side: BorderSide(
                                  color: AppColors.error.withValues(
                                    alpha: 0.55,
                                  ),
                                ),
                                minimumSize: const Size.fromHeight(46),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              label: const Text('Reject'),
                            ),
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _isSubmitting ? null : _startJob,
                              icon: const Icon(Icons.play_arrow_rounded),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                minimumSize: const Size.fromHeight(46),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              label: _isSubmitting
                                  ? const SizedBox(
                                      height: 18,
                                      width: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text('Start Job'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _contactCustomer,
                              icon: const Icon(Icons.chat_bubble_outline),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.primary,
                                side: BorderSide(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.5,
                                  ),
                                ),
                                minimumSize: const Size.fromHeight(46),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              label: const Text('Contact'),
                            ),
                          ),
                        ],
                      ),
              ),
            )
          : null,
    );
  }

  Future<void> _accept() async {
    await _submit(
      () => ref
          .read(wkScheduleViewModelProvider.notifier)
          .acceptBooking(widget.booking.id),
    );
  }

  Future<void> _reject() async {
    await _submit(
      () => ref
          .read(wkScheduleViewModelProvider.notifier)
          .rejectBooking(widget.booking.id),
    );
  }

  Future<void> _startJob() async {
    await _submit(
      () => ref
          .read(wkScheduleViewModelProvider.notifier)
          .startBooking(widget.booking.id),
    );
  }

  Future<void> _contactCustomer() async {
    final phone = widget.booking.contactPhone?.trim();
    if (phone == null || phone.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Customer phone number is not available.'),
        ),
      );
      return;
    }

    await Clipboard.setData(ClipboardData(text: phone));
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Phone number copied: $phone')));
  }

  Future<void> _submit(Future<void> Function() action) async {
    setState(() => _isSubmitting = true);
    try {
      await action();
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to update booking status.')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  String _formatDate(DateTime date) {
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    final y = date.year;
    return '$d/$m/$y';
  }

  String _formatUsd(double value) {
    final fixed = value.toStringAsFixed(2);
    final parts = fixed.split('.');
    final whole = parts[0];
    final decimal = parts[1];
    final withCommas = whole.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (_) => ',',
    );
    return '\$$withCommas.$decimal';
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final divider = Theme.of(context).dividerColor;

    return Container(
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
              Icon(icon, color: AppColors.primary, size: 18),
              const SizedBox(width: 8),
              Text(
                title,
                style: AppTextStyles.label.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }
}

class _MetaTag extends StatelessWidget {
  final IconData icon;
  final String text;

  const _MetaTag({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: scheme.surface.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: scheme.onSurfaceVariant),
          const SizedBox(width: 5),
          Text(
            text,
            style: AppTextStyles.caption.copyWith(
              color: scheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: scheme.onSurfaceVariant),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.caption.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: AppTextStyles.body2.copyWith(color: scheme.onSurface),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
