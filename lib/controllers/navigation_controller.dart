import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:petshop/controllers/product_contoller.dart';

class NavigationController extends GetxController {
  final RxInt currentIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();

    // Listen to changes in the current index
    ever(currentIndex, (index) {
      // Reset filters when navigating to any tab other than ShoppingScreen (index 1)
      if (index != 1) {
        final productController = Get.find<ProductController>();
        productController.resetFilters();
      }
    });
  }

  bool _isGuest() => FirebaseAuth.instance.currentUser == null;

  void changeIndex(int index) {
    // Guest sme samo Home (0) i Shopping (1)
    final isRestrictedTab = (index == 2 || index == 3);

    if (_isGuest() && isRestrictedTab) {
      Get.snackbar(
        'Login required',
        'Login or Signup first please.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
      return; // ne menjam tab
    }

    currentIndex.value = index;
  }
}
