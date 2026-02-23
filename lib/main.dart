import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:petshop/controllers/auth_controller.dart';
import 'package:petshop/controllers/category_controller.dart';
import 'package:petshop/controllers/navigation_controller.dart';
import 'package:petshop/controllers/product_contoller.dart';
import 'package:petshop/controllers/theme_controller.dart';
import 'package:petshop/firebase_options.dart';
import 'package:petshop/utils/app_themes.dart';
import 'package:petshop/utils/firestore_data_seeder.dart';
import 'package:petshop/view/splash_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await GetStorage.init();
  Get.put(ThemeController());
  Get.put(AuthController());
  Get.put(ProductController());
  Get.put(NavigationController());
  Get.put(CategoryController());

  //seed sample data to firestore for testing only
  await FirestoreDataSeeder.seedAllData();
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
