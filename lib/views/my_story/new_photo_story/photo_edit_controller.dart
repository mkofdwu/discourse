import 'package:discourse/models/photo.dart';
import 'package:get/get.dart';

class PhotoEditController extends GetxController {
  // nothing here for now
  final Photo _photo;

  PhotoEditController(this._photo);

  void submit() async {
    Get.back(result: _photo);
  }
}
