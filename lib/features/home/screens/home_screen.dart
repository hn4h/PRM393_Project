import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:prm_project/features/home/viewmodels/home_viewmodel.dart';
import 'package:prm_project/features/home/widgets/header.dart';
import 'package:prm_project/features/home/widgets/search-bar.dart';
import 'package:prm_project/features/home/widgets/section-header.dart';
import 'package:prm_project/features/home/widgets/service_card.dart';
import 'package:prm_project/features/home/widgets/worker_card.dart';
import 'package:prm_project/features/review/models/review_list_args.dart';
import 'package:prm_project/features/review/viewmodels/review_viewmodel.dart';
import 'package:prm_project/features/review/widgets/review_section.dart'
    as review_feature;

import 'all_services_screen.dart';
import 'all_workers_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final allServicesAsync = ref.watch(searchedServicesProvider);
    final topWorkersAsync = ref.watch(searchedWorkersProvider);
    final latestReviewsAsync = ref.watch(latestReviewsProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const HomeHeader(),
                const SizedBox(height: 16),
                _buildCalendarPromoBanner(context),
                const SizedBox(height: 24),
                Text(
                  'What service do you need?',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                CustomSearchBar(
                  hintText: 'Search services or workers',
                  onChanged: (value) {
                    ref.read(homeSearchQueryProvider.notifier).setQuery(value);
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 52,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _buildHighlightChip(
                        context,
                        icon: Icons.home_repair_service_outlined,
                        label: 'Home Repair',
                        accentColor: const Color(0xFF2F80ED),
                      ),
                      _buildHighlightChip(
                        context,
                        icon: Icons.flash_on_outlined,
                        label: 'Fast Support',
                        accentColor: const Color(0xFFF2994A),
                      ),
                      _buildHighlightChip(
                        context,
                        icon: Icons.verified_outlined,
                        label: 'Trusted Service',
                        accentColor: const Color(0xFF6C63FF),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                SectionHeader(
                  title: 'Popular Services',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const AllServicesScreen(),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                allServicesAsync.when(
                  loading: () => const SizedBox(
                    height: 270,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (err, _) => SizedBox(
                    height: 270,
                    child: Center(child: Text('Error: $err')),
                  ),
                  data: (services) => SizedBox(
                    height: 270,
                    child: services.isEmpty
                        ? const Center(child: Text('No services available'))
                        : ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: services.length,
                            itemBuilder: (context, index) =>
                                ServiceCard(service: services[index]),
                          ),
                  ),
                ),
                const SizedBox(height: 32),
                SectionHeader(
                  title: 'Top Rated Workers',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AllWorkersScreen()),
                  ),
                ),
                const SizedBox(height: 16),
                topWorkersAsync.when(
                  loading: () => const SizedBox(
                    height: 290,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (err, _) => SizedBox(
                    height: 290,
                    child: Center(child: Text('Error: $err')),
                  ),
                  data: (workers) => SizedBox(
                    height: 290,
                    child: workers.isEmpty
                        ? const Center(child: Text('No workers available'))
                        : ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: workers.length,
                            itemBuilder: (context, index) =>
                                WorkerCard(worker: workers[index]),
                          ),
                  ),
                ),
                const SizedBox(height: 32),
                latestReviewsAsync.when(
                  loading: () => const SizedBox(
                    height: 220,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (err, _) => SizedBox(
                    height: 220,
                    child: Center(child: Text('Error: $err')),
                  ),
                  data: (reviews) => review_feature.ReviewSection(
                    title: 'Latest Reviews',
                    reviews: reviews,
                    onSeeAll: () {
                      context.pushNamed(
                        'reviews',
                        extra: ReviewListArgs(
                          title: 'All Reviews',
                          reviews: reviews,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHighlightChip(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color accentColor,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: accentColor, size: 16),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarPromoBanner(BuildContext context) {
    return GestureDetector(
      onTap: () => context.pushNamed('upcoming-services'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF008DDA).withOpacity(0.9),
              const Color(0xFF0066B2).withOpacity(0.9),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF008DDA).withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.calendar_month,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'View Your Schedule',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Check your upcoming bookings',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.85),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.white.withOpacity(0.7),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
