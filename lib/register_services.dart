import 'package:discourse/services/chat_db.dart';
import 'package:get/get.dart';
import 'package:discourse/services/auth.dart';
import 'package:discourse/services/user_db.dart';

void registerServices() {
  Get.put(UserDbService());
  Get.put(AuthService());
  Get.put(ChatDbService());
}
