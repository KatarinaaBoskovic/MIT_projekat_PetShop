import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:petshop/controllers/address_controller.dart';
import 'package:petshop/controllers/auth_controller.dart';
import 'package:petshop/controllers/cart_controller.dart';
import 'package:petshop/controllers/category_controller.dart';
import 'package:petshop/controllers/currency_controller.dart';
import 'package:petshop/controllers/navigation_controller.dart';
import 'package:petshop/controllers/product_contoller.dart';
import 'package:petshop/controllers/theme_controller.dart';
import 'package:petshop/controllers/wishlist_controller.dart';
import 'package:petshop/firebase_options.dart';
import 'package:petshop/utils/app_themes.dart';
import 'package:petshop/view/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    Stripe.publishableKey =
        "pk_test_51T6AhkRx3avw4BnbTUejNrdoSLeUDjJdt9zg6U1sRfnXbIlz7G5ZwEpzPn279agqrPr58pREPHChxwtgsnVMh4sc00D4wK9u12"; // Ključ sa slike
    Stripe.instance.applySettings();
    await GetStorage.init();
    Get.put(ThemeController());
    Get.put(AuthController());
    Get.put(ProductController());
    Get.put(NavigationController());
    Get.put(CategoryController());
    Get.put(WishlistController());
    Get.put(CartController());
    Get.put(AddressController());
    Get.put(CurrencyController());
  } catch (e) {
    debugPrint("Greška pri inicijalizaciji: $e");
  }
  // seed sample data to firestore for testing only
  // assert(() {
  //   FirestoreDataSeeder.seedAllData();
  //   return true;
  // }());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pet Shop',
      theme: AppThemes.light,
      darkTheme: AppThemes.dark,
      themeMode: themeController.theme,
      defaultTransition: Transition.fade,
      home: SplashScreen(),
    );
  }
}
