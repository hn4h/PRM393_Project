import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prm_project/core/theme/app_colors.dart';
import 'package:prm_project/core/theme/app_text_styles.dart';

import '../models/wk_schedule_models.dart';
import '../screens/wk_booking_details_screen.dart';
import '../viewmodels/wk_schedule_viewmodel.dart';
import '../widgets/wk_bookings_list.dart';
import '../widgets/wk_day_agenda.dart';
import '../widgets/wk_month_calendar.dart';

class WkScheduleScreen extends ConsumerStatefulWidget {
  final int initialTabIndex;
  final WkBookingsFilter? initialFilter;

  const WkScheduleScreen({
    super.key,
    this.initialTabIndex = 0,
    this.initialFilter,
  });

  @override
  ConsumerState<WkScheduleScreen> createState() => _WkScheduleScreenState();
}

class _WkScheduleScreenState extends ConsumerState<WkScheduleScreen> {
  bool _appliedInitialFilter = false;

  @override
  Widget build(BuildContext context) {
    final asyncState = ref.watch(wkScheduleViewModelProvider);
    final initialTab = widget.initialTabIndex < 0 || widget.initialTabIndex > 1
        ? 0
        : widget.initialTabIndex;

    return DefaultTabController(
      length: 2,
      initialIndex: initialTab,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Worker Schedule'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Schedule'),
              Tab(text: 'Bookings'),
            ],
          ),
        ),
        body: asyncState.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => _ErrorView(
            onRetry: () =>
                ref.read(wkScheduleViewModelProvider.notifier).refresh(),
          ),
          data: (state) {
            if (!_appliedInitialFilter && widget.initialFilter != null) {
              _appliedInitialFilter = true;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ref
                    .read(wkScheduleViewModelProvider.notifier)
                    .setFilter(widget.initialFilter!);
              });
            }

            return TabBarView(
              children: [
                RefreshIndicator(
                  onRefresh: () =>
                      ref.read(wkScheduleViewModelProvider.notifier).refresh(),
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    children: [
                      WkMonthCalendar(
                        focusedMonthUtc7: state.focusedMonthUtc7,
                        selectedDateUtc7: state.selectedDateUtc7,
                        bookings: state.bookings,
                        onPreviousMonth: () => ref
                            .read(wkScheduleViewModelProvider.notifier)
                            .previousMonth(),
                        onNextMonth: () => ref
                            .read(wkScheduleViewModelProvider.notifier)
                            .nextMonth(),
                        onSelectDate: (date) => ref
                            .read(wkScheduleViewModelProvider.notifier)
                            .selectDate(date),
                      ),
                      const SizedBox(height: 14),
                      WkDayAgenda(
                        selectedDateUtc7: state.selectedDateUtc7,
                        bookings: state.bookings,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _LegendDot(
                            color: AppColors.success,
                            label: 'Normal load',
                          ),
                          const SizedBox(width: 12),
                          _LegendDot(
                            color: AppColors.warning,
                            label: 'Fully booked',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                RefreshIndicator(
                  onRefresh: () =>
                      ref.read(wkScheduleViewModelProvider.notifier).refresh(),
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    children: [
                      WkBookingsList(
                        bookings: state.bookings,
                        activeFilter: state.activeFilter,
                        onFilterChanged: (WkBookingsFilter filter) {
                          ref
                              .read(wkScheduleViewModelProvider.notifier)
                              .setFilter(filter);
                        },
                        onOpenBooking: (booking) async {
                          final changed = await Navigator.of(context)
                              .push<bool>(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      WkBookingDetailsScreen(booking: booking),
                                ),
                              );

                          if (changed == true) {
                            await ref
                                .read(wkScheduleViewModelProvider.notifier)
                                .refresh();
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(color: scheme.onSurfaceVariant),
        ),
      ],
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
          const Icon(Icons.error_outline, color: AppColors.error, size: 42),
          const SizedBox(height: 8),
          Text(
            'Unable to load schedule data.',
            style: AppTextStyles.body2.copyWith(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
