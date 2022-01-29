import 'dart:math';

import 'package:discourse/services/auth.dart';
import 'package:path_provider/path_provider.dart';
import 'package:discourse/models/photo.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';

class StorageService extends GetxService {
  final _auth = Get.find<AuthService>();

  final _storageRef = FirebaseStorage.instance.ref();

  Future<void> uploadPhoto(Photo photo, String prefix) async {
    assert(photo.isLocal && photo.file != null);
    final tempDir = await getTemporaryDirectory();
    final id = _randomString();
    final compressedFile = await FlutterImageCompress.compressAndGetFile(
      photo.file!.path,
      '${tempDir.path}/$id.jpg',
      quality: 70,
    );
    final storagePath = 'photos/${_auth.id}/${prefix}_$id.jpg';
    final taskSnapshot =
        await _storageRef.child(storagePath).putFile(compressedFile!);
    photo.url = await taskSnapshot.ref.getDownloadURL();
    photo.isLocal = false;
  }

  String _randomString() {
    var random = Random();
    const chars =
        'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    return List.generate(10, (i) => chars[random.nextInt(chars.length)]).join();
  }

  Future<void> deletePhoto(String photoUrl) =>
      FirebaseStorage.instance.refFromURL(photoUrl).delete();
}
