import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prm_project/core/models/service.dart';

import '../viewmodels/home_viewmodel.dart';
import '../widgets/service_title.dart';

class AllServicesScreen extends ConsumerStatefulWidget {
  const AllServicesScreen({super.key});

  @override
  ConsumerState<AllServicesScreen> createState() => _AllServicesScreenState();
}

class _AllServicesScreenState extends ConsumerState<AllServicesScreen> {
  String _selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    final servicesAsync = ref.watch(activeServicesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('All Services')),
      body: servicesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (services) {
          final categories = _buildCategories(services);
          final filteredServices = _selectedCategory == 'All'
              ? services
              : services
                    .where((service) => service.categoryId == _selectedCategory)
                    .toList();

          return Column(
            children: [
              SizedBox(
                height: 58,
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    final isSelected = category == _selectedCategory;

                    return ChoiceChip(
                      label: Text(category),
                      selected: isSelected,
                      onSelected: (_) {
                        setState(() {
                          _selectedCategory = category;
                        });
                      },
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                      backgroundColor: const Color(0xFFF4F4F4),
                      selectedColor: const Color(0xFF2F80ED),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                        side: BorderSide(
                          color: isSelected
                              ? const Color(0xFF2F80ED)
                              : const Color(0xFFE5E7EB),
                        ),
                      ),
                      showCheckmark: false,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                    );
                  },
                ),
              ),
              Expanded(
                child: filteredServices.isEmpty
                    ? const Center(child: Text('No services in this category'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredServices.length,
                        itemBuilder: (context, index) => OtherServiceTile(
                          service: filteredServices[index],
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  List<String> _buildCategories(List<Service> services) {
    final categories = services
        .map((service) => service.categoryId.trim())
        .where((category) => category.isNotEmpty)
        .toSet()
        .toList()
      ..sort();

    return ['All', ...categories];
  }
}
