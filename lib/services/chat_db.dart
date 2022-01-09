import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:discourse/models/db_objects/chat_data.dart';
import 'package:discourse/models/db_objects/chat_member.dart';
import 'package:discourse/models/db_objects/message.dart';
import 'package:discourse/models/photo.dart';
import 'package:discourse/models/replied_message.dart';
import 'package:discourse/models/unsent_message.dart';
import 'package:discourse/models/db_objects/user.dart';
import 'package:discourse/models/db_objects/user_chat.dart';
import 'package:discourse/services/auth.dart';
import 'package:discourse/services/user_db.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

abstract class BaseChatDbService {
  Future<UserPrivateChat> _getPrivateChat(String id);
  Future<UserGroupChat> _getGroupChat(String id);
  Future<PrivateChatData> _getPrivateChatData(String id);
  Future<GroupChatData> _getGroupChatData(String id);
  Future<Message> _messageFromDoc(DocumentSnapshot<Map<String, dynamic>> doc);
  Future<Member> _memberFromDoc(DocumentSnapshot<Map<String, dynamic>> doc);
  Future<List<UserPrivateChat>> myPrivateChats();
  Future<List<UserGroupChat>> myGroupChats();
  Future<UserPrivateChat> getChatWith(DiscourseUser otherUser);
  Future<void> requestPrivateChat(DiscourseUser otherUser);
  Future<UserGroupChat> newGroup(GroupChatData data);
  Stream<List<Message>> streamMessages(String chatId, int numMessages);
  Future<Message> getLastMessage(String chatId);
  Future<Message> sendMessage(UnsentMessage unsentMessage);
  Future<void> deleteMessages(List<Message> messages);
  Future<void> leaveChat(String chatId);
  Future<void> updateChatData(String chatId, GroupChatData data);
  Future<void> addMembers(String chatId, List<String> userIds);
  Future<void> removeMember(String chatId, String userId);
  Future<void> updateMemberRole(
    String chatId,
    String userId,
    MemberRole newRole,
  );
}

class ChatDbService extends GetxService implements BaseChatDbService {
  final _auth = Get.find<AuthService>();
  final _userDb = Get.find<UserDbService>();

  final _usersRef = FirebaseFirestore.instance.collection('users');
  final _privateChatsRef =
      FirebaseFirestore.instance.collection('privateChats');
  final _groupChatsRef = FirebaseFirestore.instance.collection('groupChats');

  UserChat? currentChat;

  String get _userId => _auth.currentUser.id;

  Future<List<UserPrivateChat>> myPrivateChats() async {
    final chatsSnapshot =
        await _usersRef.doc(_userId).collection('privateChats').get();
    final userChats = <UserPrivateChat>[];
    for (final doc in chatsSnapshot.docs) {
      userChats.add(await _getPrivateChat(doc.id));
    }
    return userChats;
  }

  Future<ChatData> getChatData(String chatId) async {
    final doc = await _chatsRef.doc(chatId).get();
    final data = doc.data()!;
    final chatType = ChatType.values[data['type']];
    final members =
        await _loadMembers(List<Map<String, dynamic>>.from(data['members']));
    switch (chatType) {
      case ChatType.private:
        return PrivateChatData.fromDoc(doc, members);
      case ChatType.group:
        return GroupChatData.fromDoc(doc, members);
    }
  }

  Future<List<Member>> _loadMembers(List<Map<String, dynamic>> pMaps) async {
    final members = <Member>[];
    for (final pMap in pMaps) {
      members.add(Member(
        user: await _userDb.getUser(pMap['userId']),
        color: Color(pMap['color']),
        role: MemberRole.values[pMap['role']],
      ));
    }
    return members;
  }

  Stream<List<Message>> streamMessages(String chatId, int numMessages) {
    return _chatsRef
        .doc(chatId)
        .collection('messages')
        .orderBy('sentTimestamp', descending: true)
        .limit(numMessages)
        .snapshots()
        .asyncMap(
          (snapshot) => Future.wait(snapshot.docs.map(
            (doc) => _messageFromDoc(doc),
          )),
        );
  }

  // Future<List<DocumentSnapshot<Map<String, dynamic>>>> getAllMessageDocs(
  //     String chatId) async {
  //   final querySnapshot = await _chatsRef
  //       .doc(chatId)
  //       .collection('messages')
  //       .orderBy('sentTimestamp', descending: false)
  //       .get();
  //   return querySnapshot.docs;
  // }

  Future<UserChat> getUserChat(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) async {
    final data = doc.data()!;
    switch (ChatType.values[data['type']]) {
      case ChatType.private:
        return UserPrivateChat(
          id: doc.id,
          lastReadId: data['lastReadId'],
          data: await getChatData(doc.id) as PrivateChatData,
        );
      case ChatType.group:
        return UserGroupChat(
          id: doc.id,
          lastReadId: data['lastReadId'],
          data: await getChatData(doc.id) as GroupChatData,
        );
    }
  }

