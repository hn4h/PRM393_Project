import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:prm_project/core/providers/settings_provider.dart';
import 'package:prm_project/core/theme/app_colors.dart';
import 'package:prm_project/core/theme/app_text_styles.dart';
import 'package:prm_project/core/utils/image_helper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/wk_profile_models.dart';
import '../viewmodels/wk_profile_viewmodel.dart';

class WkProfileScreen extends ConsumerWidget {
  const WkProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncData = ref.watch(wkProfileViewmodelProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Worker Profile')),
      body: asyncData.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _ErrorView(
          onRetry: () =>
              ref.read(wkProfileViewmodelProvider.notifier).refresh(),
        ),
        data: (data) => RefreshIndicator(
          onRefresh: () =>
              ref.read(wkProfileViewmodelProvider.notifier).refresh(),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            children: [
              _HeaderSection(data: data),
              const SizedBox(height: 14),
              _ServicesSection(data: data),
              const SizedBox(height: 14),
              _AvailabilitySection(data: data),
              const SizedBox(height: 14),
              _FinanceSection(data: data),
              const SizedBox(height: 14),
              _ReviewsSection(data: data),
              const SizedBox(height: 14),
              _SystemSection(data: data),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () => _logout(context),
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: BorderSide(
                    color: AppColors.error.withValues(alpha: 0.7),
                  ),
                  minimumSize: const Size.fromHeight(46),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    await Supabase.instance.client.auth.signOut();
    if (context.mounted) {
      context.go('/login');
    }
  }
}

class _HeaderSection extends ConsumerWidget {
  final WkProfileData data;

  const _HeaderSection({required this.data});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;

    return _Card(
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: scheme.surface,
                child: ClipOval(
                  child: (data.avatarUrl != null && data.avatarUrl!.isNotEmpty)
                      ? ImageHelper.loadNetworkImage(
                          imageUrl: data.avatarUrl!,
                          width: 64,
                          height: 64,
                          fit: BoxFit.cover,
                          errorWidget: const Icon(Icons.person),
                        )
                      : Icon(
                          Icons.person,
                          size: 32,
                          color: scheme.onSurfaceVariant,
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(data.name, style: AppTextStyles.headline3),
                    if ((data.email ?? '').isNotEmpty)
                      Text(
                        data.email!,
                        style: AppTextStyles.caption.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
              OutlinedButton(
                onPressed: () => context.push('/edit-profile'),
                style: OutlinedButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  minimumSize: const Size(88, 32),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Edit Profile'),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _Badge(
                  value: '⭐ ${data.rating.toStringAsFixed(1)} / 5.0',
                  label: 'Rating',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _Badge(
                  value: '${data.completedJobs}',
                  label: 'Jobs Done',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _Badge(
                  value: '${data.acceptanceRate.toStringAsFixed(0)}%',
                  label: 'Acceptance',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ServicesSection extends StatelessWidget {
  final WkProfileData data;

  const _ServicesSection({required this.data});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final divider = Theme.of(context).dividerColor;

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('My Services', style: AppTextStyles.headline3),
          const SizedBox(height: 8),
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => context.push('/wk-profile-services'),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: scheme.surface.withValues(alpha: 0.75),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: divider),
              ),
              child: Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.home_repair_service_outlined,
                      color: AppColors.primary,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${data.selectedServices.length} services selected',
                          style: AppTextStyles.label.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Tap to add or remove services.',
                          style: AppTextStyles.caption.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: scheme.onSurfaceVariant),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: data.selectedServices
                .take(6)
                .map(
                  (s) => Chip(
                    label: Text(s.name),
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  ),
                )
                .toList(growable: false),
          ),
          if (data.selectedServices.isEmpty)
            Text(
              'No services selected.',
              style: AppTextStyles.body2.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
        ],
      ),
    );
  }
}

class _AvailabilitySection extends ConsumerWidget {
  final WkProfileData data;

  const _AvailabilitySection({required this.data});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Availability Settings', style: AppTextStyles.headline3),
          const SizedBox(height: 10),
          Text(
            'Weekly Schedule',
            style: AppTextStyles.label.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          ...data.weeklyAvailability.map(
            (d) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: scheme.surface.withValues(alpha: 0.75),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 40,
                    child: Text(d.day, style: AppTextStyles.body2),
                  ),
                  Switch(
                    value: d.enabled,
                    onChanged: (v) async {
                      final updated = data.weeklyAvailability
                          .map(
                            (x) => x.day == d.day ? x.copyWith(enabled: v) : x,
                          )
                          .toList(growable: false);
                      await ref
                          .read(wkProfileViewmodelProvider.notifier)
                          .saveWeeklyAvailability(updated);
                    },
                  ),
                  const Spacer(),
                  Text('${d.start} - ${d.end}', style: AppTextStyles.caption),
                  IconButton(
                    onPressed: () => _pickTimeRange(context, ref, data, d),
                    icon: const Icon(Icons.edit_outlined, size: 18),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Time-off / Exceptions',
                  style: AppTextStyles.label.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => _addTimeOff(context, ref, data),
                child: const Text('Add date'),
              ),
            ],
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: data.timeOffDates
                .map(
                  (d) => InputChip(
                    label: Text(
                      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}',
                    ),
                    onDeleted: () async {
                      final updated = List<DateTime>.from(data.timeOffDates)
                        ..removeWhere(
                          (x) =>
                              x.year == d.year &&
                              x.month == d.month &&
                              x.day == d.day,
                        );
                      await ref
                          .read(wkProfileViewmodelProvider.notifier)
                          .saveTimeOffDates(updated);
                    },
                  ),
                )
                .toList(growable: false),
          ),
          if (data.timeOffDates.isEmpty)
            Text(
              'No time-off dates.',
              style: AppTextStyles.body2.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _pickTimeRange(
    BuildContext context,
    WidgetRef ref,
    WkProfileData data,
    WkDayAvailability day,
  ) async {
    final start = await showTimePicker(
      context: context,
      initialTime: _parseTime(day.start),
    );
    if (start == null) return;

    final end = await showTimePicker(
      context: context,
      initialTime: _parseTime(day.end),
    );
    if (end == null) return;

    if (_toMinutes(start) >= _toMinutes(end)) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('End time must be later than start time.'),
        ),
      );
      return;
    }

