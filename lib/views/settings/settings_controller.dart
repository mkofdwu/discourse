import 'package:discourse/services/auth.dart';
import 'package:discourse/views/custom_form/custom_form.dart';
import 'package:discourse/views/custom_form/custom_form_view.dart';
import 'package:get/get.dart';
import 'package:discourse/views/notification_settings/notification_settings_view.dart';
import 'package:discourse/views/privacy_settings/privacy_settings_view.dart';
import 'package:discourse/views/sign_in/sign_in_view.dart';
import 'package:discourse/widgets/bottom_sheets/yesno_bottom_sheet.dart';

class SettingsController extends GetxController {
  final _auth = Get.find<AuthService>();

  void toNotifs() => Get.to(() => NotificationSettingsView());

  void toPrivacy() => Get.to(() => PrivacySettingsView());

  void toChangePassword() {
    Get.to(
      () => CustomFormView(
        form: CustomForm(
          title: 'Change password',
          fields: [
            Field(
              'currentPassword',
              '',
              textFieldBuilder(label: 'Current password', obscureText: true),
            ),
            Field(
              'newPassword',
              '',
              textFieldBuilder(label: 'New password', obscureText: true),
            ),
            Field(
              'confirmNewPassword',
              '',
              textFieldBuilder(
                label: 'Confirm new password',
                obscureText: true,
                isLast: true,
              ),
            ),
          ],
          onSubmit: (inputs, setErrors) async {
            final errors = {
              if (inputs['currentPassword'].isEmpty)
                'currentPassword': 'Please enter your password',
              if (inputs['newPassword'].isEmpty)
                'newPassword': 'Please enter a new password',
              if (inputs['confirmNewPassword'] != inputs['newPassword'])
                'confirmNewPassword': 'The passwords entered do not match',
            };
            if (errors.isNotEmpty) {
              setErrors(errors);
              return;
            }
            final authErrors = await _auth.changePassword(
              inputs['currentPassword'],
              inputs['newPassword'],
            );
            setErrors(authErrors);
          },
        ),
      ),
    );
  }

  Future<void> signOut() async {
    final confirmed = await Get.bottomSheet(YesNoBottomSheet(
      title: 'Sign out?',
      subtitle: 'Are you sure you want to sign out of your account?',
    ));
    if (confirmed ?? false) {
      _auth.signOut();
      Get.offAll(SignInView());
      Get.snackbar('Success', 'Signed out successfully');
    }
  }
}
