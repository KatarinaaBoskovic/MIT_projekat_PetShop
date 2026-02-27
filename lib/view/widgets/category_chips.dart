import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:petshop/controllers/category_controller.dart';
import 'package:petshop/controllers/product_contoller.dart';
import 'package:petshop/utils/app_textstyles.dart';

class CategoryChips extends StatefulWidget {
  const CategoryChips({super.key});

  @override
  State<CategoryChips> createState() => _CategoryChipsState();
}

class _CategoryChipsState extends State<CategoryChips> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GetBuilder<ProductController>(
      builder: (productController) {
        final categoryController = Get.find<CategoryController>();
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
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
            ),
          );
        }
        final categories = categoryController.getCategoriesWithFallback();

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: List.generate(
              categories.length,
              (index) => Padding(
                padding: EdgeInsets.only(right: 12),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: ChoiceChip(
                    label: Text(
                      categories[index],
                      style: AppTextStyle.withColor(
                        productController.selectedCategory == categories[index]
                            ? AppTextStyle.withWeight(
                                AppTextStyle.bodySmall,
                                FontWeight.w600,
                              )
                            : AppTextStyle.bodySmall,
                        productController.selectedCategory == categories[index]
                            ? Colors.white
                            : isDark
                            ? Colors.grey[300]!
                            : Colors.grey[600]!,
                      ),
                    ),
                    selected:
                        productController.selectedCategory == categories[index],
                    onSelected: (bool selected) {
                      if (selected) {
                        //update both controllers
                        categoryController.selectCategory(categories[index]);
                        productController.filterByCategory(categories[index]);
                      }
                    },
                    selectedColor: Theme.of(context).primaryColor,
                    backgroundColor: isDark
                        ? Colors.grey[800]
                        : Colors.grey[100],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation:
                        productController.selectedCategory == categories[index]
                        ? 2
                        : 0,
                    pressElevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    labelPadding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 1,
                    ),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    side: BorderSide(
                      color:
                          productController.selectedCategory ==
                              categories[index]
                          ? Colors.transparent
                          : isDark
                          ? Colors.grey[700]!
                          : Colors.grey[300]!,
                      width: 1,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
