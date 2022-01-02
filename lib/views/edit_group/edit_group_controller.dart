import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:discourse/models/chat_data.dart';
import 'package:discourse/models/photo.dart';
import 'package:discourse/services/chat_db.dart';
import 'package:discourse/services/media.dart';
import 'package:discourse/services/storage.dart';

class EditGroupController extends GetxController {
  final _chatDb = Get.find<ChatDbService>();
  final _storageService = Get.find<StorageService>();
  final _mediaService = Get.find<MediaService>();

  Photo? _photo;
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();

  Photo? get photo => _photo;
  GroupChatData get _groupData => _chatDb.currentChat!.groupData;

  @override
  void onReady() {
    final photoUrl = _groupData.photoUrl;
    _photo = photoUrl == null ? null : Photo.url(photoUrl);
    nameController.text = _groupData.name;
    descriptionController.text = _groupData.description;
  }

  Future<void> selectPhoto() async {
    final newPhoto = await _mediaService.selectPhoto();
    if (newPhoto != null) {
      _photo = newPhoto;
    }
    update();
  }

  Future<void> updateDisplay() async {
    if (_photo != null && _photo!.isLocal) {
      await _storageService.uploadPhoto(_photo!, 'group_photo');
      _groupData.photoUrl = _photo!.url;
    }
    _groupData.name = nameController.text;
    _groupData.description = descriptionController.text;
    await _chatDb.updateChatData(_chatDb.currentChat!.id, _groupData);
    Get.back();
    Get.snackbar('Success', 'Your group details have been updated');
  }
}
