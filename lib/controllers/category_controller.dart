// ignore_for_file: avoid_print

import 'package:get/get.dart';
import 'package:petshop/models/category.dart';
import 'package:petshop/services/category_firestore_service.dart';

class CategoryController extends GetxController {
  final RxList<Category> _categories = <Category>[].obs;
  final RxBool _isLoading = false.obs;
  final RxBool _hasError = false.obs;
  final RxString _errorMessage = ''.obs;
  final Rx<Category?> _selectedCategory = Rx<Category?>(null);

  // Getters
  List<Category> get categories => _categories;
  bool get isLoading => _isLoading.value;
  bool get hasError => _hasError.value;
  String get errorMessage => _errorMessage.value;
  Category? get selectedCategory => _selectedCategory.value;

  // Get categories for display (with "All" option)
  List<String> get categoryNames {
    final names = ['All'];
    names.addAll(_categories.map((category) => category.displayName));
    return names;
  }

  @override
  void onInit() {
    super.onInit();
    loadCategories();
  }
  // Load categories from Firestore
Future<void> loadCategories() async {
  _isLoading.value = true;
  _hasError.value = false;

  try {
    final categories =
        await CategoryFirestoreService.getAllCategories();
    _categories.value = categories;
  } catch (e) {
    _hasError.value = true;
    _errorMessage.value =
        "Failed to load categories. Please try again.";
    print('Error loading categories: $e');

    // Clear categories on error
    _categories.value = [];
  } finally {
    _isLoading.value = false;
  }
}
// Select category
void selectCategory(String categoryName) {
  if (categoryName == "All") {
    _selectedCategory.value = null;
  } else {
    final category = _categories.firstWhereOrNull(
      (cat) =>
          cat.displayName == categoryName ||
          cat.name == categoryName,
    );
    _selectedCategory.value = category;
  }

  // Notify listeners that category selection changed
  update();
}

// Get category by name
Category? getCategoryByName(String categoryName) {
  return _categories.firstWhereOrNull(
    (cat) =>
        cat.displayName == categoryName ||
        cat.name == categoryName,
  );
}

// Get category by ID
Future<Category?> getCategoryById(String categoryId) async {
  try {
    return await CategoryFirestoreService.getCategoryById(categoryId);
  } catch (e) {
    print('Error getting category by ID: $e');
    return null;
  }
}

// Refresh categories
Future<void> refreshCategories() async {
  await loadCategories();
}

// Get selected category name
String get selectedCategoryName {
  return _selectedCategory.value?.displayName ?? 'All';
}

// Check if category is selected
bool isCategorySelected(String categoryName) {
  if (categoryName == 'All') {
    return _selectedCategory.value == null;
  }

  return _selectedCategory.value?.displayName == categoryName ||
      _selectedCategory.value?.name == categoryName;
}

// Get currently selected category name for display
String get selectedCategoryDisplayName {
  return _selectedCategory.value?.displayName ?? 'All';
}

// Get categories with fallback
List<String> getCategoriesWithFallback() {
  if (_categories.isNotEmpty) {
    return categoryNames;
  } else {
    // fallback categories if Firestore is empty or loading
    return [
     'All',
  'Food',
  'Care',
  'Equipment',
  'Clothes',
  'Toys',
  'Health'
    ];
  }
}
}