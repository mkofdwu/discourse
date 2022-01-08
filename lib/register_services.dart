import 'package:discourse/services/chat/chat_export_service.dart';
import 'package:discourse/services/chat_db.dart';
import 'package:discourse/services/media.dart';
import 'package:discourse/services/storage.dart';
import 'package:get/get.dart';
import 'package:discourse/services/auth.dart';
import 'package:discourse/services/user_db.dart';

void registerServices() {
  Get.put(StorageService());
  Get.put(UserDbService());
  Get.put(AuthService());
  Get.put(ChatDbService());
  Get.put(MediaService());
  Get.put(ChatExportService());
}