    final updated = data.weeklyAvailability
        .map(
          (x) => x.day == day.day
              ? x.copyWith(start: _fmtTime(start), end: _fmtTime(end))
              : x,
        )
        .toList(growable: false);

    await ref
        .read(wkProfileViewmodelProvider.notifier)
        .saveWeeklyAvailability(updated);
  }

  Future<void> _addTimeOff(
    BuildContext context,
    WidgetRef ref,
    WkProfileData data,
  ) async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDate: DateTime.now(),
    );

    if (picked == null) return;

    final normalized = DateTime(picked.year, picked.month, picked.day);
    final exists = data.timeOffDates.any(
      (d) =>
          d.year == normalized.year &&
          d.month == normalized.month &&
          d.day == normalized.day,
    );
    if (exists) return;

    final updated = List<DateTime>.from(data.timeOffDates)..add(normalized);
    await ref
        .read(wkProfileViewmodelProvider.notifier)
        .saveTimeOffDates(updated);
  }

  TimeOfDay _parseTime(String hhmm) {
    final parts = hhmm.split(':');
    final h = int.tryParse(parts.first) ?? 8;
    final m = int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0;
    return TimeOfDay(hour: h, minute: m);
  }

  String _fmtTime(TimeOfDay t) {
    return '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
  }

  int _toMinutes(TimeOfDay t) => (t.hour * 60) + t.minute;
}

class _FinanceSection extends StatelessWidget {
  final WkProfileData data;

