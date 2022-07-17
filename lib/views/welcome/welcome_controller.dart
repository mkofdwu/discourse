import 'package:discourse/views/sign_in/sign_in_view.dart';
import 'package:get/get.dart';

class WelcomeController extends GetxController {
  void toSignIn() {
    Get.to(SignInView());
  }

  void toSignUp() {
    Get.to(SignInView(signUp: true));
  }
}
