import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:petshop/controllers/cart_controller.dart';
import 'package:petshop/controllers/wishlist_controller.dart';
import 'package:petshop/models/product.dart';
import 'package:petshop/utils/app_textstyles.dart';
import 'package:petshop/utils/app_image.dart';
import 'package:petshop/view/cart_screen.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'My Wishlist',
          style: AppTextStyle.withColor(
            AppTextStyle.h3,
            isDark ? Colors.white : Colors.black,
          ),
        ),
       
      ),
      body: GetBuilder<WishlistController>(
        builder: (wishlistController) {
          if (wishlistController.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (wishlistController.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    wishlistController.errorMessage,
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => wishlistController.refreshWishlist(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (wishlistController.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Your wishlist is empty',
                    style: AppTextStyle.withColor(
                      AppTextStyle.h3,
                      Colors.grey[500]!,
                    ),
                  ),
                ],
              ),
            );
          }
          return CustomScrollView(
            slivers: [
              //summary section
              SliverToBoxAdapter(
                child: _buildSummarySection(
                  context,
                  wishlistController.itemCount,
                ),
              ),
              //wishlist items
              SliverPadding(
                padding: const EdgeInsets.all(14),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildWishItem(
                      context,
                      wishlistController.wishlistProducts[index],
                    ),
                    childCount: wishlistController.wishlistProducts.length,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSummarySection(BuildContext context, int itemCount) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.grey[100],
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$itemCount Items',
                style: AppTextStyle.withColor(
                  AppTextStyle.h2,
                  Theme.of(context).textTheme.bodyLarge!.color!,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'in your wishlist',
                style: AppTextStyle.withColor(
                  AppTextStyle.bodyMedium,
                  isDark ? Colors.grey[400]! : Colors.grey[600]!,
                ),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: () => _addAllToCart(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Add All to Cart',
              style: AppTextStyle.withColor(
                AppTextStyle.buttonMedium,
                Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Add all wishlist items to cart
 Future<void> _addAllToCart() async {
  final wishlistController = Get.find<WishlistController>();
  final cartController = Get.find<CartController>();

  if (wishlistController.isEmpty) {
    Get.snackbar(
      'Empty Wishlist',
      'Your wishlist is empty',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
    return;
  }

  final confirmed = await _showAddAllConfirmationDialog();
  if (!confirmed) return;

  Get.dialog(
    const PopScope(
      canPop: false,
      child: Center(child: CircularProgressIndicator()),
    ),
    barrierDismissible: false,
  );

  int successCount = 0;
  int failureCount = 0;
  final failedProducts = <String>[];

  //KOPIJA liste (da ne puca iteracija)
  final items = List.of(wishlistController.wishlistItems);

  //  skuplja šta treba obrisati, a briše tek na kraju
  final idsToRemove = <String>[];

  try {
    for (final wishlistItem in items) {
      final product = wishlistItem.product;

      final availableSizes = _getProductSizes(product);
      final String? selectedSize =
          availableSizes.isNotEmpty ? availableSizes.first : null;

      try {
        final success = await cartController.addToCart(
          product: product,
          quantity: 1,
          selectedSize: selectedSize,
          showNotification: false,
        );

        if (success == true) {
          successCount++;
          idsToRemove.add(product.id); 
        } else {
          failureCount++;
          failedProducts.add(product.name);
        }
      } catch (e) {
        failureCount++;
        failedProducts.add(product.name);
        debugPrint('Error adding ${product.name} to cart: $e');
      }
    }
  } finally {
    
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
  }


  for (final id in idsToRemove) {
    wishlistController.removeFromWishlist(id);
  }

  await Future.delayed(const Duration(milliseconds: 150));

  if (successCount > 0 && failureCount == 0) {
    Get.snackbar(
      'Success!',
      '$successCount items added to cart',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );

   Get.to(() => const CartScreen());

  } else if (successCount > 0 && failureCount > 0) {
    Get.snackbar(
      'Partially Added',
      '$successCount items added, $failureCount failed',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
      backgroundColor: Colors.orange,
      colorText: Colors.white,
    );

   

  } else {
    Get.snackbar(
      'Failed',
      'Failed to add items to cart. Please try again.',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }
}
  // show confirmation dialog for adding all items to cart
  Future<bool> _showAddAllConfirmationDialog() async {
    final wishlistController = Get.find<WishlistController>();
    final itemCount = wishlistController.itemCount;

    return await Get.dialog<bool>(
          AlertDialog(
            backgroundColor: Theme.of(Get.context!).cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              'Add All to Cart',
              style: AppTextStyle.withColor(
                AppTextStyle.h3,
                Theme.of(Get.context!).textTheme.headlineMedium!.color!,
              ),
            ),
            content: Text(
              'Add all $itemCount items from your wishlist to cart?\n\nProducts with sizes will use the first available size',
              style: AppTextStyle.withColor(
                AppTextStyle.bodyMedium,
                Theme.of(Get.context!).textTheme.bodyMedium!.color!,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: Text(
                  'Cancel',
                  style: AppTextStyle.withColor(
                    AppTextStyle.buttonMedium,
                    Colors.grey[600]!,
                  ),
                ),
              ),
              ElevatedButton(onPressed: ()=>Get.back(result: true), 
              style:ElevatedButton.styleFrom(
                backgroundColor: Theme.of(Get.context!).primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ) ,
              child: Text('Add All',
              style: AppTextStyle.withColor(
                    AppTextStyle.buttonMedium,
                    Colors.white,
                  ),
              ),),
            ],
          ),
        ) ??
        false;
  }

  // Get available sizes for a product
  List<String> _getProductSizes(Product product) {
    if (product.specifications.containsKey('sizes')) {
      final sizes = product.specifications['sizes'];
      if (sizes is List) {
        return sizes.cast<String>();
      }
    }
    return [];
  }

  Widget _buildWishItem(BuildContext context, Product product) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.2)
                : Colors.grey.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          //product image
          ClipRRect(
            borderRadius: const BorderRadius.horizontal(
              left: Radius.circular(12),
            ),
            child: AppImage(
              product.imageUrl,
              width: 120,
              height: 120,
              fit: BoxFit.cover,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyle.withColor(
                      AppTextStyle.bodyLarge,
                      Theme.of(context).textTheme.bodyLarge!.color!,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.category,
                    style: AppTextStyle.withColor(
                      AppTextStyle.bodySmall,
                      isDark ? Colors.grey[400]! : Colors.grey[600]!,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '${product.price.toStringAsFixed(0)} RSD',
                          maxLines: 1,
                          style: AppTextStyle.withColor(
                            AppTextStyle.h3,
                            Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.shopping_cart_outlined),
                            onPressed: () => _addToCartFromWishlist(product),
                            color: Theme.of(context).primaryColor,
                          ),

                          IconButton(
                            icon: Icon(Icons.delete_outline),
                            onPressed: () =>
                                _showDeleteConfirmationDialog(context, product),
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Add product to cart from wishlist
  Future<void> _addToCartFromWishlist(Product product) async {
  final cartController = Get.find<CartController>();
  final wishlistController = Get.find<WishlistController>();

  // Check if product has sizes and requires selection
  if (product.specifications.containsKey('sizes')) {
    final sizes = product.specifications['sizes'];
    if (sizes is List && sizes.isNotEmpty) {
      _showSizeSelectionDialog(product, cartController); // dialog će obrisati posle add
      return;
    }
  }

  final success = await cartController.addToCart(product: product, quantity: 1);

  //  ako je dodat u cart, skloni iz wishlist-e
  if (success == true) {
    wishlistController.removeFromWishlist(product.id);
  }
}

  // show size selection dialog for adding to cart
  void _showSizeSelectionDialog(
    Product product,
    CartController cartController,
  ) {
    final isDark = Theme.of(Get.context!).brightness == Brightness.dark;
    final sizes = List<String>.from(product.specifications['sizes'] ?? []);

    showDialog(
      context: Get.context!,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Select Size',
            style: AppTextStyle.withColor(
              AppTextStyle.h3,
              Theme.of(context).textTheme.headlineMedium!.color!,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Choose a size for "${product.name}"',
                style: AppTextStyle.withColor(
                  AppTextStyle.bodyMedium,
                  Theme.of(context).textTheme.bodyMedium!.color!,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                children: sizes.map((size) {
                  return ElevatedButton(
                    onPressed: () async {
                      Get.back();
                       final success = await cartController.addToCart(
    product: product,
    quantity: 1,
    selectedSize: size,
  );
  if (success == true) {
    Get.find<WishlistController>().removeFromWishlist(product.id);
  }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      size,
                      style: AppTextStyle.withColor(
                        AppTextStyle.buttonMedium,
                        Colors.white,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text(
                'Cancel',
                style: AppTextStyle.withColor(
                  AppTextStyle.buttonMedium,
                  isDark ? Colors.grey[400]! : Colors.grey[600]!,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // show delete confirmation dialog
  void _showDeleteConfirmationDialog(BuildContext context, Product product) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Remove from wishlist',
            style: AppTextStyle.withColor(
              AppTextStyle.h3,
              Theme.of(context).textTheme.headlineMedium!.color!,
            ),
          ),
          content: Text(
            'Are you sure you want to remove "${product.name}" from your wishlist?',
            style: AppTextStyle.withColor(
              AppTextStyle.bodyMedium,
              Theme.of(context).textTheme.bodyMedium!.color!,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text(
                'Cancel',
                style: AppTextStyle.withColor(
                  AppTextStyle.buttonMedium,
                  isDark ? Colors.grey[400]! : Colors.grey[600]!,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final wishlistController = Get.find<WishlistController>();
                wishlistController.removeFromWishlist(product.id);
                Get.back();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Remove',
                style: AppTextStyle.withColor(
                  AppTextStyle.buttonMedium,
                  Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
