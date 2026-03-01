import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:petshop/controllers/address_controller.dart';
import 'package:petshop/controllers/auth_controller.dart';
import 'package:petshop/controllers/cart_controller.dart';
import 'package:petshop/controllers/currency_controller.dart';
import 'package:petshop/services/cart_firestore_service.dart';
import 'package:petshop/services/orders_firestore_service.dart';
import 'package:petshop/services/stripe_service.dart';
import 'package:petshop/utils/app_textstyles.dart';
import 'package:petshop/view/checkout/widgets/address_card.dart';
import 'package:petshop/view/checkout/widgets/checkout_bottom_bar.dart';
import 'package:petshop/view/checkout/widgets/order_summary_card.dart';
import 'package:petshop/view/checkout/widgets/payment_method_card.dart';
import 'package:petshop/view/shipping_address/models/address.dart'
    as my_address;
import 'package:petshop/view/order_confirmation/screens/order_confirmation_screen.dart';
import 'package:petshop/view/shipping_address/shipping_address_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final addressControllerField = TextEditingController();
  final cityController = TextEditingController();
  final zipController = TextEditingController();
  final labelController = TextEditingController(text: 'Home');

  @override
  void dispose() {
    addressControllerField.dispose();
    cityController.dispose();
    zipController.dispose();
    labelController.dispose();
    super.dispose();
  }

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
            Obx(() {
              final addressCtrl = Get.find<AddressController>();
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildSectionTile(context, 'Shipping Address'),
                  if (addressCtrl.addresses.isNotEmpty)
                    TextButton(
                      onPressed: () =>
                          Get.to(() => const ShippingAddressScreen()),
                      child: const Text(
                        "Change",
                        style: TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              );
            }),
            const SizedBox(height: 16),

            Obx(() {
              final addressCtrl = Get.find<AddressController>();

              if (addressCtrl.addresses.isEmpty) {
                return _buildInlineAddressForm(context);
              }

              final selectedAddress = addressCtrl.addresses.firstWhere(
                (a) => a.isDefault,
                orElse: () => addressCtrl.addresses.first,
              );

              return AddressCard(address: selectedAddress);
            }),
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
            onPlaceOrder: () => _handleOrderProcess(),
          );
        },
      ),
    );
  }

  // --- NOVA FORMA ZA DIREKTAN UNOS ---
  Widget _buildInlineAddressForm(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          TextField(
            controller: addressControllerField,
            decoration: const InputDecoration(
              labelText: "Street Address",
              prefixIcon: Icon(Icons.map),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: cityController,
                  decoration: const InputDecoration(labelText: "City"),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: zipController,
                  decoration: const InputDecoration(labelText: "ZIP Code"),
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- LOGIKA ZA PLAĆANJE I ČUVANJE ---
  Future<void> _handleOrderProcess() async {
    final auth = Get.find<AuthController>();
    final cart = Get.find<CartController>();
    final addressCtrl = Get.find<AddressController>();
    final currencyController = Get.find<CurrencyController>();

    final userId = auth.user?.uid;
    final email = auth.user?.email;

    if (userId == null || email == null || cart.cartItems.isEmpty) return;

    my_address.Address? finalAddress;

    // PROVERA I KREIRANJE ADRESE
    if (addressCtrl.addresses.isEmpty) {
      if (addressControllerField.text.isEmpty || cityController.text.isEmpty) {
        Get.snackbar(
          "Error",
          "Please fill in shipping details",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      // Kreiram objekat adrese
      finalAddress = my_address.Address(
        id: '', // Biće generisano u Firestore servisu
        label: 'Home',
        fullAddress: addressControllerField.text,
        city: cityController.text,
        state: '',
        zipCode: zipController.text,
        isDefault: true,
      );

      // ČUVA U BAZI
      await addressCtrl.addAddress(finalAddress);
      // adresa je u bazi i u `addressCtrl.addresses` listi
    } else {
      finalAddress = addressCtrl.addresses.firstWhere(
        (a) => a.isDefault,
        orElse: () => addressCtrl.addresses.first,
      );
    }

    String currentCurrency = currencyController.selectedCurrency.value;
    double convertedAmount = currencyController.convertFromRsd(
      cart.total.toDouble(),
      currentCurrency,
    );
    double totalToPay = double.parse(convertedAmount.toStringAsFixed(2));

    try {
      // STRIPE PLAĆANJE
      await StripeService.initPayment(
        address: finalAddress,
        amount: totalToPay,
        currency: currentCurrency.toLowerCase(),
        userName: auth.user?.displayName ?? 'Customer',
      );
      // KREIRANJE NARUDŽBINE
      final orderId = await OrdersFirestoreService.createOrderFromCart(
        userId: userId,
        userEmail: email,
        cartItems: cart.cartItems,
        subtotal: cart.subtotal,
        savings: cart.savings,
        shipping: cart.shipping,
        total: cart.total,
        shippingAddress: {
          'address': finalAddress.fullAddress,
          'city': finalAddress.city,
        },
      );

      await CartFirestoreService.clearUserCart(userId);
      await cart.loadCartItems();

      Get.off(
        () => OrderConfirmationScreen(
          orderNumber: orderId,
          totalAmount: totalToPay,
        ),
      );
    } catch (e) {
      // proverava da li je greška samo to što je korisnik kliknuo X
      if (e.toString().contains('Cancelled') ||
          e.toString().contains('canceled')) {
        Get.snackbar(
          'Payment Canceled',
          'You have closed the payment window.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      } else {
        // za prave greške (npr. odbijena kartica)
        Get.snackbar(
          'Payment Error',
          e.toString(),
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
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
