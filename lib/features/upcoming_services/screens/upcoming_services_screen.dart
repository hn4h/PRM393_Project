import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import '../viewmodel/upcoming_services_viewmodel.dart';
import '../widgets/upcoming_service_card.dart';

class UpcomingServicesScreen extends ConsumerStatefulWidget {
  const UpcomingServicesScreen({super.key});

  @override
  ConsumerState<UpcomingServicesScreen> createState() =>
      _UpcomingServicesScreenState();
}

class _UpcomingServicesScreenState extends ConsumerState<UpcomingServicesScreen>
    with WidgetsBindingObserver {
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Auto-refresh every minute
    _refreshTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      ref.read(upcomingServicesViewModelProvider.notifier).refresh();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Refresh when app comes back to foreground
      ref.read(upcomingServicesViewModelProvider.notifier).refresh();
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final colorScheme = Theme.of(context).colorScheme;
        final asyncState = ref.watch(upcomingServicesViewModelProvider);

        return asyncState.when(
          loading: () => Scaffold(
            appBar: AppBar(
              title: const Text('Upcoming Services'),
              elevation: 0,
              centerTitle: false,
            ),
            body: const Center(child: CircularProgressIndicator()),
          ),
          error: (err, _) => Scaffold(
            appBar: AppBar(
              title: const Text('Upcoming Services'),
              elevation: 0,
              centerTitle: false,
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: colorScheme.error),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading services',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    err.toString(),
                    style: TextStyle(
                      fontSize: 14,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      ref
                          .read(upcomingServicesViewModelProvider.notifier)
                          .refresh();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
          data: (state) => Scaffold(
            appBar: AppBar(
              title: const Text('Upcoming Services'),
              elevation: 0,
              centerTitle: false,
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () {
                    ref
                        .read(upcomingServicesViewModelProvider.notifier)
                        .refresh();
                  },
                ),
              ],
            ),
            body: state.bookings.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 80,
                          color: colorScheme.onSurfaceVariant.withOpacity(0.5),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'No Upcoming Services',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'You don\'t have any accepted bookings yet',
                          style: TextStyle(
                            fontSize: 14,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () => context.goNamed('home'),
                          icon: const Icon(Icons.add),
                          label: const Text('Book a Service'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF008DDA),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () => ref
                        .read(upcomingServicesViewModelProvider.notifier)
                        .refresh(),
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: state.bookings.length,
                      itemBuilder: (context, index) {
                        final booking = state.bookings[index];
                        return UpcomingServiceCard(
                          booking: booking,
                          onTap: () {
                            context.pushNamed(
                              'booking-history-detail',
                              extra: booking,
                            );
                          },
                        );
                      },
                    ),
                  ),
          ),
        );
      },
    );
  }
}
