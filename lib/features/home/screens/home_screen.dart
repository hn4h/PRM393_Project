import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:prm_project/core/models/service.dart';
import 'package:prm_project/core/models/worker.dart';
import 'package:prm_project/features/home/widgets/header.dart';
import 'package:prm_project/features/home/widgets/popular-service-card.dart';
import 'package:prm_project/features/home/widgets/search-bar.dart';
import 'package:prm_project/features/home/widgets/section-header.dart';
import 'package:prm_project/features/home/widgets/service_title.dart';
import 'package:prm_project/features/home/widgets/worker_card.dart';

/// Home tab content — KHÔNG chứa BottomNavigationBar (đã tách ra MainShell)
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Plumbing', 'Electrical', 'Cleaning'];

  Widget _buildCategoryMenu() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildCategoryItem(Icons.ac_unit, 'AC Repair'),
        _buildCategoryItem(Icons.kitchen, 'Appliance'),
        _buildCategoryItem(Icons.face_retouching_natural, 'Beauty'),
        _buildCategoryItem(Icons.arrow_forward, 'More', isMore: true),
      ],
    );
  }

  Widget _buildCategoryItem(IconData icon, String label, {bool isMore = false}) {
    return Column(
      children: [
        Icon(icon, color: isMore ? Colors.blue : Colors.blue.shade400, size: 36),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredServices = _selectedFilter == 'All'
        ? demoServices
        : demoServices.where((s) => s.categoryId == _selectedFilter).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const HomeHeader(),
                const SizedBox(height: 24),
                const Text(
                  'What service do you need?',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                const CustomSearchBar(),
                const SizedBox(height: 24),
                _buildCategoryMenu(),
                const SizedBox(height: 32),

                SectionHeader(
                  title: 'Popular Services',
                  onTap: () => context.push('/service-discover'),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 270,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: demoServices.length,
                    itemBuilder: (context, index) =>
                        PopularServiceCard(service: demoServices[index]),
                  ),
                ),
                const SizedBox(height: 32),

                SectionHeader(title: 'Top Rated Workers', onTap: () {}),
                const SizedBox(height: 16),
                SizedBox(
                  height: 290,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: demoWorkers.length,
                    itemBuilder: (context, index) =>
                        WorkerCard(worker: demoWorkers[index]),
                  ),
                ),
                const SizedBox(height: 32),

                SectionHeader(
                  title: 'Other Services',
                  onTap: () => context.push('/service-discover'),
                ),
                const SizedBox(height: 16),

                // Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _filters.map((filter) {
                      final isSelected = _selectedFilter == filter;
                      return Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: ChoiceChip(
                          label: Text(filter),
                          selected: isSelected,
                          onSelected: (_) =>
                              setState(() => _selectedFilter = filter),
                          backgroundColor: Colors.white,
                          selectedColor: Colors.blue.shade50,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.blue : Colors.black87,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: isSelected
                                  ? Colors.blue
                                  : Colors.grey.shade300,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 16),

                // Other Services List
                ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: filteredServices.length,
                  itemBuilder: (context, index) =>
                      OtherServiceTile(service: filteredServices[index]),
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
