import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:petshop/controllers/navigation_controller.dart';
import 'package:petshop/controllers/theme_controller.dart';
import 'package:petshop/view/account_screen.dart';
import 'package:petshop/view/home_screen.dart';
import 'package:petshop/view/shopping_screen.dart';
import 'package:petshop/view/widgets/custom_bottom_navbar.dart';
import 'package:petshop/view/wishlist_screen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final NavigationController navigationController= Get.find<NavigationController>();
    
    return GetBuilder<ThemeController>(
      builder: (themeController) => Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body:  AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Obx(
            ()=>IndexedStack(
              key:ValueKey(navigationController.currentIndex.value),
              index: navigationController.currentIndex.value,
              children: const[
                HomeScreen(),
                ShoppingScreen(),
                WishlistScreen(),
                AccountScreen(),
              ],
            )
          ),
          ),
          bottomNavigationBar:const CustomBottomNavbar(),
      ),
    );
  }
}
