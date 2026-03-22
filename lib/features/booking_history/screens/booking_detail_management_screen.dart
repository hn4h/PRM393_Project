import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:prm_project/core/enums/booking_status.dart';
import 'package:prm_project/core/models/booking.dart';
import 'package:prm_project/features/booking/repository/review_repository.dart'
    as booking_review;
import 'package:prm_project/features/review/screens/create_review_screen.dart';
import 'package:prm_project/features/cs_chat/repository/cs_chat_repository.dart';
import 'package:prm_project/features/cs_chat/screens/cs_chat_room_screen.dart';

import '../viewmodel/booking_history_viewmodel.dart';

final bookingReviewExistsProvider = FutureProvider.family<bool, String>((
  ref,
  bookingId,
) {
  return ref.read(booking_review.reviewRepositoryProvider).hasReview(bookingId);
});

class BookingDetailManagementScreen extends ConsumerWidget {
  final Booking booking;

  const BookingDetailManagementScreen({super.key, required this.booking});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Booking Detail',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildWorkerHeader(context),
                  const SizedBox(height: 24),
                  const Text(
                    'Service',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildServiceItem(
                    booking.serviceName ?? 'Service',
                    '\$${booking.totalPrice.toStringAsFixed(2)}',
                  ),
                  const Divider(height: 40),
                  const Text(
                    'Contact Information',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildContactBox(),
                  const SizedBox(height: 24),
                  const Text(
                    'Details',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildDetailBox(),
                ],
              ),
            ),
          ),
          _buildActionButton(context, ref),
        ],
      ),
    );
  }

  Widget _buildWorkerHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundImage:
                booking.workerAvatar != null && booking.workerAvatar!.isNotEmpty
                ? NetworkImage(booking.workerAvatar!)
                : null,
            child: booking.workerAvatar == null || booking.workerAvatar!.isEmpty
                ? const Icon(Icons.person, size: 30)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking.workerName ?? 'Worker',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  booking.serviceName ?? 'Service',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed:
                (booking.status == BookingStatus.accepted ||
                    booking.status == BookingStatus.inProgress)
                ? () => _openChatRoom(context)
                : null,
            icon: Icon(
              Icons.chat_bubble_outline,
              color:
                  (booking.status == BookingStatus.accepted ||
                      booking.status == BookingStatus.inProgress)
                  ? const Color(0xFF008DDA)
                  : Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceItem(String name, String price) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle_outline,
            color: Color(0xFF008DDA),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Text(price, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildContactBox() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildRow('Name', booking.contactName ?? 'N/A'),
          _buildRow('Phone', booking.contactPhone ?? 'N/A'),
          if (booking.address != null && booking.address!.isNotEmpty)
            _buildRow('Address', booking.address!, isMultiLine: true),
          if (booking.notes != null && booking.notes!.isNotEmpty)
            _buildRow('Notes', booking.notes!, isMultiLine: true),
        ],
      ),
    );
  }

  Widget _buildDetailBox() {
    final scheduled = booking.scheduledAt ?? DateTime.now();
    final serviceFee = booking.totalPrice * 0.05;
    final total = booking.totalPrice + serviceFee;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildRow(
            'Status',
            booking.statusText,
            valueColor: booking.statusColor,
          ),
          _buildRow('Date', DateFormat('EEE, d MMM yyyy').format(scheduled)),
          _buildRow('Time', DateFormat('hh:mm a').format(scheduled)),
          _buildRow('Duration', '${booking.durationMinutes} min'),
          _buildRow(
            'Payment Method',
            _formatPaymentMethod(booking.paymentMethod),
          ),
          const Divider(height: 24),
          _buildRow(
            'Service Price',
            '\$${booking.totalPrice.toStringAsFixed(2)}',
          ),
          _buildRow('Service Fee (5%)', '\$${serviceFee.toStringAsFixed(2)}'),
          const Divider(height: 24),
          _buildRow('Total', '\$${total.toStringAsFixed(2)}', isTotal: true),
        ],
      ),
    );
  }

  String _formatPaymentMethod(String method) {
    switch (method.toLowerCase()) {
      case 'credit card':
        return 'Credit Card';
      case 'paypal':
        return 'PayPal';
      case 'apple pay':
        return 'Apple Pay';
      case 'google pay':
        return 'Google Pay';
      case 'cash':
        return 'Cash';
      default:
        return method;
    }
  }

  Widget _buildRow(
    String label,
    String value, {
    bool isTotal = false,
    bool isMultiLine = false,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: isMultiLine
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: isTotal ? 16 : 14,
                color:
                    valueColor ??
                    (isTotal ? const Color(0xFF008DDA) : Colors.black),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openChatRoom(BuildContext context) async {
    try {
      final repo = CsChatRepository(Supabase.instance.client);
      final conversationId = await repo.getConversationIdForBooking(booking.id);
      if (conversationId == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Chat is not available for this booking yet.'),
            ),
          );
        }
        return;
      }
      if (context.mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => CsChatRoomScreen(conversationId: conversationId),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Unable to open chat: $e')));
      }
    }
  }

  Widget _buildActionButton(BuildContext context, WidgetRef ref) {
    if (booking.status == BookingStatus.cancelled ||
        booking.status == BookingStatus.rejected ||
        booking.status == BookingStatus.accepted) {
      return const SizedBox.shrink();
    }

    if (booking.status == BookingStatus.completed) {
      final reviewExistsAsync = ref.watch(
        bookingReviewExistsProvider(booking.id),
      );

      return reviewExistsAsync.when(
        loading: () => _buildBottomButton(
          context,
          buttonText: 'Checking Review...',
          buttonColor: const Color(0xFFB0BEC5),
          onPressed: null,
        ),
        error: (_, __) => _buildBottomButton(
          context,
          buttonText: 'Add Review',
          buttonColor: const Color(0xFF008DDA),
          onPressed: () => _handleCompletedAction(context, ref),
        ),
        data: (exists) {
          if (exists) {
            return _buildBottomButton(
              context,
              buttonText: 'Review Submitted',
              buttonColor: Colors.green.shade600,
              onPressed: null,
            );
          }

          return _buildBottomButton(
            context,
            buttonText: 'Add Review',
            buttonColor: const Color(0xFF008DDA),
            onPressed: () => _handleCompletedAction(context, ref),
          );
        },
      );
    }

    String buttonText = '';
    Color buttonColor = const Color(0xFF008DDA);

    switch (booking.status) {
      case BookingStatus.pending:
        buttonText = 'Cancel Booking';
        buttonColor = Colors.red.shade400;
        break;
      case BookingStatus.inProgress:
        buttonText = 'Mark as Completed';
        buttonColor = Colors.green.shade600;
        break;
      default:
        return const SizedBox.shrink();
    }

    return _buildBottomButton(
      context,
      buttonText: buttonText,
      buttonColor: buttonColor,
      onPressed: () => _handleAction(context, ref, booking.status),
    );
  }

  Widget _buildBottomButton(
    BuildContext context, {
    required String buttonText,
    required Color buttonColor,
    required VoidCallback? onPressed,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFF1F4F8))),
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          disabledBackgroundColor: buttonColor,
          minimumSize: const Size(double.infinity, 54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: Text(
          buttonText,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _handleAction(
    BuildContext context,
    WidgetRef ref,
    BookingStatus status,
  ) {
    switch (status) {
      case BookingStatus.pending:
        _showConfirmationDialog(
          context,
          ref,
          'Cancel Booking',
          'Are you sure you want to cancel this booking?',
          onConfirm: () async {
            await ref
                .read(bookingHistoryViewModelProvider.notifier)
                .cancelBooking(booking.id);
            if (context.mounted) {
              Navigator.pop(context);
              context.pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Booking cancelled successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          },
        );
        break;
      case BookingStatus.inProgress:
        _showConfirmationDialog(
          context,
          ref,
          'Complete Service',
          'Are you sure the service has been completed?',
          onConfirm: () async {
            await ref
                .read(bookingHistoryViewModelProvider.notifier)
                .completeBooking(booking.id);
            if (context.mounted) {
              Navigator.pop(context);
              context.pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Booking marked as completed!'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          },
        );
        break;
      default:
        break;
    }
  }

  Future<void> _handleCompletedAction(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => CreateReviewScreen(booking: booking)),
    );

    if (result == true && context.mounted) {
      ref.invalidate(bookingReviewExistsProvider(booking.id));
      await ref.read(bookingHistoryViewModelProvider.notifier).refresh();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Review submitted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  void _showConfirmationDialog(
    BuildContext context,
    WidgetRef ref,
    String title,
    String content, {
    required Future<void> Function() onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(content),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              await onConfirm();
            },
            child: Text(
              'Confirm',
              style: TextStyle(
                color: title.contains('Cancel')
                    ? Colors.red
                    : const Color(0xFF008DDA),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
