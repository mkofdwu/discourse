import 'package:discourse/models/db_objects/user.dart';
import 'package:discourse/services/auth.dart';
import 'package:discourse/services/media.dart';
import 'package:discourse/services/storage.dart';
import 'package:discourse/services/user_db.dart';
import 'package:discourse/views/custom_form/custom_form.dart';
import 'package:discourse/views/custom_form/custom_form_view.dart';
import 'package:discourse/views/friends/friends_view.dart';
import 'package:discourse/views/settings/settings_view.dart';
import 'package:discourse/widgets/bottom_sheets/input_bottom_sheet.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class MyProfileController extends GetxController {
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
      await _storage.uploadPhoto(newPhoto, 'profilephoto');
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
          Field(
            'aboutMe',
            user.aboutMe,
            textFieldBuilder(label: 'About me', isLast: true),
          ),
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
    try {
      await _auth.verifyEmail();
      Get.snackbar(
        'Email sent',
        'Click the link sent to ${user.email} to validate your email',
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'too-many-requests') {
        Get.snackbar(
          'Failed to send email',
          'There have been too many email verification requests from this device. Try again in a while',
        );
      }
    }
  }

  void toSettings() => Get.to(SettingsView());

  void toFriendsList() => Get.to(FriendsView());
}
