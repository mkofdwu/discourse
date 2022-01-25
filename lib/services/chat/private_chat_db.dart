import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:discourse/models/db_objects/chat_data.dart';
import 'package:discourse/models/db_objects/chat_member.dart';
import 'package:discourse/models/unsent_request.dart';
import 'package:discourse/models/db_objects/user.dart';
import 'package:discourse/models/db_objects/user_chat.dart';
import 'package:discourse/services/auth.dart';
import 'package:discourse/services/relationships.dart';
import 'package:discourse/services/requests.dart';
import 'package:discourse/services/user_db.dart';
import 'package:get/get.dart';

abstract class BasePrivateChatDbService {
  Future<UserChat> getChatWith(DiscourseUser user);
  Future<UserPrivateChat> createChatWith(DiscourseUser otherUser);
  Future<void> addUserPrivateChat(String chatId, String otherUserId);
}

class PrivateChatDbService extends GetxService
    implements BasePrivateChatDbService {
  final _usersRef = FirebaseFirestore.instance.collection('users');
  final _messagesRef = FirebaseFirestore.instance.collection('messages');
  final _privateChatsRef =
      FirebaseFirestore.instance.collection('privateChats');

  final _auth = Get.find<AuthService>();
  final _userDb = Get.find<UserDbService>();
  final _relationships = Get.find<RelationshipsService>();
  final _requests = Get.find<RequestsService>();

  @override
  Future<UserChat> getChatWith(DiscourseUser otherUser) async {
    final querySnapshot = await _usersRef
        .doc(_auth.id)
        .collection('privateChats')
        .where('otherUserId', isEqualTo: otherUser.id)
        .limit(1)
        .get();
    if (querySnapshot.docs.isEmpty) {
      return NonExistentChat(
        otherUser: otherUser,
        members: [
          Member.create(_auth.currentUser),
          Member.create(otherUser),
        ],
      );
    }
    final doc = querySnapshot.docs.single;
    final data = doc.data();
    return UserPrivateChat(
      id: doc.id,
      lastReadAt: data['lastReadAt']?.toDate(),
      pinned: data['pinned'],
      otherUser: await _userDb.getUser(data['otherUserId']),
      data: PrivateChatData(),
    );
  }

  @override
  Future<UserPrivateChat> createChatWith(DiscourseUser otherUser) async {
    // for the purposes of this exercise there are no security rules so the chat
    // is created from the client
    // dont need to send a message to create chat.
    // but chats without messages aren't displayed
    final chatDoc = await _privateChatsRef.add({
      'memberIds': [_auth.id, otherUser.id],
    });
    await _messagesRef.doc(chatDoc.id).set({});
    await _usersRef
        .doc(_auth.id)
        .collection('privateChats')
        .doc(chatDoc.id)
        .set({
      'type': 0,
      'lastReadAt': null,
      'pinned': false,
      'otherUserId': otherUser.id,
    });
    if (await _relationships.needToAsk(otherUser.id, RequestType.talk)) {
      await _requests.sendRequest(UnsentRequest(
        toUserId: otherUser.id,
        type: RequestType.talk,
        data: chatDoc.id,
      ));
    } else {
      await _usersRef
          .doc(otherUser.id)
          .collection('privateChats')
          .doc(chatDoc.id)
          .set({
        'type': 0,
        'lastReadAt': null,
        'pinned': false,
        'otherUserId': _auth.id,
      });
    }
    return UserPrivateChat(
      id: chatDoc.id,
      pinned: false,
      otherUser: otherUser,
      data: PrivateChatData(),
    );
  }

  @override
  Future<void> addUserPrivateChat(String chatId, String otherUserId) async {
    await _usersRef.doc(_auth.id).collection('privateChats').doc(chatId).set({
      'type': 0,
      'lastReadAt': null,
      'pinned': false,
      'otherUserId': otherUserId,
    });
  }
}
