import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:petshop/controllers/cart_controller.dart';
import 'package:petshop/models/cart_item.dart';
import 'package:petshop/utils/app_textstyles.dart';
import 'package:petshop/view/checkout/screens/checkout_screen.dart';
import 'package:petshop/utils/app_image.dart';
import 'package:petshop/view/widgets/price_text.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(
            Icons.arrow_back_ios,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        title: Text(
          'My Cart',
          style: AppTextStyle.withColor(
            AppTextStyle.h3,
            isDark ? Colors.white : Colors.black,
          ),
        ),
      ),
      body: GetBuilder<CartController>(
        builder: (cartController) {
          if (cartController.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (cartController.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    cartController.errorMessage,
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => cartController.refreshCart(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (cartController.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Your cart is empty',
                    style: AppTextStyle.withColor(
                      AppTextStyle.h3,
                      Colors.grey[600]!,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add some products to your cart',
                    style: AppTextStyle.withColor(
                      AppTextStyle.bodyMedium,
                      Colors.grey[500]!,
                    ),
                  ),
                ],
              ),
            );
          }
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: cartController.cartItems.length,
                  itemBuilder: (context, index) =>
                      _buildCartItem(context, cartController.cartItems[index]),
                ),
              ),
              _buildCartSummary(context, cartController),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCartItem(BuildContext context, CartItem cartItem) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final product = cartItem.product;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
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
              left: Radius.circular(16),
            ),
            child: AppImage(
              product.imageUrl,
              width: 100,
              height: 100,
              fit: BoxFit.cover,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          cartItem.selectedSize != null &&
                                  cartItem.selectedSize!.isNotEmpty
                              ? '${product.name} (${cartItem.selectedSize})'
                              : product.name,
                          style: AppTextStyle.withColor(
                            AppTextStyle.bodyLarge,
                            Theme.of(context).textTheme.bodyLarge!.color!,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        onPressed: () =>
                            _showDeleteConformationDialog(context, cartItem),
                        icon: Icon(
                          Icons.delete_outline,
                          color: Colors.red[400],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            PriceText(
                              priceRsd: product.price.toDouble(),
                              style: AppTextStyle.withColor(
                                AppTextStyle.h3,
                                Theme.of(context).primaryColor,
                              ),
                            ),
                            if (product.oldPrice != null &&
                                product.oldPrice! > product.price) ...[
                              const SizedBox(height: 2),
                              PriceText(
                                priceRsd: product.oldPrice!.toDouble(),
                                style:
                                    AppTextStyle.withColor(
                                      AppTextStyle.bodySmall,
                                      Colors.grey[500]!,
                                    ).copyWith(
                                      decoration: TextDecoration.lineThrough,
                                    ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      Container(
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: cartItem.quantity > 1
                                  ? () => _updateQuantity(
                                      cartItem,
                                      cartItem.quantity - 1,
                                    )
                                  : null,
                              icon: Icon(
                                Icons.remove,
                                size: 20,
                                color: cartItem.quantity > 1
                                    ? Theme.of(context).primaryColor
                                    : Colors.grey,
                              ),
                            ),
                            Text(
                              '${cartItem.quantity}',
                              style: AppTextStyle.withColor(
                                AppTextStyle.bodyLarge,
                                Theme.of(context).primaryColor,
                              ),
                            ),
                            IconButton(
                              onPressed: cartItem.quantity < product.stock
                                  ? () => _updateQuantity(
                                      cartItem,
                                      cartItem.quantity + 1,
                                    )
                                  : null,
                              icon: Icon(
                                Icons.add,
                                size: 20,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ],
                        ),
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

  void _showDeleteConformationDialog(BuildContext context, CartItem cartItem) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Get.dialog(
      AlertDialog(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red[400]!.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.delete_outline,
                color: Colors.red[400],
                size: 32,
              ),
            ),

            const SizedBox(height: 8),
            Text(
              'Are you sure you want to remove "${cartItem.product.name}" from your cart?',
              textAlign: TextAlign.center,
              style: AppTextStyle.withColor(
                AppTextStyle.bodyMedium,
                isDark ? Colors.grey[400]! : Colors.grey[600]!,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(
                        color: isDark ? Colors.white70 : Colors.black12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: AppTextStyle.withColor(
                        AppTextStyle.bodyMedium,
                        Theme.of(context).textTheme.bodyLarge!.color!,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      final cartController = Get.find<CartController>();
                      cartController.removeFromCart(cartItem.id);
                      Get.back();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[400],
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Remove',
                      style: AppTextStyle.withColor(
                        AppTextStyle.bodyMedium,
                        Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      barrierColor: Colors.black54,
    );
  }

  // Update cart item quantity
  Future<void> _updateQuantity(CartItem cartItem, int newQuantity) async {
    final cartController = Get.find<CartController>();
    await cartController.updateQuantity(cartItem.id, newQuantity);
  }

  Widget _buildCartSummary(
    BuildContext context,
    CartController cartController,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total (${cartController.itemCount} items)',
                style: AppTextStyle.withColor(
                  AppTextStyle.bodyMedium,
                  Theme.of(context).textTheme.bodyLarge!.color!,
                ),
              ),
              PriceText(
                priceRsd: cartController.total.toDouble(),
                style: AppTextStyle.withColor(
                  AppTextStyle.h2,
                  Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Get.to(() => const CheckoutScreen()),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Proceed to Checkout',
                style: AppTextStyle.withColor(
                  AppTextStyle.buttonMedium,
                  Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