  const _FinanceSection({required this.data});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Finance & Performance', style: AppTextStyles.headline3),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.monetization_on_outlined,
                  color: AppColors.success,
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Monthly Earnings',
                      style: AppTextStyles.caption.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      _usd(data.monthlyEarningsUsd),
                      style: AppTextStyles.headline3.copyWith(
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(
              Icons.calendar_month_outlined,
              color: AppColors.primary,
            ),
            title: const Text('View Completed Bookings'),
            subtitle: Text('${data.incomeHistory.length} completed jobs'),
            trailing: Icon(Icons.chevron_right, color: scheme.onSurfaceVariant),
            onTap: () =>
                context.push('/wk-schedule?tab=bookings&status=completed'),
          ),
        ],
      ),
    );
  }

  String _usd(double value) {
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

class _ReviewsSection extends StatelessWidget {
  final WkProfileData data;

  const _ReviewsSection({required this.data});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('Customer Reviews', style: AppTextStyles.headline3),
              ),
              TextButton(
                onPressed: () => context.push('/wk-profile-reviews'),
                child: const Text('View all'),
              ),
            ],
          ),
          if (data.reviews.isEmpty)
            Text(
              'No reviews yet.',
              style: AppTextStyles.body2.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ...data.reviews
              .take(2)
              .map(
                (r) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    radius: 14,
                    backgroundColor: AppColors.warning.withValues(alpha: 0.12),
                    child: Text(
                      '${r.rating}',
                      style: AppTextStyles.caption.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  title: Text(r.comment.isNotEmpty ? r.comment : 'No comment'),
                  subtitle: Text(
                    '${r.createdAtUtc7.day.toString().padLeft(2, '0')}/${r.createdAtUtc7.month.toString().padLeft(2, '0')}/${r.createdAtUtc7.year}',
                  ),
                ),
              ),
        ],
      ),
    );
  }
}

class _SystemSection extends ConsumerWidget {
  final WkProfileData data;

  const _SystemSection({required this.data});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final scheme = Theme.of(context).colorScheme;

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('System & Support', style: AppTextStyles.headline3),
          const SizedBox(height: 10),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Notification Sound'),
            value: data.notificationSound,
            onChanged: (v) => ref
                .read(wkProfileViewmodelProvider.notifier)
                .saveNotificationPrefs(
                  sound: v,
                  vibration: data.notificationVibration,
                ),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Notification Vibration'),
            value: data.notificationVibration,
            onChanged: (v) => ref
                .read(wkProfileViewmodelProvider.notifier)
                .saveNotificationPrefs(
                  sound: data.notificationSound,
                  vibration: v,
                ),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.brightness_4_outlined, color: scheme.primary),
            title: const Text('Theme Mode'),
            trailing: DropdownButton<ThemeMode>(
              value: themeMode,
              underline: const SizedBox(),
              onChanged: (ThemeMode? newValue) {
                if (newValue != null) {
                  ref.read(themeModeProvider.notifier).setThemeMode(newValue);
                }
              },
              items: const [
                DropdownMenuItem(
                  value: ThemeMode.system,
                  child: Text('System'),
                ),
                DropdownMenuItem(value: ThemeMode.light, child: Text('Light')),
                DropdownMenuItem(value: ThemeMode.dark, child: Text('Dark')),
              ],
            ),
          ),
          const SizedBox(height: 8),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.support_agent_outlined),
            title: const Text('Support Center'),
            subtitle: const Text(
              'Contact admin if you have issues with the app.',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Support form will be connected next.'),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String value;
  final String label;

  const _Badge({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: scheme.surface.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.label.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;

  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final divider = Theme.of(context).dividerColor;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: divider),
      ),
      child: child,
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
          const Icon(Icons.error_outline, size: 44, color: AppColors.error),
          const SizedBox(height: 8),
          Text(
            'Unable to load worker profile.',
            style: AppTextStyles.body2.copyWith(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 10),
          ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
