import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:discourse/models/db_objects/chat_data.dart';
import 'package:discourse/models/db_objects/user_chat.dart';
import 'package:discourse/services/auth.dart';
import 'package:discourse/services/chat/group_chat_db.dart';
import 'package:discourse/services/chat/private_chat_db.dart';
import 'package:discourse/services/storage.dart';
import 'package:discourse/services/user_db.dart';
import 'package:get/get.dart';

abstract class BaseCommonChatService {
  Future<List<UserChat>> myChats();
  Future<void> setPinChat(String chatId, bool pinned);
  Future<void> stopReadingChat(String chatId);
  Future<void> startReadingChat(String chatId);
}

class CommonChatDbService extends GetxService implements BaseCommonChatService {
  final _auth = Get.find<AuthService>();
  final _userDb = Get.find<UserDbService>();
  final _groupChatDb = Get.find<GroupChatDbService>();
  final _privateChatDb = Get.find<PrivateChatDbService>();
  final _storage = Get.find<StorageService>();

  final _usersRef = FirebaseFirestore.instance.collection('users');

  @override
  Future<List<UserChat>> myChats() async {
    // TODO: sort by has unread messages
    final chatsSnapshot = await _usersRef
        .doc(_auth.id)
        .collection('chats')
        .orderBy('pinned', descending: true)
        .get();
    final userChats = <UserChat>[];
    for (final doc in chatsSnapshot.docs) {
      final data = doc.data();
      final type = ChatType.values[doc['type']];
      if (type == ChatType.private) {
        userChats.add(UserPrivateChat(
          id: doc.id,
          lastReadAt: data['lastReadAt']?.toDate(),
          pinned: data['pinned'],
          otherUser: await _userDb.getUser(data['otherUserId']),
          data: await _privateChatDb.getChatData(doc.id),
        ));
      } else {
        userChats.add(UserGroupChat(
          id: doc.id,
          lastReadAt: data['lastReadAt']?.toDate(),
          pinned: data['pinned'],
          data: await _groupChatDb.getChatData(doc.id),
        ));
      }
    }
    return userChats;
  }

  @override
  Future<void> setPinChat(String chatId, bool pinned) async {
    await _usersRef
        .doc(_auth.id)
        .collection('chats')
        .doc(chatId)
        .update({'pinned': pinned});
  }

  @override
  Future<void> stopReadingChat(String chatId) async {
    await _usersRef
        .doc(_auth.id)
        .collection('chats')
        .doc(chatId)
        .update({'lastReadAt': DateTime.now()});
  }

  @override
  Future<void> startReadingChat(String chatId) async {
    await _usersRef
        .doc(_auth.id)
        .collection('chats')
        .doc(chatId)
        .update({'lastReadAt': DateTime.now().add(Duration(days: 10))});
    // all messages from now until 10 days later are considered read
    // (as long as this page is open)
    // when leaving chat page will be reset to current time
    // safe to assume user user will not leave page open for this long
  }

  Future<void> deletePhotos(List<String> photoUrls, UserChat chat) async {
    await FirebaseFirestore.instance
        .collection(chat is UserGroupChat ? 'groupChats' : 'privateChats')
        .doc(chat.id)
        .update({'mediaUrls': FieldValue.arrayRemove(photoUrls)});
    for (final photoUrl in photoUrls) {
      await _storage.deletePhoto(photoUrl);
    }
  }
}
