import 'package:discourse/services/auth.dart';
import 'package:discourse/services/misc_cache.dart';
import 'package:discourse/views/home/home_view.dart';
import 'package:discourse/views/welcome/welcome_view.dart';
import 'package:get/get.dart';

class StartupController extends GetxController {
  final _auth = Get.find<AuthService>();

  @override
  Future<void> onReady() async {
    await _auth.refreshCurrentUser();
    if (_auth.isSignedIn) {
      await Get.find<MiscCache>().fetchData();
      Get.off(HomeView());
    } else {
      Get.off(WelcomeView());
    }
  }
}
