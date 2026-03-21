import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:prm_project/core/models/booking.dart';

class UpcomingServiceCard extends StatelessWidget {
  final Booking booking;
  final VoidCallback onTap;

  const UpcomingServiceCard({
    super.key,
    required this.booking,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final scheduledDate = booking.scheduledAt ?? DateTime.now();
    final formattedFullDate = DateFormat('dd/MM/yyyy').format(scheduledDate);
    final formattedTime = DateFormat('hh:mm a').format(scheduledDate);

    final isToday =
        scheduledDate.day == DateTime.now().day &&
        scheduledDate.month == DateTime.now().month &&
        scheduledDate.year == DateTime.now().year;

    final isTomorrow =
        scheduledDate.day == DateTime.now().add(const Duration(days: 1)).day &&
        scheduledDate.month ==
            DateTime.now().add(const Duration(days: 1)).month &&
        scheduledDate.year == DateTime.now().add(const Duration(days: 1)).year;

    final dateLabel = isToday
        ? 'Today, $formattedFullDate'
        : isTomorrow
        ? 'Tomorrow, $formattedFullDate'
        : formattedFullDate;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colorScheme.outlineVariant.withOpacity(0.3),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header with service image
            Container(
              height: 140,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                color: colorScheme.primaryContainer,
                image:
                    booking.serviceImage != null &&
                        booking.serviceImage!.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(booking.serviceImage!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child:
                  booking.serviceImage == null || booking.serviceImage!.isEmpty
                  ? Center(
                      child: Icon(
                        Icons.cleaning_services,
                        size: 48,
                        color: colorScheme.primary,
                      ),
                    )
                  : null,
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date indicator badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isToday
                          ? Colors.orange.withOpacity(0.2)
                          : isTomorrow
                          ? Colors.blue.withOpacity(0.2)
                          : Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      dateLabel,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isToday
                            ? Colors.orange.shade700
                            : isTomorrow
                            ? Colors.blue.shade700
                            : colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Service name
                  Text(
                    booking.serviceName ?? 'Service',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Worker name
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: colorScheme.primaryContainer,
                        backgroundImage:
                            booking.workerAvatar != null &&
                                booking.workerAvatar!.isNotEmpty
                            ? NetworkImage(booking.workerAvatar!)
                            : null,
                        child:
                            booking.workerAvatar == null ||
                                booking.workerAvatar!.isEmpty
                            ? Icon(
                                Icons.person,
                                size: 18,
                                color: colorScheme.primary,
                              )
                            : null,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Service Provider',
                              style: TextStyle(
                                fontSize: 12,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            Text(
                              booking.workerName ?? 'Worker',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Time and duration
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest.withOpacity(
                        0.5,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 16,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          formattedTime,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Icon(Icons.timer, size: 16, color: colorScheme.primary),
                        const SizedBox(width: 8),
                        Text(
                          '${booking.durationMinutes} min',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Price
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Price',
                        style: TextStyle(
                          fontSize: 14,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        '₫${booking.totalPrice.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
