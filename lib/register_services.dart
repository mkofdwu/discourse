import 'package:discourse/services/chat/chat_export.dart';
import 'package:discourse/services/chat/common_chat_db.dart';
import 'package:discourse/services/chat/group_chat_db.dart';
import 'package:discourse/services/chat/messages_db.dart';
import 'package:discourse/services/chat/private_chat_db.dart';
import 'package:discourse/services/chat/whos_typing.dart';
import 'package:discourse/services/media.dart';
import 'package:discourse/services/misc_cache.dart';
import 'package:discourse/services/relationships.dart';
import 'package:discourse/services/requests.dart';
import 'package:discourse/services/storage.dart';
import 'package:discourse/services/story_db.dart';
import 'package:get/get.dart';
import 'package:discourse/services/auth.dart';
import 'package:discourse/services/user_db.dart';

void registerServices() {
  Get.put(UserDbService());
  Get.put(AuthService());
  Get.put(StorageService());
  Get.put(MediaService());
  Get.put(RequestsService());
  Get.put(RelationshipsService());
  // chats
  Get.put(MessagesDbService());
  Get.put(PrivateChatDbService());
  Get.put(GroupChatDbService());
  Get.put(CommonChatDbService());
  Get.put(WhosTypingService());
  Get.put(ChatExportService());
  // story
  Get.put(StoryDbService());
  Get.put(MiscCache());
}
