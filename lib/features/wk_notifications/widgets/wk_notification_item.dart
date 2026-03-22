import 'package:flutter/material.dart';
import 'package:prm_project/core/theme/app_colors.dart';
import 'package:prm_project/core/theme/app_text_styles.dart';

import '../models/wk_notification_models.dart';

class WkNotificationCard extends StatelessWidget {
  final WkNotificationItem item;
  final VoidCallback onTap;

  const WkNotificationCard({
    super.key,
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = wkNotificationColor(item.type);
    final scheme = Theme.of(context).colorScheme;
    final divider = Theme.of(context).dividerColor;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: item.isRead
              ? scheme.surface
              : AppColors.primary.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: item.isRead
                ? divider
                : AppColors.primary.withValues(alpha: 0.25),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                wkNotificationIcon(item.type),
                color: iconColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: AppTextStyles.body2.copyWith(
                            fontWeight: item.isRead
                                ? FontWeight.w600
                                : FontWeight.w800,
                            color: scheme.onSurface,
                          ),
                        ),
                      ),
                      if (!item.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.body,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.body2.copyWith(
                      color: scheme.onSurfaceVariant,
                      fontWeight: item.isRead
                          ? FontWeight.w400
                          : FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _relativeTime(item.createdAt),
                    style: AppTextStyles.caption.copyWith(
                      color: scheme.onSurfaceVariant,
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

  String _relativeTime(DateTime time) {
    final now = DateTime.now().toUtc().add(const Duration(hours: 7));
    final diff = now.difference(time);

    if (diff.inMinutes <= 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} minutes ago';
    if (diff.inHours < 24) return '${diff.inHours} hours ago';
    if (diff.inHours < 48) return 'Yesterday';
    return '${time.day.toString().padLeft(2, '0')}/${time.month.toString().padLeft(2, '0')}/${time.year}';
  }
}
