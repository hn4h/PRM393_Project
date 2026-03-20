import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:prm_project/features/home/viewmodels/home_viewmodel.dart';
import 'package:prm_project/features/home/widgets/header.dart';
import 'package:prm_project/features/home/widgets/popular-service-card.dart';
import 'package:prm_project/features/home/widgets/search-bar.dart';
import 'package:prm_project/features/home/widgets/section-header.dart';
import 'package:prm_project/features/home/widgets/service_title.dart';
import 'package:prm_project/features/home/widgets/worker_card.dart';

/// Home tab content — fetches real data from Supabase via Riverpod
class HomeScreen extends ConsumerWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final allServicesAsync = ref.watch(activeServicesProvider);
    final filteredAsync = ref.watch(filteredServicesProvider);
    final topWorkersAsync = ref.watch(topRatedWorkersProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);

    final filters = [
      'All',
      'Cleaning',
      'Plumbing',
      'Electrical',
      'Painting',
      'AC Repair',
      'Appliance',
    ];

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const HomeHeader(),
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
                const CustomSearchBar(),
                const SizedBox(height: 24),

                // ── Category Quick Menu ─────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildCategoryItem(context, Icons.ac_unit, 'AC Repair'),
                    _buildCategoryItem(context, Icons.kitchen, 'Appliance'),
                    _buildCategoryItem(
                      context,
                      Icons.cleaning_services,
                      'Cleaning',
                    ),
                    _buildCategoryItem(
                      context,
                      Icons.arrow_forward,
                      'More',
                      isMore: true,
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // ── Popular Services (horizontal scroll) ────────
                SectionHeader(
                  title: 'Popular Services',
                  onTap: () => context.push('/service-discover'),
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
                                PopularServiceCard(service: services[index]),
                          ),
                  ),
                ),
                const SizedBox(height: 32),

                // ── Top Rated Workers ───────────────────────────
                SectionHeader(title: 'Top Rated Workers', onTap: () {}),
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

                // ── Other Services (filtered list) ──────────────
                SectionHeader(
                  title: 'Other Services',
                  onTap: () => context.push('/service-discover'),
                ),
                const SizedBox(height: 16),

                // Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: filters.map((filter) {
                      final isSelected = selectedCategory == filter;
                      return Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: ChoiceChip(
                          label: Text(filter),
                          selected: isSelected,
                          onSelected: (_) =>
                              ref
                                      .read(selectedCategoryProvider.notifier)
                                      .state =
                                  filter,
                          backgroundColor: colorScheme.surface,
                          selectedColor: Colors.blue.shade50,
                          labelStyle: TextStyle(
                            color: isSelected
                                ? Colors.blue
                                : colorScheme.onSurface,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: isSelected
                                  ? Colors.blue
                                  : Theme.of(context).dividerColor,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 16),

                // Filtered Service List
                filteredAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (err, _) => Center(child: Text('Error: $err')),
                  data: (services) => services.isEmpty
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32),
                            child: Text('No services in this category'),
                          ),
                        )
                      : ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: services.length,
                          itemBuilder: (context, index) =>
                              OtherServiceTile(service: services[index]),
                        ),
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryItem(
    BuildContext context,
    IconData icon,
    String label, {
    bool isMore = false,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: isMore ? Colors.blue : Colors.blue.shade400,
          size: 36,
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
