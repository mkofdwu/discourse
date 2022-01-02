import 'package:discourse/services/user_db.dart';
import 'package:discourse/views/settings/settings_view.dart';
import 'package:flutter/widgets.dart';
import 'package:discourse/models/photo.dart';
import 'package:discourse/services/auth.dart';
import 'package:discourse/services/media.dart';
import 'package:discourse/services/storage.dart';

import 'package:get/get.dart';

class EditProfileController extends GetxController {
  final _auth = Get.find<AuthService>();
  final _userDb = Get.find<UserDbService>();
  final _storageService = Get.find<StorageService>();
  final _mediaService = Get.find<MediaService>();

  Photo? _photo;
  final emailController = TextEditingController();

  Photo? get photo => _photo;

  @override
  void onReady() {
    final photoUrl = _auth.currentUser.photoUrl;
    _photo = photoUrl == null ? null : Photo.url(photoUrl);
    emailController.text = _auth.currentUser.email;
  }

  Future<void> selectPhoto() async {
    final newPhoto = await _mediaService.selectPhoto();
    if (newPhoto != null) {
      _photo = newPhoto;
    }
    update();
  }

  Future<void> updateProfile() async {
    await _auth.updateEmail(emailController.text);
    if (_photo != null && _photo!.isLocal) {
      await _storageService.uploadPhoto(_photo!, 'profile_photo');
      _auth.currentUser.photoUrl = _photo!.url;
    }
    await _userDb.setUserData(_auth.currentUser);
    Get.snackbar('Success', 'Your profile has been successfully updated');
  }

  void goToSettings() => Get.to(SettingsView());
}
