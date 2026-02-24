import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:petshop/controllers/category_controller.dart';
import 'package:petshop/controllers/product_contoller.dart';
import 'package:petshop/utils/app_textstyles.dart';

class FilterBottomSheet {
  static void show(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final productController = Get.find<ProductController>();

    //local state for the filter sheet
    String selectedCategory = productController.selectedCategory;
    final minPriceController = TextEditingController(
      text: productController.minPrice > 0
          ? productController.minPrice.toString()
          : '',
    );
    final maxPriceController = TextEditingController(
      text: productController.maxPrice < double.infinity
          ? productController.maxPrice.toString()
          : '',
    );

    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Container(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Filter Products',
                      style: AppTextStyle.withColor(
                        AppTextStyle.h3,
                        Theme.of(context).textTheme.bodyLarge!.color!,
                      ),
                    ),
            
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: Icon(
                        Icons.close,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  'Price Range',
                  style: AppTextStyle.withColor(
                    AppTextStyle.bodyLarge,
                    Theme.of(context).textTheme.bodyLarge!.color!,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: minPriceController,
                        decoration: InputDecoration(
                          hintText: 'Min',
                          prefixText: 'RSD ',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: isDark
                                  ? Colors.grey[700]!
                                  : Colors.grey[300]!,
                            ),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 16),
            
                    Expanded(
                      child: TextField(
                        controller: maxPriceController,
                        decoration: InputDecoration(
                          hintText: 'Max',
                          prefixText: 'RSD ',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: isDark
                                  ? Colors.grey[700]!
                                  : Colors.grey[300]!,
                            ),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
            
                Text(
                  'Categories',
                  style: AppTextStyle.withColor(
                    AppTextStyle.bodyLarge,
                    Theme.of(context).textTheme.bodyLarge!.color!,
                  ),
                ),
            
                const SizedBox(height: 16),
                GetBuilder<CategoryController>(
                  builder: (categoryController) {
                    if (categoryController.isLoading) {
                      return const SizedBox(
                        height: 50,
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
            
                    if (categoryController.hasError) {
                      return SizedBox(
                        height: 50,
                        child: Center(
                          child: Text(
                            'Failed to load categories',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ),
                      );
                    }
            
                    final categories = categoryController.categoryNames;
            
                    return Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: categories
                          .map(
                            (category) => FilterChip(
                              label: Text(category),
                              selected: category == selectedCategory,
                              onSelected: (selected) {
                                if (selected) {
                                  if (selected) {
                                    setState(() {
                                      selectedCategory = category;
                                    });
                                  }
                                }
                              },
                              backgroundColor: Theme.of(context).cardColor,
                              selectedColor: Theme.of(
                                context,
                              ).primaryColor.withValues(alpha: 0.2),
                              labelStyle: AppTextStyle.withColor(
                                AppTextStyle.bodyMedium,
                                category == selectedCategory
                                    ? Theme.of(context).primaryColor
                                    : Theme.of(
                                        context,
                                      ).textTheme.bodyLarge!.color!,
                              ),
                            ),
                          )
                          .toList(),
                    );
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Apply filters
                      double minPrice = 0.0;
                      double maxPrice = double.infinity;
            
                      if (minPriceController.text.isNotEmpty) {
                        minPrice =
                            double.tryParse(minPriceController.text) ?? 0.0;
                      }
            
                      if (maxPriceController.text.isNotEmpty) {
                        maxPrice =
                            double.tryParse(maxPriceController.text) ??
                            double.infinity;
                      }
                      //apply category filters
                      productController.filterByCategory(selectedCategory);
                      //apply price filter
                      productController.setPriceRange(minPrice, maxPrice);
                      Get.back();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Apply Filters',
                      style: AppTextStyle.withColor(
                        AppTextStyle.buttonMedium,
                        Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        selectedCategory = '';
                        minPriceController.clear();
                        maxPriceController.clear();
                      });
                      productController.resetFilters();
                      Get.back();
                    },
                    child: Text(
                      'Reset Filters',
                      style: AppTextStyle.withColor(
                        AppTextStyle.buttonMedium,
                        Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
