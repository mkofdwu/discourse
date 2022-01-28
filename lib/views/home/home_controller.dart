import 'package:discourse/services/misc_cache.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  int currentTab = 0;

  @override
  void onReady() {
    Get.find<MiscCache>().fetchData();
  }

  void onSelectTab(int index) {
    currentTab = index;
    update();
  }
}
