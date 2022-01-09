import 'package:discourse/services/auth.dart';
import 'package:discourse/views/change_password/change_password_view.dart';
import 'package:discourse/views/custom_form/custom_form.dart';
import 'package:discourse/views/custom_form/custom_form_view.dart';
import 'package:discourse/views/notification_settings/notification_settings_view.dart';
import 'package:discourse/views/privacy_settings/privacy_settings_view.dart';
import 'package:discourse/views/sign_in/sign_in_view.dart';
import 'package:discourse/widgets/yesno_bottom_sheet.dart';
import 'package:get/get.dart';

class SettingsController extends GetxController {
  final _authService = Get.find<AuthService>();

  void goToNotifs() => Get.to(() => NotificationSettingsView());

  void goToPrivacy() => Get.to(() => PrivacySettingsView());

  void goToChangePassword() => Get.to(
        () => CustomFormView(
          form: CustomForm(
            title: 'Change password',
            fields: [
              FormField(
                'currentPassword',
                textFieldBuilder(label: 'Current password', obscureText: true),
              ),
              FormField(
                'newPassword',
                textFieldBuilder(label: 'New password', obscureText: true),
              ),
              FormField(
                'confirmNewPassword',
                textFieldBuilder(
                    label: 'Confirm new password', obscureText: true),
              ),
            ],
            onSubmit: (inputs, setErrors) {
              inputs;
              setErrors({});
            },
          ),
        ),
      );

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
