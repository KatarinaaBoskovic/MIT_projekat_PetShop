import 'package:get/state_manager.dart';

class NavigationController extends GetxController{
  final RxInt currentIndex =0.obs;

  void changeIndex(int index){
    currentIndex.value=index;
  }
}