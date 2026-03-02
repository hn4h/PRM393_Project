import 'package:flutter/material.dart';
import 'package:prm_project/core/models/service.dart';
import 'package:prm_project/core/models/category.dart';
import 'package:prm_project/features/discover/widgets/discover_service_card.dart';
import 'package:prm_project/features/discover/widgets/filter_bottom_sheet.dart';

class DiscoverScreen extends StatefulWidget {
  DiscoverScreen({Key? key}) : super(key: key);

  @override
  _DiscoverScreenState createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  String _searchQuery = '';
  String _selectedCategoryId = 'All'; // 'All' hoặc id của Category
  RangeValues _priceRange = const RangeValues(0, 1000); // Giá mặc định

  // Hàm mở Bottom Sheet Filter
  void _openFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled:
          true, // Để bottom sheet có thể đẩy lên khi có bàn phím
      backgroundColor: Colors.transparent,
      builder: (context) {
        return FilterBottomSheet(
          initialCategoryId: _selectedCategoryId,
          initialPriceRange: _priceRange,
          onApplyFilters: (selectedCategory, priceRange) {
            setState(() {
              _selectedCategoryId = selectedCategory;
              _priceRange = priceRange;
            });
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredServices = demoServices.where((service) {
      final matchCategory =
          _selectedCategoryId == 'All' ||
          service.categoryId == _selectedCategoryId;
      final matchSearch = service.name.toLowerCase().contains(
        _searchQuery.toLowerCase(),
      );
      final matchPrice =
          service.price >= _priceRange.start &&
          service.price <= _priceRange.end;
      return matchCategory && matchSearch && matchPrice;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Discover',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt_outlined, color: Colors.black),
            onPressed: _openFilterBottomSheet,
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: "Search in services, workers, etc.",
                hintStyle: TextStyle(color: Colors.grey.shade500),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
              ),
            ),
          ),

          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              children: [
                _buildFilterChip('All', 'All'),
                ...demoCategories.map(
                  (cat) => _buildFilterChip(cat.name, cat.id),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: filteredServices.length,
              itemBuilder: (context, index) {
                return DiscoverServiceCard(service: filteredServices[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String id) {
    bool isSelected = _selectedCategoryId == id;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() => _selectedCategoryId = id);
        },
        backgroundColor: Colors.white,
        selectedColor: Colors.lightBlue,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected ? Colors.transparent : Colors.grey.shade300,
          ),
        ),
      ),
    );
  }
}
