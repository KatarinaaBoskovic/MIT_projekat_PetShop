import 'package:get/get.dart';
import 'package:petshop/controllers/auth_controller.dart';
import 'package:petshop/models/product.dart';
import 'package:petshop/models/wishlist_item.dart';
import 'package:petshop/services/wishlist_firestore_service.dart';

class WishlistController extends GetxController {
  final RxList<WishlistItem> _wishlistItems = <WishlistItem>[].obs;
  final RxBool _isLoading = false.obs;
  final RxBool _hasError = false.obs;
  final RxString _errorMessage = ''.obs;
  final RxInt _itemCount = 0.obs;

  // Get authenticated user ID
  String? get _userId {
    final authController = Get.find<AuthController>();
    return authController.user?.uid;
  }

  // Getters
  List<WishlistItem> get wishlistItems => _wishlistItems;
  bool get isLoading => _isLoading.value;
  bool get hasError => _hasError.value;
  String get errorMessage => _errorMessage.value;
  int get itemCount => _itemCount.value;
  bool get isEmpty => _wishlistItems.isEmpty;

  @override
  void onInit() {
    super.onInit();
    loadWishlistItems();
    _listenToAuthChanges();
  }

  // listen to authentication changes
  void _listenToAuthChanges() {
    final authController = Get.find<AuthController>();

    // listen to auth state changes
    ever(authController.isLoggedIn.obs, (bool isLoggedIn) {
      if (isLoggedIn) {
        // User signed in, load their wishlist
        loadWishlistItems();
      } else {
        // User signed out, clear wishlist
        _wishlistItems.clear();
        _itemCount.value = 0;
        update();
      }
    });
  }

  // Load wishlist items from Firestore
  Future<void> loadWishlistItems() async {
    _isLoading.value = true;
    _hasError.value = false;
   
    try {
      final userId = _userId;
      if (userId == null) {
        _wishlistItems.clear();
        _itemCount.value = 0;
        _hasError.value = true;
        _errorMessage.value = "Please sign in to view your wishlist";
        return;
      }

      final items = await WishlistFirestoreService.getUserWishlistItems(userId);

      _wishlistItems.value = items;
      _itemCount.value = items.length;
     update();
    } catch (e) {
      _hasError.value = true;
      _errorMessage.value = "Failed to load wishlist items. Please try again.";
      print('Error loading wishlist item: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  // Add product to wishlist
  Future<bool> addToWishlist(Product product) async {
    try {
      final userId = _userId;
      if (userId == null) {
        Get.snackbar(
          'Authentication Required',
          'Please sign in to add items to your wishlist',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );
        return false;
      }

      final success = await WishlistFirestoreService.addToWishlist(
        userId: userId,
        product: product,
      );

      if (success) {
        await loadWishlistItems(); // Refresh wishlist
        update();
        Get.snackbar(
          'Added to Wishlist',
          '${product.name} added to your wishlist',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );
      } else {
        Get.snackbar(
          'Error',
          'Failed to add item to wishlist',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );
      }

      return success;
    } catch (e) {
      print('Error adding to wishlist: $e');
      Get.snackbar(
        'Error',
        'Failed to add item to wishlist',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
      return false;
    }
  }

  // Remove product from wishlist
  Future<bool> removeFromWishlist(String productId) async {
    try {
      final userId = _userId;
      if (userId == null) {
        Get.snackbar(
          'Authentication Required',
          'Please sign in to manage your wishlist',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );
        return false;
      }

      final success = await WishlistFirestoreService.removeFromWishlist(
        userId,
        productId,
      );

      if (success) {
        await loadWishlistItems(); // Refresh wishlist
        update();
        Get.snackbar(
          'Removed from Wishlist',
          'Item removed from your wishlist',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );
      }
      return success;
    } catch (e) {
      print('Error removing from wishlist: $e');
      return false;
    }
  }

  // Toggle product in wishlist
  
  Future<bool> toggleWishlist(Product product) async {
  try{
final userId = _userId;
if (userId == null) {
    Get.snackbar(
      'Authentication Required',
      'Please sign in to manage your wishlist',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
    return false;
  }
    final isInWishlist = isProductInWishlist(product.id);
    if(isInWishlist){
      _wishlistItems.removeWhere((item)=>item.productId==product.id);
      _itemCount.value=_wishlistItems.length;
      update();
      update(['wishlist_${product.id}']);

      final success=await removeFromWishlist(product.id);
      if(!success){
        await loadWishlistItems();
      }
      return success;
    }else{
      final tempItem=WishlistItem(id: 'temp_${DateTime.now().millisecondsSinceEpoch}', userId: userId, productId: product.id, product: product, addedAt: DateTime.now(),);
      _wishlistItems.insert(0, tempItem);
      _itemCount.value=_wishlistItems.length;
      update();
      update(['wishlist_${product.id}']);

      final success=await addToWishlist(product);
      if(!success){
        await loadWishlistItems();
      }
      return success;

    }
    }
  catch(e){
    print('Error toggling wishlist: $e');
    await loadWishlistItems();
    return false;
  }
  
  
}

  // Check if product is in wishlist
  bool isProductInWishlist(String productId) {
    return _wishlistItems.any((item) => item.productId == productId);
  }

  // Get wishlist item for product
  WishlistItem? getWishlistItem(String productId) {
    try {
      return _wishlistItems.firstWhere((item) => item.productId == productId);
    } catch (e) {
      return null;
    }
  }

  // Clear entire wishlist
  Future<bool> clearWishlist() async {
    try {
      final userId = _userId;
      if (userId == null) {
        Get.snackbar(
          'Authentication Required',
          'Please sign in to manage your wishlist',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );
        return false;
      }

      final success = await WishlistFirestoreService.clearUserWishlist(userId);

      if (success) {
        _wishlistItems.clear();
        _itemCount.value = 0;

        Get.snackbar(
          'Wishlist Cleared',
          'All items removed from wishlist',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );
      }

      return success;
    } catch (e) {
      print('Error clearing wishlist: $e');
      return false;
    }
  }

  // Refresh wishlist
Future<void> refreshWishlist() async {
  await loadWishlistItems();
}

// Get products from wishlist
List<Product> get wishlistProducts {
  return _wishlistItems.map((item) => item.product).toList();
}
}
