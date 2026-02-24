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

  void changeIndex(int index) {
    currentIndex.value = index;
  }
}