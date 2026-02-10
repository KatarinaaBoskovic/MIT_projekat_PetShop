import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
      bottomNavigationBar: CheckoutBottomBar(
        totalAmount: 11529,
        onPlaceOrder: () {
          //generate a random order number(later from backend)
          final orderNumber =
              'ORD${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

          Get.to(() =>  OrderConfirmationScreen(
            orderNumber: orderNumber,
            totalAmount: 11529,
          ));
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
