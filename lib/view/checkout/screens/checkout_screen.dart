import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:petshop/controllers/auth_controller.dart';
import 'package:petshop/controllers/cart_controller.dart';
import 'package:petshop/services/cart_firestore_service.dart';
import 'package:petshop/services/orders_firestore_service.dart';
import 'package:petshop/utils/app_textstyles.dart';
import 'package:petshop/view/checkout/widgets/address_card.dart';
import 'package:petshop/view/checkout/widgets/checkout_bottom_bar.dart';
import 'package:petshop/view/checkout/widgets/order_summary_card.dart';
import 'package:petshop/view/checkout/widgets/payment_method_card.dart';
import 'package:petshop/view/order_confirmation/screens/order_confirmation_screen.dart';

class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

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
          'Checkout',
          style: AppTextStyle.withColor(
            AppTextStyle.h3,
            isDark ? Colors.white : Colors.black,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTile(context, 'Shipping Address'),
            const SizedBox(height: 16),
            const AddressCard(),
            const SizedBox(height: 24),
            _buildSectionTile(context, 'Payment Method'),
            const SizedBox(height: 16),
            const PaymentMethodCard(),
            const SizedBox(height: 24),
            _buildSectionTile(context, 'Order Summary'),
            const SizedBox(height: 16),
            const OrderSummaryCard(),
          ],
        ),
      ),
      bottomNavigationBar: GetBuilder<CartController>(
        builder: (cart) {
          return CheckoutBottomBar(
            totalAmount: cart.total,
            onPlaceOrder: () async {
              final auth = Get.find<AuthController>();
              final userId = auth.user?.uid;
              final totalBeforeClear = cart.total;
              final email = auth.user?.email;
              if (userId == null || email == null) {
                Get.snackbar('Error', 'Missing user data');
                return;
              }

              if (cart.cartItems.isEmpty) {
                Get.snackbar(
                  'Cart is empty',
                  'Add products to your cart first',
                );
                return;
              }

              try {
                final orderId =
                    await OrdersFirestoreService.createOrderFromCart(
                      userId: userId,
                      userEmail: email,
                      cartItems: cart.cartItems,
                      subtotal: cart.subtotal,
                      savings: cart.savings,
                      shipping: cart.shipping,
                      total: cart.total,
                      // shippingAddress: ??? (kad povežem AddressCard)
                    );

                await CartFirestoreService.clearUserCart(userId);
                await cart.loadCartItems();

                Get.off(
                  () => OrderConfirmationScreen(
                    orderNumber: orderId,
                    totalAmount: totalBeforeClear,
                  ),
                );
              } catch (e) {
                debugPrint('PLACE ORDER ERROR: $e');
                Get.snackbar('Error', e.toString());
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildSectionTile(BuildContext context, String title) {
    return Text(
      title,
      style: AppTextStyle.withColor(
        AppTextStyle.h3,
        Theme.of(context).textTheme.bodyLarge!.color!,
      ),
    );
  }
}
