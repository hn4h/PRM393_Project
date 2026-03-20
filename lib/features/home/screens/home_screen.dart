import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prm_project/features/home/viewmodels/home_viewmodel.dart';
import 'package:prm_project/features/home/widgets/header.dart';
import 'package:prm_project/features/home/widgets/popular-service-card.dart';
import 'package:prm_project/features/home/widgets/search-bar.dart';
import 'package:prm_project/features/home/widgets/section-header.dart';
import 'package:prm_project/features/home/widgets/worker_card.dart';

import 'all_services_screen.dart';
import 'all_workers_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final allServicesAsync = ref.watch(searchedServicesProvider);
    final topWorkersAsync = ref.watch(searchedWorkersProvider);

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
                CustomSearchBar(
                  onChanged: (value) {
                    ref.read(searchQueryProvider.notifier).state = value;
                  },
                ),
                const SizedBox(height: 24),
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
                                PopularServiceCard(service: services[index]),
                          ),
                  ),
                ),
                const SizedBox(height: 32),
                SectionHeader(
                  title: 'Top Rated Workers',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const AllWorkersScreen(),
                    ),
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
