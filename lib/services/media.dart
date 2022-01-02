import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:discourse/models/photo.dart';

class MediaService {
  Future<Photo?> selectPhoto() async {
    final file = await ImagePicker().pickImage(source: ImageSource.gallery);
    return file == null ? null : Photo.file(File(file.path));
  }

  Future<Photo?> takePhotoFromCamera() async {
    final file = await ImagePicker().pickImage(source: ImageSource.camera);
    return file == null ? null : Photo.file(File(file.path));
  }
}
