import 'package:discourse/services/auth.dart';
import 'package:discourse/views/sign_in/sign_in_view.dart';
import 'package:discourse/widgets/yesno_bottom_sheet.dart';
import 'package:get/get.dart';

class SettingsController extends GetxController {
  final _authService = Get.find<AuthService>();

  Future<void> signOut() async {
    final confirmed = await Get.bottomSheet(YesNoBottomSheet(
      title: 'Sign out?',
      subtitle: 'Are you sure you want to sign out of your account?',
    ));
    if (confirmed ?? false) {
      _authService.signOut();
      Get.offAll(SignInView());
      Get.snackbar('Success', 'Signed out successfully');
    }
  }
}
