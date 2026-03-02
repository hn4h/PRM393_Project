import 'package:flutter/material.dart';
import 'package:prm_project/core/models/category.dart';

class FilterBottomSheet extends StatefulWidget {
  final String initialCategoryId;
  final RangeValues initialPriceRange;
  final Function(String selectedCategory, RangeValues priceRange)
  onApplyFilters;

  const FilterBottomSheet({
    Key? key,
    required this.initialCategoryId,
    required this.initialPriceRange,
    required this.onApplyFilters,
  }) : super(key: key);

  @override
  _FilterBottomSheetState createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late String _tempSelectedCategoryId;
  late RangeValues _tempPriceRange;

  // Controller cho ô nhập liệu Min/Max
  final TextEditingController _minController = TextEditingController();
  final TextEditingController _maxController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tempSelectedCategoryId = widget.initialCategoryId;
    _tempPriceRange = widget.initialPriceRange;
    _updateTextFields();
  }

  void _updateTextFields() {
    _minController.text = _tempPriceRange.start.round().toString();
    _maxController.text = _tempPriceRange.end.round().toString();
  }

  @override
  void dispose() {
    _minController.dispose();
    _maxController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      // Đảm bảo không bị che khi bật bàn phím
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 1. Header (Nút Close + Title)
            Stack(
              alignment: Alignment.center,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: InkWell(
                    onTap: () => Navigator.pop(context),
                    child: const Text(
                      "Close",
                      style: TextStyle(color: Colors.black87, fontSize: 16),
                    ),
                  ),
                ),
                const Text(
                  "Filters",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 2. Categories Wrap
            const Text(
              "Categories",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _buildSheetCategoryChip('All', 'All'),
                // Gắn danh sách category từ data của bạn
                ...demoCategories.map(
                  (cat) => _buildSheetCategoryChip(cat.name, cat.id),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 3. Price Range Slider
            const Text(
              "Price Range",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            RangeSlider(
              values: _tempPriceRange,
              min: 0,
              max: 1000,
              activeColor: Colors.lightBlue,
              inactiveColor: Colors.grey.shade200,
              onChanged: (values) {
                setState(() {
                  _tempPriceRange = values;
                  _updateTextFields();
                });
              },
            ),

            // 4. Min / Max Price TextFields
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Min Price",
                        style: TextStyle(color: Colors.black87),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _minController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                        ),
                        onSubmitted: (val) {
                          double? newMin = double.tryParse(val);
                          if (newMin != null && newMin <= _tempPriceRange.end) {
                            setState(
                              () => _tempPriceRange = RangeValues(
                                newMin,
                                _tempPriceRange.end,
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Max Price",
                        style: TextStyle(color: Colors.black87),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _maxController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                        ),
                        onSubmitted: (val) {
                          double? newMax = double.tryParse(val);
                          if (newMax != null &&
                              newMax >= _tempPriceRange.start) {
                            setState(
                              () => _tempPriceRange = RangeValues(
                                _tempPriceRange.start,
                                newMax,
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),

            // 5. Buttons (Reset & Apply)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _tempSelectedCategoryId = 'All';
                        _tempPriceRange = const RangeValues(0, 1000);
                        _updateTextFields();
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                    child: const Text(
                      "Reset",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onApplyFilters(
                        _tempSelectedCategoryId,
                        _tempPriceRange,
                      );
                      Navigator.pop(context); // Đóng bottom sheet
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightBlue,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      "Apply Filters",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Widget nội bộ tạo Chip trong Bottom Sheet
  Widget _buildSheetCategoryChip(String label, String id) {
    bool isSelected = _tempSelectedCategoryId == id;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() => _tempSelectedCategoryId = id);
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
    );
  }
}
