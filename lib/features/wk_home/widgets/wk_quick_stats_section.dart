import 'package:flutter/material.dart';
import 'package:prm_project/core/theme/app_colors.dart';
import 'package:prm_project/core/theme/app_text_styles.dart';

import '../models/wk_home_models.dart';

class WkQuickStatsSection extends StatelessWidget {
  final WkQuickStats stats;

  const WkQuickStatsSection({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Today at a glance', style: AppTextStyles.headline3),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                color: AppColors.error,
                icon: Icons.notifications_active_outlined,
                title: 'Pending',
                value: '${stats.pendingRequests}',
                subtitle: stats.pendingRequests > 0
                    ? 'New requests'
                    : 'No requests',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatCard(
                color: AppColors.primary,
                icon: Icons.today_outlined,
                title: 'Today\'s jobs',
                value: '${stats.todayJobs}',
                subtitle: 'Scheduled shifts',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatCard(
                color: AppColors.success,
                icon: Icons.payments_outlined,
                title: 'Earnings',
                value: _formatUsd(stats.expectedIncome),
                subtitle: 'Expected',
              ),
            ),
          ],
        ),
      ],
    );
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

class _StatCard extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String title;
  final String value;
  final String subtitle;

  const _StatCard({
    required this.color,
    required this.icon,
    required this.title,
    required this.value,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final divider = Theme.of(context).dividerColor;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 8),
          Text(
            title,
            style: AppTextStyles.caption.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.body1.copyWith(
              fontWeight: FontWeight.w700,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: AppTextStyles.caption.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
