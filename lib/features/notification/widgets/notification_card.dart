import 'package:flutter/material.dart';
import 'package:prm_project/features/notification/models/notification_model.dart';
import 'package:intl/intl.dart';

class NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback? onTap;

  const NotificationCard({
    super.key,
    required this.notification,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isRead = notification.isRead;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isRead
              ? colorScheme.surface
              : colorScheme.primaryContainer.withOpacity(0.15),
          border: Border(
            bottom: BorderSide(
              color: colorScheme.outlineVariant.withOpacity(0.4),
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Icon based on type ──────────────────────────────
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: _iconBgColor(colorScheme),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _typeIcon,
                color: _iconColor(colorScheme),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),

            // ── Text content ────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight:
                                isRead ? FontWeight.w500 : FontWeight.w700,
                            color: colorScheme.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (!isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.body,
                    style: TextStyle(
                      fontSize: 13,
                      color: colorScheme.onSurfaceVariant,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _formatTime(notification.createdAt),
                    style: TextStyle(
                      fontSize: 11,
                      color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData get _typeIcon {
    switch (notification.type) {
      case NotificationType.booking:
        return Icons.calendar_today_rounded;
      case NotificationType.promotion:
        return Icons.local_offer_rounded;
      case NotificationType.system:
        return Icons.info_outline_rounded;
    }
  }

  Color _iconBgColor(ColorScheme cs) {
    switch (notification.type) {
      case NotificationType.booking:
        return cs.primaryContainer;
      case NotificationType.promotion:
        return cs.tertiaryContainer;
      case NotificationType.system:
        return cs.secondaryContainer;
    }
  }

  Color _iconColor(ColorScheme cs) {
    switch (notification.type) {
      case NotificationType.booking:
        return cs.primary;
      case NotificationType.promotion:
        return cs.tertiary;
      case NotificationType.system:
        return cs.secondary;
    }
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';

    return DateFormat('dd/MM/yyyy').format(dt);
  }
}
