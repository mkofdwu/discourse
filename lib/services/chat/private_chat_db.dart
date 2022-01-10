import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:discourse/models/db_objects/chat_data.dart';
import 'package:discourse/models/db_objects/chat_member.dart';
import 'package:discourse/models/db_objects/user.dart';
import 'package:discourse/models/db_objects/user_chat.dart';
import 'package:discourse/services/auth.dart';
import 'package:discourse/services/user_db.dart';
import 'package:get/get.dart';

abstract class BasePrivateChatDbService {
  Future<List<UserPrivateChat>> myPrivateChats();
  Future<UserChat> getChatWith(DiscourseUser user);
  Future<String> createChatWith(DiscourseUser otherUser);
}

class PrivateChatDbService extends GetxService
    implements BasePrivateChatDbService {
  final _usersRef = FirebaseFirestore.instance.collection('users');
  final _privateChatsRef =
      FirebaseFirestore.instance.collection('privateChats');

  final _auth = Get.find<AuthService>();
  final _userDb = Get.find<UserDbService>();

  String get _userId => _auth.currentUser.id;

  Future<PrivateChatData> _getChatData(String chatId) async {
    final doc = await _privateChatsRef.doc(chatId).get();
    final memberIds = List<String>.from(doc.data()!['memberIds']);
    assert(memberIds.length == 2);
    final otherUserId = memberIds.firstWhere((uid) => uid != _userId);
    return PrivateChatData(otherUser: await _userDb.getUser(otherUserId));
  }

  @override
  Future<List<UserPrivateChat>> myPrivateChats() async {
    final chatsSnapshot =
        await _usersRef.doc(_userId).collection('privateChats').get();
    final userChats = <UserPrivateChat>[];
    for (final doc in chatsSnapshot.docs) {
      final data = doc.data();
      userChats.add(UserPrivateChat(
        id: doc.id,
        lastReadId: data['lastReadId'],
        pinned: data['pinned'],
        data: await _getChatData(doc.id),
      ));
    }
    return userChats;
  }

  @override
  Future<UserChat> getChatWith(DiscourseUser user) async {
    final querySnapshot = await _usersRef
        .doc(_userId)
        .collection('chats')
        .where('otherUserId', isEqualTo: user.id)
        .limit(1)
        .get();
    if (querySnapshot.docs.isEmpty) {
      return NonExistentChat(
        otherUser: user,
        members: [
          Member.create(user),
          Member.create(_auth.currentUser),
        ],
      );
    }
    final doc = querySnapshot.docs.single;
    final data = doc.data();
    return UserPrivateChat(
      id: doc.id,
      lastReadId: data['lastReadId'],
      pinned: data['pinned'],
      data: await _getChatData(doc.id),
    );
  }

  @override
  Future<String> createChatWith(DiscourseUser otherUser) async {
    // for the purposes of this exercise there are no security rules so the chat
    // is created from the client
    // dont need to send a message to create chat.
    // but chats without messages aren't displayed
    final chatDoc = await _privateChatsRef.add({
      'memberIds': [_userId, otherUser.id],
    });
    await _usersRef
        .doc(_auth.currentUser.id)
        .collection('chats')
        .doc(chatDoc.id)
        .set({'type': 0, 'lastReadId': null, 'otherUserId': otherUser.id});
    await _usersRef.doc(otherUser.id).collection('chats').doc(chatDoc.id).set({
      'type': 0,
      'lastReadId': null,
      'otherUserId': _auth.currentUser.id,
    });
    return chatDoc.id;
  }
}