  Future<Message> _messageFromDoc(
      DocumentSnapshot<Map<String, dynamic>> doc) async {
    final data = doc.data()!;
    final chatId = doc.reference.parent.parent!.id;
    final repliedMessage = data['repliedMessageId'] == null
        ? null
        : await _getRepliedMessage(chatId, data['repliedMessageId']);
    return Message(
      id: doc.id,
      chatId: chatId,
      sender: await _userDb.getUser(data['senderId']),
      repliedMessage: repliedMessage,
      photo: data['photoUrl'] == null ? null : Photo.url(data['photoUrl']),
      text: data['text'],
      sentTimestamp: data['sentTimestamp'].toDate(),
      fromMe: data['senderId'] == _auth.currentUser.id,
    );
  }

  Future<RepliedMessage> _getRepliedMessage(
    String chatId,
    String messageId,
  ) async {
    final doc =
        await _chatsRef.doc(chatId).collection('messages').doc(messageId).get();
    final data = doc.data()!;
    return RepliedMessage.fromDoc(
      doc,
      await _userDb.getUser(data['senderId']),
    );
  }

  Future<Message> getMessage(UserChat userChat, String messageId) async {
    final messageDoc = await _chatsRef
        .doc(userChat.id)
        .collection('messages')
        .doc(messageId)
        .get();
    return _messageFromDoc(messageDoc);
  }

  Future<Message> sendMessage(UnsentMessage message) async {
    await _chatsRef.doc(message.chatId).update({
      'lastMessageText': _auth.currentUser.username + ': ' + message.text!,
    });
    final sentTimestamp = DateTime.now();
    final messageDoc =
        await _chatsRef.doc(message.chatId).collection('messages').add({
      'senderId': _auth.currentUser.id,
      'repliedMessageId': message.repliedMessage?.id,
      'photoUrl': message.photo?.url,
      'text': message.text,
      'sentTimestamp': Timestamp.fromDate(sentTimestamp),
    });
    return Message(
      id: messageDoc.id,
      chatId: message.chatId,
      sender: _auth.currentUser,
      repliedMessage: message.repliedMessage,
      photo: message.photo,
      text: message.text,
      sentTimestamp: sentTimestamp,
      fromMe: true,
    );
  }

  // refactor into separate service

  Stream<String?> typingTextStream(String chatId) {
    return _chatsRef.doc(chatId).snapshots().asyncMap((doc) async {
      final userIds = List<String>.from(doc.data()!['typing']);
      userIds.remove(_auth.currentUser.id);
      if (userIds.isEmpty) return null;
      if (userIds.length > 5) return 'Many people are typing...';
      // find usernames
      final usernames =
          await Future.wait<String>(userIds.map<Future<String>>((userId) async {
        return (await _userDb.getUser(userId)).username;
      }));
      if (usernames.length == 1) return usernames.single + ' is typing...';
      return usernames.sublist(0, usernames.length - 1).join(', ') +
          ' and ' +
          usernames.last +
          ' are typing...';
    });
  }

  Future<void> startTyping(String chatId) async {
    await _chatsRef.doc(chatId).update({
      'typing': FieldValue.arrayUnion([_userId]),
    });
  }

  Future<void> stopTyping(String chatId) async {
    await _chatsRef.doc(chatId).update({
      'typing': FieldValue.arrayRemove([_userId]),
    });
  }

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
      data: await getChatData(doc.id) as PrivateChatData,
    );
  }

  Future<String> createChatWith(DiscourseUser otherUser) async {
    // for the purposes of this exercise there are no security rules so the chat
    // is created from the client
    // dont need to send a message to create chat.
    // but chats without messages aren't displayed
    final chatDoc = await _chatsRef.add({
      'lastMessageText': null,
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

  Future<UserGroupChat> newGroup(GroupChatData data) async {
    final chatDoc = await _chatsRef.add(data.toData());
    for (final member in data.members) {
      await _usersRef
          .doc(member.user.id)
          .collection('chats')
          .doc(chatDoc.id)
          .set({'type': 1, 'lastReadId': null});
    }
    return UserGroupChat(id: chatDoc.id, data: data);
  }

  Future<void> deleteMessages(List<Message> messages) async {
    for (final message in messages) {
      assert(message.fromMe, "cannot delete someone else's message");
      await _chatsRef
          .doc(message.chatId)
          .collection('messages')
          .doc(message.id)
          .delete();
    }
  }

  Future<void> leaveChat(String chatId) async {
    await removeMember(chatId, _auth.currentUser.id);
    await _usersRef
        .doc(_auth.currentUser.id)
        .collection('chats')
        .doc(chatId)
        .delete();
  }

  // manage group chat details

  Future<void> updateChatData(String chatId, GroupChatData newData) async {
    await _chatsRef.doc(chatId).update(newData.toData());
  }

  Future<void> addMembers(
    String chatId,
    List<Member> members,
  ) async {
    // await _chatsRef.doc(chatId).collection('members').doc()
    //   'members': FieldValue.arrayUnion(
    //     members.map((p) => p.toData()).toList(),
    //   ),
    // });
  }

  Future<void> removeMember(String chatId, String userId) async {
    await _chatsRef.doc(chatId).update({
      'members.$userId': FieldValue.delete(),
    });
  }

  @override
  Future<void> updateMemberRole(
    String chatId,
    String userId,
    MemberRole newRole,
  ) async {
    await _groupChatsRef
        .doc(chatId)
        .collection('members')
        .doc(userId)
        .update({'role': newRole.index});
  }
}
