import 'package:discourse/models/db_objects/user.dart';
import 'package:discourse/services/auth.dart';
import 'package:discourse/services/media.dart';
import 'package:discourse/services/storage.dart';
import 'package:discourse/services/user_db.dart';
import 'package:discourse/views/custom_form/custom_form.dart';
import 'package:discourse/views/custom_form/custom_form_view.dart';
import 'package:discourse/views/notification_settings/notification_settings_view.dart';
import 'package:discourse/views/privacy_settings/privacy_settings_view.dart';
import 'package:discourse/views/sign_in/sign_in_view.dart';
import 'package:discourse/widgets/bottom_sheets/input_bottom_sheet.dart';
import 'package:discourse/widgets/bottom_sheets/yesno_bottom_sheet.dart';
import 'package:get/get.dart';

class SettingsController extends GetxController {
  final _auth = Get.find<AuthService>();
  final _userDb = Get.find<UserDbService>();
  final _media = Get.find<MediaService>();
  final _storage = Get.find<StorageService>();

  DiscourseUser get user => _auth.currentUser;
  bool get emailVerified => _auth.emailVerified;

  Future<void> selectPhoto() async {
    final newPhoto = await _media.selectPhoto();
    if (newPhoto != null) {
      assert(newPhoto.isLocal);
      await _storage.uploadPhoto(newPhoto, user.id, 'profilephoto');
      user.photoUrl = newPhoto.url;
      await _userDb.setUserData(user);
      update();
    }
  }

  Future<void> editUsername() async {
    final newUsername = await Get.bottomSheet(InputBottomSheet(
      title: 'Edit username',
      subtitle: 'Enter a new username for this account:',
    ));
    if (newUsername == null || newUsername.isEmpty) return;
    if (await _userDb.getUserByUsername(newUsername) != null) {
      Get.snackbar(
        'Error',
        'Failed to change username as this username is already taken',
      );
      return;
    }
    user.username = newUsername;
    await _userDb.setUserData(user);
    update();
  }

  Future<void> editAboutMe() async {
    await Get.to(CustomFormView(
      form: CustomForm(
        title: 'Edit about me',
        description: 'Enter a few words about yourself in the box below',
        fields: [
          Field('aboutMe',
              textFieldBuilder(label: 'About me', defaultValue: user.aboutMe)),
        ],
        onSubmit: (inputs, setErrors) async {
          final String aboutMe = inputs['aboutMe'];
          if (aboutMe.isEmpty) {
            // delete about; set to null
            user.aboutMe = null;
          } else {
            user.aboutMe = aboutMe;
          }
          await _userDb.setUserData(user);
          setErrors({});
          Get.back();
          update();
        },
      ),
    ));
  }

  void verifyEmail() async {
    await _auth.verifyEmail();
    Get.snackbar(
      'Email sent',
      'Click the link sent to ${user.email} to validate your email',
    );
  }

  void goToNotifs() => Get.to(() => NotificationSettingsView());

  void goToPrivacy() => Get.to(() => PrivacySettingsView());

  void goToChangePassword() => Get.to(
        () => CustomFormView(
          form: CustomForm(
            title: 'Change password',
            fields: [
              Field(
                'currentPassword',
                textFieldBuilder(label: 'Current password', obscureText: true),
              ),
              Field(
                'newPassword',
                textFieldBuilder(label: 'New password', obscureText: true),
              ),
              Field(
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
      _auth.signOut();
      Get.offAll(SignInView());
      Get.snackbar('Success', 'Signed out successfully');
    }
  }
}
