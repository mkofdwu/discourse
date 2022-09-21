import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:discourse/models/db_objects/chat_data.dart';
import 'package:discourse/models/db_objects/message_link.dart';
import 'package:discourse/models/db_objects/message_media_url.dart';
import 'package:discourse/models/db_objects/user_chat.dart';
import 'package:discourse/services/auth.dart';
import 'package:discourse/services/chat/group_chat_db.dart';
import 'package:discourse/services/chat/private_chat_db.dart';
import 'package:discourse/services/user_db.dart';
import 'package:get/get.dart';

class CommonChatDbService extends GetxService {
  final _auth = Get.find<AuthService>();
  final _userDb = Get.find<UserDbService>();
  final _groupChatDb = Get.find<GroupChatDbService>();
  final _privateChatDb = Get.find<PrivateChatDbService>();

  final _usersRef = FirebaseFirestore.instance.collection('users');

  Future<List<UserChat>> myChats() async {
    final chatsSnapshot = await _usersRef
        .doc(_auth.id)
        .collection('chats')
        .orderBy('pinned', descending: true)
        .get();
    final userChats = <UserChat>[];
    for (final doc in chatsSnapshot.docs) {
      final data = doc.data();
      final type = ChatType.values[doc['type']];
      // TODO: store lastUpdated field in chatdata to show newer messages at top
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

  Future<void> setPinChat(String chatId, bool pinned) async {
    await _usersRef
        .doc(_auth.id)
        .collection('chats')
        .doc(chatId)
        .update({'pinned': pinned});
  }

  Future<void> stopReadingChat(String chatId) async {
    await _usersRef
        .doc(_auth.id)
        .collection('chats')
        .doc(chatId)
        .update({'lastReadAt': DateTime.now()});
  }

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

  Future<void> updateMediaList(UserChat chat) async {
    // called when deleting photos
    await FirebaseFirestore.instance
        .collection(chat is UserGroupChat ? 'groupChats' : 'privateChats')
        .doc(chat.id)
        .update({'mediaUrls': chat.data.media.map((m) => m.toData()).toList()});
  }

  Future<void> addMedia(UserChat chat, MessageMedia media) async {
    await FirebaseFirestore.instance
        .collection(chat is UserGroupChat ? 'groupChats' : 'privateChats')
        .doc(chat.id)
        .update({
      'mediaUrls': FieldValue.arrayUnion([media.toData()]),
    });
  }

  Future<void> addLink(UserChat chat, MessageLink link) async {
    final doc = await FirebaseFirestore.instance
        .collection(chat is UserGroupChat ? 'groupChats' : 'privateChats')
        .doc(chat.id)
        .collection('links')
        .add(link.toData());
    link.id = doc.id;
  }

  Future<void> removeLink(UserChat chat, MessageLink link) async {
    await FirebaseFirestore.instance
        .collection(chat is UserGroupChat ? 'groupChats' : 'privateChats')
        .doc(chat.id)
        .collection('links')
        .doc(link.id)
        .delete();
  }
}
